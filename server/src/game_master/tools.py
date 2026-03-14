"""Game Master Tools — Functions the AI agent can call.

These tools let the Game Master manipulate game state, check player inventory,
resolve skill checks, manage missions, and interact with the memory system.

Each function operates on a GameSession and returns a result dict that gets
serialized back to the agent as tool output.
"""

from __future__ import annotations

import json
from typing import Any

from ..memory.manager import MemoryManager
from ..state.models import (
    GameSession,
    InventoryItem,
    Mission,
    MissionStage,
    get_part_as_item,
    load_all_missions,
    load_all_parts,
    load_ship_systems,
    roll_skill_check,
)

# ---------------------------------------------------------------------------
# Tool definitions for Anthropic tool_use
# Each tool is: (name, description, input_schema, handler_fn)
# ---------------------------------------------------------------------------


def read_game_state(session: GameSession, **kwargs) -> dict:
    """Return a formatted summary of current player and ship state."""
    p = session.player
    s = session.ship

    systems_summary = []
    for name, sys in s.systems.items():
        systems_summary.append(sys.summary())

    return {
        "player": {
            "name": p.name,
            "level": p.level,
            "xp": p.xp,
            "xp_to_next": p.xp_to_next,
            "credits": p.credits,
            "skill_points": p.skill_points,
            "skills": p.skills.model_dump(),
        },
        "ship": {
            "name": s.name,
            "classification": s.classification,
            "hull_hp": s.hull_hp,
            "max_hull_hp": s.max_hull_hp,
            "power_available": s.power_available,
            "power_total": s.power_total,
            "systems": systems_summary,
        },
        "world": {
            "phase": session.world.phase,
            "active_mission": session.world.active_mission_id,
            "active_stage": session.world.active_stage_id,
            "completed_missions": session.world.completed_missions,
            "active_effects": session.world.active_effects,
        },
        "turn": session.turn_count,
    }


def check_inventory(session: GameSession, **kwargs) -> dict:
    """Return formatted inventory list with weights and totals."""
    items = []
    for item in session.ship.inventory:
        items.append({
            "id": item.item_id,
            "name": item.name,
            "quantity": item.quantity,
            "rarity": item.rarity,
            "weight": item.weight,
            "system_type": item.system_type,
        })
    return {
        "items": items,
        "total_items": len(items),
        "total_weight": session.ship.inventory_weight(),
    }


def update_game_state(session: GameSession, *, field: str, value: Any) -> dict:
    """Update a specific game state field. Supports dotted paths like 'player.credits'."""
    parts = field.split(".")
    obj: Any = session
    for part in parts[:-1]:
        if isinstance(obj, dict):
            obj = obj[part]
        else:
            obj = getattr(obj, part)
    final_key = parts[-1]
    if isinstance(obj, dict):
        old_value = obj.get(final_key)
        obj[final_key] = value
    else:
        old_value = getattr(obj, final_key, None)
        setattr(obj, final_key, value)
    return {"field": field, "old_value": old_value, "new_value": value}


def upgrade_system(session: GameSession, *, system_name: str) -> dict:
    """Upgrade a ship system by one level. Validates resources and applies costs."""
    sys = session.ship.systems.get(system_name)
    if not sys:
        return {"success": False, "error": f"Unknown system: {system_name}"}

    systems_data = load_ship_systems()
    sys_data = None
    for sd in systems_data:
        if sd["system_name"] == system_name:
            sys_data = sd
            break
    if not sys_data:
        return {"success": False, "error": f"No data for system: {system_name}"}

    target_level = sys.level + 1
    if target_level > sys_data.get("milestone_1_max_level", 3):
        return {"success": False, "error": f"{sys.display_name} is at max level for this phase"}

    upgrade_costs = sys_data.get("upgrade_costs", {})
    cost_data = upgrade_costs.get(str(target_level))
    if not cost_data:
        return {"success": False, "error": f"No upgrade path to level {target_level}"}

    credits_needed = cost_data.get("credits", 0)
    part_needed = cost_data.get("part_id")

    # Validate resources
    if session.player.credits < credits_needed:
        return {
            "success": False,
            "error": f"Not enough credits. Need {credits_needed}, have {session.player.credits}",
        }
    if part_needed:
        item = session.ship.find_item(part_needed)
        if not item:
            parts_db = load_all_parts()
            part_info = parts_db.get(part_needed, {})
            part_name = part_info.get("name", part_needed)
            return {
                "success": False,
                "error": f"Missing required part: {part_name} ({part_needed})",
            }

    # Apply costs
    session.player.credits -= credits_needed
    if part_needed:
        session.ship.remove_item(part_needed)

    # Apply upgrade
    sys.level = target_level
    sys.active = True
    sys.installed_part = part_needed
    session.ship.recalculate_power()

    return {
        "success": True,
        "system": system_name,
        "new_level": target_level,
        "credits_spent": credits_needed,
        "part_used": part_needed,
        "power_available": session.ship.power_available,
        "power_total": session.ship.power_total,
    }


