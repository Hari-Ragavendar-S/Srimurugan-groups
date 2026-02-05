"""
Working server for Sri Murugan Finance - No reload mode
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

# Create FastAPI app
app = FastAPI(
    title="Sri Murugan Finance API",
    description="Working server for testing",
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
        "message": "🎉 Sri Murugan Finance API is working!",
        "status": "success",
        "server": "running properly"
    }

@app.get("/health")
def health():
    return {"status": "healthy", "message": "Server is running properly"}

@app.get("/test")
def test():
    return {
        "test": "success",
        "message": "All systems working",
        "port": 8000,
        "host": "localhost"
    }

if __name__ == "__main__":
    print("🚀 Starting server on http://localhost:8000")
    print("📖 API docs at http://localhost:8000/docs")
    
    # Start without reload to avoid issues
    uvicorn.run(
        app, 
        host="127.0.0.1",
        port=8000,
        reload=False,  # Disable reload
        log_level="info"
    )