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


async def analyze_narrative_context(game_state: Dict[str, Any]) -> Dict[str, Any]:
    """
    Analyze recent player choices and mission history for story opportunities

    Args:
        game_state: Current game state

    Returns:
        Dictionary with:
        - recent_choices: Recent major choices player made
        - narrative_themes: Detected themes (exploration, survival, morality, etc.)
        - story_opportunities: Potential narrative moments
        - emotional_tone: Current emotional tone
        - character_arc_hints: Suggestions for character development
    """
    progress = game_state.get("progress", {})
    player = game_state.get("player", {})
    mission = game_state.get("mission", {})

    # Recent choices
    major_choices = progress.get("major_choices", [])
    if isinstance(major_choices, list):
        recent_choices = major_choices[-5:]  # Last 5 choices
    else:
        recent_choices = []

    # Completed missions - analyze patterns
    completed_missions = progress.get("completed_missions", [])
    total_missions = len(completed_missions) if isinstance(completed_missions, list) else 0

    # Detect narrative themes based on completed missions and choices
    narrative_themes = []

    # Check for exploration theme
    discovered_locations = progress.get("discovered_locations", [])
    if len(discovered_locations) > 5:
        narrative_themes.append("exploration")

    # Check for survival theme (based on ship state)
    ship = game_state.get("ship", {})
    hull_pct = (ship.get("hull_hp", 0) / ship.get("max_hull_hp", 100) * 100) if ship.get("max_hull_hp", 0) > 0 else 0
    if hull_pct < 75:
        narrative_themes.append("survival")

    # Check for morality theme (if major_choices contain moral decisions)
    if any("spare" in str(choice).lower() or "help" in str(choice).lower() or "mercy" in str(choice).lower() for choice in recent_choices):
        narrative_themes.append("morality")

    # Determine emotional tone
    emotional_tone = "hopeful"  # Default
    if hull_pct < 50:
        emotional_tone = "desperate"
    elif total_missions > 10:
        emotional_tone = "experienced"
    elif mission and mission.get("type") == "story":
        emotional_tone = "contemplative"

    # Story opportunities based on context
    story_opportunities = []

    # Mission completion milestone
    if total_missions > 0 and total_missions % 5 == 0:
        story_opportunities.append(f"Milestone: {total_missions} missions completed - reflect on journey")

    # First major system upgrade
    systems = ship.get("systems", {})
    high_level_systems = [name for name, sys in systems.items() if isinstance(sys, dict) and sys.get("level", 0) >= 3]
    if high_level_systems and len(high_level_systems) == 1:
        story_opportunities.append(f"First major upgrade: {high_level_systems[0]} - character growth moment")

    # Low resources
    if hull_pct < 50:
        story_opportunities.append("Survival moment - reflect on determination and resilience")

    # New location discovery
    if discovered_locations and len(discovered_locations) % 3 == 0:
        story_opportunities.append("Explorer's moment - wonder at the universe")

    # Character arc hints based on player progression
    character_arc_hints = []
    player_level = player.get("level", 1)

    if player_level >= 3 and total_missions < 5:
        character_arc_hints.append("Growing in experience but cautious - perhaps gaining confidence")

    if total_missions > 15:
        character_arc_hints.append("Veteran - has seen much, perhaps contemplating purpose")

    # Check skill progression for specialization
    skills = player.get("skills", {})
    if isinstance(skills, dict):
        max_skill = max(skills.values()) if skills else 0
        if max_skill >= 5:
            dominant_skill = max(skills.items(), key=lambda x: x[1])[0]
            character_arc_hints.append(f"Specializing in {dominant_skill} - identity forming")

    return {
        "recent_choices": recent_choices,
        "narrative_themes": narrative_themes,
        "story_opportunities": story_opportunities,
        "emotional_tone": emotional_tone,
        "character_arc_hints": character_arc_hints,
        "mission_count": total_missions,
        "exploration_count": len(discovered_locations)
    }


