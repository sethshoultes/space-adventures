"""
Game Function Registry

Defines functions that AI agents (primarily ATLAS) can call to interact
with game state and perform actions.

Functions follow OpenAI function calling format for compatibility with
LiteLLM across all providers.
"""

from typing import Dict, Any, Callable, Optional
import logging

logger = logging.getLogger(__name__)


# =============================================================================
# FUNCTION DEFINITIONS (OpenAI format)
# =============================================================================

FUNCTION_DEFINITIONS = [
    {
        "name": "get_ship_status",
        "description": "Get current ship status including all systems, hull HP, power levels, and operational state",
        "parameters": {
            "type": "object",
            "properties": {},
            "required": []
        }
    },
    {
        "name": "get_power_budget",
        "description": "Get detailed power budget showing available power, total capacity, and power consumption by system",
        "parameters": {
            "type": "object",
            "properties": {},
            "required": []
        }
    },
    {
        "name": "get_system_details",
        "description": "Get detailed information about a specific ship system",
        "parameters": {
            "type": "object",
            "properties": {
                "system_name": {
                    "type": "string",
                    "description": "Name of the system (hull, power, propulsion, warp, life_support, computer, sensors, shields, weapons, communications)",
                    "enum": ["hull", "power", "propulsion", "warp", "life_support", "computer", "sensors", "shields", "weapons", "communications"]
                }
            },
            "required": ["system_name"]
        }
    },
    {
        "name": "upgrade_system",
        "description": "Upgrade a ship system to the next level (requires sufficient credits and parts)",
        "parameters": {
            "type": "object",
            "properties": {
                "system_name": {
                    "type": "string",
                    "description": "Name of the system to upgrade",
                    "enum": ["hull", "power", "propulsion", "warp", "life_support", "computer", "sensors", "shields", "weapons", "communications"]
                }
            },
            "required": ["system_name"]
        }
    },
    {
        "name": "get_inventory",
        "description": "Get current inventory of parts, materials, and items",
        "parameters": {
            "type": "object",
            "properties": {
                "filter_type": {
                    "type": "string",
                    "description": "Optional filter by item type (parts, materials, consumables, quest_items)",
                    "enum": ["parts", "materials", "consumables", "quest_items", "all"]
                }
            },
            "required": []
        }
    },
    {
        "name": "get_available_missions",
        "description": "Get list of currently available missions",
        "parameters": {
            "type": "object",
            "properties": {
                "difficulty": {
                    "type": "string",
                    "description": "Optional filter by difficulty level",
                    "enum": ["easy", "medium", "hard", "extreme", "all"]
                }
            },
            "required": []
        }
    },
    {
        "name": "calculate_upgrade_cost",
        "description": "Calculate the cost to upgrade a system to the next level",
        "parameters": {
            "type": "object",
            "properties": {
                "system_name": {
                    "type": "string",
                    "description": "Name of the system to calculate upgrade cost for",
                    "enum": ["hull", "power", "propulsion", "warp", "life_support", "computer", "sensors", "shields", "weapons", "communications"]
                }
            },
            "required": ["system_name"]
        }
    },
    {
        "name": "get_player_status",
        "description": "Get current player status including level, XP, skills, and credits",
        "parameters": {
            "type": "object",
            "properties": {},
            "required": []
        }
    },
    {
        "name": "recommend_upgrades",
        "description": "Get AI recommendations for which systems to upgrade based on current state and available resources",
        "parameters": {
            "type": "object",
            "properties": {
                "priority": {
                    "type": "string",
                    "description": "Priority focus for recommendations",
                    "enum": ["combat", "exploration", "efficiency", "balanced"]
                }
            },
            "required": []
        }
    }
]


# =============================================================================
# FUNCTION IMPLEMENTATIONS
# =============================================================================

