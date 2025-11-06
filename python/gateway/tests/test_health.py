"""
Tests for Gateway Service health check endpoints.
"""

import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock
import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from main import app


@pytest.fixture
def client():
    """Create test client."""
    return TestClient(app)


def test_health_check(client):
    """Test basic health check endpoint."""
    response = client.get("/health")

    assert response.status_code == 200
    data = response.json()

    assert data["status"] == "healthy"
    assert data["service"] == "gateway"
    assert "timestamp" in data
    assert "version" in data


def test_root_endpoint(client):
    """Test root endpoint returns service information."""
    response = client.get("/")

    assert response.status_code == 200
    data = response.json()

    assert data["service"] == "Space Adventures Gateway"
    assert data["status"] == "operational"
    assert "docs" in data
    assert "health" in data


@pytest.mark.asyncio
@patch('httpx.AsyncClient')
async def test_health_check_all_services_healthy(mock_client_class, client):
    """Test aggregate health check when all services are healthy."""
    # Mock successful responses from all services
    mock_client = MagicMock()
    mock_client_class.return_value.__aenter__.return_value = mock_client

    # Mock AI Service response
    ai_response = MagicMock()
    ai_response.status_code = 200

    # Mock Whisper Service response
    whisper_response = MagicMock()
    whisper_response.status_code = 200

    # Return different responses for different URLs
    mock_client.get.side_effect = [ai_response, whisper_response]

    response = client.get("/health/all")

    assert response.status_code == 200
    data = response.json()

    assert "services" in data
    assert "gateway" in data["services"]
    assert "ai-service" in data["services"]
    assert "whisper-service" in data["services"]

    # Gateway should always be healthy
    assert data["services"]["gateway"]["status"] == "healthy"


@pytest.mark.asyncio
@patch('httpx.AsyncClient')
async def test_health_check_service_unavailable(mock_client_class, client):
    """Test aggregate health check when a service is unavailable."""
    mock_client = MagicMock()
    mock_client_class.return_value.__aenter__.return_value = mock_client

    # Mock AI Service failing
    mock_client.get.side_effect = Exception("Connection refused")

    response = client.get("/health/all")

    assert response.status_code == 200
    data = response.json()

    # Overall status should be degraded
    assert data["status"] == "degraded"
    assert "services" in data


def test_cors_headers(client):
    """Test CORS headers are present."""
    response = client.options("/health", headers={
        "Origin": "http://localhost:3000",
        "Access-Control-Request-Method": "GET"
    })

    # FastAPI's CORS middleware handles OPTIONS automatically
    assert response.status_code == 200