async def check_character_development(game_state: Dict[str, Any]) -> Dict[str, Any]:
    """
    Monitor player progression and suggest character moments

    Args:
        game_state: Current game state

    Returns:
        Dictionary with:
        - player_level: Current player level
        - recent_growth: Recent XP gains, level ups
        - skill_progression: Which skills are developing
        - personality_indicators: Suggested personality traits based on actions
        - character_moment_opportunity: Whether now is good time for character development
    """
    player = game_state.get("player", {})
    progress = game_state.get("progress", {})

    player_level = player.get("level", 1)
    player_xp = player.get("xp", 0)
    skills = player.get("skills", {})

    # Skill progression analysis
    skill_progression = {}
    dominant_skills = []
    underdeveloped_skills = []

    if isinstance(skills, dict) and skills:
        avg_skill = sum(skills.values()) / len(skills)

        for skill_name, skill_value in skills.items():
            skill_progression[skill_name] = {
                "level": skill_value,
                "relative": "high" if skill_value > avg_skill else "low"
            }

            if skill_value >= 5:
                dominant_skills.append(skill_name)
            elif skill_value < avg_skill - 1:
                underdeveloped_skills.append(skill_name)

    # Personality indicators based on skill focus
    personality_indicators = []

    if "engineering" in dominant_skills:
        personality_indicators.append("Technical, problem-solver, detail-oriented")
    if "diplomacy" in dominant_skills:
        personality_indicators.append("Charismatic, persuasive, people-focused")
    if "combat" in dominant_skills:
        personality_indicators.append("Decisive, tactical, action-oriented")
    if "science" in dominant_skills:
        personality_indicators.append("Analytical, curious, knowledge-seeking")

    # Check for balanced development
    if len(dominant_skills) >= 3:
        personality_indicators.append("Well-rounded, adaptable, versatile")
    elif len(dominant_skills) == 0:
        personality_indicators.append("Still finding their way, potential untapped")

    # Determine if this is a good moment for character development
    character_moment_opportunity = False
    moment_reason = None

    # After level up
    if player_level > 1 and player_xp < 50:  # Just leveled up (low XP in new level)
        character_moment_opportunity = True
        moment_reason = "Recent level up - growth and reflection"

    # Skill milestone
    if any(skill >= 5 for skill in skills.values()) and len(dominant_skills) <= 2:
        character_moment_opportunity = True
        moment_reason = "Skill mastery achieved - defining moment"

    # Mission milestone
    completed_missions = progress.get("completed_missions", [])
    mission_count = len(completed_missions) if isinstance(completed_missions, list) else 0
    if mission_count > 0 and mission_count % 10 == 0:
        character_moment_opportunity = True
        moment_reason = "Mission milestone - pause to reflect on journey"

    return {
        "player_level": player_level,
        "player_xp": player_xp,
        "skills": skills,
        "skill_progression": skill_progression,
        "dominant_skills": dominant_skills,
        "underdeveloped_skills": underdeveloped_skills,
        "personality_indicators": personality_indicators,
        "character_moment_opportunity": character_moment_opportunity,
        "moment_reason": moment_reason,
        "mission_count": mission_count
    }


