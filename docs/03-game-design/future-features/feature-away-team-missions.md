# Away Team Missions

**Priority:** Post-MVP (Phase 2)
**Phase:** Phase 2, Week 5-8
**Complexity:** High
**AI Integration:** Medium-High

## Overview

Away Team Missions transform Phase 2 gameplay by adding tactical crew-based missions inspired by Star Trek's away team episodes. Instead of all missions being ship-based, players select crew members to form away teams that explore planets, derelict stations, and anomalies. Crew composition, skills, and relationships affect outcomes, creating strategic depth and memorable character moments.

## Core Concept

**Away Team Structure:**
- Select 2-4 crew members for planetary/station missions
- Each crew member's skills and personality matter
- Crew can be injured or killed (optional permadeath)
- Different crew combinations unlock unique interactions
- Success depends on having right skills for situation

**Mission Types:**
- Planetary exploration
- Derelict ship/station investigation
- Rescue operations
- Scientific surveys
- First contact encounters
- Salvage operations in dangerous environments

## Design Principles

1. **Meaningful Choices** - Who you bring matters
2. **Crew Development** - Away missions build skills and relationships
3. **Risk vs Reward** - Danger is real, stakes are high
4. **Star Trek Authenticity** - Captures away team dynamics
5. **Tactical Depth** - Not just skill checks, but strategy
6. **Character Moments** - Crew personalities shine through
7. **Consequences** - Injuries, deaths, trauma persist

## Game Design

### Away Team Selection

Before mission, select crew:

```
╔══════════════════════════════════════════════════════════════╗
║ AWAY TEAM SELECTION                                          ║
║ Mission: Survey Abandoned Colony - Epsilon III              ║
╠══════════════════════════════════════════════════════════════╣
║ Required Skills: Science 5+, Engineering 3+                 ║
║ Recommended: Medical (hazardous environment)                 ║
║ Team Size: 2-4 crew members                                 ║
║                                                              ║
║ AVAILABLE CREW:                                              ║
║                                                              ║
║ [✓] You (Captain)                                           ║
║     ENG:4 SCI:5 MED:2 COM:3 DIP:6                          ║
║     Status: Healthy                                          ║
║     Note: Captain must lead away team                       ║
║                                                              ║
║ [ ] Dr. Sarah Chen (Medical Officer)                        ║
║     ENG:2 SCI:7 MED:9 COM:1 DIP:6                          ║
║     Status: Healthy | Morale: High                          ║
║     Bonus: +20% to medical checks, injury treatment         ║
║     Personality: Cautious, will advise restraint            ║
║                                                              ║
║ [ ] Marcus Rodriguez (Engineer)                             ║
║     ENG:8 SCI:4 MED:1 COM:3 DIP:2                          ║
║     Status: Healthy | Morale: Normal                        ║
║     Bonus: +20% to engineering checks, repairs              ║
║     Personality: Bold, prefers action                        ║
║     ⚠ Conflict with Dr. Chen (recent disagreement)         ║
║                                                              ║
║ [ ] Lieutenant Kira Tanaka (Tactical)                       ║
║     ENG:3 SCI:3 MED:2 COM:8 DIP:4                          ║
║     Status: Minor injury (bruised ribs) - 90% effective    ║
║     Bonus: +30% to combat, security protocols               ║
║     Personality: Protective, watches the team's back        ║
║                                                              ║
║ [ ] Dr. Elias Vorn (Scientist)                              ║
║     ENG:4 SCI:9 MED:3 COM:2 DIP:5                          ║
║     Status: Healthy | Morale: High                          ║
║     Bonus: +25% to science, xenobiology                      ║
║     Personality: Curious, gets absorbed in discoveries      ║
║     Note: Friends with Dr. Chen (bonus if both present)     ║
║                                                              ║
║ CURRENT TEAM: 1/4 selected                                  ║
║ Skill Coverage: SCI ✓ | ENG ✗ | MED ✗ | COM ✗              ║
║                                                              ║
║ Ship AI Recommendation: "Include Dr. Chen for medical and  ║
║ Marcus for engineering. Be aware of their tension."         ║
║                                                              ║
║ [Confirm Team] [Cancel Mission]                             ║
╚══════════════════════════════════════════════════════════════╝
```

**Selection Factors:**

