"""
Notification endpoints for loan reminders and balance alerts
"""

from typing import List
from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session
from app.database import get_db
from app import models, schemas, auth
from app.services.notification_service import NotificationService

router = APIRouter()

@router.get("/my-notifications", response_model=List[schemas.NotificationResponse])
def get_my_notifications(
    unread_only: bool = False,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's notifications"""
    notifications = NotificationService.get_user_notifications(
        db, current_user.id, unread_only
    )
    return notifications

@router.put("/{notification_id}/read")
def mark_notification_read(
    notification_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    """Mark notification as read"""
    success = NotificationService.mark_notification_read(
        db, notification_id, current_user.id
    )
    
    if not success:
        raise HTTPException(status_code=404, detail="Notification not found")
    
    return {"message": "Notification marked as read"}

@router.get("/upcoming-dues", response_model=schemas.DueReminderResponse)
def get_upcoming_dues(
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's upcoming loan dues"""
    due_reminder = NotificationService.get_upcoming_dues(db, current_user.id)
    
    # Send maintenance reminder for each upcoming due
    for due in due_reminder.upcoming_dues:
        from datetime import datetime
        due_date = datetime.fromisoformat(due["due_date"]).date()
        NotificationService.send_maintenance_reminder(
            db, current_user.id, due["emi_amount"], due_date
        )
    
    return due_reminder

@router.post("/test-reminder/{user_id}")
def test_reminder(
    user_id: int,
    db: Session = Depends(get_db)
):
    """Test endpoint to create a sample reminder notification"""
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Create test notification
    notification = models.Notification(
        user_id=user_id,
        title="🧪 Test Reminder",
        message="This is a test notification for loan due reminder system.",
        notification_type="test_reminder"
    )
    
    db.add(notification)
    db.commit()
    db.refresh(notification)
    
    return {"message": "Test notification created", "notification_id": notification.id}

@router.post("/send-maintenance-reminders")
def send_maintenance_reminders(
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    """Send maintenance reminders to all users (Admin endpoint)"""
    def send_reminders():
        notifications_sent = NotificationService.send_due_reminders(db)
        return notifications_sent
    
    background_tasks.add_task(send_reminders)
    return {"message": "Maintenance reminders are being sent in background"}