async def evaluate_atmosphere(game_state: Dict[str, Any]) -> Dict[str, Any]:
    """
    Determine current scene mood and potential descriptive moments

    Args:
        game_state: Current game state

    Returns:
        Dictionary with:
        - current_mood: Overall emotional atmosphere
        - scene_type: What kind of scene is this (quiet, tense, triumphant, etc.)
        - environmental_details: Notable environmental factors
        - descriptive_opportunities: When storyteller should paint the scene
        - tension_level: Current dramatic tension (0-10)
    """
    ship = game_state.get("ship", {})
    mission = game_state.get("mission", {})
    environment = game_state.get("environment", {})
    progress = game_state.get("progress", {})

    # Base mood calculation
    hull_hp = ship.get("hull_hp", 0)
    max_hull = ship.get("max_hull_hp", 100)
    hull_pct = (hull_hp / max_hull * 100) if max_hull > 0 else 0

    power_avail = ship.get("power_available", 0)
    power_total = ship.get("power_total", 0)
    power_pct = (power_avail / power_total * 100) if power_total > 0 else 0

    # Determine mood
    current_mood = "calm"
    scene_type = "quiet moment"
    tension_level = 2  # Default low tension

    # High tension scenarios
    if hull_pct < 25 or power_pct < 10:
        current_mood = "desperate"
        scene_type = "survival crisis"
        tension_level = 9
    elif hull_pct < 50:
        current_mood = "tense"
        scene_type = "challenging situation"
        tension_level = 6

    # Mission-based mood
    if mission:
        mission_type = mission.get("type", "unknown")

        if mission_type == "combat":
            current_mood = "adrenaline"
            scene_type = "action sequence"
            tension_level = 8
        elif mission_type == "story":
            current_mood = "contemplative"
            scene_type = "narrative moment"
            tension_level = 4
        elif mission_type == "exploration":
            current_mood = "wonder"
            scene_type = "discovery"
            tension_level = 3
        elif mission_type == "rescue":
            current_mood = "urgent"
            scene_type = "time-sensitive"
            tension_level = 7

    # Environmental factors
    environmental_details = []
    location = environment.get("location") or mission.get("location", "Unknown Space")

    environmental_details.append(f"Location: {location}")

    # Check for threats
    threats = environment.get("threats", [])
    if threats:
        environmental_details.append(f"{len(threats)} threats detected")
        tension_level = min(10, tension_level + 2)

    # Check for opportunities
    opportunities = environment.get("opportunities", [])
    if opportunities:
        environmental_details.append(f"{len(opportunities)} opportunities available")

    # Weather/conditions
    weather = environment.get("weather", None)
    if weather and weather != "Normal space conditions":
        environmental_details.append(f"Conditions: {weather}")

    # Positive moments (lower tension, raise mood)
    completed_missions = progress.get("completed_missions", [])
    if completed_missions and len(completed_missions) % 5 == 0:
        current_mood = "triumphant"
        scene_type = "victory"
        tension_level = 2

    # Descriptive opportunities
    descriptive_opportunities = []

    # Good times for description
    if scene_type == "quiet moment":
        descriptive_opportunities.append("Calm moment - perfect for atmospheric description")

    if scene_type == "discovery":
        descriptive_opportunities.append("New discovery - paint the wonder and awe")

    if scene_type == "narrative moment":
        descriptive_opportunities.append("Story beat - focus on emotional resonance")

    if tension_level >= 7:
        descriptive_opportunities.append("High tension - brief, visceral descriptions")

    # After completing missions
    if mission and mission.get("stage") == "complete":
        descriptive_opportunities.append("Mission complete - describe the aftermath")

    return {
        "current_mood": current_mood,
        "scene_type": scene_type,
        "tension_level": tension_level,
        "environmental_details": environmental_details,
        "descriptive_opportunities": descriptive_opportunities,
        "hull_status": f"{hull_pct:.0f}%",
        "power_status": f"{power_pct:.0f}%",
        "location": location
    }


