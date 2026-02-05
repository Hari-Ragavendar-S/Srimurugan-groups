"""
Notification service for loan due reminders and balance checks
"""

from datetime import datetime, timedelta, date
from sqlalchemy.orm import Session
from sqlalchemy import and_
from app import models, schemas
from typing import List
import logging

logger = logging.getLogger(__name__)

class NotificationService:
    
    @staticmethod
    def create_notification(db: Session, notification: schemas.NotificationCreate) -> models.Notification:
        """Create a new notification"""
        db_notification = models.Notification(**notification.dict())
        db.add(db_notification)
        db.commit()
        db.refresh(db_notification)
        return db_notification
    
    @staticmethod
    def get_user_notifications(db: Session, user_id: int, unread_only: bool = False) -> List[models.Notification]:
        """Get notifications for a user"""
        query = db.query(models.Notification).filter(models.Notification.user_id == user_id)
        
        if unread_only:
            query = query.filter(models.Notification.is_read == False)
        
        return query.order_by(models.Notification.created_at.desc()).all()
    
    @staticmethod
    def mark_notification_read(db: Session, notification_id: int, user_id: int) -> bool:
        """Mark notification as read"""
        notification = db.query(models.Notification).filter(
            and_(
                models.Notification.id == notification_id,
                models.Notification.user_id == user_id
            )
        ).first()
        
        if notification:
            notification.is_read = True
            db.commit()
            return True
        return False
    
    @staticmethod
    def check_upcoming_dues(db: Session) -> List[dict]:
        """Check for loans with upcoming due dates (next 3 days)"""
        today = date.today()
        three_days_later = today + timedelta(days=3)
        
        # Get active loans with due dates in next 3 days
        upcoming_loans = db.query(models.Loan).filter(
            and_(
                models.Loan.status == "active",
                models.Loan.next_due_date.between(today, three_days_later)
            )
        ).all()
        
        due_reminders = []
        for loan in upcoming_loans:
            days_until_due = (loan.next_due_date - today).days
            
            due_reminders.append({
                "loan_id": loan.id,
                "user_id": loan.user_id,
                "due_date": loan.next_due_date,
                "days_until_due": days_until_due,
                "emi_amount": loan.monthly_emi,
                "user": loan.user
            })
        
        return due_reminders
    
    @staticmethod
    def send_due_reminders(db: Session) -> int:
        """Send due date reminders to users"""
        upcoming_dues = NotificationService.check_upcoming_dues(db)
        notifications_sent = 0
        
        for due in upcoming_dues:
            # Check if reminder already sent for this due date
            existing_notification = db.query(models.Notification).filter(
                and_(
                    models.Notification.user_id == due["user_id"],
                    models.Notification.loan_id == due["loan_id"],
                    models.Notification.notification_type == "due_reminder",
                    models.Notification.created_at >= datetime.now() - timedelta(days=1)
                )
            ).first()
            
            if not existing_notification:
                # Create reminder notification
                if due["days_until_due"] == 0:
                    title = "🚨 EMI Due Today - Maintain Amount"
                    message = f"Your EMI of ₹{due['emi_amount']:,.2f} is due today. Please maintain this amount for payment."
                elif due["days_until_due"] == 1:
                    title = "⏰ EMI Due Tomorrow - Maintain Amount"
                    message = f"Your EMI of ₹{due['emi_amount']:,.2f} is due tomorrow. Please maintain this amount."
                else:
                    title = f"📅 EMI Due in {due['days_until_due']} days - Maintain Amount"
                    message = f"Your EMI of ₹{due['emi_amount']:,.2f} is due on {due['due_date'].strftime('%d %b %Y')}. Please maintain this amount for timely payment."
                
                notification = models.Notification(
                    user_id=due["user_id"],
                    loan_id=due["loan_id"],
                    title=title,
                    message=message,
                    notification_type="maintenance_reminder",
                    sent_at=datetime.now()
                )
                
                db.add(notification)
                notifications_sent += 1
        
        db.commit()
        return notifications_sent
    
    @staticmethod
    def get_upcoming_dues(db: Session, user_id: int) -> schemas.DueReminderResponse:
        """Get user's upcoming loan dues without balance checking"""
        # Get upcoming dues for next 7 days
        today = date.today()
        next_week = today + timedelta(days=7)
        
        upcoming_loans = db.query(models.Loan).filter(
            and_(
                models.Loan.user_id == user_id,
                models.Loan.status == "active",
                models.Loan.next_due_date.between(today, next_week)
            )
        ).all()
        
        upcoming_dues = []
        total_due_amount = 0
        
        for loan in upcoming_loans:
            days_until_due = (loan.next_due_date - today).days
            upcoming_dues.append({
                "loan_id": loan.id,
                "due_date": loan.next_due_date.isoformat(),
                "days_until_due": days_until_due,
                "emi_amount": loan.monthly_emi,
                "purpose": loan.purpose
            })
            total_due_amount += loan.monthly_emi
        
        return schemas.DueReminderResponse(
            user_id=user_id,
            upcoming_dues=upcoming_dues,
            total_due_amount=total_due_amount
        )
    
    @staticmethod
    def send_maintenance_reminder(db: Session, user_id: int, due_amount: float, due_date: date) -> bool:
        """Send reminder to maintain loan due amount"""
        # Check if reminder already sent today
        today = datetime.now().date()
        existing_reminder = db.query(models.Notification).filter(
            and_(
                models.Notification.user_id == user_id,
                models.Notification.notification_type == "maintenance_reminder",
                models.Notification.created_at >= datetime.combine(today, datetime.min.time())
            )
        ).first()
        
        if not existing_reminder:
            days_until_due = (due_date - today).days
            
            if days_until_due == 0:
                title = "🚨 EMI Due Today - Maintain Amount"
                message = f"Your EMI of ₹{due_amount:,.2f} is due today. Please ensure you maintain this amount for payment."
            elif days_until_due == 1:
                title = "⏰ EMI Due Tomorrow - Maintain Amount"
                message = f"Your EMI of ₹{due_amount:,.2f} is due tomorrow ({due_date.strftime('%d %b %Y')}). Please maintain this amount."
            else:
                title = f"📅 EMI Due in {days_until_due} days - Maintain Amount"
                message = f"Your EMI of ₹{due_amount:,.2f} is due on {due_date.strftime('%d %b %Y')}. Please maintain this amount for timely payment."
            
            notification = models.Notification(
                user_id=user_id,
                title=title,
                message=message,
                notification_type="maintenance_reminder",
                sent_at=datetime.now()
            )
            
            db.add(notification)
            db.commit()
            return True
        
        return False
    
    @staticmethod
    def update_next_due_date(db: Session, loan_id: int) -> bool:
        """Update next due date after EMI payment"""
        loan = db.query(models.Loan).filter(models.Loan.id == loan_id).first()
        if loan and loan.next_due_date:
            # Move due date to next month
            if loan.next_due_date.month == 12:
                next_due = loan.next_due_date.replace(year=loan.next_due_date.year + 1, month=1)
            else:
                next_due = loan.next_due_date.replace(month=loan.next_due_date.month + 1)
            
            loan.next_due_date = next_due
            db.commit()
            return True
        return False