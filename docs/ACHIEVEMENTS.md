# Achievement System Documentation

## Overview

The Space Adventures achievement system tracks player accomplishments throughout the game. Achievements unlock automatically based on gameplay milestones and persist across save/load cycles.

**Key Features:**
- 15 achievements tracking major milestones
- Auto-unlock on gameplay events
- EventBus signal integration for UI notifications
- Full save/load support
- Extensible architecture for adding new achievements

## Architecture

### Components

1. **GameState.gd** - Core achievement logic
   - `ACHIEVEMENTS` constant - Achievement definitions
   - `player.achievements` - Player's achievement progress
   - Unlock/query functions
   - Auto-unlock check functions

2. **EventBus.gd** - Signal system
   - `achievement_unlocked(achievement_id, achievement_data)` signal
   - Allows UI and other systems to react to unlocks

3. **Save System** - Persistence
   - Achievements automatically saved with game state
   - Migration support for adding new achievements to old saves

## Achievement List

### Progression Achievements
| ID | Name | Description | Unlock Condition |
|---|---|---|---|
| `first_mission` | First Steps | Complete your first mission | Complete 1 mission |
| `five_missions` | Mission Runner | Complete 5 missions | Complete 5 missions |
| `ten_missions` | Mission Master | Complete 10 missions | Complete 10 missions |
| `level_3` | Rising Star | Reach level 3 | Player level ≥ 3 |
| `level_5` | Experienced Explorer | Reach level 5 | Player level ≥ 5 |
| `level_10` | Veteran Commander | Reach level 10 | Player level ≥ 10 |

### Ship System Achievements
| ID | Name | Description | Unlock Condition |
|---|---|---|---|
| `first_upgrade` | Engineer's Touch | Upgrade your first ship system | Install any system at level 1+ |
| `ten_systems` | Complete Ship | Unlock all 10 ship systems | All 10 systems at level 1+ |
| `all_systems_level_1` | Launch Ready | Bring all ship systems to Level 1 | All 10 systems exactly at level 1 |

### Economy Achievements
| ID | Name | Description | Unlock Condition |
|---|---|---|---|
| `credits_1000` | Entrepreneur | Collect 1000 credits | Total credits ≥ 1000 |
| `credits_5000` | Wealthy Trader | Collect 5000 credits | Total credits ≥ 5000 |

### Skill Achievements
| ID | Name | Description | Unlock Condition |
|---|---|---|---|
| `skill_master` | Skill Master | Raise any skill to level 10 | Any skill ≥ 10 |
| `ten_successful_checks` | Lucky Streak | Successfully pass 10 skill checks | 10+ successful skill checks |

### Discovery Achievements
| ID | Name | Description | Unlock Condition |
|---|---|---|---|
| `ten_parts` | Scavenger | Discover 10 different ship parts | 10+ parts discovered |
| `twenty_parts` | Master Scavenger | Discover 20 different ship parts | 20+ parts discovered |

## Usage

### For Developers

#### Checking if Achievement is Unlocked

```gdscript
if GameState.is_achievement_unlocked("first_mission"):
    print("Player has completed their first mission!")
```

#### Manually Unlocking Achievement

```gdscript
# Unlock an achievement (returns true if newly unlocked, false if already unlocked)
var newly_unlocked = GameState.unlock_achievement("custom_achievement")
if newly_unlocked:
    print("Achievement unlocked!")
```

#### Getting Achievement Progress

```gdscript
var progress = GameState.get_achievement_progress()
print("Unlocked %d / %d achievements (%.1f%%)" % [
    progress.unlocked,
    progress.total,
    progress.percentage
])
```

#### Getting All Achievements

```gdscript
var all_achievements = GameState.get_all_achievements()
for achievement in all_achievements:
    print("%s: %s - %s (Unlocked: %s)" % [
        achievement.id,
        achievement.name,
        achievement.description,
        "Yes" if achievement.unlocked else "No"
    ])
```

#### Getting Only Unlocked Achievements

```gdscript
var unlocked = GameState.get_unlocked_achievements()
print("You have unlocked %d achievements:" % unlocked.size())
for achievement in unlocked:
    print("  - %s" % achievement.name)
```

#### Listening for Achievement Unlocks

```gdscript
func _ready():
    EventBus.achievement_unlocked.connect(_on_achievement_unlocked)

func _on_achievement_unlocked(achievement_id: String, achievement_data: Dictionary):
    # Show achievement notification UI
    show_achievement_notification(
        achievement_data.name,
        achievement_data.description
    )
```

#### Recording Skill Check Success

When a player successfully passes a skill check in a mission:

```gdscript
# In mission system when player succeeds at a skill check
GameState.record_skill_check_success()
```

### Auto-Unlock Triggers

Achievements automatically unlock when conditions are met. The following game events trigger achievement checks:

| Event | Function | Checked Achievements |
|---|---|---|
| Player levels up | `add_xp()` | Level achievements |
| Credits added | `add_credits()` | Credit achievements |
| Mission completed | `complete_mission()` | Mission achievements |
| System installed | `install_system()` | System achievements |
| Skill increased | `increase_skill()` | Skill achievements |
| Part discovered | `EventBus.part_discovered` | Discovery achievements |
| Skill check passed | `record_skill_check_success()` | Skill check achievements |

## Data Structure

### Achievement Definition (in ACHIEVEMENTS constant)

```gdscript
const ACHIEVEMENTS = {
    "achievement_id": {
        "name": "Achievement Name",
        "description": "Achievement description",
        "hidden": false  # If true, don't show until unlocked
    }
}
```

