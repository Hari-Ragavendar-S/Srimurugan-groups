"""
Simple working server for Sri Murugan Finance
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

# Create FastAPI app
app = FastAPI(
    title="Sri Murugan Finance API",
    description="Simple working server",
    version="1.0.0"
)

# Add CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {
        "message": "Sri Murugan Finance API is working!",
        "status": "success",
        "server": "running"
    }

@app.get("/health")
def health():
    return {"status": "healthy", "message": "Server is running properly"}

@app.get("/test")
def test():
    return {
        "test": "success",
        "message": "API endpoints are working",
        "endpoints": [
            "GET /",
            "GET /health", 
            "GET /test",
            "GET /docs"
        ]
    }

if __name__ == "__main__":
    print("=" * 50)
    print("🚀 Starting Sri Murugan Finance Server...")
    print("=" * 50)
    print("✅ Server URL: http://localhost:8000")
    print("✅ API Docs: http://localhost:8000/docs")
    print("✅ Health Check: http://localhost:8000/health")
    print("✅ Test Endpoint: http://localhost:8000/test")
    print("=" * 50)
    print("Press Ctrl+C to stop the server")
    print("=" * 50)
    
    uvicorn.run(
        app, 
        host="127.0.0.1",  # Use localhost instead of 0.0.0.0
        port=8000,
        reload=True,
        log_level="info"
    )