async def assess_combat_readiness(game_state: Dict[str, Any]) -> Dict[str, Any]:
    """
    Analyze ship's combat capability - weapons, shields, hull integrity

    Args:
        game_state: Current game state

    Returns:
        Dictionary with:
        - combat_ready: Boolean indicating if ship is combat-capable
        - readiness_level: Overall readiness (nominal/fair/poor/critical)
        - weapons_status: Weapon system details
        - shields_status: Shield system details
        - hull_status: Hull integrity details
        - issues: List of combat-critical issues
        - recommendations: List of tactical recommendations
    """
    ship = game_state.get("ship", {})
    systems = ship.get("systems", {})

    # Weapons analysis
    weapons = systems.get("weapons", {})
    weapons_level = weapons.get("level", 0)
    weapons_health = weapons.get("health", 100)
    weapons_active = weapons.get("active", False)
    weapons_operational = weapons_level > 0 and weapons_health > 50 and weapons_active

    weapons_status = {
        "level": weapons_level,
        "health": weapons_health,
        "active": weapons_active,
        "operational": weapons_operational
    }

    # Shields analysis
    shields = systems.get("shields", {})
    shields_level = shields.get("level", 0)
    shields_health = shields.get("health", 100)
    shields_active = shields.get("active", False)
    shields_operational = shields_level > 0 and shields_health > 50 and shields_active

    shields_status = {
        "level": shields_level,
        "health": shields_health,
        "active": shields_active,
        "operational": shields_operational
    }

    # Hull analysis
    hull_hp = ship.get("hull_hp", 0)
    max_hull_hp = ship.get("max_hull_hp", 100)
    hull_percentage = (hull_hp / max_hull_hp * 100) if max_hull_hp > 0 else 0

    hull_status = {
        "hp": hull_hp,
        "max": max_hull_hp,
        "percentage": round(hull_percentage, 1),
        "critical": hull_percentage < 25
    }

    # Assess combat readiness
    issues = []
    recommendations = []

    # Weapons issues
    if not weapons_operational:
        if weapons_level == 0:
            issues.append("Weapons offline. No offensive capability.")
            recommendations.append("Install weapons system before engaging hostiles.")
        elif weapons_health < 50:
            issues.append(f"Weapons damaged ({weapons_health}% health). Reduced effectiveness.")
            recommendations.append("Repair weapons before combat engagement.")
        elif not weapons_active:
            issues.append("Weapons powered down.")
            recommendations.append("Activate weapons systems.")

    # Shields issues
    if not shields_operational:
        if shields_level == 0:
            issues.append("Shields offline. No defensive capability.")
            recommendations.append("Install shield generators before combat.")
        elif shields_health < 50:
            issues.append(f"Shields damaged ({shields_health}% health). Minimal protection.")
            recommendations.append("Repair shields or avoid combat.")
        elif not shields_active:
            issues.append("Shields powered down.")
            recommendations.append("Activate shield systems.")
    elif shields_health < 75:
        issues.append(f"Shields at {shields_health}%. Recommend avoiding combat until repaired.")

    # Hull issues
    if hull_percentage < 25:
        issues.append(f"HULL BREACH. Critical structural damage ({hull_percentage:.0f}%).")
        recommendations.append("Emergency repair required. Avoid all combat.")
    elif hull_percentage < 50:
        issues.append(f"Hull integrity compromised ({hull_percentage:.0f}%).")
        recommendations.append("Repair hull before engaging in combat.")
    elif hull_percentage < 75:
        issues.append(f"Hull damage detected ({hull_percentage:.0f}%).")

    # Overall readiness assessment
    combat_ready = weapons_operational and (shields_operational or hull_percentage > 75)

    if hull_percentage < 25 or (not weapons_operational and not shields_operational):
        readiness_level = "critical"
    elif not combat_ready:
        readiness_level = "poor"
    elif hull_percentage < 60 or shields_health < 60 or weapons_health < 60:
        readiness_level = "fair"
    else:
        readiness_level = "nominal"

    return {
        "combat_ready": combat_ready,
        "readiness_level": readiness_level,
        "weapons_status": weapons_status,
        "shields_status": shields_status,
        "hull_status": hull_status,
        "issues": issues,
        "recommendations": recommendations
    }


async def scan_threats(game_state: Dict[str, Any]) -> Dict[str, Any]:
    """
    Scan for hostile ships, environmental hazards, and combat threats

    Args:
        game_state: Current game state

    Returns:
        Dictionary with:
        - threats: List of all detected threats
        - immediate_threats: Threats requiring immediate action
        - environmental_hazards: Non-combat environmental dangers
        - threat_assessment: Overall threat level (none/low/medium/high/critical)
        - time_to_contact: Estimated seconds to engagement (if applicable)
    """
    environment = game_state.get("environment", {})
    mission = game_state.get("mission", {})

    threats = []
    immediate_threats = []
    environmental_hazards = []

    # Scan environment for threats
    env_threats = environment.get("threats", [])
    if isinstance(env_threats, list):
        threats.extend(env_threats)

    # Scan mission for threats
    mission_threats = mission.get("threats", [])
    if isinstance(mission_threats, list):
        threats.extend(mission_threats)

    # Check nearby objects for hostiles
    nearby_objects = environment.get("nearby_objects", [])
    if isinstance(nearby_objects, list):
        for obj in nearby_objects:
            if isinstance(obj, dict):
                obj_type = obj.get("type", "unknown")
                threat_level = obj.get("threat_level", 0)
                distance = obj.get("distance", 999)
                hostile = obj.get("hostile", False)

                if hostile or threat_level >= 3:
                    threat_desc = f"Hostile {obj_type} detected"
                    if distance < 100:
                        immediate_threats.append(f"{threat_desc}. Range: {distance}m")
                    else:
                        threats.append(f"{threat_desc}. Range: {distance}m")
                elif threat_level >= 2:
                    environmental_hazards.append(f"{obj_type} (threat level {threat_level})")

    # Check mission stage for combat
    current_stage = mission.get("current_stage", {})
    stage_type = current_stage.get("type", "")
    if stage_type == "combat":
        stage_desc = current_stage.get("description", "")
        if "hostile" in stage_desc.lower() or "enemy" in stage_desc.lower():
            immediate_threats.append("Combat engagement imminent")

    # Environmental hazards
    weather = environment.get("weather", "")
    if weather and "storm" in weather.lower():
        environmental_hazards.append(f"Space weather: {weather}")
    if weather and ("radiation" in weather.lower() or "solar" in weather.lower()):
        environmental_hazards.append(f"Radiation hazard: {weather}")

    # Assess overall threat level
    if immediate_threats:
        threat_assessment = "critical" if len(immediate_threats) > 2 else "high"
        time_to_contact = "30s"  # Immediate threats are close
    elif threats:
        threat_assessment = "medium" if len(threats) > 1 else "low"
        time_to_contact = "unknown"
    else:
        threat_assessment = "none"
        time_to_contact = "N/A"

    return {
        "threats": threats,
        "immediate_threats": immediate_threats,
        "environmental_hazards": environmental_hazards,
        "threat_assessment": threat_assessment,
        "time_to_contact": time_to_contact
    }