def start_mission(session: GameSession, *, mission_id: str) -> dict:
    """Load a mission and set it as active. Returns the first stage."""
    if session.world.active_mission_id:
        return {
            "success": False,
            "error": f"Already in mission: {session.world.active_mission_id}",
        }

    missions = load_all_missions()
    mission = missions.get(mission_id)
    if not mission:
        return {"success": False, "error": f"Unknown mission: {mission_id}"}

    # Check requirements
    reqs = mission.requirements
    if reqs.get("min_level", 0) > session.player.level:
        return {"success": False, "error": f"Need level {reqs['min_level']}"}
    for req_mission in reqs.get("completed_missions", []):
        if req_mission not in session.world.completed_missions:
            return {"success": False, "error": f"Must complete {req_mission} first"}

    # Activate
    session.world.active_mission_id = mission_id
    first_stage = mission.stages[0] if mission.stages else None
    session.world.active_stage_id = first_stage.stage_id if first_stage else None

    result: dict[str, Any] = {
        "success": True,
        "mission_id": mission_id,
        "title": mission.title,
        "location": mission.location,
        "description": mission.description,
        "objectives": mission.objectives,
    }
    if first_stage:
        result["stage"] = {
            "stage_id": first_stage.stage_id,
            "title": first_stage.title,
            "description": first_stage.description,
            "choices": [
                {"id": c.choice_id, "text": c.text, "requirements": c.requirements}
                for c in first_stage.choices
            ],
        }
    return result


def resolve_choice(session: GameSession, *, choice_id: str) -> dict:
    """Process a player's choice in the current mission stage."""
    mission_id = session.world.active_mission_id
    stage_id = session.world.active_stage_id
    if not mission_id or not stage_id:
        return {"success": False, "error": "No active mission or stage"}

    missions = load_all_missions()
    mission = missions.get(mission_id)
    if not mission:
        return {"success": False, "error": f"Mission not found: {mission_id}"}

    choice = mission.get_choice(stage_id, choice_id)
    if not choice:
        return {"success": False, "error": f"Choice not found: {choice_id} in stage {stage_id}"}

    # Check requirements
    reqs = choice.requirements
    if reqs:
        skill_name = reqs.get("skill")
        skill_level_needed = reqs.get("skill_level", 0)
        if skill_name:
            player_skill = getattr(session.player.skills, skill_name, 0)
            if choice.success_chance == "skill_based":
                # Do a skill check
                check = roll_skill_check(player_skill, skill_level_needed)
                if check["success"]:
                    outcome = choice.consequences.get("success", {})
                else:
                    outcome = choice.consequences.get("failure", {})
                    if not outcome:
                        outcome = choice.consequences.get("success", {})
                result = _apply_outcome(session, mission, outcome, check)
                result["skill_check"] = check
                return result

    # Guaranteed success path
    outcome = choice.consequences.get("success", {})
    return _apply_outcome(session, mission, outcome)


