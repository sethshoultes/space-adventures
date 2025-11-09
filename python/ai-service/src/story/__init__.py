"""
Story Engine Module

Dynamic narrative generation system for Space Adventures.

Components:
- MemoryManager: Player choice/relationship/consequence tracking
- StoryEngine: On-demand narrative generation with caching (Level 4)
- WorldState: Global economy, factions, events
- MissionPool: Lazy queue for generic side missions (Level 3)
"""

from .memory_manager import MemoryManager

__all__ = [
    "MemoryManager",
]
