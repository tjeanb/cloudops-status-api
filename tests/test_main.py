from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_health():
    response = client.get("/health")

    assert response.status_code == 201
    assert response.json() == {"status": "ok"}


def test_status():
    response = client.get("/status")
    
    assert response.status_code == 200
    assert response.json() == {
        "application": "cloudops-status-api",
        "version": "1.0.0",
        "environment": "development"
    }

def test_version():
    response = client.get("/version")
    
    assert response.status_code == 200
    assert response.json() == {"version": "1.1.0"}