def _apply_outcome(
    session: GameSession,
    mission: Mission,
    outcome: dict,
    skill_check: dict | None = None,
) -> dict:
    """Apply a choice outcome: advance stage, award XP, apply effects."""
    result: dict[str, Any] = {"success": True}

    # Narrative text
    result["text"] = outcome.get("text", "")

    # XP bonus
    xp_bonus = outcome.get("xp_bonus", 0)
    if xp_bonus:
        xp_result = session.player.award_xp(xp_bonus)
        result["xp_awarded"] = xp_bonus
        result["level_up"] = xp_result

    # Effects
    effects = outcome.get("effects", [])
    for effect in effects:
        if effect not in session.world.active_effects:
            session.world.active_effects.append(effect)
    result["effects"] = effects

    # Mission result (success/failure)
    mission_result = outcome.get("mission_result")
    if mission_result == "success":
        return _complete_mission(session, mission, result)
    elif mission_result == "failure":
        return _fail_mission(session, mission, result)

    # Advance to next stage
    next_stage_id = outcome.get("next_stage")
    if next_stage_id:
        session.world.active_stage_id = next_stage_id
        next_stage = mission.get_stage(next_stage_id)
        if next_stage:
            # Check if terminal stage (no choices)
            if not next_stage.choices:
                if "complete" in next_stage_id or "success" in next_stage_id:
                    return _complete_mission(session, mission, result)
                elif "fail" in next_stage_id:
                    return _fail_mission(session, mission, result)
            result["next_stage"] = {
                "stage_id": next_stage.stage_id,
                "title": next_stage.title,
                "description": next_stage.description,
                "choices": [
                    {"id": c.choice_id, "text": c.text, "requirements": c.requirements}
                    for c in next_stage.choices
                ],
            }

    return result


def _complete_mission(session: GameSession, mission: Mission, result: dict) -> dict:
    """Handle mission completion: award rewards, clean up."""
    rewards = mission.rewards
    result["mission_complete"] = True
    result["mission_id"] = mission.mission_id

    # Award XP
    mission_xp = rewards.get("xp", 0)
    if mission_xp:
        xp_result = session.player.award_xp(mission_xp)
        result["mission_xp"] = mission_xp
        result["level_up"] = xp_result

    # Award credits
    credits_reward = rewards.get("credits", 0)
    if credits_reward:
        session.player.credits += credits_reward
        result["credits_awarded"] = credits_reward

    # Award items
    for item_data in rewards.get("items", []):
        part_id = item_data.get("part_id", "")
        qty = item_data.get("quantity", 1)
        item = get_part_as_item(part_id)
        if item:
            item.quantity = qty
            session.ship.add_item(item)
    result["items_awarded"] = [i.get("part_id", "") for i in rewards.get("items", [])]

    # Discovered parts
    for part_id in rewards.get("discovered_parts", []):
        if part_id not in session.world.discovered_parts:
            session.world.discovered_parts.append(part_id)

    # Mark complete
    session.world.completed_missions.append(mission.mission_id)
    session.world.active_mission_id = None
    session.world.active_stage_id = None
    session.world.active_effects = []

    return result


def _fail_mission(session: GameSession, mission: Mission, result: dict) -> dict:
    """Handle mission failure."""
    result["mission_failed"] = True
    result["mission_id"] = mission.mission_id

    fail_data = mission.failure_consequences
    fail_xp = fail_data.get("xp", 0)
    if fail_xp:
        session.player.award_xp(fail_xp)
        result["consolation_xp"] = fail_xp

    session.world.active_mission_id = None
    session.world.active_stage_id = None
    session.world.active_effects = []
    return result


def do_skill_check(session: GameSession, *, skill: str, difficulty: int) -> dict:
    """Roll a skill check against a difficulty level."""
    skill_value = getattr(session.player.skills, skill, 0)
    return roll_skill_check(skill_value, difficulty)


def search_memory_tool(session: GameSession, *, query: str, memory: MemoryManager) -> dict:
    """Search player memory files for a keyword."""
    results = memory.search_memory(query)
    return {"query": query, "matches": results[:20]}


def write_memory_tool(
    session: GameSession,
    *,
    memory_type: str,
    content: str,
    memory: MemoryManager,
    section: str = "",
    npc: str = "",
    context: str = "",
    consequence: str = "",
) -> dict:
    """Write to appropriate memory file.

    memory_type: 'daily_log' | 'player_profile' | 'relationship' | 'decision' | 'world_state'
    """
    if memory_type == "daily_log":
        path = memory.write_daily_log(content, session.session_id)
        return {"written": True, "type": "daily_log", "path": path}
    elif memory_type == "player_profile":
        msg = memory.write_player_profile(section or "Notes", content)
        return {"written": True, "type": "player_profile", "message": msg}
    elif memory_type == "relationship":
        msg = memory.write_relationship(npc or "Unknown", content)
        return {"written": True, "type": "relationship", "message": msg}
    elif memory_type == "decision":
        msg = memory.write_decision(content, context, consequence)
        return {"written": True, "type": "decision", "message": msg}
    elif memory_type == "world_state":
        msg = memory.write_world_state(section or "Notes", content)
        return {"written": True, "type": "world_state", "message": msg}
    else:
        return {"written": False, "error": f"Unknown memory type: {memory_type}"}