async def evaluate_tactical_options(game_state: Dict[str, Any]) -> Dict[str, Any]:
    """
    Analyze tactical situation and suggest strategic actions

    Args:
        game_state: Current game state

    Returns:
        Dictionary with:
        - recommended_action: Primary tactical recommendation
        - alternative_actions: List of alternative options
        - tactical_advantages: Current advantages in situation
        - tactical_disadvantages: Current disadvantages
        - risk_level: Risk assessment (low/medium/high/critical)
        - success_probability: Estimated % chance of success
    """
    ship = game_state.get("ship", {})
    environment = game_state.get("environment", {})
    mission = game_state.get("mission", {})

    # Get combat readiness (reuse logic)
    combat_status = await assess_combat_readiness(game_state)
    combat_ready = combat_status["combat_ready"]
    readiness_level = combat_status["readiness_level"]

    # Get threat assessment
    threat_status = await scan_threats(game_state)
    threat_level = threat_status["threat_assessment"]
    immediate_threats = threat_status["immediate_threats"]

    tactical_advantages = []
    tactical_disadvantages = []
    alternative_actions = []
    recommended_action = "Hold position and monitor situation"
    risk_level = "low"
    success_probability = 75

    # Analyze advantages
    systems = ship.get("systems", {})
    weapons = systems.get("weapons", {})
    shields = systems.get("shields", {})
    propulsion = systems.get("propulsion", {})

    if weapons.get("level", 0) >= 3:
        tactical_advantages.append("Advanced weapons systems")
    if shields.get("level", 0) >= 3:
        tactical_advantages.append("Strong defensive shields")
    if propulsion.get("level", 0) >= 3:
        tactical_advantages.append("High maneuverability")

    # Analyze disadvantages
    if not combat_ready:
        tactical_disadvantages.append("Combat systems not operational")
    if readiness_level in ["poor", "critical"]:
        tactical_disadvantages.append("Poor combat readiness")
    if combat_status["hull_status"]["percentage"] < 60:
        tactical_disadvantages.append("Hull damage limits combat effectiveness")

    # Determine recommended action based on situation
    if immediate_threats:
        if combat_ready and readiness_level in ["nominal", "fair"]:
            recommended_action = "Engage targets. Weapons range in 30 seconds."
            alternative_actions.append("Evasive maneuvers to extend engagement range")
            alternative_actions.append("Attempt to establish communications")
            risk_level = "medium"
            success_probability = 65
        else:
            recommended_action = "Evasive maneuvers required immediately"
            alternative_actions.append("Emergency warp jump if warp drive available")
            alternative_actions.append("Attempt to negotiate/communicate")
            risk_level = "high"
            success_probability = 40
    elif threat_level in ["medium", "high"]:
        if combat_ready:
            recommended_action = "Prepare for potential engagement. Increase alert status."
            alternative_actions.append("Avoid contact and change course")
            alternative_actions.append("Investigate threats at safe distance")
            risk_level = "medium"
            success_probability = 70
        else:
            recommended_action = "Avoid contact. Alter course to maintain safe distance."
            alternative_actions.append("Repair systems before proceeding")
            alternative_actions.append("Call for assistance if communications available")
            risk_level = "medium"
            success_probability = 60
    else:
        # No threats
        if readiness_level == "critical":
            recommended_action = "Emergency repairs required. Find safe harbor."
            risk_level = "high"
            success_probability = 50
        elif readiness_level in ["poor", "fair"]:
            recommended_action = "Conduct repairs and system maintenance."
            alternative_actions.append("Continue mission at reduced capacity")
            risk_level = "low"
            success_probability = 80
        else:
            recommended_action = "All systems nominal. Ready for operations."
            alternative_actions.append("Conduct routine patrols")
            alternative_actions.append("Investigate nearby points of interest")
            risk_level = "low"
            success_probability = 90

    return {
        "recommended_action": recommended_action,
        "alternative_actions": alternative_actions,
        "tactical_advantages": tactical_advantages,
        "tactical_disadvantages": tactical_disadvantages,
        "risk_level": risk_level,
        "success_probability": success_probability
    }