**Skill Requirements:**
- Some missions require specific skills
- Missing required skills = higher failure chance
- Skill checks use best crew member's skill

**Crew Status:**
- Injured crew less effective
- Low morale crew may underperform
- Exhausted crew need rest

**Crew Relationships:**
- Positive relationships = teamwork bonuses
- Negative relationships = penalties
- Some combinations unlock special dialogue

**Personality Fit:**
- Bold mission? Bold crew members perform better
- Diplomatic mission? Cautious crew members shine
- Match personalities to mission type

### Mission Structure

**Phase 1: Deployment**
```
╔══════════════════════════════════════════════════════════════╗
║ AWAY TEAM - Epsilon III Colony                              ║
╠══════════════════════════════════════════════════════════════╣
║ Your away team materializes at the colony's main entrance. ║
║ The settlement is eerily quiet. No signs of life.          ║
║                                                              ║
║ TEAM STATUS:                                                 ║
║ • You (Captain) - Healthy                                   ║
║ • Dr. Sarah Chen - Healthy                                  ║
║ • Marcus Rodriguez - Healthy                                ║
║                                                              ║
║ Dr. Chen: [Scanning with tricorder] "I'm reading           ║
║           atmospheric contamination. Radiation levels       ║
║           are elevated but not immediately dangerous."      ║
║                                                              ║
║ Marcus: "Power grid's offline. Whatever happened here,     ║
║          it wasn't an orderly evacuation."                  ║
║                                                              ║
║ What's your approach?                                        ║
║                                                              ║
║ A) Proceed cautiously, scan before moving                   ║
║    [Cautious approach - favors Dr. Chen]                    ║
║                                                              ║
║ B) Split up to cover more ground                            ║
║    [Risky approach - faster but dangerous]                  ║
║                                                              ║
║ C) Focus on main buildings first                            ║
║    [Systematic approach - favors Marcus]                    ║
║                                                              ║
║ D) Consult the team                                         ║
║    [Democratic approach - hear opinions]                    ║
║                                                              ║
║ [Select Approach]                                            ║
╚══════════════════════════════════════════════════════════════╝
```

**Phase 2: Investigation**

**Skill Checks:**
```
╔══════════════════════════════════════════════════════════════╗
║ You find a locked door blocking access to the lab.         ║
║                                                              ║
║ OPTIONS:                                                     ║
║                                                              ║
║ A) Marcus: Bypass the lock (Engineering Check)             ║
║    Chance: 85% (Marcus ENG:8 + tools)                       ║
║    Risk: Might trigger alarm                                ║
║                                                              ║
║ B) You: Override security (Computer + Engineering)         ║
║    Chance: 70% (Your ENG:4 + SCI:5)                        ║
║    Risk: Slower                                              ║
║                                                              ║
║ C) Brute force the door                                     ║
║    Chance: 60% (Team effort)                                ║
║    Risk: Noisy, might damage contents                       ║
║                                                              ║
║ D) Look for alternate entrance                              ║
║    Chance: Varies                                            ║
║    Risk: Takes time                                          ║
║                                                              ║
║ [Select Option]                                              ║
╚══════════════════════════════════════════════════════════════╝
```

**Crew Interactions:**
```
╔══════════════════════════════════════════════════════════════╗
║ Marcus: "Captain, I found something. You need to see this."║
║                                                              ║
║ You find Marcus in the colony's command center, staring at ║
║ a screen showing security footage from the last days.      ║
║                                                              ║
║ Dr. Chen: "They knew something was coming. Look - they're  ║
║           gathering children, sending them to the ships."   ║
║                                                              ║
║ The footage shows panicked colonists evacuating. Then the  ║
║ screen goes dark.                                           ║
║                                                              ║
║ Marcus: "Whatever it was, it happened fast."               ║
║                                                              ║
║ Dr. Chen: "I'm detecting organic residue on the walls.     ║
║           This wasn't a natural disaster."                  ║
║                                                              ║
║ You can:                                                     ║
║ [A] Continue investigating (push deeper)                    ║
║ [B] Collect data and return to ship (play it safe)         ║
║ [C] Search for survivors (humanitarian priority)           ║
║ [D] Ask team for input                                      ║
╚══════════════════════════════════════════════════════════════╝
```

**Phase 3: Crisis/Climax**

