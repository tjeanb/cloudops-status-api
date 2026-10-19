from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_health():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_status():
    response = client.get("/status")
    
    assert response.status_code == 200
    assert response.json() == {
        "application": "cloudops-status-api",
        "version": "1.0.0",
        "environment": "development"
    }