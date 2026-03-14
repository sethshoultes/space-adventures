"""Application configuration using pydantic-settings."""

from pathlib import Path

from pydantic_settings import BaseSettings


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

    # Database
    database_path: str = "./space_adventures.db"

    # Memory
    memory_dir: str = "./memory"

    # Game data
    game_data_dir: str = str(Path(__file__).resolve().parent / "data")

    model_config = {"env_file": ".env", "env_prefix": "SA_"}


settings = Settings()