**Something Goes Wrong:**
```
╔══════════════════════════════════════════════════════════════╗
║ ALERT: HOSTILE CONTACT                                      ║
╠══════════════════════════════════════════════════════════════╣
║ The organic residue Dr. Chen detected wasn't residue.      ║
║ It was alive. And it's spreading.                          ║
║                                                              ║
║ Marcus: "We need to move! NOW!"                            ║
║                                                              ║
║ Dr. Chen: "I'm sealing the contaminated sections, but--"   ║
║           [Stops, stares at her scanner]                    ║
║           "Oh no. Marcus, behind you!"                      ║
║                                                              ║
║ A tendril of alien biomatter lashes toward Marcus.         ║
║                                                              ║
║ IMMEDIATE DECISION:                                         ║
║                                                              ║
║ A) Push Marcus out of the way (You take the hit)           ║
║    Risk: Captain injured                                    ║
║    Benefit: Marcus safe                                      ║
║                                                              ║
║ B) Pull Dr. Chen to safety, both dodge (Reflex check)      ║
║    Risk: Marcus must dodge alone (his Combat:3)            ║
║    Benefit: If successful, all safe                         ║
║                                                              ║
║ C) Shoot the tendril (Combat check)                        ║
║    Risk: Might miss, escalate situation                     ║
║    Benefit: Eliminate immediate threat                      ║
║                                                              ║
║ D) Marcus: Engineer a containment field (Engineering)      ║
║    Risk: Takes time, must hold position                     ║
║    Benefit: Secure area if successful                       ║
║                                                              ║
║ [CHOOSE NOW] - 5 seconds                                    ║
╚══════════════════════════════════════════════════════════════╝
```

**Consequences:**
```
You chose: Push Marcus out of the way

╔══════════════════════════════════════════════════════════════╗
║ You shove Marcus aside just as the tendril strikes.        ║
║ It catches your arm instead.                                ║
║                                                              ║
║ [CAPTAIN INJURED - Moderate wound]                         ║
║                                                              ║
║ Pain shoots through your arm, but you stay on your feet.   ║
║                                                              ║
║ Dr. Chen: "Captain!" [Rushes to your side]                 ║
║                                                              ║
║ Marcus: [Stunned] "You... you saved me."                   ║
║         [Relationship +15]                                  ║
║                                                              ║
║ Dr. Chen: "Hold still. I can treat this, but we need to   ║
║           get out of here first."                          ║
║           [Medical check: 95% success with Dr. Chen]       ║
║                                                              ║
║ Marcus: "I'll cover you. Move!"                            ║
║         [Marcus is now Determined - +10% all checks]        ║
║                                                              ║
║ The biomass is spreading. You need to escape.              ║
║                                                              ║
║ [Continue Mission] [Emergency Evacuation]                   ║
╚══════════════════════════════════════════════════════════════╝
```

**Phase 4: Resolution**

**Success:**
```
╔══════════════════════════════════════════════════════════════╗
║ MISSION COMPLETE: Epsilon III Survey                        ║
╠══════════════════════════════════════════════════════════════╣
║ Status: SUCCESS (with complications)                        ║
║                                                              ║
║ OBJECTIVES:                                                  ║
║ ✓ Survey abandoned colony                                   ║
║ ✓ Discover what happened                                    ║
║ ✓ Collect scientific data                                   ║
║ ✗ Find survivors (none found)                               ║
║                                                              ║
║ CASUALTIES:                                                  ║
║ • Captain: Moderate injury (recovered with treatment)       ║
║ • Dr. Chen: Healthy                                         ║
║ • Marcus Rodriguez: Healthy                                 ║
║                                                              ║
║ REWARDS:                                                     ║
║ • XP: 200 (all crew)                                        ║
║ • Scientific data on alien biomass                          ║
║ • Colony database (contains valuable information)          ║
║ • Salvageable equipment                                      ║
║                                                              ║
║ CREW MORALE:                                                 ║
║ Dr. Chen: +10 (proud of team's survival)                   ║
║ Marcus: +15 (grateful for your sacrifice)                   ║
║                                                              ║
║ RELATIONSHIPS:                                               ║
║ Marcus → You: +15 (You saved his life)                      ║
║ Marcus → Dr. Chen: +5 (Worked well together)               ║
║                                                              ║
║ UNLOCKED:                                                    ║
║ • New research: Hostile Xenobiology                         ║
║ • Mission: "Biomass Source" (follow-up investigation)       ║
║                                                              ║
║ Ship AI: "Welcome back, Captain. Medical bay is prepared   ║
║          for your treatment. Well done down there."         ║
║                                                              ║
║ [Continue]                                                   ║
╚══════════════════════════════════════════════════════════════╝
```

