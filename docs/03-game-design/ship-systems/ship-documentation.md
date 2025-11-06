# Space Adventures - AI-Generated Ship Documentation System

**Version:** 1.0
**Date:** November 5, 2025
**Purpose:** Complete ship manual generation system with concurrent AI processing

---

## Table of Contents
1. [Overview](#overview)
2. [Ship Manual Structure](#ship-manual-structure)
3. [Content Generation System](#content-generation-system)
4. [Multi-Process Task Queue](#multi-process-task-queue)
5. [Update Triggers & Versioning](#update-triggers--versioning)
6. [Manual Content Types](#manual-content-types)
7. [Example Manual Entries](#example-manual-entries)
8. [Export & Viewing](#export--viewing)
9. [Implementation](#implementation)

---

## Overview

### Design Philosophy

**Living Documentation:**
- Ship manual updates automatically as player builds ship
- Each system installation generates comprehensive documentation
- Multiple AI processes work concurrently to avoid blocking gameplay
- Documentation evolves with ship upgrades and player choices

**Core Principles:**
- **Non-blocking** - Documentation generation never interrupts gameplay
- **Progressive** - Manual grows as ship is built
- **Contextual** - Documentation reflects player's specific ship configuration
- **Immersive** - Written in-universe, Star Trek style
- **Practical** - Includes specs, procedures, safety warnings, and lore

### Purpose

The ship manual serves multiple roles:
1. **Reference Guide** - Technical specs and capabilities
2. **Tutorial** - How to use systems effectively
3. **World-Building** - In-universe lore and flavor
4. **Achievement Log** - Record of player's ship-building journey

---

## Ship Manual Structure

### Manual Organization

```
┌─────────────────────────────────────────────────┐
│ SHIP TECHNICAL MANUAL                           │
│ ───────────────────────────────────────────────│
│                                                 │
│ ◆ SHIP OVERVIEW                                │
│   - Ship Name & Classification                 │
│   - Build History Timeline                     │
│   - Current Configuration Summary              │
│                                                 │
│ ◆ SYSTEM DOCUMENTATION (10 sections)           │
│   1. Hull & Structure                          │
│   2. Power Core (Reactor)                      │
│   3. Propulsion (Impulse Engines)              │
│   4. Warp Drive                                │
│   5. Life Support                              │
│   6. Computer Core                             │
│   7. Sensors                                   │
│   8. Shields                                   │
│   9. Weapons                                   │
│   10. Communication Array                      │
│                                                 │
│ ◆ OPERATIONAL PROCEDURES                       │
│   - Startup/Shutdown Sequences                 │
│   - Emergency Protocols                        │
│   - Maintenance Schedules                      │
│                                                 │
│ ◆ MISSION LOGS (Player-specific)               │
│   - Significant mission records                │
│   - Notable events and discoveries             │
│                                                 │
│ ◆ APPENDICES                                   │
│   - Glossary                                   │
│   - Part Compatibility Matrix                  │
│   - Troubleshooting Guide                      │
│                                                 │
└─────────────────────────────────────────────────┘
```

### System Documentation Template

Each of the 10 ship systems follows this structure:

```markdown
## [SYSTEM NAME] - Level [N]

### SYSTEM OVERVIEW
[AI-generated description of what this system does, its importance]

### TECHNICAL SPECIFICATIONS
- **System Level:** [0-5]
- **Power Consumption:** [X] MW
- **Mass:** [X] metric tons
- **Installed Part:** [Part name and rarity]
- **Health Status:** [X]/100
- **Efficiency Rating:** [X]%

### CAPABILITIES
[AI-generated list of what this system enables]
- At Current Level: [capabilities]
- Next Level Unlock: [future capabilities]

### OPERATING PROCEDURES

#### Normal Operations
[Step-by-step AI-generated procedures]
1. [Procedure step]
2. [Procedure step]

#### Emergency Procedures
[AI-generated emergency protocols]
⚠️ WARNING: [Safety considerations]

### MAINTENANCE & TROUBLESHOOTING

#### Routine Maintenance
[AI-generated maintenance schedule]

#### Common Issues
| Symptom | Probable Cause | Solution |
|---------|---------------|----------|
| [Issue] | [Cause]       | [Fix]    |

### LORE & BACKGROUND
[AI-generated in-universe flavor text about this type of system]

### UPGRADE HISTORY
- **[Date]:** Installed [Part Name] (Level 0 → 1)
- **[Date]:** Upgraded to [Part Name] (Level 1 → 2)
```

---

## Content Generation System

### AI Task Types for Documentation

```python
class DocTaskType(str, Enum):
    SYSTEM_OVERVIEW = "system_overview"
    TECHNICAL_SPECS = "technical_specs"
    CAPABILITIES = "capabilities"
    OPERATING_PROCEDURES = "operating_procedures"
    EMERGENCY_PROTOCOLS = "emergency_protocols"
    MAINTENANCE_GUIDE = "maintenance_guide"
    TROUBLESHOOTING = "troubleshooting"
    LORE_FLAVOR = "lore_flavor"
    SHIP_OVERVIEW = "ship_overview"
    MISSION_LOG_ENTRY = "mission_log_entry"
```

### Documentation Generation Prompts

#### System Overview Prompt

```python
SYSTEM_OVERVIEW_PROMPT = """
Generate a ship system overview for a space adventure game ship manual.

CONTEXT:
- System Name: {system_name}
- System Level: {level} (0-5 scale, 0 = not installed)
- Installed Part: {part_name} ({rarity})
- Ship Name: {ship_name}
- Player's Build Progress: {systems_installed}/10 systems installed

TONE: Star Trek TNG technical manual - serious, professional, but accessible

Generate a 2-3 paragraph overview that explains:
1. What this system does and why it's critical to the ship
2. How this specific part/level performs relative to standard configurations
3. Brief mention of how it integrates with other ship systems

TECHNICAL DETAILS TO INCLUDE:
{technical_context}

Write in the voice of a ship's computer or technical manual, second person ("your ship's X system...").
"""

TECHNICAL_CONTEXT = {
    "hull": "structural integrity, compartmentalization, armor rating, total HP pool",
    "power": "energy generation capacity, reactor stability, power distribution efficiency",
    "propulsion": "sub-light velocity, acceleration, maneuverability, fuel efficiency",
    "warp": "maximum warp factor, range per fuel unit, jump calculation time",
    # ... for all 10 systems
}
```

#### Operating Procedures Prompt

```python
OPERATING_PROCEDURES_PROMPT = """
Generate standard operating procedures for a ship system.

SYSTEM: {system_name} (Level {level})
SHIP CONFIGURATION: {ship_context}

Create two sections:

1. NORMAL OPERATIONS (4-6 numbered steps)
   - Pre-activation checks
   - Startup sequence
   - Normal operation monitoring
   - Shutdown procedure

2. EMERGENCY PROCEDURES (3-5 numbered steps)
   - When to use emergency protocols
   - Emergency shutdown
   - Backup system activation
   - Safety considerations

TONE: Clear, directive, professional. Like a real spacecraft operations manual.
FORMAT: Numbered steps, use ⚠️ for warnings, ✓ for confirmations.
"""
```

#### Lore & Flavor Prompt

```python
LORE_FLAVOR_PROMPT = """
Generate in-universe lore and flavor text for a ship system.

SYSTEM: {system_name}
ERA: Post-Exodus Earth, ~2287
PART: {part_name} ({rarity})

Write 2-3 paragraphs covering:
1. History of this type of system (who developed it, when, why)
2. How this specific part/manufacturer is regarded in the post-Exodus world
3. Interesting technical detail or anecdote about this system

CONTEXT:
- Humanity evacuated Earth decades ago
- Player is scavenging Earth for pre-Exodus tech
- Tech is mix of salvaged, jury-rigged, and rare pristine equipment

TONE: Star Trek meets Firefly - serious sci-fi with hints of resourcefulness and wonder.
AVOID: Over-explaining, breaking fourth wall, game mechanics talk.
"""
```

#### Troubleshooting Guide Prompt

```python
TROUBLESHOOTING_PROMPT = """
Generate a troubleshooting table for a ship system.

SYSTEM: {system_name} (Level {level})
CURRENT HEALTH: {health}/100
INSTALLED PART: {part_name}

Create a table with 5-7 common issues:

| Symptom | Probable Cause | Solution |
|---------|---------------|----------|

Each issue should be:
- Realistic for this system type
- Progressively more serious (minor → critical)
- Specific to the current level and part
- Include both technical and player-actionable solutions

EXAMPLES:
- "Fluctuating power readings" → "Loose connection in power relay" → "Recalibrate power coupling from Engineering console"
- "Reactor temperature critical" → "Coolant leak in primary loop" → "Emergency shutdown, repair coolant system"

FORMAT: Markdown table, technical but accessible language.
"""
```

### Generation Workflow

```python
async def generate_system_documentation(
    system_name: str,
    level: int,
    part: Dict[str, Any],
    ship_state: Dict[str, Any],
    settings: Dict[str, Any]
) -> SystemDocumentation:
    """
    Generate complete documentation for a ship system.
    Uses task queue to parallelize AI generation.
    """

    # Create all documentation tasks
    tasks = [
        DocTask(
            task_type=DocTaskType.SYSTEM_OVERVIEW,
            priority=TaskPriority.NORMAL,
            system_name=system_name,
            context={"level": level, "part": part, "ship": ship_state}
        ),
        DocTask(
            task_type=DocTaskType.CAPABILITIES,
            priority=TaskPriority.NORMAL,
            system_name=system_name,
            context={"level": level, "part": part}
        ),
        DocTask(
            task_type=DocTaskType.OPERATING_PROCEDURES,
            priority=TaskPriority.LOW,
            system_name=system_name,
            context={"level": level, "ship": ship_state}
        ),
        DocTask(
            task_type=DocTaskType.LORE_FLAVOR,
            priority=TaskPriority.LOW,
            system_name=system_name,
            context={"part": part}
        ),
        DocTask(
            task_type=DocTaskType.TROUBLESHOOTING,
            priority=TaskPriority.LOW,
            system_name=system_name,
            context={"level": level, "health": 100, "part": part}
        )
    ]

    # Submit all tasks to queue (will run concurrently)
    task_ids = [await task_queue.submit(task) for task in tasks]

    # Gather results (non-blocking if using background processing)
    results = await task_queue.gather(task_ids)

    # Assemble complete documentation
    return SystemDocumentation(
        system_name=system_name,
        level=level,
        overview=results[0],
        capabilities=results[1],
        procedures=results[2],
        lore=results[3],
        troubleshooting=results[4],
        technical_specs=_generate_specs_from_data(level, part),
        generated_at=datetime.now()
    )
```

---

## Multi-Process Task Queue

### Task Queue Architecture

**Purpose:** Manage multiple concurrent AI generation tasks without blocking gameplay

```python
# python/src/ai/task_queue.py

from enum import Enum
from dataclasses import dataclass
from typing import Optional, List, Callable, Any
import asyncio
from queue import PriorityQueue
import uuid

class TaskPriority(int, Enum):
    CRITICAL = 0   # Gameplay-blocking (rare)
    HIGH = 1       # User-requested, visible
    NORMAL = 2     # Auto-updates, background
    LOW = 3        # Pre-generation, optimization

class TaskStatus(str, Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"

@dataclass
class AITask:
    task_id: str
    task_type: str  # DocTaskType, MissionTaskType, etc.
    priority: TaskPriority
    context: dict
    created_at: float

    status: TaskStatus = TaskStatus.PENDING
    result: Optional[Any] = None
    error: Optional[str] = None
    started_at: Optional[float] = None
    completed_at: Optional[float] = None

    def __lt__(self, other):
        """For priority queue comparison"""
        # Lower priority number = higher priority
        if self.priority != other.priority:
            return self.priority < other.priority
        # Same priority: FIFO
        return self.created_at < other.created_at

class AITaskQueue:
    def __init__(self, max_workers: int = 2):
        self.max_workers = max_workers
        self.queue = PriorityQueue()
        self.tasks: dict[str, AITask] = {}
        self.active_tasks: set[str] = set()
        self.workers: List[asyncio.Task] = []
        self.running = False

    async def start(self):
        """Start worker processes"""
        self.running = True
        self.workers = [
            asyncio.create_task(self._worker(i))
            for i in range(self.max_workers)
        ]

    async def stop(self):
        """Stop all workers"""
        self.running = False
        await asyncio.gather(*self.workers, return_exceptions=True)

    async def submit(self, task: AITask) -> str:
        """Submit a task to the queue"""
        task.task_id = str(uuid.uuid4())
        task.created_at = asyncio.get_event_loop().time()

        self.tasks[task.task_id] = task
        self.queue.put(task)

        return task.task_id

    async def _worker(self, worker_id: int):
        """Worker coroutine that processes tasks"""
        while self.running:
            try:
                # Get next task (blocks if queue empty)
                task = await asyncio.to_thread(self.queue.get, timeout=1.0)

                if task is None:
                    continue

                # Process task
                await self._process_task(task, worker_id)

            except Exception as e:
                print(f"Worker {worker_id} error: {e}")
                await asyncio.sleep(1)

    async def _process_task(self, task: AITask, worker_id: int):
        """Process a single task"""
        task.status = TaskStatus.RUNNING
        task.started_at = asyncio.get_event_loop().time()
        self.active_tasks.add(task.task_id)

        try:
            # Route to appropriate generator
            if task.task_type.startswith("doc_"):
                result = await self._generate_documentation(task)
            elif task.task_type.startswith("mission_"):
                result = await self._generate_mission_content(task)
            else:
                raise ValueError(f"Unknown task type: {task.task_type}")

            task.result = result
            task.status = TaskStatus.COMPLETED

        except Exception as e:
            task.error = str(e)
            task.status = TaskStatus.FAILED
            print(f"Task {task.task_id} failed: {e}")

        finally:
            task.completed_at = asyncio.get_event_loop().time()
            self.active_tasks.remove(task.task_id)

    async def _generate_documentation(self, task: AITask) -> str:
        """Generate documentation content"""
        from .multi_provider import MultiProviderAIClient
        from .doc_prompts import get_prompt_for_task

        # Get appropriate AI provider (usually quick_provider for docs)
        client = MultiProviderAIClient(self.settings)

        # Build prompt
        prompt = get_prompt_for_task(task.task_type, task.context)

        # Generate content
        result = await client.generate(
            task_type=AITaskType.SHIP_DOCUMENTATION,
            prompt=prompt,
            max_tokens=1000
        )

        return result

    async def get_task_status(self, task_id: str) -> Optional[AITask]:
        """Get current task status"""
        return self.tasks.get(task_id)

    async def wait_for_task(self, task_id: str, timeout: Optional[float] = None) -> Any:
        """Wait for a specific task to complete"""
        start_time = asyncio.get_event_loop().time()

        while True:
            task = self.tasks.get(task_id)

            if not task:
                raise ValueError(f"Task {task_id} not found")

            if task.status == TaskStatus.COMPLETED:
                return task.result

            if task.status == TaskStatus.FAILED:
                raise Exception(f"Task failed: {task.error}")

            if timeout and (asyncio.get_event_loop().time() - start_time) > timeout:
                raise asyncio.TimeoutError(f"Task {task_id} timed out")

            await asyncio.sleep(0.1)

    async def gather(self, task_ids: List[str], timeout: Optional[float] = None) -> List[Any]:
        """Wait for multiple tasks to complete"""
        results = []
        for task_id in task_ids:
            result = await self.wait_for_task(task_id, timeout)
            results.append(result)
        return results

    def get_queue_stats(self) -> dict:
        """Get current queue statistics"""
        pending = sum(1 for t in self.tasks.values() if t.status == TaskStatus.PENDING)
        running = len(self.active_tasks)
        completed = sum(1 for t in self.tasks.values() if t.status == TaskStatus.COMPLETED)
        failed = sum(1 for t in self.tasks.values() if t.status == TaskStatus.FAILED)

        return {
            "pending": pending,
            "running": running,
            "completed": completed,
            "failed": failed,
            "total": len(self.tasks),
            "workers": self.max_workers
        }
```

### Task Queue Configuration

**From settings.json:**
```json
{
  "performance": {
    "max_parallel_tasks": 2,
    "auto_prioritize_gameplay": true,
    "background_processing": true,
    "task_timeout_seconds": 60
  },
  "advanced": {
    "auto_update_ship_manual": true,
    "manual_update_trigger": "on_system_install"
  }
}
```

**Task Priorities:**
- **CRITICAL (0)** - Gameplay-blocking content (extremely rare, avoid if possible)
- **HIGH (1)** - User explicitly requested documentation, visible in UI
- **NORMAL (2)** - Auto-updates when system installed/upgraded
- **LOW (3)** - Pre-generation, background optimization

---

## Update Triggers & Versioning

### When Documentation Updates

```python
class DocUpdateTrigger(str, Enum):
    ON_SYSTEM_INSTALL = "on_system_install"        # Immediate
    ON_SYSTEM_UPGRADE = "on_system_upgrade"        # Immediate
    ON_DAMAGE = "on_damage"                        # When system health changes
    MILESTONE = "milestone"                        # Major ship milestones
    MANUAL_REQUEST = "manual_request"              # Player opens manual
    IDLE_BACKGROUND = "idle_background"            # Pre-generate when idle
```

### Trigger Configuration

**From Settings:**
```python
UPDATE_TRIGGERS = {
    "on_system_install": {
        "enabled": True,
        "priority": TaskPriority.NORMAL,
        "sections": ["overview", "specs", "capabilities", "procedures", "lore"],
        "delay_seconds": 0  # Immediate
    },
    "on_system_upgrade": {
        "enabled": True,
        "priority": TaskPriority.NORMAL,
        "sections": ["overview", "specs", "capabilities"],
        "delay_seconds": 0
    },
    "on_damage": {
        "enabled": True,
        "priority": TaskPriority.LOW,
        "sections": ["troubleshooting"],
        "delay_seconds": 30  # Batch updates
    },
    "milestone": {
        "enabled": True,
        "priority": TaskPriority.HIGH,
        "sections": ["ship_overview", "mission_logs"],
        "delay_seconds": 0
    }
}
```

### Versioning System

Each documentation entry is versioned:

```python
@dataclass
class DocumentationVersion:
    version: str  # "1.0.0"
    system_name: str
    level: int
    part_id: str
    generated_at: datetime
    trigger: DocUpdateTrigger

    # Content
    overview: str
    capabilities: str
    procedures: str
    lore: str
    troubleshooting: str

    # Metadata
    ai_provider: str  # Which AI generated this
    generation_time_seconds: float
    token_count: int

class ShipManual:
    def __init__(self):
        self.versions: dict[str, List[DocumentationVersion]] = {}
        self.current_version: dict[str, str] = {}  # system -> version

    def add_version(self, doc: DocumentationVersion):
        """Add new documentation version"""
        if doc.system_name not in self.versions:
            self.versions[doc.system_name] = []

        self.versions[doc.system_name].append(doc)
        self.current_version[doc.system_name] = doc.version

    def get_current(self, system_name: str) -> Optional[DocumentationVersion]:
        """Get current version of system documentation"""
        if system_name not in self.versions:
            return None

        version = self.current_version.get(system_name)
        for doc in self.versions[system_name]:
            if doc.version == version:
                return doc
        return None

    def get_history(self, system_name: str) -> List[DocumentationVersion]:
        """Get all versions for a system (changelog)"""
        return self.versions.get(system_name, [])
```

### Example Update Flow

```python
async def on_system_installed(system_name: str, level: int, part: dict):
    """Called when player installs a ship system"""

    # Check if auto-update enabled
    if not SettingsManager.get_setting("advanced.auto_update_ship_manual"):
        return

    trigger_config = UPDATE_TRIGGERS["on_system_install"]

    if not trigger_config["enabled"]:
        return

    # Create documentation tasks
    tasks = []
    for section in trigger_config["sections"]:
        task = AITask(
            task_type=f"doc_{section}",
            priority=trigger_config["priority"],
            context={
                "system_name": system_name,
                "level": level,
                "part": part,
                "ship_state": GameState.get_ship_state(),
                "trigger": DocUpdateTrigger.ON_SYSTEM_INSTALL
            }
        )
        task_id = await task_queue.submit(task)
        tasks.append(task_id)

    # Option 1: Wait for completion (blocking)
    # results = await task_queue.gather(tasks, timeout=30)

    # Option 2: Background processing (non-blocking)
    # Results will be available later when player opens manual
    # Store task IDs for status checking
    GameState.pending_doc_tasks[system_name] = tasks

    # Show notification if enabled
    if SettingsManager.get_setting("performance.show_task_notifications"):
        UI.show_notification(f"Generating documentation for {system_name}...")
```

---

## Manual Content Types

### 1. System Overview
**Length:** 2-3 paragraphs
**Tone:** Professional, informative
**Includes:** Purpose, significance, integration with other systems

### 2. Technical Specifications
**Length:** Structured data + 1 paragraph
**Tone:** Factual, precise
**Includes:** Level, power, mass, part details, performance metrics

### 3. Capabilities
**Length:** Bulleted list (5-8 items)
**Tone:** Concise, capability-focused
**Includes:** Current level capabilities, next level preview

### 4. Operating Procedures
**Length:** 8-12 numbered steps
**Tone:** Directive, clear
**Includes:** Startup, operation, shutdown, emergency protocols

### 5. Maintenance & Troubleshooting
**Length:** Table format (5-7 issues)
**Tone:** Diagnostic, solution-oriented
**Includes:** Common issues, causes, fixes

### 6. Lore & Background
**Length:** 2-3 paragraphs
**Tone:** In-universe, immersive
**Includes:** History, manufacturer lore, interesting details

### 7. Upgrade History
**Length:** Chronological list
**Tone:** Log-style, factual
**Includes:** Timestamp, part name, level change

---

## Example Manual Entries

### Example 1: Warp Drive - Level 1 (Basic)

```markdown
## WARP DRIVE SYSTEM - LEVEL 1

### SYSTEM OVERVIEW

Your ship's warp drive system is the key to faster-than-light travel, enabling interstellar voyages that would otherwise take centuries using conventional propulsion. Currently operating at Level 1 with the salvaged **Alcubierre Mark II Drive Core** (uncommon), this system creates a stable warp bubble around your vessel by distorting spacetime itself.

The Mark II is a reliable, if dated, pre-Exodus design manufactured by Proxima Dynamics circa 2265. While it lacks the refinement of modern drives, it's proven technology—thousands of these units carried the Exodus fleet to safety. At your current configuration, the drive is capable of achieving Warp Factor 2.0, sufficient for short interstellar jumps within a 5 light-year radius.

Integration with your Level 1 Power Core provides just enough energy for sustained warp travel, though you'll need to manage power carefully during longer journeys. The Computer Core assists with jump calculations, while Sensors provide navigational data to avoid stellar hazards at superluminal velocities.

### TECHNICAL SPECIFICATIONS

- **System Level:** 1
- **Power Consumption:** 20 MW (active), 2 MW (standby)
- **Mass:** 45 metric tons
- **Installed Part:** Alcubierre Mark II Drive Core (Uncommon)
- **Health Status:** 100/100
- **Maximum Warp Factor:** 2.0
- **Range per Fuel Unit:** 5 light-years
- **Jump Calculation Time:** 45 seconds
- **Cooldown Between Jumps:** 5 minutes

### CAPABILITIES

**At Current Level (Level 1):**
- Achieve Warp Factor 2.0 (10x speed of light)
- Short-range interstellar travel (5 LY radius)
- Basic jump calculations via Computer Core integration
- Emergency warp jump capability (15 second warm-up)
- Automatic hazard avoidance (basic)

**Next Level Unlock (Level 2):**
- Warp Factor 3.5 (42x speed of light)
- Extended range (10 LY radius)
- Faster jump calculations (15 seconds)
- Advanced trajectory plotting
- Reduced power consumption (30 MW vs. 20 MW - more efficient)

### OPERATING PROCEDURES

#### Normal Warp Jump Sequence

1. **Pre-Jump Checks**
   - ✓ Verify warp drive health > 70%
   - ✓ Confirm sufficient fuel reserves (minimum 10 units recommended)
   - ✓ Ensure Power Core output ≥ 20 MW
   - ✓ Check destination coordinates with Sensors

2. **Warp Drive Initialization**
   - Activate warp drive from Navigation console
   - System draws 2 MW for nacelle warm-up
   - Wait for "READY" indicator (~30 seconds)

3. **Jump Calculation**
   - Computer Core calculates safe trajectory
   - Sensors scan route for stellar hazards
   - Calculation time: ~45 seconds for 5 LY jump

4. **Warp Engagement**
   - Confirm jump authorization
   - Drive draws full 20 MW power
   - Warp bubble forms (visible distortion effect)
   - Ship accelerates to Warp Factor 2.0
   - Time at warp varies by distance (1 LY ≈ 2 hours at Warp 2)

5. **Warp Exit**
   - Automatic deceleration at destination
   - Power consumption drops to 2 MW standby
   - 5-minute cooldown before next jump

#### Emergency Procedures

⚠️ **WARNING:** Emergency warp jumps are high-risk operations. Use only when normal jump is impossible.

1. **Emergency Jump Activation**
   - Access Emergency Warp protocol from any console
   - System bypasses safety checks (15 second warm-up vs. 75 seconds)
   - ⚠️ WARNING: No hazard avoidance, trajectory may be imprecise

2. **Warp Drive Failure Mid-Jump**
   - Automatic emergency drop to normal space
   - Warp bubble collapse is controlled but jarring
   - Immediate system diagnostic required
   - Position may be several light-years from intended destination

3. **Catastrophic Power Loss During Warp**
   - Drive has 30-second emergency capacitor reserve
   - Sufficient for controlled bubble collapse
   - ⚠️ CRITICAL: Do not allow Power Core to drop below 5 MW during warp

### MAINTENANCE & TROUBLESHOOTING

#### Routine Maintenance
- **After Every 10 Jumps:** Inspect warp coil alignment (Engineering console diagnostic)
- **Weekly:** Verify spacetime distortion calibration
- **Monthly:** Full nacelle structural integrity scan

#### Common Issues

| Symptom | Probable Cause | Solution |
|---------|---------------|----------|
| Jump calculations taking >60 seconds | Computer Core overloaded | Close non-essential programs, upgrade Computer Core |
| Warp bubble instability (flickering) | Insufficient power delivery | Verify Power Core output, check power relay conduits |
| Unable to achieve Warp 2.0 (stuck at Warp 1.5) | Warp coil misalignment | Run diagnostic: Engineering > Warp Drive > Calibrate Coils |
| Emergency drop to normal space | Stellar hazard detected | Expected behavior - Sensors prevented collision. Recalculate route. |
| Drive temperature critical (>95°C) | Cooldown period not observed | Mandatory 5-minute cooldown between jumps. Emergency vent heat. |
| "Insufficient Fuel" error | Fuel reserves too low | Refuel to minimum 10 units before long jumps |

### LORE & BACKGROUND

The Alcubierre warp drive, first theorized in 1994 by Mexican physicist Miguel Alcubierre, remained in the realm of speculative physics for over two centuries. The breakthrough came in 2247 when Proxima Dynamics successfully demonstrated a stable warp bubble using exotic matter with negative mass-energy density. The Mark II, released in 2265, became the workhorse of the Exodus fleet.

Your salvaged Mark II likely spent decades aboard an Exodus vessel before being abandoned or lost during Earth's evacuation. Proxima Dynamics was based in the Nevada Desert, and their production facilities are rumored to still contain pristine drive components—if you can navigate the hazards of what's left of the American Southwest.

These drives are prized by scavengers for their reliability. The Mark II's modular design means parts can be swapped in the field with basic tools, a crucial feature in the post-Exodus era where maintenance must often be performed without proper facilities. Many independent spacers consider the Mark II superior to flashier modern designs for precisely this reason: when you're light-years from help, simplicity is a virtue.

### UPGRADE HISTORY

- **Stardate 2287.305:** Installed Alcubierre Mark II Drive Core (Level 0 → 1)
  - Location: Abandoned spaceport, New Phoenix Sector
  - Salvage mission: "First Steps to the Stars"

---

**Last Updated:** Stardate 2287.305
**Documentation Version:** 1.0.0
**Generated By:** Ship's Computer Core (Level 1)
```

---

### Example 2: Computer Core - Level 2 (Intermediate)

```markdown
## COMPUTER CORE SYSTEM - LEVEL 2

### SYSTEM OVERVIEW

The Computer Core serves as the central intelligence of your vessel, coordinating all ship systems, performing navigational calculations, managing automation, and providing tactical analysis. Your current installation, the **Syntech Neural Matrix v4.1** (rare), represents a significant upgrade from standard cores, featuring advanced neural network architecture and parallel processing capabilities.

At Level 2, your Computer Core can manage complex multi-system operations simultaneously. The Neural Matrix excels at pattern recognition and predictive analysis—critical for missions involving Unknown phenomena or first contact scenarios. During combat, it provides real-time tactical recommendations by analyzing enemy movement patterns and calculating optimal response strategies.

This system is deeply integrated with every other component of your ship. It reduces jump calculation times for the Warp Drive, enhances target tracking for Weapons, coordinates shield harmonics, optimizes Life Support efficiency, and even assists with trade negotiations by analyzing market trends from Communication intercepts. As you upgrade other systems, the Computer Core's value only increases.

### TECHNICAL SPECIFICATIONS

- **System Level:** 2
- **Power Consumption:** 5 MW (standard operation), 8 MW (intensive processing)
- **Processing Power:** 450 exaFLOPS
- **Memory Capacity:** 2.5 petabytes
- **Installed Part:** Syntech Neural Matrix v4.1 (Rare)
- **Health Status:** 100/100
- **AI Assistance Level:** Intermediate (can offer suggestions, limited autonomy)
- **Automation Capacity:** 3 simultaneous automated tasks

### CAPABILITIES

**At Current Level (Level 2):**
- Run 3 automated tasks simultaneously (e.g., route planning + sensor analysis + life support optimization)
- Advanced tactical analysis in combat situations
- Reduce Warp jump calculation time by 50%
- Enhanced sensor data interpretation (pattern recognition)
- Trade route optimization and market analysis
- Basic predictive modeling for mission outcomes
- Natural language interface with crew

**Next Level Unlock (Level 3):**
- 5 simultaneous automated tasks
- Full AI assistant with proactive suggestions
- Advanced threat assessment and countermeasure recommendations
- Automatic system fault detection and self-repair initiation
- Enhanced NPC interaction analysis (detect deception, predict behavior)
- Ship-wide automation (auto-pilot, combat macros)

### OPERATING PROCEDURES

#### Normal Operations

1. **System Startup**
   - Computer Core initializes automatically on ship power-up
   - POST (Power-On Self-Test) completes in 5 seconds
   - Neural network calibration: 15 seconds
   - ✓ All systems reporting to Core

2. **Assigning Automated Tasks**
   - Access Computer Core interface from any console
   - Select task type (navigation, analysis, optimization, monitoring)
   - Define parameters and success criteria
   - Core executes in background (check status via AI Assistant)
   - Maximum 3 concurrent tasks at Level 2

3. **Using AI Assistant**
   - Voice activation: "Computer, [query]"
   - Or use text interface on any console
   - Assistant provides information, suggestions, and alerts
   - Current intelligence level: Intermediate (helpful but requires direction)

4. **System Coordination**
   - Computer Core automatically manages system priorities
   - During high-power demand, Core allocates power optimally
   - Monitors all system health—alerts on anomalies

#### Emergency Procedures

⚠️ **WARNING:** Computer Core failure affects all ship systems. Immediate action required.

1. **Computer Core Failure**
   - Ship systems revert to manual control
   - No automated assistance or calculations
   - Warp jumps become manual and dangerous (not recommended)
   - Emergency reboot: Engineering console > Core Systems > Emergency Restart (60 seconds)

2. **Core Corruption / Malware**
   - Isolate Computer Core from critical systems (prevents cascade failure)
   - Run diagnostic: Core Security > Full System Scan
   - Restore from backup (last clean state)
   - If corruption severe: Initiate factory reset (⚠️ loses all customizations)

3. **Power Failure to Computer Core**
   - Core has 10-minute battery backup
   - Enough time to restore power or execute controlled shutdown
   - ⚠️ CRITICAL: If backup expires, all ship automation ceases immediately

### MAINTENANCE & TROUBLESHOOTING

#### Routine Maintenance
- **Weekly:** Clear temporary processing cache (frees memory)
- **Monthly:** Defragment memory storage (improves performance)
- **After Major Battles:** Run diagnostic for combat damage to processing nodes

#### Common Issues

| Symptom | Probable Cause | Solution |
|---------|---------------|----------|
| Slow response times | Memory fragmentation | Engineering > Computer Core > Defragment Memory |
| Cannot assign 4th automated task | Task limit reached (Level 2 = 3 tasks) | Complete or cancel existing task, or upgrade to Level 3 |
| AI Assistant giving incorrect info | Outdated sensor data | Update sensor feeds: Sensors > Refresh Data > Computer Sync |
| Random system warnings | Neural network over-sensitive | Recalibrate warning thresholds: Core Settings > Sensitivity (reduce to 85%) |
| Jump calculations slower than expected | Background tasks consuming resources | Check active automated tasks—pause non-critical tasks during jumps |
| "Core Temperature Warning" | Intensive processing for >30 minutes | Normal for complex calculations—ensure cooling, or reduce task load |
| Missing ship logs / data gaps | Memory corruption or storage failure | Restore from backup: Core Systems > Data Recovery |

### LORE & BACKGROUND

Syntech Industries pioneered neural network-based ship computers in the 2270s, just before the Exodus. The Neural Matrix series was their flagship product, designed to learn and adapt to a crew's operational patterns. Unlike rule-based systems, the Matrix uses bio-inspired neural architectures—some whisper it's based on scans of actual human brains, though Syntech always denied this.

The v4.1 you've installed is a late-model unit, likely from 2283—only four years before the Exodus. Finding one intact and uncorrupted is remarkable. Most Neural Matrix cores were wiped during the evacuation to prevent sensitive data from falling into unknown hands. Yours may have been aboard a ship that never made it off-world, or perhaps it was deliberately hidden by someone who intended to return.

In the post-Exodus scavenging community, Syntech cores are legendary. A functioning v4 can be traded for a small ship's worth of supplies. Their adaptability makes them invaluable for the unpredictable challenges of exploring ruined Earth or venturing into deep space. Some spacers claim their Neural Matrix "knows" them—anticipates their commands, offers advice before it's asked for. Whether this is genuine emergent intelligence or skilled programming remains a matter of debate... and some unease.

### UPGRADE HISTORY

- **Stardate 2287.290:** Installed Generic Core Array (Level 0 → 1)
  - Location: Scrapyard, Chicago Dead Zone
  - Salvage mission: "Digital Awakening"

- **Stardate 2287.312:** Upgraded to Syntech Neural Matrix v4.1 (Level 1 → 2)
  - Location: Sunken Syntech facility, Silicon Bay
  - Salvage mission: "Ghosts in the Machine"
  - Notable: Core contained partial memory of previous crew—mission logs accessible in Archives

---

**Last Updated:** Stardate 2287.312
**Documentation Version:** 2.0.0
**Generated By:** Syntech Neural Matrix v4.1 (self-documented)
⚙️ *Core note: I am pleased to be of service.*
```

---

## Export & Viewing

### Viewing Options

**In-Game Manual Viewer:**
```
┌──────────────────────────────────────────────────┐
│ [<] SHIP TECHNICAL MANUAL              [Search] │
├──────────────────────────────────────────────────┤
│                                                  │
│ ◆ SHIP OVERVIEW                                 │
│   └─ Configuration Summary                      │
│                                                  │
│ ◆ SYSTEMS (7/10 installed)                      │
│   ├─ Hull & Structure [Level 2]                 │
│   ├─ Power Core [Level 1]                       │
│   ├─ Propulsion [Level 2]                       │
│   ├─ Warp Drive [Level 1] ◄ VIEWING             │
│   ├─ Life Support [Level 1]                     │
│   ├─ Computer Core [Level 2]                    │
│   ├─ Sensors [Level 1]                          │
│   └─ [3 systems not installed]                  │
│                                                  │
│ ◆ PROCEDURES                                     │
│ ◆ MISSION LOGS                                   │
│ ◆ APPENDICES                                     │
│                                                  │
├──────────────────────────────────────────────────┤
│ [Export PDF] [Print] [Share] [History/Changes]  │
└──────────────────────────────────────────────────┘
```

### Export Formats

**1. PDF Export**
```python
async def export_manual_to_pdf(ship_manual: ShipManual, output_path: str):
    """
    Export ship manual to formatted PDF document.
    Uses ReportLab or WeasyPrint for PDF generation.
    """
    from reportlab.lib.pagesizes import letter
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
    from reportlab.lib.styles import getSampleStyleSheet

    doc = SimpleDocTemplate(output_path, pagesize=letter)
    story = []
    styles = getSampleStyleSheet()

    # Title page
    story.append(Paragraph(f"Ship Technical Manual: {ship_manual.ship_name}", styles['Title']))
    story.append(Spacer(1, 12))

    # Table of contents
    story.append(Paragraph("Table of Contents", styles['Heading1']))
    # ... generate TOC

    # System documentation sections
    for system_name in SYSTEM_NAMES:
        doc_version = ship_manual.get_current(system_name)
        if doc_version:
            # System heading
            story.append(Paragraph(f"{system_name.upper()} - Level {doc_version.level}", styles['Heading1']))

            # Overview
            story.append(Paragraph("System Overview", styles['Heading2']))
            story.append(Paragraph(doc_version.overview, styles['BodyText']))

            # Specifications
            # ... format as table

            # ... other sections

    doc.build(story)
```

**2. Markdown Export**
```python
def export_manual_to_markdown(ship_manual: ShipManual) -> str:
    """Export to markdown format for easy sharing/editing"""
    md = f"# {ship_manual.ship_name} - Technical Manual\n\n"
    md += f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M')}\n\n"
    md += "---\n\n"

    # Ship overview
    overview_doc = ship_manual.get_current("ship_overview")
    if overview_doc:
        md += f"## Ship Overview\n\n{overview_doc.content}\n\n"

    # Systems
    md += "## Installed Systems\n\n"
    for system_name in SYSTEM_NAMES:
        doc = ship_manual.get_current(system_name)
        if doc:
            md += f"### {system_name.title()} - Level {doc.level}\n\n"
            md += f"{doc.overview}\n\n"
            md += f"**Capabilities:**\n{doc.capabilities}\n\n"
            # ... other sections
            md += "---\n\n"

    return md
```

**3. JSON Export** (for backup/transfer)
```python
def export_manual_to_json(ship_manual: ShipManual) -> str:
    """Export complete manual with all versions as JSON"""
    export_data = {
        "ship_name": ship_manual.ship_name,
        "exported_at": datetime.now().isoformat(),
        "format_version": "1.0.0",
        "systems": {}
    }

    for system_name, versions in ship_manual.versions.items():
        export_data["systems"][system_name] = [
            {
                "version": v.version,
                "level": v.level,
                "generated_at": v.generated_at.isoformat(),
                "content": {
                    "overview": v.overview,
                    "capabilities": v.capabilities,
                    "procedures": v.procedures,
                    "lore": v.lore,
                    "troubleshooting": v.troubleshooting
                }
            }
            for v in versions
        ]

    return json.dumps(export_data, indent=2)
```

---

## Implementation

### Godot Integration

```gdscript
# godot/scripts/ui/ship_manual_viewer.gd
extends Control

var current_system: String = ""
var manual_data: Dictionary = {}

signal manual_refresh_requested(system_name: String)

func _ready():
    # Connect to AI task completion signals
    AIService.task_completed.connect(_on_doc_task_completed)

    # Load existing manual data
    load_manual()

func load_manual():
    """Load ship manual from saved data"""
    if not FileAccess.file_exists("user://ship_manual.json"):
        return

    var file = FileAccess.open("user://ship_manual.json", FileAccess.READ)
    if file:
        var json = JSON.new()
        json.parse(file.get_as_text())
        manual_data = json.data
        file.close()

    refresh_display()

func display_system_documentation(system_name: String):
    """Display documentation for a specific system"""
    current_system = system_name

    var system_doc = manual_data.get(system_name, {})

    if system_doc.is_empty():
        # No documentation yet - request generation
        $NoDocLabel.visible = true
        $GenerateButton.visible = true
        $ContentContainer.visible = false
        return

    # Check if documentation is being generated
    if GameState.pending_doc_tasks.has(system_name):
        $LoadingIndicator.visible = true
        $StatusLabel.text = "Generating documentation..."
        return

    # Display documentation
    $NoDocLabel.visible = false
    $GenerateButton.visible = false
    $LoadingIndicator.visible = false
    $ContentContainer.visible = true

    # Populate sections
    $ContentContainer/Overview.text = system_doc.get("overview", "")
    $ContentContainer/Specs.text = format_specs(system_doc.get("specs", {}))
    $ContentContainer/Capabilities.text = system_doc.get("capabilities", "")
    $ContentContainer/Procedures.text = system_doc.get("procedures", "")
    $ContentContainer/Troubleshooting.text = system_doc.get("troubleshooting", "")
    $ContentContainer/Lore.text = system_doc.get("lore", "")

func _on_generate_button_pressed():
    """User manually requested documentation generation"""
    var system = GameState.ship.systems[current_system]

    # Request documentation generation with HIGH priority
    AIService.request_system_documentation(
        current_system,
        system.level,
        system.installed_part,
        TaskPriority.HIGH  # User-requested = high priority
    )

    $LoadingIndicator.visible = true
    $GenerateButton.visible = false

func _on_doc_task_completed(task_id: String, result: Dictionary):
    """Called when AI documentation task completes"""
    if result.system_name == current_system:
        # Update manual data
        manual_data[current_system] = result
        save_manual()

        # Refresh display
        display_system_documentation(current_system)

func save_manual():
    """Save manual data to disk"""
    var file = FileAccess.open("user://ship_manual.json", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(manual_data, "\t"))
        file.close()

func _on_export_pdf_pressed():
    """Export manual to PDF"""
    var result = await AIService.export_manual_to_pdf(manual_data)
    if result.success:
        OS.shell_open(result.file_path)
```

### Python API Endpoints

```python
# python/src/api/documentation.py

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, List
import asyncio

router = APIRouter(prefix="/api/documentation", tags=["documentation"])

class DocGenerationRequest(BaseModel):
    system_name: str
    level: int
    part: Dict[str, Any]
    ship_state: Dict[str, Any]
    priority: str = "normal"  # "critical", "high", "normal", "low"
    sections: List[str] = ["overview", "capabilities", "procedures", "lore", "troubleshooting"]

class DocGenerationResponse(BaseModel):
    task_id: str
    status: str  # "submitted", "pending", "running", "completed"
    estimated_time_seconds: int

@router.post("/generate", response_model=DocGenerationResponse)
async def generate_system_documentation(request: DocGenerationRequest):
    """
    Generate comprehensive documentation for a ship system.
    Returns immediately with task ID - actual generation happens async.
    """
    from ..ai.task_queue import task_queue, AITask, TaskPriority
    from ..ai.doc_tasks import DocTaskType

    # Map priority string to enum
    priority_map = {
        "critical": TaskPriority.CRITICAL,
        "high": TaskPriority.HIGH,
        "normal": TaskPriority.NORMAL,
        "low": TaskPriority.LOW
    }
    priority = priority_map.get(request.priority, TaskPriority.NORMAL)

    # Create tasks for each requested section
    tasks = []
    for section in request.sections:
        task = AITask(
            task_type=f"doc_{section}",
            priority=priority,
            context={
                "system_name": request.system_name,
                "level": request.level,
                "part": request.part,
                "ship_state": request.ship_state
            }
        )
        task_id = await task_queue.submit(task)
        tasks.append(task_id)

    # Store task group
    group_id = f"doc_{request.system_name}_{int(time.time())}"
    doc_task_groups[group_id] = tasks

    return DocGenerationResponse(
        task_id=group_id,
        status="submitted",
        estimated_time_seconds=len(tasks) * 8  # ~8 seconds per section
    )

@router.get("/status/{task_id}")
async def get_documentation_status(task_id: str):
    """Check status of documentation generation"""
    if task_id not in doc_task_groups:
        raise HTTPException(status_code=404, detail="Task not found")

    tasks = doc_task_groups[task_id]
    statuses = [await task_queue.get_task_status(tid) for tid in tasks]

    all_completed = all(s.status == "completed" for s in statuses)
    any_failed = any(s.status == "failed" for s in statuses)

    if all_completed:
        # Gather all results
        results = {s.task_type.replace("doc_", ""): s.result for s in statuses}
        return {"status": "completed", "results": results}
    elif any_failed:
        return {"status": "failed", "error": "Some tasks failed"}
    else:
        running = sum(1 for s in statuses if s.status == "running")
        pending = sum(1 for s in statuses if s.status == "pending")
        return {"status": "running", "progress": f"{running} running, {pending} pending"}

@router.post("/export/pdf")
async def export_manual_pdf(manual_data: Dict[str, Any]):
    """Export ship manual to PDF"""
    # Implementation using ReportLab or WeasyPrint
    pdf_path = await generate_pdf(manual_data)
    return {"success": True, "file_path": pdf_path}
```

---

**Document Complete**
**Last Updated:** November 5, 2025
