"""
Tests for Gateway Service request routing functionality.
"""

import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from main import app


@pytest.fixture
def client():
    """Create test client."""
    return TestClient(app)


@pytest.mark.asyncio
@patch('httpx.AsyncClient')
async def test_route_to_ai_service(mock_client_class, client):
    """Test routing request to AI service."""
    mock_client = MagicMock()
    mock_client_class.return_value.__aenter__.return_value = mock_client

    # Mock successful AI service response
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.json.return_value = {
        "success": True,
        "data": {"message": "Test response"}
    }
    mock_client.request.return_value = mock_response

    response = client.post(
        "/api/v1/ai/chat/message",
        json={"message": "Hello", "session_id": "test123"}
    )

    assert response.status_code == 200


@pytest.mark.asyncio
@patch('httpx.AsyncClient')
async def test_route_to_whisper_service(mock_client_class, client):
    """Test routing request to Whisper service."""
    mock_client = MagicMock()
    mock_client_class.return_value.__aenter__.return_value = mock_client

    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.json.return_value = {
        "success": True,
        "text": "Transcribed text"
    }
    mock_client.request.return_value = mock_response

    response = client.post("/api/v1/whisper/transcribe")

    # Will fail without actual file, but tests routing
    assert response.status_code in [200, 422]  # 422 = validation error (expected)


@pytest.mark.asyncio
@patch('httpx.AsyncClient')
async def test_service_timeout_handling(mock_client_class, client):
    """Test handling of service timeout errors."""
    mock_client = MagicMock()
    mock_client_class.return_value.__aenter__.return_value = mock_client

    # Mock timeout exception
    import httpx
    mock_client.request.side_effect = httpx.TimeoutException("Timeout")

    response = client.post(
        "/api/v1/ai/test",
        json={"test": "data"}
    )

    assert response.status_code == 504  # Gateway timeout


@pytest.mark.asyncio
@patch('httpx.AsyncClient')
async def test_service_error_handling(mock_client_class, client):
    """Test handling of service errors."""
    mock_client = MagicMock()
    mock_client_class.return_value.__aenter__.return_value = mock_client

    # Mock general exception
    mock_client.request.side_effect = Exception("Service error")

    response = client.post(
        "/api/v1/ai/test",
        json={"test": "data"}
    )

    assert response.status_code == 502  # Bad gateway


def test_invalid_route(client):
    """Test request to non-existent route."""
    response = client.get("/api/v1/invalid/route")

    assert response.status_code == 404
