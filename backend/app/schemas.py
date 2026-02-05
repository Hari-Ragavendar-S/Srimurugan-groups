from pydantic import BaseModel, EmailStr
from datetime import datetime, date
from typing import Optional, List

# User schemas
class UserBase(BaseModel):
    email: EmailStr
    phone: str
    full_name: str

class UserCreate(UserBase):
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserMPINLogin(BaseModel):
    phone: str
    mpin: str

class UserResponse(UserBase):
    id: int
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True

# Loan schemas
class LoanBase(BaseModel):
    loan_amount: float
    interest_rate: float
    tenure_months: int
    purpose: str

class LoanCreate(LoanBase):
    pass

class LoanResponse(LoanBase):
    id: int
    user_id: int
    monthly_emi: float
    outstanding_amount: float
    next_due_date: Optional[date]
    status: str
    created_at: datetime
    
    class Config:
        from_attributes = True

# Transaction schemas
class TransactionBase(BaseModel):
    transaction_type: str
    amount: float
    description: Optional[str] = None

class TransactionCreate(TransactionBase):
    loan_id: Optional[int] = None

class TransactionResponse(TransactionBase):
    id: int
    user_id: int
    loan_id: Optional[int]
    status: str
    created_at: datetime
    
    class Config:
        from_attributes = True

# Notification schemas
class NotificationBase(BaseModel):
    title: str
    message: str
    notification_type: str

class NotificationCreate(NotificationBase):
    user_id: int
    loan_id: Optional[int] = None
    scheduled_for: Optional[datetime] = None

class NotificationResponse(NotificationBase):
    id: int
    user_id: int
    loan_id: Optional[int]
    is_read: bool
    scheduled_for: Optional[datetime]
    sent_at: Optional[datetime]
    created_at: datetime
    
    class Config:
        from_attributes = True

# Token schemas
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

# Due reminder schema
class DueReminderResponse(BaseModel):
    user_id: int
    upcoming_dues: List[dict]
    total_due_amount: float