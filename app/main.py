from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/status")
def status():
    return{
        "application": "cloudops-status-api",
        "version": "1.0.0",
        "environment": "development"
    }

@app.get("/version")
def version():
    return {"version": "1.1.0"}