def query_world_state(session: GameSession, **kwargs) -> dict:
    """Return current world state: factions, economy, events, phase."""
    w = session.world
    return {
        "phase": w.phase,
        "phase_name": "Earthbound" if w.phase == 1 else "Space",
        "completed_missions": w.completed_missions,
        "discovered_locations": w.discovered_locations,
        "discovered_parts": w.discovered_parts,
        "factions": w.factions,
        "active_events": w.active_events,
        "major_choices": w.major_choices,
        "all_systems_level_1": all(
            sys.level >= 1 for sys in session.ship.systems.values()
        ),
    }


def list_available_missions(session: GameSession, **kwargs) -> dict:
    """List missions the player can currently start."""
    all_missions = load_all_missions()
    available = []
    for mid, mission in all_missions.items():
        if mid in session.world.completed_missions:
            continue
        reqs = mission.requirements
        if reqs.get("min_level", 0) > session.player.level:
            continue
        required_missions = reqs.get("completed_missions", [])
        if any(rm not in session.world.completed_missions for rm in required_missions):
            continue
        available.append({
            "mission_id": mid,
            "title": mission.title,
            "type": mission.type,
            "difficulty": mission.difficulty,
            "location": mission.location,
            "description": mission.description[:100] + "..." if len(mission.description) > 100 else mission.description,
        })
    return {"available_missions": available, "count": len(available)}


def give_item(session: GameSession, *, item_id: str, quantity: int = 1) -> dict:
    """Give a part/item to the player."""
    item = get_part_as_item(item_id)
    if not item:
        return {"success": False, "error": f"Unknown item: {item_id}"}
    item.quantity = quantity
    session.ship.add_item(item)
    return {"success": True, "item": item.name, "quantity": quantity}


def award_xp(session: GameSession, *, amount: int) -> dict:
    """Award XP to the player."""
    result = session.player.award_xp(amount)
    return {"xp_awarded": amount, **result}


def award_credits(session: GameSession, *, amount: int) -> dict:
    """Award credits to the player."""
    session.player.credits += amount
    return {"credits_awarded": amount, "new_total": session.player.credits}


# ---------------------------------------------------------------------------
# Tool registry: maps tool names to (schema, handler)
# ---------------------------------------------------------------------------

