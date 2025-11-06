"""
Standard response models for consistent API responses across all services.
"""

from pydantic import BaseModel, Field
from typing import Optional, Any, Dict
from datetime import datetime


class StandardResponse(BaseModel):
    """Standard successful response format."""
    success: bool = True
    data: Optional[Any] = None
    message: Optional[str] = None
    timestamp: str = Field(default_factory=lambda: datetime.utcnow().isoformat())
    service: Optional[str] = None


class ErrorResponse(BaseModel):
    """Standard error response format."""
    success: bool = False
    error: str
    error_code: str
    service: str
    timestamp: str = Field(default_factory=lambda: datetime.utcnow().isoformat())
    request_id: Optional[str] = None
    details: Optional[Dict[str, Any]] = None
