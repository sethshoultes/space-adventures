"""API endpoints for AI Service"""

from .missions import router as missions_router
from .chat import router as chat_router
from .dialogue import router as dialogue_router
from .orchestrator import router as orchestrator_router
from .story import router as story_router

__all__ = ["missions_router", "chat_router", "dialogue_router", "orchestrator_router", "story_router"]
