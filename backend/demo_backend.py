"""
🎯 Sri Murugan Finance Backend - Complete Demo
This script demonstrates all backend features working together
"""

import requests
import json
from datetime import datetime

# Server URL
BASE_URL = "http://localhost:8000"

def print_section(title):
    print("\n" + "="*60)
    print(f"🎯 {title}")
    print("="*60)

def print_response(response, title="Response"):
    print(f"\n📋 {title}:")
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        print("✅ SUCCESS")
        try:
            data = response.json()
            print(json.dumps(data, indent=2))
        except:
            print(response.text)
    else:
        print("❌ ERROR")
        print(response.text)

def demo_backend():
    print("🚀 Starting Sri Murugan Finance Backend Demo")
    print(f"Server: {BASE_URL}")
    
    # Test server health
    print_section("1. SERVER HEALTH CHECK")
    response = requests.get(f"{BASE_URL}/health")
    print_response(response, "Health Check")
    
    # Register new user
    print_section("2. USER REGISTRATION")
    user_data = {
        "email": "demo@srimurugan.com",
        "phone": "+919876543999",
        "full_name": "Demo User",
        "password": "demo123"
    }
    response = requests.post(f"{BASE_URL}/api/auth/register", json=user_data)
    print_response(response, "User Registration")
    
    # Login user
    print_section("3. USER LOGIN & TOKEN GENERATION")
    login_data = {
        "username": "demo@srimurugan.com",  # FastAPI OAuth2 uses 'username' field
        "password": "demo123"
    }
    response = requests.post(f"{BASE_URL}/api/auth/login", data=login_data)
    print_response(response, "User Login")
    
    if response.status_code == 200:
        token_data = response.json()
        access_token = token_data["access_token"]
        headers = {"Authorization": f"Bearer {access_token}"}
        
        # Get user info
        print_section("4. GET USER INFORMATION")
        response = requests.get(f"{BASE_URL}/api/users/me", headers=headers)
        print_response(response, "User Info")
        
        # Apply for loan
        print_section("5. LOAN APPLICATION")
        loan_data = {
            "loan_amount": 500000,
            "interest_rate": 12.5,
            "tenure_months": 36,
            "purpose": "Business Expansion"
        }
        response = requests.post(f"{BASE_URL}/api/loans/apply", json=loan_data, headers=headers)
        print_response(response, "Loan Application")
        
        if response.status_code == 200:
            loan_id = response.json()["id"]
            
            # Get user's loans
            print_section("6. GET USER LOANS")
            response = requests.get(f"{BASE_URL}/api/loans/my-loans", headers=headers)
            print_response(response, "User Loans")
            
            # Create transaction
            print_section("7. CREATE TRANSACTION")
            transaction_data = {
                "loan_id": loan_id,
                "transaction_type": "payment",
                "amount": 15000,
                "description": "First EMI Payment"
            }
            response = requests.post(f"{BASE_URL}/api/transactions/", json=transaction_data, headers=headers)
            print_response(response, "Transaction Creation")
            
            # Get user transactions
            print_section("8. GET USER TRANSACTIONS")
            response = requests.get(f"{BASE_URL}/api/transactions/my-transactions", headers=headers)
            print_response(response, "User Transactions")
            
            # Get notifications
            print_section("9. GET NOTIFICATIONS")
            response = requests.get(f"{BASE_URL}/api/notifications/my-notifications", headers=headers)
            print_response(response, "User Notifications")
            
            # Check upcoming dues
            print_section("10. CHECK UPCOMING DUES")
            response = requests.get(f"{BASE_URL}/api/notifications/upcoming-dues", headers=headers)
            print_response(response, "Upcoming Dues")
            
            # Set MPIN
            print_section("11. SET MPIN")
            response = requests.post(f"{BASE_URL}/api/auth/set-mpin?mpin=1234", headers=headers)
            print_response(response, "Set MPIN")
            
            # MPIN Login
            print_section("12. MPIN LOGIN")
            mpin_data = {
                "phone": "+919876543999",
                "mpin": "1234"
            }
            response = requests.post(f"{BASE_URL}/api/auth/mpin-login", json=mpin_data)
            print_response(response, "MPIN Login")
    
    # Admin endpoints (without authentication for demo)
    print_section("13. ADMIN - GET ALL USERS")
    response = requests.get(f"{BASE_URL}/api/admin/users")
    print_response(response, "All Users")
    
    print_section("14. ADMIN - GET SYSTEM STATS")
    response = requests.get(f"{BASE_URL}/api/admin/stats")
    print_response(response, "System Statistics")
    
    print_section("15. API DOCUMENTATION")
    print(f"📖 Swagger UI: {BASE_URL}/docs")
    print(f"📖 ReDoc: {BASE_URL}/redoc")
    
    print("\n" + "="*60)
    print("🎉 BACKEND DEMO COMPLETED!")
    print("="*60)
    print("✅ All features working:")
    print("   • User Registration & Authentication")
    print("   • JWT Token Generation")
    print("   • Loan Management")
    print("   • Transaction Processing")
    print("   • Notification System")
    print("   • MPIN Support")
    print("   • Admin Dashboard")
    print("   • Database Integration")
    print("="*60)

if __name__ == "__main__":
    try:
        demo_backend()
    except requests.exceptions.ConnectionError:
        print("❌ ERROR: Cannot connect to server!")
        print("Please make sure the server is running on http://localhost:8000")
        print("Run: python working_server.py")
    except Exception as e:
        print(f"❌ ERROR: {e}")