async def check_crew_morale(game_state: Dict[str, Any]) -> Dict[str, Any]:
    """
    Monitor crew morale and emotional state

    Args:
        game_state: Current game state

    Returns:
        Dictionary with:
        - overall_morale: Morale level (critical, low, good, excellent)
        - morale_score: Numeric score 0-100
        - recent_crew_losses: Number of recent crew losses
        - recent_mission_failures: Number of recent mission failures
        - morale_factors: List of factors affecting morale
        - crew_needs: What the crew needs right now
    """
    progress = game_state.get("progress", {})
    mission = game_state.get("mission", {})
    ship = game_state.get("ship", {})

    # Check for crew losses (from progress events or mission data)
    notable_events = progress.get("notable_events", [])
    recent_crew_losses = 0
    recent_mission_failures = 0

    if isinstance(notable_events, list):
        # Look for crew loss events in recent history
        recent_events = notable_events[-10:]  # Last 10 events
        for event in recent_events:
            event_text = str(event).lower() if event else ""
            if "crew" in event_text and ("lost" in event_text or "died" in event_text or "killed" in event_text):
                recent_crew_losses += 1
            if "mission" in event_text and ("failed" in event_text or "failure" in event_text):
                recent_mission_failures += 1

    # Check mission difficulty and current state
    mission_active = bool(mission)
    current_difficulty = mission.get("difficulty", 1) if mission_active else 0

    # Check ship condition as morale factor
    hull_hp = ship.get("hull_hp", 0)
    max_hull_hp = ship.get("max_hull_hp", 100)
    hull_percentage = (hull_hp / max_hull_hp * 100) if max_hull_hp > 0 else 0

    # Completed missions as positive factor
    completed_missions = progress.get("completed_missions", [])
    total_completed = len(completed_missions) if isinstance(completed_missions, list) else 0

    # Calculate overall morale
    morale_score = 100  # Start at neutral

    # Negative factors
    morale_score -= (recent_crew_losses * 25)  # Each loss is significant
    morale_score -= (recent_mission_failures * 15)
    if hull_percentage < 50:
        morale_score -= 20  # Ship damage affects morale
    if current_difficulty >= 4:
        morale_score -= 10  # High difficulty missions are stressful

    # Positive factors
    if total_completed > 0:
        morale_score += min(total_completed * 5, 30)  # Success builds morale (capped)
    if hull_percentage > 90:
        morale_score += 10  # Well-maintained ship boosts morale

    # Clamp score
    morale_score = max(0, min(100, morale_score))

    # Determine morale level
    if morale_score < 25:
        overall_morale = "critical"
    elif morale_score < 50:
        overall_morale = "low"
    elif morale_score < 75:
        overall_morale = "good"
    else:
        overall_morale = "excellent"

    # Identify morale factors
    morale_factors = []
    crew_needs = []

    if recent_crew_losses > 0:
        morale_factors.append(f"Recent crew losses: {recent_crew_losses}")
        crew_needs.append("Time to grieve and heal")

    if recent_mission_failures > 0:
        morale_factors.append(f"Recent mission failures: {recent_mission_failures}")
        crew_needs.append("Renewed sense of purpose")

    if hull_percentage < 50:
        morale_factors.append(f"Ship damage: {hull_percentage:.0f}% hull integrity")
        crew_needs.append("Repairs and safety assurance")

    if total_completed > 5:
        morale_factors.append(f"Mission successes: {total_completed} completed")

    if current_difficulty >= 4:
        morale_factors.append(f"High-difficulty mission in progress (difficulty {current_difficulty})")
        crew_needs.append("Confidence in leadership")

    if not morale_factors:
        morale_factors.append("No significant morale factors detected")

    if not crew_needs:
        crew_needs.append("Continued steady leadership")

    return {
        "overall_morale": overall_morale,
        "morale_score": morale_score,
        "recent_crew_losses": recent_crew_losses,
        "recent_mission_failures": recent_mission_failures,
        "morale_factors": morale_factors,
        "crew_needs": crew_needs
    }


