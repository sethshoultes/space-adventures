"""
Agent Tools

Tools that autonomous agents can use to analyze game state and make decisions.
"""

from typing import Dict, List, Any, Optional


async def get_system_status(game_state: Dict[str, Any]) -> Dict[str, Any]:
    """
    Analyze ship systems and return status report

    Args:
        game_state: Current game state

    Returns:
        Dictionary with:
        - hull: Hull status (hp, max, percentage)
        - power: Power status (current, max, consumption)
        - systems: Individual system statuses
        - issues: List of detected issues
    """
    ship = game_state.get("ship", {})

    # Hull status
    hull_hp = ship.get("hull_hp", 0)
    max_hull_hp = ship.get("max_hull_hp", 100)
    hull_percentage = (hull_hp / max_hull_hp * 100) if max_hull_hp > 0 else 0

    hull_status = "critical" if hull_percentage < 25 else \
                  "damaged" if hull_percentage < 50 else \
                  "degraded" if hull_percentage < 75 else \
                  "nominal"

    # Power status
    power_available = ship.get("power_available", 0)
    power_total = ship.get("power_total", 0)
    power_consumption = power_total - power_available if power_total > 0 else 0

    power_percentage = (power_available / power_total * 100) if power_total > 0 else 0
    power_status = "critical" if power_percentage < 10 else \
                   "low" if power_percentage < 30 else \
                   "nominal"

    # Systems status
    systems = ship.get("systems", {})
    system_statuses = {}
    issues = []

    for sys_name, sys_data in systems.items():
        if not isinstance(sys_data, dict):
            continue

        level = sys_data.get("level", 0)
        health = sys_data.get("health", 100)
        active = sys_data.get("active", False)

        operational = health > 50 and (level > 0 or sys_name == "hull")

        system_statuses[sys_name] = {
            "level": level,
            "health": health,
            "active": active,
            "operational": operational
        }

        # Detect issues
        if health < 50:
            issues.append(f"{sys_name.title()} system health critical ({health}%)")
        elif health < 75:
            issues.append(f"{sys_name.title()} system damaged ({health}%)")

        if level > 0 and not active:
            issues.append(f"{sys_name.title()} system offline")

    # Hull-specific issues
    if hull_percentage < 50:
        issues.append(f"Hull integrity at {hull_percentage:.0f}%")

    # Power-specific issues
    if power_percentage < 30:
        issues.append(f"Power reserves low ({power_percentage:.0f}%)")

    if power_consumption > power_total * 0.9:
        issues.append("Power consumption near maximum capacity")

    return {
        "hull": {
            "hp": hull_hp,
            "max": max_hull_hp,
            "percentage": round(hull_percentage, 1),
            "status": hull_status
        },
        "power": {
            "available": power_available,
            "total": power_total,
            "consumption": power_consumption,
            "percentage": round(power_percentage, 1),
            "status": power_status
        },
        "systems": system_statuses,
        "issues": issues
    }


async def check_mission_progress(game_state: Dict[str, Any]) -> Dict[str, Any]:
    """
    Check current mission status and objectives

    Args:
        game_state: Current game state

    Returns:
        Dictionary with:
        - mission_active: Whether a mission is active
        - mission_title: Mission title
        - current_stage: Current mission stage
        - objectives: List of objectives with completion status
        - time_in_mission: Estimated time spent
        - notable_events: Recent significant events
    """
    mission = game_state.get("mission", {})
    progress = game_state.get("progress", {})

    mission_active = bool(mission)

    if not mission_active:
        return {
            "mission_active": False,
            "mission_title": None,
            "current_stage": None,
            "objectives": [],
            "time_in_mission": "0s",
            "notable_events": []
        }

    # Mission info
    mission_title = mission.get("title", "Unknown Mission")
    current_stage = mission.get("stage", "unknown")

    # Objectives (if available)
    objectives = mission.get("objectives", [])
    objective_list = []

    if isinstance(objectives, list):
        for obj in objectives:
            if isinstance(obj, dict):
                objective_list.append({
                    "text": obj.get("text", ""),
                    "completed": obj.get("completed", False)
                })
            else:
                objective_list.append({
                    "text": str(obj),
                    "completed": False
                })

    # Notable events (from progress)
    notable_events = progress.get("notable_events", [])
    if isinstance(notable_events, list):
        notable_events = notable_events[-5:]  # Last 5 events
    else:
        notable_events = []

    # Time estimation (placeholder - would need actual tracking)
    time_in_mission = mission.get("time_elapsed", "unknown")

    return {
        "mission_active": True,
        "mission_title": mission_title,
        "current_stage": current_stage,
        "objectives": objective_list,
        "time_in_mission": time_in_mission,
        "notable_events": notable_events
    }


async def scan_environment(game_state: Dict[str, Any]) -> Dict[str, Any]:
    """
    Scan surroundings for items, threats, opportunities

    Args:
        game_state: Current game state

    Returns:
        Dictionary with:
        - location: Current location name
        - nearby_objects: List of objects with distance and threat level
        - opportunities: Detected opportunities
        - threats: Detected threats
        - weather: Environmental conditions
    """
    environment = game_state.get("environment", {})
    mission = game_state.get("mission", {})

    # Location
    location = environment.get("location") or mission.get("location", "Unknown Location")

    # Nearby objects
    nearby_objects = environment.get("nearby_objects", [])
    if not isinstance(nearby_objects, list):
        nearby_objects = []

    # Opportunities
    opportunities = environment.get("opportunities", [])
    if not isinstance(opportunities, list):
        opportunities = []

    # Threats
    threats = environment.get("threats", [])
    if not isinstance(threats, list):
        threats = []

    # Add mission-specific threats
    mission_threats = mission.get("threats", [])
    if isinstance(mission_threats, list):
        threats.extend(mission_threats)

    # Environmental conditions
    weather = environment.get("weather", "Normal space conditions")

    # Detect implicit threats from nearby objects
    for obj in nearby_objects:
        if isinstance(obj, dict):
            threat_level = obj.get("threat_level", 0)
            obj_type = obj.get("type", "unknown")

            if threat_level >= 3:
                threats.append(f"High-threat {obj_type} detected nearby")
            elif threat_level >= 2:
                opportunities.append(f"Caution: {obj_type} in area (threat level {threat_level})")

    return {
        "location": location,
        "nearby_objects": nearby_objects,
        "opportunities": opportunities,
        "threats": threats,
        "weather": weather
    }


# Tool schemas for LangGraph
TOOL_SCHEMAS = [
    {
        "name": "get_system_status",
        "description": "Analyze ship systems including hull, power, and all subsystems. Returns status report with detected issues.",
        "parameters": {
            "type": "object",
            "properties": {
                "game_state": {
                    "type": "object",
                    "description": "Current game state"
                }
            },
            "required": ["game_state"]
        }
    },
    {
        "name": "check_mission_progress",
        "description": "Check current mission status, objectives, and recent events.",
        "parameters": {
            "type": "object",
            "properties": {
                "game_state": {
                    "type": "object",
                    "description": "Current game state"
                }
            },
            "required": ["game_state"]
        }
    },
    {
        "name": "scan_environment",
        "description": "Scan surroundings for nearby objects, threats, and opportunities.",
        "parameters": {
            "type": "object",
            "properties": {
                "game_state": {
                    "type": "object",
                    "description": "Current game state"
                }
            },
            "required": ["game_state"]
        }
    }
]


# Tool mapping for execution
TOOL_FUNCTIONS = {
    "get_system_status": get_system_status,
    "check_mission_progress": check_mission_progress,
    "scan_environment": scan_environment
}
