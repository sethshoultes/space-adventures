"""
AI Orchestrator Package

Multi-agent AI system using LiteLLM for provider-agnostic orchestration.

Manages 4 AI personalities:
- ATLAS: Ship's computer (operational tasks, function calling)
- Storyteller: Narrative engine (missions, story content)
- Tactical: Combat advisor (tactical analysis, strategy)
- Companion: Personal AI friend (emotional support, conversation)

Supports multiple providers:
- Ollama (local, free)
- Anthropic Claude (quality narrative)
- OpenAI GPT (versatile content)
"""

from .orchestrator import AIOrchestrator
from .config import OrchestratorConfig
from .agents import AgentType, get_agent_prompt

__all__ = [
    "AIOrchestrator",
    "OrchestratorConfig",
    "AgentType",
    "get_agent_prompt",
]
