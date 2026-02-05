"""
Complete Sri Murugan Finance Server with all features
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import auth, users, loans, transactions, notifications, admin
from app.database import engine
from app import models
import uvicorn

# Create database tables
models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Sri Murugan Finance API",
    description="Complete Backend API for Sri Murugan Finance mobile application",
    version="1.0.0"
)

# CORS middleware for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this properly in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(users.router, prefix="/api/users", tags=["Users"])
app.include_router(loans.router, prefix="/api/loans", tags=["Loans"])
app.include_router(transactions.router, prefix="/api/transactions", tags=["Transactions"])
app.include_router(notifications.router, prefix="/api/notifications", tags=["Notifications"])
app.include_router(admin.router, prefix="/api/admin", tags=["Admin"])

@app.get("/")
async def root():
    return {
        "message": "🎉 Sri Murugan Finance API is running!",
        "version": "1.0.0",
        "features": [
            "User Authentication",
            "Loan Management", 
            "Transaction Processing",
            "Notification System",
            "Admin Dashboard"
        ]
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy", "message": "All systems operational"}

if __name__ == "__main__":
    print("🚀 Starting Complete Sri Murugan Finance Server...")
    print("✅ Server: http://localhost:8000")
    print("📖 API Docs: http://localhost:8000/docs")
    print("🔧 Admin Panel: http://localhost:8000/api/admin/stats")
    
    uvicorn.run(
        app, 
        host="127.0.0.1",
        port=8000,
        reload=False,
        log_level="info"
    )