**Failure/Partial Success:**
```
╔══════════════════════════════════════════════════════════════╗
║ MISSION FAILED: Epsilon III Survey                          ║
╠══════════════════════════════════════════════════════════════╣
║ Status: EMERGENCY EVACUATION                                ║
║                                                              ║
║ The biomass spread too quickly. You barely made it out.    ║
║                                                              ║
║ CASUALTIES:                                                  ║
║ • Marcus Rodriguez: CRITICAL INJURY                         ║
║   - Tendril strike to chest                                 ║
║   - In medical bay, stable but serious                      ║
║   - Will recover, but needs 2 weeks rest                    ║
║                                                              ║
║ OBJECTIVES:                                                  ║
║ ✗ Complete survey                                           ║
║ ✗ Collect all data                                          ║
║ ✓ Escape alive                                              ║
║                                                              ║
║ CONSEQUENCES:                                                ║
║ • Marcus unavailable for 2 weeks (14 days)                  ║
║ • Partial data recovered                                    ║
║ • Crew morale: -15 (traumatic experience)                   ║
║ • You feel responsible                                      ║
║                                                              ║
║ Dr. Chen: "He'll live, but it was close. Too close."       ║
║                                                              ║
║ Marcus (barely conscious): "Not... your fault, Captain..."  ║
║                                                              ║
║ [This weighs on you]                                        ║
║                                                              ║
║ [Continue]                                                   ║
╚══════════════════════════════════════════════════════════════╝
```

### Injury & Death System

**Injury Severity:**
- **Minor:** -10% effectiveness, heals in 3 days
- **Moderate:** -25% effectiveness, heals in 7 days
- **Severe:** -50% effectiveness, heals in 14 days
- **Critical:** Incapacitated, medical bay, 14-30 days

**Death (Optional Permadeath Mode):**
```
╔══════════════════════════════════════════════════════════════╗
║ CREW MEMBER DECEASED                                        ║
╠══════════════════════════════════════════════════════════════╣
║ Lieutenant Kira Tanaka has died.                           ║
║                                                              ║
║ She gave her life protecting Dr. Vorn from the collapse.   ║
║                                                              ║
║ Dr. Chen: "There was nothing we could have done. She knew  ║
║           what she was doing."                              ║
║                                                              ║
║ Dr. Vorn: [Shaken] "She... she saved me. I should have--"  ║
║                                                              ║
║ You: [Say something to the crew]                            ║
║                                                              ║
║ CONSEQUENCES:                                                ║
║ • Lieutenant Tanaka permanently removed from crew           ║
║ • All crew: Morale -30                                      ║
║ • Dr. Vorn: Survivor's guilt, morale -50                    ║
║ • Memorial service unlocked                                 ║
║ • Crew will remember her sacrifice                          ║
║                                                              ║
║ "In the service of exploration, some pay the ultimate      ║
║  price. We honor their sacrifice by continuing the         ║
║  mission."                                                   ║
║                                                              ║
║ [Hold Memorial Service] [Continue]                          ║
╚══════════════════════════════════════════════════════════════╝
```

### Crew Synergies

**Positive Combinations:**

**Dr. Chen + Dr. Vorn** (Friends)
- +15% to all science checks
- Special dialogue about discoveries
- Boost each other's morale

**Marcus + Lt. Tanaka** (Tactical Respect)
- +10% to combat and engineering
- Efficient problem-solving
- Cover each other in danger

**You + Any Crew** (Leadership)
- +5% to all checks (base captain bonus)
- Crew performs better with captain present
- Morale boost from your presence

**Negative Combinations:**

**Marcus + Dr. Chen** (Tension)
- -5% to teamwork checks
- Occasional disagreements
- Can improve through missions together

**Dr. Vorn + Lt. Tanaka** (Personality Clash)
- Vorn's curiosity vs Tanaka's caution
- -5% when they disagree on approach
- No penalty if roles are clear

### Mission Types

**1. Planetary Survey**
- Explore unknown planets
- Collect samples
- Catalog life forms
- Science-focused

