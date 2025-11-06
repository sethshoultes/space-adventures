"""
Middleware for Gateway Service.

Provides request logging, timing, and error tracking.
"""

import time
import logging
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware
from typing import Callable
import uuid

logger = logging.getLogger(__name__)


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """
    Middleware to log all incoming requests and responses.

    Logs:
    - Request method, path, headers
    - Response status code
    - Request duration
    - Request ID for tracking
    """

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        """Process request and log details."""
        # Generate unique request ID
        request_id = str(uuid.uuid4())

        # Record start time
        start_time = time.time()

        # Log incoming request
        logger.info(
            f"Request started: {request.method} {request.url.path}",
            extra={
                "request_id": request_id,
                "method": request.method,
                "path": request.url.path,
                "client": request.client.host if request.client else "unknown"
            }
        )

        # Process request
        try:
            response = await call_next(request)

            # Calculate duration
            duration = time.time() - start_time

            # Log response
            logger.info(
                f"Request completed: {request.method} {request.url.path} - {response.status_code}",
                extra={
                    "request_id": request_id,
                    "method": request.method,
                    "path": request.url.path,
                    "status_code": response.status_code,
                    "duration_ms": round(duration * 1000, 2)
                }
            )

            # Add request ID to response headers
            response.headers["X-Request-ID"] = request_id

            return response

        except Exception as e:
            # Log error
            duration = time.time() - start_time
            logger.error(
                f"Request failed: {request.method} {request.url.path} - {str(e)}",
                extra={
                    "request_id": request_id,
                    "method": request.method,
                    "path": request.url.path,
                    "error": str(e),
                    "duration_ms": round(duration * 1000, 2)
                },
                exc_info=True
            )
            raise


class ServiceRegistryMiddleware:
    """
    Middleware for tracking available services.

    This could be expanded to:
    - Dynamic service discovery
    - Service health monitoring
    - Load balancing across multiple instances
    """

    def __init__(self):
        self.services = {}

    def register_service(self, name: str, url: str, health_endpoint: str = "/health"):
        """Register a backend service."""
        self.services[name] = {
            "url": url,
            "health_endpoint": health_endpoint,
            "status": "unknown"
        }
        logger.info(f"Registered service: {name} at {url}")

    def get_service_url(self, name: str) -> str:
        """Get URL for a registered service."""
        service = self.services.get(name)
        if service:
            return service["url"]
        raise ValueError(f"Service not found: {name}")

    def list_services(self) -> dict:
        """List all registered services."""
        return self.services


# Global service registry instance
service_registry = ServiceRegistryMiddleware()