TOOL_DEFINITIONS: list[dict] = [
    {
        "name": "read_game_state",
        "description": "Get a full summary of the player's current state: stats, skills, ship systems, power, active mission, and world state. Call this before making any claims about the player's capabilities.",
        "input_schema": {
            "type": "object",
            "properties": {},
            "required": [],
        },
    },
    {
        "name": "check_inventory",
        "description": "List all items in the player's ship inventory with quantities, rarities, and weights.",
        "input_schema": {
            "type": "object",
            "properties": {},
            "required": [],
        },
    },
    {
        "name": "update_game_state",
        "description": "Update a specific game state field using a dotted path (e.g., 'player.credits', 'ship.name', 'player.skills.engineering'). Use for ad-hoc state changes.",
        "input_schema": {
            "type": "object",
            "properties": {
                "field": {"type": "string", "description": "Dotted path to the field (e.g., 'player.credits')"},
                "value": {"description": "New value for the field"},
            },
            "required": ["field", "value"],
        },
    },
    {
        "name": "upgrade_system",
        "description": "Upgrade a ship system by one level. Validates the player has enough credits and required parts. Systems: hull, power, propulsion, warp, life_support, computer, sensors, shields, weapons, communications.",
        "input_schema": {
            "type": "object",
            "properties": {
                "system_name": {"type": "string", "description": "Name of the ship system to upgrade"},
            },
            "required": ["system_name"],
        },
    },
    {
        "name": "start_mission",
        "description": "Start a mission by ID. Validates requirements and returns the first stage with available choices. Use list_available_missions first to see what's available.",
        "input_schema": {
            "type": "object",
            "properties": {
                "mission_id": {"type": "string", "description": "The mission ID to start"},
            },
            "required": ["mission_id"],
        },
    },
    {
        "name": "resolve_choice",
        "description": "Process the player's choice in the current mission stage. Handles skill checks, applies consequences, advances to next stage or completes the mission.",
        "input_schema": {
            "type": "object",
            "properties": {
                "choice_id": {"type": "string", "description": "The choice ID the player selected"},
            },
            "required": ["choice_id"],
        },
    },
    {
        "name": "roll_skill_check",
        "description": "Roll a skill check: d20 + skill_value vs 10 + (difficulty * 2). Skills: engineering, diplomacy, combat, science. Difficulty 1-5.",
        "input_schema": {
            "type": "object",
            "properties": {
                "skill": {"type": "string", "enum": ["engineering", "diplomacy", "combat", "science"]},
                "difficulty": {"type": "integer", "minimum": 1, "maximum": 5},
            },
            "required": ["skill", "difficulty"],
        },
    },
    {
        "name": "search_memory",
        "description": "Search the player's memory files (profile, relationships, decisions, world state, daily logs) for a keyword. Returns matching lines with file and line number.",
        "input_schema": {
            "type": "object",
            "properties": {
                "query": {"type": "string", "description": "Keyword to search for"},
            },
            "required": ["query"],
        },
    },
    {
        "name": "write_memory",
        "description": "Write to the player's memory system. Types: 'daily_log' (session events), 'player_profile' (stats/style), 'relationship' (NPC updates), 'decision' (major choices), 'world_state' (world changes).",
        "input_schema": {
            "type": "object",
            "properties": {
                "memory_type": {
                    "type": "string",
                    "enum": ["daily_log", "player_profile", "relationship", "decision", "world_state"],
                },
                "content": {"type": "string", "description": "The content to write"},
                "section": {"type": "string", "description": "Section name (for player_profile and world_state)"},
                "npc": {"type": "string", "description": "NPC name (for relationship type)"},
                "context": {"type": "string", "description": "Context (for decision type)"},
                "consequence": {"type": "string", "description": "Consequence (for decision type)"},
            },
            "required": ["memory_type", "content"],
        },
    },
    {
        "name": "query_world_state",
        "description": "Get detailed world state: phase, completed missions, discovered parts/locations, faction standings, active events, and whether all systems are level 1+ (space-ready).",
        "input_schema": {
            "type": "object",
            "properties": {},
            "required": [],
        },
    },
    {
        "name": "list_available_missions",
        "description": "List all missions the player can currently start, based on level and completed prerequisites.",
        "input_schema": {
            "type": "object",
            "properties": {},
            "required": [],
        },
    },
    {
        "name": "give_item",
        "description": "Give the player a part or item by ID. Use for quest rewards or narrative events.",
        "input_schema": {
            "type": "object",
            "properties": {
                "item_id": {"type": "string", "description": "The part/item ID to give"},
                "quantity": {"type": "integer", "default": 1},
            },
            "required": ["item_id"],
        },
    },
    {
        "name": "award_xp",
        "description": "Award experience points to the player. Handles level-up automatically.",
        "input_schema": {
            "type": "object",
            "properties": {
                "amount": {"type": "integer", "description": "XP to award"},
            },
            "required": ["amount"],
        },
    },
    {
        "name": "award_credits",
        "description": "Award credits to the player.",
        "input_schema": {
            "type": "object",
            "properties": {
                "amount": {"type": "integer", "description": "Credits to award"},
            },
            "required": ["amount"],
        },
    },
]

# Map tool names to handler functions
TOOL_HANDLERS: dict[str, callable] = {
    "read_game_state": read_game_state,
    "check_inventory": check_inventory,
    "update_game_state": update_game_state,
    "upgrade_system": upgrade_system,
    "start_mission": start_mission,
    "resolve_choice": resolve_choice,
    "roll_skill_check": do_skill_check,
    "search_memory": search_memory_tool,
    "write_memory": write_memory_tool,
    "query_world_state": query_world_state,
    "list_available_missions": list_available_missions,
    "give_item": give_item,
    "award_xp": award_xp,
    "award_credits": award_credits,
}