**2. Derelict Investigation**
- Explore abandoned ships/stations
- Salvage technology
- Discover what happened
- Engineering and science focus

**3. Rescue Operation**
- Save stranded personnel
- Medical and combat skills needed
- Time pressure
- High stakes

**4. First Contact Ground Mission**
- Meet species on their homeworld
- Diplomacy critical
- Cultural sensitivity
- Long-term consequences

**5. Hostile Environment Exploration**
- Extreme conditions (radiation, heat, etc.)
- Specialized equipment needed
- Engineering to adapt gear
- Medical for treatment

**6. Combat Mission** (Rare, usually defensive)
- Defend location
- Protect crew/civilians
- Combat skills essential
- Moral weight

### Technical Implementation

**Data Models:**

**GDScript:**
```gdscript
# away_team.gd
class_name AwayTeam
extends Node

signal team_assembled(members: Array)
signal crew_injured(crew_id: String, severity: String)
signal crew_died(crew_id: String)
signal mission_completed(result: Dictionary)

var current_team: Array[String] = []  # Crew IDs
var mission_location: String = ""
var mission_status: String = "inactive"  # inactive, deployed, in_progress, evacuating
var team_morale_modifier: float = 1.0

func assemble_team(crew_ids: Array) -> bool:
    """Assemble away team from crew IDs"""
    # Validate crew availability
    for crew_id in crew_ids:
        var crew = GameState.get_crew_member(crew_id)
        if not crew or crew.status != "active":
            return false

    current_team = crew_ids
    _calculate_team_synergies()
    emit_signal("team_assembled", current_team)
    return true

func get_team_skill(skill_name: String) -> int:
    """Get best skill value in current team"""
    var best = 0
    for crew_id in current_team:
        var crew = GameState.get_crew_member(crew_id)
        if crew:
            best = max(best, crew.get_skill(skill_name))
    return best

func apply_injury(crew_id: String, severity: String) -> void:
    """Apply injury to crew member"""
    var crew = GameState.get_crew_member(crew_id)
    if not crew:
        return

    var injury = {
        "type": severity,  # minor, moderate, severe, critical
        "effectiveness": _get_injury_penalty(severity),
        "heal_days": _get_heal_time(severity),
        "timestamp": GameState.current_day
    }

    crew.status = "injured"
    crew.current_injury = injury

    # Morale impact
    _apply_injury_morale_impact(severity)

    emit_signal("crew_injured", crew_id, severity)

    # Check if critical
    if severity == "critical":
        _handle_critical_injury(crew_id)

func kill_crew_member(crew_id: String, cause: String) -> void:
    """Permanent death of crew member"""
    var crew = GameState.get_crew_member(crew_id)
    if not crew:
        return

    crew.status = "deceased"
    crew.cause_of_death = cause
    crew.day_of_death = GameState.current_day

    # Major morale impact
    GameState.adjust_all_crew_morale(-30, "Death of " + crew.name)

    # Special morale for those present
    for team_member_id in current_team:
        if team_member_id != crew_id:
            var team_member = GameState.get_crew_member(team_member_id)
            team_member.adjust_morale(-20, "Witnessed death of " + crew.name)

    # Trauma memory
    _add_trauma_memory(crew_id, cause)

    emit_signal("crew_died", crew_id)

    # Remove from active roster
    GameState.remove_crew_member(crew_id)

func _calculate_team_synergies() -> void:
    """Calculate bonuses/penalties from crew combinations"""
    team_morale_modifier = 1.0

    # Check relationships
    for i in range(current_team.size()):
        for j in range(i + 1, current_team.size()):
            var crew_a = GameState.get_crew_member(current_team[i])
            var crew_b = GameState.get_crew_member(current_team[j])

            var relationship = crew_a.relationships.get(current_team[j], 0)

            if relationship > 50:  # Good friends
                team_morale_modifier += 0.15
            elif relationship < -20:  # Tension
                team_morale_modifier -= 0.05

func _get_injury_penalty(severity: String) -> float:
    match severity:
        "minor": return 0.10
        "moderate": return 0.25
        "severe": return 0.50
        "critical": return 1.0  # Incapacitated
        _: return 0.0

func _get_heal_time(severity: String) -> int:
    match severity:
        "minor": return 3
        "moderate": return 7
        "severe": return 14
        "critical": return 21
        _: return 0

func _apply_injury_morale_impact(severity: String) -> void:
    var impact = 0
    match severity:
        "minor": impact = -5
        "moderate": impact = -10
        "severe": impact = -20
        "critical": impact = -30

    for crew_id in current_team:
        var crew = GameState.get_crew_member(crew_id)
        crew.adjust_morale(impact, "Team member injured on away mission")

func _handle_critical_injury(crew_id: String) -> void:
    """Handle potentially fatal critical injury"""
    var crew = GameState.get_crew_member(crew_id)

    # Check if medical crew present
    var has_medical = false
    for team_id in current_team:
        var team_member = GameState.get_crew_member(team_id)
        if team_member.get_skill("medical") >= 5:
            has_medical = true
            break

    # Medical check determines if they survive
    var survival_chance = 50.0
    if has_medical:
        survival_chance = 85.0

    # In permadeath mode, they might die
    if GameState.permadeath_enabled and randf() * 100 > survival_chance:
        kill_crew_member(crew_id, "Critical injury on away mission")
```