### Player Achievement Data (in player.achievements)

```gdscript
player.achievements = {
    "achievement_id": {
        "id": "achievement_id",
        "name": "Achievement Name",
        "description": "Achievement description",
        "hidden": false,
        "unlocked": false,        # true when unlocked
        "unlocked_at": 0.0        # Unix timestamp of unlock
    }
}
```

## Adding New Achievements

### Step 1: Define Achievement

Add to `ACHIEVEMENTS` constant in `GameState.gd`:

```gdscript
const ACHIEVEMENTS: Dictionary = {
    # ... existing achievements ...
    "my_new_achievement": {
        "name": "Achievement Name",
        "description": "What the player accomplished",
        "hidden": false
    }
}
```

### Step 2: Create Check Function

Add a check function in GameState.gd:

```gdscript
func _check_my_custom_achievements() -> void:
    # Check condition
    if some_condition:
        unlock_achievement("my_new_achievement")
```

### Step 3: Trigger Check

Call check function when appropriate event occurs:

```gdscript
func some_game_event():
    # ... do something ...

    # Check for achievements
    _check_my_custom_achievements()
```

### Step 4: Test

1. Trigger the unlock condition in game
2. Verify console shows: "Achievement unlocked: ..."
3. Check `GameState.is_achievement_unlocked("my_new_achievement")`
4. Save and reload - verify achievement persists

## Testing

### Manual Testing

1. Run game in Godot editor
2. Trigger achievement conditions:
   - Complete a mission → `first_mission`
   - Level up to 3 → `level_3`
   - Install a system → `first_upgrade`
   - Etc.
3. Watch console for unlock messages
4. Save game
5. Reload game
6. Verify achievements still unlocked

### Automated Testing

Run the test script:

```bash
# In Godot editor
# 1. Open scenes/test_achievements.tscn
# 2. Press F6 to run scene
# 3. Watch console output for test results
```

Or use the test script directly (requires running as part of a scene):

```gdscript
# scripts/test_achievements.gd
# Tests all achievement functionality
```

## Save/Load Integration

Achievements are automatically included in save files:

```gdscript
# Saving
var save_data = GameState.to_dict()
# save_data.player.achievements contains all achievement data

# Loading
GameState.from_dict(save_data)
# Achievements restored from save
```

### Migration Support

When new achievements are added to the game:

1. Old saves automatically get new achievements (locked state)
2. `_initialize_achievements()` adds missing achievements
3. Existing unlocked achievements remain unlocked

## Performance Considerations

- Achievement checks are lightweight (simple conditionals)
- Checks only run when relevant events occur
- No polling or frame-by-frame checks
- Unlocked achievements emit signal once only

## Future Enhancements

Potential future additions (not currently implemented):

- **Hidden achievements** - Use `"hidden": true` in definition
- **Achievement rewards** - Bonus credits, items, etc.
- **Steam/Platform integration** - Sync with external platforms
- **Achievement UI** - Dedicated achievements screen
- **Progress tracking** - Track partial progress (e.g., 3/10 missions)
- **Rare achievements** - Statistical rarity based on player data

## Troubleshooting

### Achievement not unlocking

1. Check condition is actually met:
   ```gdscript
   print("Credits: ", GameState.player.credits)  # Should be >= 1000 for credits_1000
   ```

2. Verify check function is called:
   ```gdscript
   func _check_credit_achievements():
       print("Checking credit achievements...")  # Add debug print
   ```

3. Check achievement ID is correct:
   ```gdscript
   GameState.unlock_achievement("credits_1000")  # Correct
   GameState.unlock_achievement("1000_credits")  # Wrong - won't work
   ```

### Achievement unlocks multiple times

This is prevented by `unlock_achievement()`:

```gdscript
func unlock_achievement(achievement_id: String) -> bool:
    # ...
    if achievement.unlocked:
        return false  # Already unlocked, don't unlock again
    # ...
```

### Achievement not persisting

Verify save/load is working:

```gdscript
# After unlocking achievement
SaveManager.save_game(1)

# After reload
SaveManager.load_game(1)
print("Achievement still unlocked: ", GameState.is_achievement_unlocked("first_mission"))
```

### Signal not firing

Connect to signal in `_ready()`:

```gdscript
func _ready():
    EventBus.achievement_unlocked.connect(_on_achievement_unlocked)

func _on_achievement_unlocked(achievement_id: String, achievement_data: Dictionary):
    print("Achievement signal received: ", achievement_id)
```

## Code Reference

**Main Files:**
- `/godot/scripts/autoload/game_state.gd` - Achievement system implementation
- `/godot/scripts/autoload/event_bus.gd` - Achievement signal definition
- `/godot/scripts/test_achievements.gd` - Comprehensive test suite
- `/docs/ACHIEVEMENTS.md` - This documentation

**Key Functions:**
- `GameState.unlock_achievement(achievement_id)` - Unlock achievement
- `GameState.is_achievement_unlocked(achievement_id)` - Check unlock status
- `GameState.get_achievement_progress()` - Get progress summary
- `GameState.get_all_achievements()` - Get all achievements
- `GameState.get_unlocked_achievements()` - Get unlocked only
- `GameState.record_skill_check_success()` - Track skill check success

**Signals:**
- `EventBus.achievement_unlocked(achievement_id, achievement_data)` - Achievement unlocked

---

**Last Updated:** 2025-11-07
**Version:** 1.0.0