async def get_ship_status(game_state: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """
    Get current ship status

    Args:
        game_state: Current game state dictionary (optional, uses mock if not provided)

    Returns:
        Ship status dictionary
    """
    if game_state is None:
        # Mock data for testing
        return {
            "success": True,
            "data": {
                "ship_name": "USS Prototype",
                "ship_class": "None",
                "systems": {
                    "hull": {"level": 2, "health": 85, "active": True},
                    "power": {"level": 2, "health": 100, "active": True},
                    "shields": {"level": 1, "health": 100, "active": False},
                    "weapons": {"level": 1, "health": 100, "active": False}
                },
                "hull_hp": 170,
                "max_hull_hp": 200,
                "power_available": 25,
                "power_total": 50
            }
        }

    # Extract ship data from game state
    ship = game_state.get("ship", {})
    return {
        "success": True,
        "data": ship
    }


async def get_power_budget(game_state: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """
    Get power budget details

    Args:
        game_state: Current game state dictionary

    Returns:
        Power budget information
    """
    if game_state is None:
        # Mock data
        return {
            "success": True,
            "data": {
                "available": 25,
                "total": 50,
                "percentage": 50.0,
                "consumption_by_system": {
                    "hull": 5,
                    "power": 0,  # Power core generates, doesn't consume
                    "shields": 10,
                    "weapons": 10
                }
            }
        }

    ship = game_state.get("ship", {})
    return {
        "success": True,
        "data": {
            "available": ship.get("power_available", 0),
            "total": ship.get("power_total", 0),
            "percentage": (ship.get("power_available", 0) / max(ship.get("power_total", 1), 1)) * 100
        }
    }


async def get_system_details(system_name: str, game_state: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """
    Get detailed information about a specific system

    Args:
        system_name: Name of the system
        game_state: Current game state

    Returns:
        System details
    """
    if game_state is None:
        # Mock data
        mock_systems = {
            "hull": {"level": 2, "health": 85, "active": True, "max_level": 5},
            "power": {"level": 2, "health": 100, "active": True, "max_level": 5}
        }
        system = mock_systems.get(system_name)
        if not system:
            return {"success": False, "error": f"Unknown system: {system_name}"}

        return {"success": True, "data": system}

    ship = game_state.get("ship", {})
    systems = ship.get("systems", {})
    system = systems.get(system_name)

    if not system:
        return {"success": False, "error": f"System not found: {system_name}"}

    return {"success": True, "data": system}


async def upgrade_system(system_name: str, game_state: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """
    Upgrade a ship system (would interact with real game state in production)

    Args:
        system_name: Name of system to upgrade
        game_state: Current game state

    Returns:
        Upgrade result
    """
    # In production, this would:
    # 1. Check if player has required credits/parts
    # 2. Verify system can be upgraded (not max level)
    # 3. Deduct costs
    # 4. Increase system level
    # 5. Update game state
    # 6. Return result

    logger.info(f"Upgrade system requested: {system_name}")

    # For now, return mock success
    return {
        "success": True,
        "data": {
            "system": system_name,
            "old_level": 1,
            "new_level": 2,
            "credits_spent": 500,
            "message": f"Successfully upgraded {system_name} to level 2"
        }
    }


async def get_inventory(filter_type: str = "all", game_state: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """
    Get inventory contents

    Args:
        filter_type: Type filter
        game_state: Current game state

    Returns:
        Inventory data
    """
    if game_state is None:
        # Mock inventory
        return {
            "success": True,
            "data": {
                "parts": [
                    {"id": "part_001", "name": "Hull Plating", "quantity": 5},
                    {"id": "part_002", "name": "Power Conduit", "quantity": 3}
                ],
                "materials": [
                    {"id": "mat_001", "name": "Duranium", "quantity": 150},
                    {"id": "mat_002", "name": "Tritanium", "quantity": 75}
                ]
            }
        }

    inventory = game_state.get("inventory", [])
    return {"success": True, "data": inventory}


async def get_available_missions(difficulty: str = "all", game_state: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """
    Get available missions

    Args:
        difficulty: Difficulty filter
        game_state: Current game state

    Returns:
        Available missions
    """
    # Mock missions
    return {
        "success": True,
        "data": {
            "missions": [
                {
                    "id": "mission_001",
                    "title": "Salvage Operation",
                    "difficulty": "easy",
                    "rewards": {"credits": 250, "xp": 100}
                }
            ]
        }
    }


async def calculate_upgrade_cost(system_name: str, game_state: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """
    Calculate upgrade cost for a system

    Args:
        system_name: System to calculate for
        game_state: Current game state

    Returns:
        Cost calculation
    """
    # Mock cost calculation
    base_costs = {
        "hull": 500,
        "power": 600,
        "propulsion": 700,
        "shields": 800,
        "weapons": 900
    }

    cost = base_costs.get(system_name, 500)

    return {
        "success": True,
        "data": {
            "system": system_name,
            "current_level": 1,
            "target_level": 2,
            "credits_required": cost,
            "parts_required": [
                {"name": f"{system_name.title()} Component", "quantity": 1}
            ]
        }
    }


async def get_player_status(game_state: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """
    Get player status

    Args:
        game_state: Current game state

    Returns:
        Player status
    """
    if game_state is None:
        return {
            "success": True,
            "data": {
                "name": "Captain",
                "level": 3,
                "xp": 750,
                "next_level_xp": 1000,
                "credits": 1500,
                "skills": {
                    "engineering": 2,
                    "diplomacy": 1,
                    "combat": 2,
                    "science": 1
                }
            }
        }

    player = game_state.get("player", {})
    return {"success": True, "data": player}


async def recommend_upgrades(priority: str = "balanced", game_state: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """
    Get upgrade recommendations

    Args:
        priority: Priority focus
        game_state: Current game state

    Returns:
        Recommendations
    """
    # This would use actual game state to make intelligent recommendations
    return {
        "success": True,
        "data": {
            "priority": priority,
            "recommendations": [
                {
                    "system": "power",
                    "reason": "Increased power generation enables activating more systems",
                    "priority": "high"
                },
                {
                    "system": "hull",
                    "reason": "Current hull integrity at 85%, repair or upgrade recommended",
                    "priority": "medium"
                }
            ]
        }
    }


# =============================================================================
# FUNCTION REGISTRY
# =============================================================================

FUNCTION_REGISTRY: Dict[str, Callable] = {
    "get_ship_status": get_ship_status,
    "get_power_budget": get_power_budget,
    "get_system_details": get_system_details,
    "upgrade_system": upgrade_system,
    "get_inventory": get_inventory,
    "get_available_missions": get_available_missions,
    "calculate_upgrade_cost": calculate_upgrade_cost,
    "get_player_status": get_player_status,
    "recommend_upgrades": recommend_upgrades,
}


async def execute_function(
    function_name: str,
    arguments: Dict[str, Any],
    game_state: Optional[Dict[str, Any]] = None
) -> Dict[str, Any]:
    """
    Execute a registered function

    Args:
        function_name: Name of function to execute
        arguments: Function arguments
        game_state: Current game state (passed to all functions)

    Returns:
        Function execution result
    """
    if function_name not in FUNCTION_REGISTRY:
        return {
            "success": False,
            "error": f"Unknown function: {function_name}"
        }

    try:
        func = FUNCTION_REGISTRY[function_name]

        # Add game_state to arguments if function accepts it
        if "game_state" in func.__code__.co_varnames:
            arguments["game_state"] = game_state

        result = await func(**arguments)
        return result

    except Exception as e:
        logger.error(f"Error executing function {function_name}: {e}")
        return {
            "success": False,
            "error": f"Function execution failed: {str(e)}"
        }


def get_functions_for_agent(agent_name: str) -> Optional[list]:
    """
    Get function definitions for a specific agent

    Args:
        agent_name: Name of the agent

    Returns:
        List of function definitions or None
    """
    # Only ATLAS gets function calling capability
    if agent_name.lower() == "atlas":
        return FUNCTION_DEFINITIONS
    return None
