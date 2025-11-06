# Space Adventures - Resources & Survival Mechanics

**Version:** 1.0
**Date:** November 5, 2025
**Purpose:** Resource management and survival systems with multiple viable playstyles

---

## Table of Contents
1. [Overview](#overview)
2. [Resource Types](#resource-types)
3. [Time Management](#time-management)
4. [Multiple Playstyles](#multiple-playstyles)
5. [Concurrent Mission System](#concurrent-mission-system)
6. [Resource Acquisition](#resource-acquisition)
7. [Survival Challenges](#survival-challenges)
8. [Implementation](#implementation)

---

## Overview

### Design Philosophy

**Attainable, Not Punishing:**
- Resources add depth, not frustration
- Multiple paths to success (survival, missions, exploration)
- Never locked into one playstyle
- Failure is interesting, not game-ending

**Player Choice:**
- **Survivalist:** Focus on resource gathering and management
- **Missioner:** Complete objectives for guaranteed rewards
- **Explorer:** Discover new locations and opportunities
- **Hybrid:** Mix approaches as preferred

---

## Resource Types

### Primary Resources

#### 1. **Fuel (Deuterium)**
**Purpose:** Warp travel, power generation backup

```gdscript
var fuel: Dictionary = {
    "current": 100,
    "max": 200,
    "consumption_rate": 10,  # per warp jump
    "critical_threshold": 20
}
```

**Acquisition:**
- Complete missions (+20-50 fuel)
- Trade at stations (buy/sell)
- Scavenge fuel depots
- Extract from gas giants (Phase 2)

**Usage:**
- Warp travel (10-50 fuel per jump based on distance)
- Emergency power (5 fuel = 25 power units)
- Sell for credits

#### 2. **Credits**
**Purpose:** Universal currency for trading

```gdscript
var credits: int = 500  # Starting amount
```

**Acquisition:**
- Mission rewards (+50-500 credits)
- Sell resources/items
- Trade goods between stations
- Complete trade missions

**Usage:**
- Buy ship parts
- Buy resources (fuel, supplies)
- Repair services
- Crew wages (if implemented)

#### 3. **Supplies**
**Purpose:** Life support consumables

```gdscript
var supplies: Dictionary = {
    "food": 30,         # Days of food
    "water": 30,        # Days of water
    "oxygen": 30,       # Days of O2
    "medical": 10       # Medical kits
}
```

**Acquisition:**
- Buy at stations
- Scavenge locations
- Mission rewards
- Produce (if Life Support L4+)

**Usage:**
- Daily consumption (crew size dependent)
- Heal injuries (medical supplies)
- Trade commodity

#### 4. **Rare Materials**
**Purpose:** Craft/upgrade high-level ship parts

```gdscript
var rare_materials: Dictionary = {
    "titanium_alloy": 0,
    "antimatter_pods": 0,
    "quantum_crystals": 0,
    "exotic_matter": 0,
    "alien_artifacts": 0
}
```

**Acquisition:**
- Rare mission rewards
- Exploration discoveries
- Salvage advanced wrecks
- Trade (expensive)

**Usage:**
- Upgrade systems to L4-5
- Craft legendary parts
- Research projects
- Trade (very valuable)

### Secondary Resources

#### 5. **Repair Materials**
**Purpose:** Fix damaged systems

```gdscript
var repair_materials: Dictionary = {
    "metal_scrap": 50,
    "electronics": 20,
    "power_cells": 10
}
```

**Acquisition:**
- Salvage missions
- Buy at stations
- Dismantle unused parts

**Usage:**
- Repair systems (cost based on damage)
- Craft basic parts

#### 6. **Data**
**Purpose:** Information, intelligence, research

```gdscript
var data: Dictionary = {
    "scan_data": 0,        # From sensor scans
    "research_data": 0,    # Scientific discoveries
    "nav_data": 0,         # Star charts
    "intel": 0             # Faction information
}
```

**Acquisition:**
- Scan anomalies
- Complete science missions
- Explore new systems
- Trade/buy

**Usage:**
- Unlock new missions
- Sell for credits
- Research upgrades
- Trade with scientists

---

## Time Management

### Time System

**Time Unit:** Days
- 1 day = average mission duration OR travel time
- Player actions consume time
- Resources deplete daily
- Events occur on schedule

```gdscript
var game_time: Dictionary = {
    "days_elapsed": 0,
    "current_date": "2247-03-15",
    "time_pressure": false  # Story deadlines (optional)
}

func advance_time(days: int):
    game_time.days_elapsed += days

    # Consume supplies
    consume_daily_supplies(days)

    # Crew morale changes
    update_crew_morale(days)

    # Check for time-based events
    check_scheduled_events()

    # Mission deadlines
    check_mission_deadlines()
```

### Time Costs

**Actions that consume time:**
- **Missions:** 1-5 days (difficulty dependent)
- **Warp Travel:** 0.1-10 days (distance dependent)
- **Repairs:** 0.5-3 days (damage dependent)
- **Rest/Recovery:** 1-7 days
- **Shopping/Trading:** 0.1 days
- **Exploration:** 1-3 days

**Fast Forward:**
- Player can skip time if needed
- Useful for waiting for repairs/events
- Resources still consumed

```gdscript
func fast_forward(days: int, reason: String = "waiting"):
    if can_afford_time(days):
        advance_time(days)
        show_time_passage_summary(days, reason)
    else:
        show_error("Insufficient supplies to wait that long")
```

---

## Multiple Playstyles

### 1. Survivalist Playstyle

**Focus:** Resource management, scavenging, preparation

**Gameplay Loop:**
```
Scavenge Locations → Gather Resources →
Manage Supplies → Explore Carefully →
Build Reserves → Occasional Missions
```

**Strengths:**
- Always well-supplied
- Can survive anywhere
- Self-sufficient
- Good at finding hidden caches

**Challenges:**
- Slower progression
- Miss time-sensitive opportunities
- Less story engagement initially

**Resources Strategy:**
- Prioritize supply missions
- Explore every location thoroughly
- Trade resources for profit
- Install Life Support L4+ for production

### 2. Mission-Focused Playstyle

**Focus:** Complete objectives, earn rewards, progress story

**Gameplay Loop:**
```
Accept Mission → Complete Objectives →
Earn Rewards → Upgrade Ship →
Unlock New Missions → Repeat
```

**Strengths:**
- Faster progression
- Guaranteed rewards
- Strong story engagement
- Clear goals

**Challenges:**
- Resource management less forgiving
- Must complete missions successfully
- Time pressure from deadlines

**Resources Strategy:**
- Choose missions with supply rewards
- Buy resources at stations as needed
- Focus on mission efficiency
- Install systems that help mission success

### 3. Explorer Playstyle

**Focus:** Discovery, scanning, finding secrets

**Gameplay Loop:**
```
Explore New System → Scan Everything →
Find Anomalies → Discover Secrets →
Uncover Hidden Missions → Document
```

**Strengths:**
- Unique discoveries
- Unexpected rewards
- Unlock hidden content
- Rich lore experience

**Challenges:**
- Less predictable income
- Fuel-intensive
- Can get lost/sidetracked

**Resources Strategy:**
- Invest in high-level sensors
- Efficient warp drive
- Explore near stations for resupply
- Sell discovery data

### 4. Hybrid Approach (Recommended)

**Focus:** Balance all activities

**Gameplay Loop:**
```
Mission → Explore on Route → Scavenge →
Trade Resources → Next Mission →
Discover Secret → Follow Lead
```

**Strengths:**
- Most flexible
- Never bored
- Multiple income streams
- Complete experience

**Optimal Strategy:**
- Accept missions near exploration targets
- Scavenge while traveling
- Trade surplus resources
- Follow interesting leads

---

## Concurrent Mission System

### Multiple Active Missions (Post-MVP)

**Max Active Missions:** 3 simultaneous

**Design:**
- Player can have up to 3 missions active
- Different missions have different deadlines
- Can switch between missions freely
- Must manage time/resources across all

```gdscript
# godot/scripts/missions/mission_tracker.gd
extends Node

const MAX_ACTIVE_MISSIONS = 3

var active_missions: Array[Mission] = []
var available_missions: Array[Mission] = []

func can_accept_mission() -> bool:
    return len(active_missions) < MAX_ACTIVE_MISSIONS

func accept_mission(mission: Mission) -> bool:
    if not can_accept_mission():
        show_error("Maximum active missions reached (3/3)")
        return false

    active_missions.append(mission)
    mission.start_time = GameState.game_time.days_elapsed
    EventBus.emit_signal("mission_accepted", mission)
    return true

func abandon_mission(mission: Mission):
    active_missions.erase(mission)
    mission.state = Mission.State.ABANDONED

    # Reputation penalty
    apply_reputation_penalty(mission)

    EventBus.emit_signal("mission_abandoned", mission)

func check_deadlines():
    """Check if any missions have expired"""
    for mission in active_missions:
        if mission.has_deadline():
            var time_remaining = mission.get_time_remaining()
            if time_remaining <= 0:
                fail_mission(mission, "deadline_missed")
```

### Mission Tracker UI

```
┌──────────────────────────────────────────────────┐
│  ACTIVE MISSIONS (2/3)                           │
├──────────────────────────────────────────────────┤
│                                                  │
│  ▶ Echoes in Hangar 7                  [In Progress]
│    └─ Retrieve warp coil                       │
│    └─ Location: Kennedy Spaceport              │
│    └─ Deadline: 5 days remaining              │
│    └─ Reward: Warp Coil (Rare), 150 XP        │
│                                                  │
│  ⏸ The Rival's Challenge               [On Hold]
│    └─ Compete with Marcus for salvage         │
│    └─ Location: Military Base Delta            │
│    └─ Deadline: None                           │
│    └─ Reward: Rival's respect, Ship Part      │
│                                                  │
│  [Accept New Mission] [Abandon Mission]        │
└──────────────────────────────────────────────────┘
```

### Mission Interaction

**Missions can interact:**
- Information from one helps another
- NPCs appear in multiple missions
- Choices in one affect others
- Can discover connections

**Example:**
```
Mission A: Find research data at Station Alpha
Mission B: Trade with scientist at Station Beta

If you help the scientist in Mission B first, they'll tell you
exactly where the data is in Mission A (shortcut).
```

---

## Resource Acquisition

### Scavenging System

```gdscript
# godot/scripts/exploration/scavenge_location.gd
class_name ScavengeLocation
extends Node

var location_id: String
var location_name: String
var scavenged: bool = false
var respawn_time: int = 30  # days

var loot_table: Dictionary = {
    "fuel": {"min": 10, "max": 30, "chance": 0.7},
    "supplies": {"min": 5, "max": 15, "chance": 0.8},
    "credits": {"min": 50, "max": 200, "chance": 0.6},
    "parts": {"items": ["common_part_1", "uncommon_part_2"], "chance": 0.3},
    "data": {"amount": 5, "chance": 0.5}
}

func scavenge() -> Dictionary:
    """Scavenge this location for resources"""
    if scavenged and not has_respawned():
        return {"error": "Already scavenged"}

    var loot = generate_loot()
    scavenged = true
    scavenge_time = GameState.game_time.days_elapsed

    # Apply loot to inventory
    apply_loot(loot)

    # Time cost
    GameState.advance_time(1)

    return loot

func has_respawned() -> bool:
    var days_since = GameState.game_time.days_elapsed - scavenge_time
    return days_since >= respawn_time

func generate_loot() -> Dictionary:
    var loot = {}

    for resource_type in loot_table:
        var entry = loot_table[resource_type]
        if randf() < entry.get("chance", 1.0):
            if entry.has("min"):
                loot[resource_type] = randi_range(entry.min, entry.max)
            elif entry.has("items"):
                loot[resource_type] = entry.items[randi() % len(entry.items)]
            elif entry.has("amount"):
                loot[resource_type] = entry.amount

    return loot
```

### Trading System

```gdscript
# godot/scripts/economy/trading_station.gd
class_name TradingStation
extends Node

var station_id: String
var market_prices: Dictionary = {
    "fuel": 5,          # credits per unit
    "food": 10,
    "water": 8,
    "metal_scrap": 15,
    "electronics": 25,
    "titanium_alloy": 200
}

var price_variation: float = 0.2  # ±20% price variation

func get_buy_price(resource: String) -> int:
    """Price player pays to buy"""
    var base_price = market_prices.get(resource, 0)
    var variation = randf_range(1.0 - price_variation, 1.0 + price_variation)
    return int(base_price * variation)

func get_sell_price(resource: String) -> int:
    """Price station pays to buy from player"""
    return int(get_buy_price(resource) * 0.6)  # Sell for 60% of buy price

func buy_resource(resource: String, amount: int) -> bool:
    var cost = get_buy_price(resource) * amount

    if GameState.credits < cost:
        show_error("Insufficient credits")
        return false

    GameState.credits -= cost
    GameState.resources[resource] += amount
    return true

func sell_resource(resource: String, amount: int) -> bool:
    if GameState.resources.get(resource, 0) < amount:
        show_error("Insufficient " + resource)
        return false

    var payment = get_sell_price(resource) * amount
    GameState.resources[resource] -= amount
    GameState.credits += payment
    return true
```

---

## Survival Challenges

### Resource Depletion

```gdscript
func consume_daily_supplies(days: int):
    """Consume supplies for each day"""
    var crew_size = max(1, len(GameState.crew.members))

    # Base consumption per person per day
    var food_per_day = 1
    var water_per_day = 1
    var oxygen_per_day = 1

    # Reduced consumption with better life support
    var life_support_level = GameState.ship.systems.life_support.level
    var efficiency = 1.0 - (life_support_level * 0.1)  # 10% reduction per level

    # Total consumption
    var food_needed = int(days * crew_size * food_per_day * efficiency)
    var water_needed = int(days * crew_size * water_per_day * efficiency)
    var oxygen_needed = int(days * crew_size * oxygen_per_day * efficiency)

    # Deduct supplies
    GameState.supplies.food -= food_needed
    GameState.supplies.water -= water_needed
    GameState.supplies.oxygen -= oxygen_needed

    # Check for critical shortages
    check_supply_status()
```

### Supply Shortages

```gdscript
func check_supply_status():
    """Check for critical resource levels"""

    # Food shortage
    if GameState.supplies.food <= 0:
        trigger_starvation()
    elif GameState.supplies.food < 5:
        show_warning("Food critically low!")

    # Water shortage
    if GameState.supplies.water <= 0:
        trigger_dehydration()
    elif GameState.supplies.water < 5:
        show_warning("Water critically low!")

    # Oxygen shortage
    if GameState.supplies.oxygen <= 0:
        trigger_asphyxiation()
    elif GameState.supplies.oxygen < 5:
        show_warning("Oxygen critically low!")

    # Fuel shortage
    if GameState.fuel.current < GameState.fuel.critical_threshold:
        show_warning("Fuel low! May not reach next system!")

func trigger_starvation():
    """Handle food running out"""
    show_crisis("CRITICAL: Out of food!")

    # Crew morale plummets
    for crew in GameState.crew.members:
        crew.morale -= 30

    # Player must find solution immediately
    trigger_emergency_event("starvation")

func trigger_emergency_event(crisis_type: String):
    """Force player to deal with crisis"""
    var emergency = EmergencyDialog.new()
    emergency.setup(crisis_type)
    emergency.show_modal()
```

### Emergency Solutions

```gdscript
func handle_supply_emergency(crisis: String) -> Dictionary:
    """Options when supplies critical"""

    var options = []

    # Can we reach a station?
    var nearest_station = find_nearest_station()
    if nearest_station and can_reach_station(nearest_station):
        options.append({
            "id": "reach_station",
            "text": "Divert to %s (%.1f days)" % [nearest_station.name, calculate_travel_time(nearest_station)],
            "feasible": true
        })

    # Can we scavenge locally?
    var scavenge_sites = find_nearby_scavenge_sites()
    if len(scavenge_sites) > 0:
        options.append({
            "id": "scavenge",
            "text": "Search nearby locations for supplies",
            "feasible": true
        })

    # Distress call (if comms available)
    if GameState.ship.systems.communications.level >= 2:
        options.append({
            "id": "distress",
            "text": "Send distress call (may attract help... or pirates)",
            "feasible": true,
            "risky": true
        })

    # Desperate measures
    options.append({
        "id": "ration",
        "text": "Strict rationing (crew morale suffers)",
        "feasible": true,
        "consequence": "morale_loss"
    })

    return {"crisis": crisis, "options": options}
```

---

## Implementation

### Resource Manager Singleton

```gdscript
# godot/scripts/autoload/resource_manager.gd
extends Node

signal resource_changed(resource_type: String, amount: int, delta: int)
signal resource_critical(resource_type: String, amount: int)
signal resource_depleted(resource_type: String)

var resources: Dictionary = {
    "fuel": 100,
    "credits": 500,
    "food": 30,
    "water": 30,
    "oxygen": 30,
    "medical": 10,
    "metal_scrap": 50,
    "electronics": 20,
    "power_cells": 10
}

var resource_max: Dictionary = {
    "fuel": 200,
    "food": 90,
    "water": 90,
    "oxygen": 90,
    "medical": 50
}

func add_resource(resource_type: String, amount: int):
    var old_amount = resources.get(resource_type, 0)
    var max_amount = resource_max.get(resource_type, INF)

    resources[resource_type] = min(old_amount + amount, max_amount)
    var actual_delta = resources[resource_type] - old_amount

    emit_signal("resource_changed", resource_type, resources[resource_type], actual_delta)

func remove_resource(resource_type: String, amount: int) -> bool:
    var current = resources.get(resource_type, 0)

    if current < amount:
        return false  # Not enough

    resources[resource_type] -= amount
    emit_signal("resource_changed", resource_type, resources[resource_type], -amount)

    # Check if critical
    if is_critical(resource_type, resources[resource_type]):
        emit_signal("resource_critical", resource_type, resources[resource_type])

    # Check if depleted
    if resources[resource_type] <= 0:
        emit_signal("resource_depleted", resource_type)

    return true

func has_resource(resource_type: String, amount: int) -> bool:
    return resources.get(resource_type, 0) >= amount

func is_critical(resource_type: String, amount: int) -> bool:
    var critical_thresholds = {
        "fuel": 20,
        "food": 5,
        "water": 5,
        "oxygen": 5
    }
    return amount < critical_thresholds.get(resource_type, 0)
```

---

**Document Status:** Complete v1.0
**Last Updated:** November 5, 2025
