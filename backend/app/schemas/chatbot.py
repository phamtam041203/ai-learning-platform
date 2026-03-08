"""Chatbot schemas"""
from pydantic import BaseModel
from typing import Optional, List

class ChatMessage(BaseModel):
    message: str
    context: Optional[str] = None

class ChatResponse(BaseModel):
    response: str
    confidence: float
    sources: Optional[List[str]] = None