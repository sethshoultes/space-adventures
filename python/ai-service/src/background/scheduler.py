"""
Background task scheduler using APScheduler.

Manages scheduled and periodic AI-first tasks:
- Mission pre-generation
- Daily/weekly events
- Cache cleanup
- Content updates
"""

import os
import logging
from typing import Optional
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger
from apscheduler.triggers.interval import IntervalTrigger

logger = logging.getLogger(__name__)


class BackgroundScheduler:
    """
    Manages background tasks for AI-first architecture.

    Supports:
    - Periodic tasks (every N minutes/hours)
    - Scheduled tasks (specific times/days)
    - One-time delayed tasks
    """

    def __init__(self):
        """Initialize the scheduler."""
        self.enabled = os.getenv("BACKGROUND_TASKS_ENABLED", "true").lower() == "true"

        if not self.enabled:
            logger.info("Background tasks disabled")
            self.scheduler = None
            return

        # Create async scheduler
        self.scheduler = AsyncIOScheduler()

        logger.info("Background scheduler initialized")

    def start(self):
        """Start the scheduler."""
        if not self.enabled or not self.scheduler:
            logger.info("Scheduler not started (disabled)")
            return

        if not self.scheduler.running:
            self.scheduler.start()
            logger.info("Background scheduler started")

    def shutdown(self):
        """Shutdown the scheduler."""
        if self.scheduler and self.scheduler.running:
            self.scheduler.shutdown()
            logger.info("Background scheduler shutdown")

    def add_interval_task(
        self,
        func,
        minutes: Optional[int] = None,
        hours: Optional[int] = None,
        task_id: Optional[str] = None,
        **kwargs
    ):
        """
        Add a task that runs at regular intervals.

        Args:
            func: Function to execute
            minutes: Run every N minutes
            hours: Run every N hours
            task_id: Unique identifier for the task
            **kwargs: Additional arguments to pass to function

        Example:
            # Pre-generate missions every 30 minutes
            scheduler.add_interval_task(
                pregenerate_missions,
                minutes=30,
                task_id="mission_pregeneration"
            )
        """
        if not self.enabled or not self.scheduler:
            return

        trigger = IntervalTrigger(minutes=minutes, hours=hours)

        self.scheduler.add_job(
            func,
            trigger,
            id=task_id,
            kwargs=kwargs,
            replace_existing=True
        )

        interval_str = f"{hours}h" if hours else f"{minutes}m"
        logger.info(f"Added interval task '{task_id}': {func.__name__} every {interval_str}")

    def add_cron_task(
        self,
        func,
        hour: int = 0,
        minute: int = 0,
        day_of_week: Optional[str] = None,
        task_id: Optional[str] = None,
        **kwargs
    ):
        """
        Add a task that runs on a schedule (cron-like).

        Args:
            func: Function to execute
            hour: Hour to run (0-23)
            minute: Minute to run (0-59)
            day_of_week: Day(s) to run (mon, tue, wed, thu, fri, sat, sun)
            task_id: Unique identifier
            **kwargs: Additional arguments to pass to function

        Example:
            # Generate daily events at 3 AM
            scheduler.add_cron_task(
                generate_daily_events,
                hour=3,
                minute=0,
                task_id="daily_events"
            )

            # Weekly content refresh on Mondays at 2 AM
            scheduler.add_cron_task(
                refresh_galaxy_state,
                hour=2,
                minute=0,
                day_of_week='mon',
                task_id="weekly_refresh"
            )
        """
        if not self.enabled or not self.scheduler:
            return

        trigger = CronTrigger(
            hour=hour,
            minute=minute,
            day_of_week=day_of_week
        )

        self.scheduler.add_job(
            func,
            trigger,
            id=task_id,
            kwargs=kwargs,
            replace_existing=True
        )

        schedule_str = f"{hour:02d}:{minute:02d}"
        if day_of_week:
            schedule_str += f" on {day_of_week}"

        logger.info(f"Added cron task '{task_id}': {func.__name__} at {schedule_str}")

    def remove_task(self, task_id: str):
        """Remove a scheduled task."""
        if not self.enabled or not self.scheduler:
            return

        try:
            self.scheduler.remove_job(task_id)
            logger.info(f"Removed task '{task_id}'")
        except Exception as e:
            logger.warning(f"Failed to remove task '{task_id}': {e}")

    def get_jobs(self):
        """Get list of scheduled jobs."""
        if not self.enabled or not self.scheduler:
            return []

        return self.scheduler.get_jobs()


# Global scheduler instance
_scheduler: Optional[BackgroundScheduler] = None


def get_scheduler() -> BackgroundScheduler:
    """Get or create global scheduler instance."""
    global _scheduler
    if _scheduler is None:
        _scheduler = BackgroundScheduler()
    return _scheduler
