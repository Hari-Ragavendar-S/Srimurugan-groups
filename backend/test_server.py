"""
Simple test server to check if FastAPI is working
"""
from fastapi import FastAPI
import uvicorn

app = FastAPI(title="Test Server")

@app.get("/")
def read_root():
    return {"message": "Server is working!", "status": "OK"}

@app.get("/test")
def test_endpoint():
    return {"test": "success", "server": "running"}

if __name__ == "__main__":
    print("Starting test server...")
    print("Access at: http://localhost:8000")
    print("Test endpoint: http://localhost:8000/test")
    uvicorn.run(app, host="127.0.0.1", port=8000, log_level="info")