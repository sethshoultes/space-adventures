# Achievements Quick Reference

## 15 Achievements Implemented

### API Functions

```gdscript
# Unlock achievement (returns true if newly unlocked)
GameState.unlock_achievement("achievement_id")

# Check if unlocked
GameState.is_achievement_unlocked("achievement_id")

# Get progress summary
var progress = GameState.get_achievement_progress()
# Returns: {total: 15, unlocked: 5, percentage: 33.3, achievements: [...]}

# Get all achievements
var all = GameState.get_all_achievements()

# Get only unlocked
var unlocked = GameState.get_unlocked_achievements()

# Track skill check success
GameState.record_skill_check_success()
```

### Listen for Unlocks

```gdscript
func _ready():
    EventBus.achievement_unlocked.connect(_on_achievement_unlocked)

func _on_achievement_unlocked(achievement_id: String, data: Dictionary):
    print("Unlocked: %s" % data.name)
```

## All Achievements

| ID | Trigger |
|---|---|
| `first_mission` | Complete 1 mission |
| `five_missions` | Complete 5 missions |
| `ten_missions` | Complete 10 missions |
| `level_3` | Reach level 3 |
| `level_5` | Reach level 5 |
| `level_10` | Reach level 10 |
| `first_upgrade` | Install first system |
| `ten_systems` | Install all 10 systems |
| `all_systems_level_1` | All systems at level 1 |
| `credits_1000` | Collect 1000 credits |
| `credits_5000` | Collect 5000 credits |
| `skill_master` | Any skill at level 10 |
| `ten_successful_checks` | Pass 10 skill checks |
| `ten_parts` | Discover 10 parts |
| `twenty_parts` | Discover 20 parts |

## Auto-Unlock Triggers

- `add_xp()` → level achievements
- `add_credits()` → credit achievements
- `complete_mission()` → mission achievements
- `install_system()` → system achievements
- `increase_skill()` → skill achievements
- `record_skill_check_success()` → skill check achievements
- `EventBus.part_discovered` signal → discovery achievements

## Files

- Implementation: `godot/scripts/autoload/game_state.gd`
- Signal: `godot/scripts/autoload/event_bus.gd`
- Tests: `godot/scripts/test_achievements.gd`
- Docs: `docs/ACHIEVEMENTS.md`
