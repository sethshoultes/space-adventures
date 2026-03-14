"""Application configuration using pydantic-settings."""

from pathlib import Path

from pydantic_settings import BaseSettings

# Project root is the parent of server/
_SERVER_DIR = Path(__file__).resolve().parent.parent  # server/src -> server/
_PROJECT_ROOT = _SERVER_DIR.parent  # server/ -> project root


class Settings(BaseSettings):
    """Server configuration loaded from environment variables."""

    # App
    app_name: str = "Space Adventures"
    debug: bool = False

    # Server
    host: str = "0.0.0.0"
    port: int = 8000

    # CORS
    cors_origins: list[str] = ["http://localhost:3000", "http://localhost:5173"]

    # Anthropic API
    anthropic_api_key: str = ""
    claude_model: str = "claude-sonnet-4-20250514"

    # Redis (optional, for future event queue)
    redis_url: str = "redis://localhost:6379"

    # Database — stored in server/ directory
    database_path: str = str(_SERVER_DIR / "space_adventures.db")

    # Memory — stored at project root memory/ directory
    memory_dir: str = str(_PROJECT_ROOT / "memory")

    # Game data — bundled inside server/src/data/
    game_data_dir: str = str(_SERVER_DIR / "src" / "data")

    model_config = {"env_file": ".env", "env_prefix": "SA_"}


settings = Settings()