async def evaluate_player_progress(game_state: Dict[str, Any]) -> Dict[str, Any]:
    """
    Track player achievements, level ups, and milestones

    Args:
        game_state: Current game state

    Returns:
        Dictionary with:
        - current_level: Player's current level
        - recent_level_up: Whether player recently leveled up
        - recent_achievements: List of recent achievements
        - major_milestone: Whether a major milestone was reached
        - milestone_name: Name of the milestone (if any)
        - progress_summary: Summary of player's progress
        - total_missions_completed: Total missions completed
        - ship_systems_operational: Number of operational ship systems
    """
    player = game_state.get("player", {})
    progress = game_state.get("progress", {})
    ship = game_state.get("ship", {})

    # Player stats
    current_level = player.get("level", 1)
    current_xp = player.get("xp", 0)

    # Progress markers
    completed_missions = progress.get("completed_missions", [])
    total_missions = len(completed_missions) if isinstance(completed_missions, list) else 0

    discovered_locations = progress.get("discovered_locations", [])
    total_locations = len(discovered_locations) if isinstance(discovered_locations, list) else 0

    phase = progress.get("phase", 1)

    # Ship development
    systems = ship.get("systems", {})
    installed_systems = 0
    max_level_systems = 0

    if isinstance(systems, dict):
        for sys_data in systems.values():
            if isinstance(sys_data, dict):
                level = sys_data.get("level", 0)
                if level > 0:
                    installed_systems += 1
                if level >= 3:
                    max_level_systems += 1

    # Detect recent achievements
    recent_achievements = []
    recent_level_up = False
    major_milestone = False
    milestone_name = ""

    # Check for level milestones
    if current_level >= 10:
        milestone_name = f"Reached Level {current_level}"
        major_milestone = True
        recent_achievements.append(f"achieved level {current_level}")

    # Check for mission milestones
    if total_missions == 10:
        milestone_name = "Completed 10 Missions"
        major_milestone = True
        recent_achievements.append("completed 10 missions")
    elif total_missions == 25:
        milestone_name = "Completed 25 Missions"
        major_milestone = True
        recent_achievements.append("completed 25 missions")
    elif total_missions > 0 and total_missions % 5 == 0:
        recent_achievements.append(f"completed {total_missions} missions")

    # Check for ship system milestones
    if installed_systems == 10:
        milestone_name = "All Systems Operational"
        major_milestone = True
        recent_achievements.append("brought all ship systems online")
    elif max_level_systems >= 5:
        recent_achievements.append(f"upgraded {max_level_systems} systems to max level")

    # Check for phase progression
    if phase == 2:
        milestone_name = "Achieved Spaceflight"
        major_milestone = True
        recent_achievements.append("launched into space")

    # Check for exploration
    if total_locations >= 10:
        recent_achievements.append(f"explored {total_locations} locations")

    # Build progress summary
    progress_summary = f"Level {current_level}, {total_missions} missions completed, {installed_systems}/10 systems operational"

    # Detect recent level up (would need previous state comparison in production)
    # For now, check if XP is close to level threshold (simplified)
    xp_for_next_level = 100 * current_level  # Simplified XP calculation
    if current_xp >= xp_for_next_level * 0.9:
        recent_achievements.append("approaching next level")

    return {
        "current_level": current_level,
        "recent_level_up": recent_level_up,
        "recent_achievements": recent_achievements,
        "major_milestone": major_milestone,
        "milestone_name": milestone_name,
        "progress_summary": progress_summary,
        "total_missions_completed": total_missions,
        "ship_systems_operational": installed_systems
    }


