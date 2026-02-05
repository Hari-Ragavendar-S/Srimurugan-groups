"""
Server startup script with database initialization
"""

import uvicorn
import os
from init_db import init_sample_data

def main():
    print("Starting Sri Murugan Finance API Server...")
    
    # Initialize database with sample data
    print("Checking database initialization...")
    init_sample_data()
    
    # Start the server
    print("\nStarting FastAPI server...")
    print("Server will be available at: http://localhost:8000")
    print("API Documentation: http://localhost:8000/docs")
    uvicorn.run(
        "app.main:app",
        host="127.0.0.1",
        port=8000,
        reload=True,
        log_level="info"
    )

if __name__ == "__main__":
    main()