### UI Design

**Team Selection Screen:**
(Already shown above in Away Team Selection section)

**In-Mission HUD:**
```
╔══════════════════════════════════════════════════════════════╗
║ AWAY TEAM - Epsilon III Colony [Active]                    ║
╠══════════════════════════════════════════════════════════════╣
║ Team Status:                                                 ║
║ • You: ████░ 80% (Moderate injury)                          ║
║ • Dr. Chen: █████ 100% (Healthy)                            ║
║ • Marcus: █████ 100% (Healthy, Determined +10%)            ║
║                                                              ║
║ Location: Research Lab - Level 2                            ║
║ Objective: Collect scientific data                          ║
║ Time Elapsed: 47 minutes                                     ║
║                                                              ║
║ [Team] [Scan] [Equipment] [Emergency Beam-Out]              ║
╚══════════════════════════════════════════════════════════════╝
```

**Post-Mission Report:**
(Already shown above in Resolution section)

### Balance & Progression

**Early Phase 2:**
- Simple away missions
- Low risk of death
- Tutorial-style introductions
- Build player confidence

**Mid Phase 2:**
- Complex missions
- Real risk of injury
- Strategic crew selection critical
- Permadeath optional but encouraged

**Late Phase 2:**
- High-stakes missions
- Multiple objectives
- Large away teams (4-6 members)
- Player expertise assumed

## Testing Checklist

- [ ] Team selection validates crew status
- [ ] Skill checks use correct crew member
- [ ] Injuries apply correct penalties
- [ ] Crew death (if enabled) handled properly
- [ ] Morale impacts work correctly
- [ ] Relationship bonuses/penalties apply
- [ ] Mission completion rewards distributed
- [ ] Save/load preserves away team state
- [ ] Emergency evacuation always available
- [ ] Crew synergies calculate correctly

## Implementation Timeline

**Phase 2, Weeks 5-8 (4 weeks)**

**Week 5:** Foundation
- Away team selection system
- Basic mission flow
- Skill check integration

**Week 6:** Core Mechanics
- Injury and death system
- Crew synergies
- Crisis scenarios

**Week 7:** Mission Content
- Multiple mission templates
- Variety in scenarios
- Unique encounters

**Week 8:** Polish & Balance
- UI refinement
- Difficulty balancing
- Permadeath testing

## Future Enhancements

1. **Equipment System** - Specialized away team gear
2. **Environmental Suits** - Different planet types need different suits
3. **Away Team Vehicles** - Rovers, shuttles, etc.
4. **Base Building** - Establish away team outposts
5. **Multi-Stage Missions** - Return to same location multiple times
6. **Crew Training** - Specialized away team training programs

## References

**Star Trek Episodes:**
- TNG "The Arsenal of Freedom" - Away team in danger
- TNG "Schisms" - Crew members affected by mission
- DS9 "The Ship" - Crew trapped, casualties
- VOY "Blink of an Eye" - Planetary survey with consequences

**Game Inspirations:**
- XCOM series - Squad selection, permadeath stakes
- Mass Effect - Character-driven away missions
- FTL - Crew management, tough decisions

---

**Next Steps:**
1. Approve design
2. Prototype crew selection system
3. Create mission template framework
4. Implement injury/death system
5. Design 5-10 varied missions
6. Extensive playtesting