async def assess_emotional_tone(game_state: Dict[str, Any]) -> Dict[str, Any]:
    """
    Determine if player might need encouragement or celebration

    Args:
        game_state: Current game state

    Returns:
        Dictionary with:
        - needs_encouragement: Whether player could use encouragement
        - facing_difficult_challenge: Whether player is in a tough situation
        - celebrating_success: Whether player deserves celebration
        - emotional_state: Estimated emotional state (struggling, challenged, engaged, triumphant)
        - support_type: Type of support needed (none, gentle, moderate, strong)
        - hull_condition: Current hull condition percentage
        - current_challenge_level: Current mission difficulty
    """
    player = game_state.get("player", {})
    ship = game_state.get("ship", {})
    mission = game_state.get("mission", {})
    progress = game_state.get("progress", {})

    # Default values
    needs_encouragement = False
    facing_difficult_challenge = False
    celebrating_success = False
    emotional_state = "engaged"
    support_type = "none"

    # Analyze current situation
    hull_hp = ship.get("hull_hp", 0)
    max_hull_hp = ship.get("max_hull_hp", 100)
    hull_percentage = (hull_hp / max_hull_hp * 100) if max_hull_hp > 0 else 0

    mission_active = bool(mission)
    mission_difficulty = mission.get("difficulty", 1) if mission_active else 0

    completed_missions = progress.get("completed_missions", [])
    total_completed = len(completed_missions) if isinstance(completed_missions, list) else 0

    player_level = player.get("level", 1)

    # Check for difficult challenges
    if mission_difficulty >= 4:
        facing_difficult_challenge = True
        needs_encouragement = True
        emotional_state = "challenged"
        support_type = "gentle"

    # Check for struggle indicators
    if hull_percentage < 30:
        needs_encouragement = True
        emotional_state = "struggling"
        support_type = "moderate"

    # Check for low progress despite being active
    if player_level >= 3 and total_completed < 5:
        needs_encouragement = True
        support_type = "gentle"

    # Check for success indicators
    if total_completed >= 10 or player_level >= 5:
        celebrating_success = True
        emotional_state = "triumphant"
        support_type = "celebration"

    # Check for recent ship damage but high difficulty mission
    if hull_percentage < 60 and mission_difficulty >= 3:
        needs_encouragement = True
        facing_difficult_challenge = True
        emotional_state = "challenged"
        support_type = "moderate"

    # Override if things are going well
    if hull_percentage > 80 and total_completed > 5:
        needs_encouragement = False
        emotional_state = "engaged"
        support_type = "none"

    return {
        "needs_encouragement": needs_encouragement,
        "facing_difficult_challenge": facing_difficult_challenge,
        "celebrating_success": celebrating_success,
        "emotional_state": emotional_state,
        "support_type": support_type,
        "hull_condition": f"{hull_percentage:.0f}%",
        "current_challenge_level": mission_difficulty
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
    },
    {
        "name": "analyze_narrative_context",
        "description": "Analyze recent player choices and mission history to identify story opportunities, narrative themes, and character arc hints.",
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
        "name": "check_character_development",
        "description": "Monitor player progression, skill development, and personality traits to suggest character development moments.",
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
        "name": "evaluate_atmosphere",
        "description": "Determine current scene mood, tension level, and identify opportunities for atmospheric descriptions.",
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
        "name": "assess_combat_readiness",
        "description": "Analyze ship's combat capability including weapons, shields, and hull integrity. Returns readiness level and tactical recommendations.",
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
        "name": "scan_threats",
        "description": "Scan for hostile ships, environmental hazards, and combat threats. Returns threat assessment and time to contact.",
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
        "name": "evaluate_tactical_options",
        "description": "Analyze tactical situation and recommend strategic actions based on combat readiness and threats.",
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
        "name": "check_crew_morale",
        "description": "Monitor crew morale, emotional state, and recent losses. Returns morale level and what crew needs.",
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
        "name": "evaluate_player_progress",
        "description": "Track player achievements, level ups, and major milestones. Returns recent accomplishments and progress summary.",
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
        "name": "assess_emotional_tone",
        "description": "Determine if player needs encouragement or celebration based on current situation and challenges.",
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
    "scan_environment": scan_environment,
    "analyze_narrative_context": analyze_narrative_context,
    "check_character_development": check_character_development,
    "evaluate_atmosphere": evaluate_atmosphere,
    "assess_combat_readiness": assess_combat_readiness,
    "scan_threats": scan_threats,
    "evaluate_tactical_options": evaluate_tactical_options,
    "check_crew_morale": check_crew_morale,
    "evaluate_player_progress": evaluate_player_progress,
    "assess_emotional_tone": assess_emotional_tone
}
