"""
Background tasks and scheduling system.

Implements AI-first patterns:
- Mission pre-generation
- Scheduled content updates
- Background processing
"""

from .scheduler import BackgroundScheduler, get_scheduler
from .mission_queue import MissionQueue, get_mission_queue
from .tasks import (
    pregenerate_missions,
    generate_daily_events,
    cleanup_old_cache
)

__all__ = [
    "BackgroundScheduler",
    "get_scheduler",
    "MissionQueue",
    "get_mission_queue",
    "pregenerate_missions",
    "generate_daily_events",
    "cleanup_old_cache",
]
