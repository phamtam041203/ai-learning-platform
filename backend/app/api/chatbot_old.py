# backend/app/api/chatbot.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional, List
import logging

from app.database import get_db, get_mongo_db
from app.models.user import User
from app.api.auth import get_current_user
from app.ml.chatbot.bert_qa import BERTQuestionAnswering
from app.ml.chatbot.gpt_assistant import GPTAssistant

router = APIRouter()
logger = logging.getLogger(__name__)

# Initialize AI models (singleton pattern)
bert_qa = None
gpt_assistant = None

def get_bert_qa():
    global bert_qa
    if bert_qa is None:
        bert_qa = BERTQuestionAnswering()
    return bert_qa

def get_gpt_assistant():
    global gpt_assistant
    if gpt_assistant is None:
        gpt_assistant = GPTAssistant()
    return gpt_assistant

class ChatMessage(BaseModel):
    message: str
    context: Optional[str] = None
    chat_type: str = "general"  # 'general', 'qa', 'explain'

class QARequest(BaseModel):
    question: str
    material_id: Optional[int] = None
    context: Optional[str] = None

class ExplainRequest(BaseModel):
    concept: str
    level: str = "beginner"  # beginner, intermediate, advanced

@router.post("/chat")
async def chat(
    request: ChatMessage,
    current_user: User = Depends(get_current_user),
    mongo_db = Depends(get_mongo_db)
):
    """
    General chatbot endpoint
    Routes to appropriate AI model based on chat_type
    """
    try:
        assistant = get_gpt_assistant()
        
        # Build context from user profile
        context = {
            "name": current_user.full_name,
            "student_id": current_user.student_id,
            "department": current_user.department
        }
        
        # Get response from GPT
        response = assistant.chat(
            user_id=current_user.id,
            message=request.message,
            context=context
        )
        
        # Save conversation to MongoDB
        conversation = {
            "user_id": current_user.id,
            "message": request.message,
            "response": response,
            "chat_type": request.chat_type,
            "timestamp": datetime.utcnow()
        }
        mongo_db.conversations.insert_one(conversation)
        
        return {
            "response": response,
            "type": "gpt",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Chat error: {e}")
        raise HTTPException(status_code=500, detail="Chat service error")

@router.post("/qa")
async def question_answering(
    request: QARequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Question Answering using BERT
    Finds answers from course materials
    """
    try:
        qa_model = get_bert_qa()
        
        # If material_id provided, get content from database
        if request.material_id:
            from app.models.course import CourseMaterial
            material = db.query(CourseMaterial).filter(
                CourseMaterial.id == request.material_id
            ).first()
            
            if not material:
                raise HTTPException(status_code=404, detail="Material not found")
            
            context = material.content
        elif request.context:
            context = request.context
        else:
            raise HTTPException(
                status_code=400, 
                detail="Either material_id or context must be provided"
            )
        
        # Get answer
        answers = qa_model.answer_question(
            question=request.question,
            context=context,
            top_k=3
        )
        
        return {
            "question": request.question,
            "answers": answers,
            "material_id": request.material_id
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"QA error: {e}")
        raise HTTPException(status_code=500, detail="QA service error")

@router.post("/explain")
async def explain_concept(
    request: ExplainRequest,
    current_user: User = Depends(get_current_user)
):
    """
    Explain a concept using GPT
    Adjusts explanation based on user level
    """
    try:
        assistant = get_gpt_assistant()
        
        explanation = assistant.explain_concept(
            concept=request.concept,
            level=request.level
        )
        
        return {
            "concept": request.concept,
            "level": request.level,
            "explanation": explanation
        }
        
    except Exception as e:
        logger.error(f"Explain error: {e}")
        raise HTTPException(status_code=500, detail="Explanation service error")

@router.post("/summarize")
async def summarize_content(
    material_id: int,
    max_length: int = 200,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Summarize course material content"""
    try:
        from app.models.course import CourseMaterial
        
        material = db.query(CourseMaterial).filter(
            CourseMaterial.id == material_id
        ).first()
        
        if not material:
            raise HTTPException(status_code=404, detail="Material not found")
        
        assistant = get_gpt_assistant()
        summary = assistant.summarize_content(
            content=material.content,
            max_length=max_length
        )
        
        return {
            "material_id": material_id,
            "title": material.title,
            "summary": summary
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Summarize error: {e}")
        raise HTTPException(status_code=500, detail="Summarization service error")

@router.get("/history")
async def get_chat_history(
    limit: int = 50,
    current_user: User = Depends(get_current_user),
    mongo_db = Depends(get_mongo_db)
):
    """Get user's chat history"""
    try:
        conversations = list(
            mongo_db.conversations.find(
                {"user_id": current_user.id}
            ).sort("timestamp", -1).limit(limit)
        )
        
        # Convert ObjectId to string
        for conv in conversations:
            conv['_id'] = str(conv['_id'])
        
        return {"conversations": conversations}
        
    except Exception as e:
        logger.error(f"History error: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch history")

@router.delete("/history")
async def clear_chat_history(
    current_user: User = Depends(get_current_user),
    mongo_db = Depends(get_mongo_db)
):
    """Clear user's chat history"""
    try:
        assistant = get_gpt_assistant()
        assistant.clear_history(current_user.id)
        
        mongo_db.conversations.delete_many({"user_id": current_user.id})
        
        return {"message": "Chat history cleared"}
        
    except Exception as e:
        logger.error(f"Clear history error: {e}")
        raise HTTPException(status_code=500, detail="Failed to clear history")

from datetime import datetime# backend/app/api/chatbot.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional, List
import logging

from app.database import get_db, get_mongo_db
from app.models.user import User
from app.api.auth import get_current_user
from app.ml.chatbot.bert_qa import BERTQuestionAnswering
from app.ml.chatbot.gpt_assistant import GPTAssistant

router = APIRouter()
logger = logging.getLogger(__name__)

# Initialize AI models (singleton pattern)
bert_qa = None
gpt_assistant = None

def get_bert_qa():
    global bert_qa
    if bert_qa is None:
        bert_qa = BERTQuestionAnswering()
    return bert_qa

def get_gpt_assistant():
    global gpt_assistant
    if gpt_assistant is None:
        gpt_assistant = GPTAssistant()
    return gpt_assistant

class ChatMessage(BaseModel):
    message: str
    context: Optional[str] = None
    chat_type: str = "general"  # 'general', 'qa', 'explain'

class QARequest(BaseModel):
    question: str
    material_id: Optional[int] = None
    context: Optional[str] = None

class ExplainRequest(BaseModel):
    concept: str
    level: str = "beginner"  # beginner, intermediate, advanced

@router.post("/chat")
async def chat(
    request: ChatMessage,
    current_user: User = Depends(get_current_user),
    mongo_db = Depends(get_mongo_db)
):
    """
    General chatbot endpoint
    Routes to appropriate AI model based on chat_type
    """
    try:
        assistant = get_gpt_assistant()
        
        # Build context from user profile
        context = {
            "name": current_user.full_name,
            "student_id": current_user.student_id,
            "department": current_user.department
        }
        
        # Get response from GPT
        response = assistant.chat(
            user_id=current_user.id,
            message=request.message,
            context=context
        )
        
        # Save conversation to MongoDB
        conversation = {
            "user_id": current_user.id,
            "message": request.message,
            "response": response,
            "chat_type": request.chat_type,
            "timestamp": datetime.utcnow()
        }
        mongo_db.conversations.insert_one(conversation)
        
        return {
            "response": response,
            "type": "gpt",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Chat error: {e}")
        raise HTTPException(status_code=500, detail="Chat service error")

@router.post("/qa")
async def question_answering(
    request: QARequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Question Answering using BERT
    Finds answers from course materials
    """
    try:
        qa_model = get_bert_qa()
        
        # If material_id provided, get content from database
        if request.material_id:
            from app.models.course import CourseMaterial
            material = db.query(CourseMaterial).filter(
                CourseMaterial.id == request.material_id
            ).first()
            
            if not material:
                raise HTTPException(status_code=404, detail="Material not found")
            
            context = material.content
        elif request.context:
            context = request.context
        else:
            raise HTTPException(
                status_code=400, 
                detail="Either material_id or context must be provided"
            )
        
        # Get answer
        answers = qa_model.answer_question(
            question=request.question,
            context=context,
            top_k=3
        )
        
        return {
            "question": request.question,
            "answers": answers,
            "material_id": request.material_id
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"QA error: {e}")
        raise HTTPException(status_code=500, detail="QA service error")

@router.post("/explain")
async def explain_concept(
    request: ExplainRequest,
    current_user: User = Depends(get_current_user)
):
    """
    Explain a concept using GPT
    Adjusts explanation based on user level
    """
    try:
        assistant = get_gpt_assistant()
        
        explanation = assistant.explain_concept(
            concept=request.concept,
            level=request.level
        )
        
        return {
            "concept": request.concept,
            "level": request.level,
            "explanation": explanation
        }
        
    except Exception as e:
        logger.error(f"Explain error: {e}")
        raise HTTPException(status_code=500, detail="Explanation service error")

@router.post("/summarize")
async def summarize_content(
    material_id: int,
    max_length: int = 200,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Summarize course material content"""
    try:
        from app.models.course import CourseMaterial
        
        material = db.query(CourseMaterial).filter(
            CourseMaterial.id == material_id
        ).first()
        
        if not material:
            raise HTTPException(status_code=404, detail="Material not found")
        
        assistant = get_gpt_assistant()
        summary = assistant.summarize_content(
            content=material.content,
            max_length=max_length
        )
        
        return {
            "material_id": material_id,
            "title": material.title,
            "summary": summary
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Summarize error: {e}")
        raise HTTPException(status_code=500, detail="Summarization service error")

@router.get("/history")
async def get_chat_history(
    limit: int = 50,
    current_user: User = Depends(get_current_user),
    mongo_db = Depends(get_mongo_db)
):
    """Get user's chat history"""
    try:
        conversations = list(
            mongo_db.conversations.find(
                {"user_id": current_user.id}
            ).sort("timestamp", -1).limit(limit)
        )
        
        # Convert ObjectId to string
        for conv in conversations:
            conv['_id'] = str(conv['_id'])
        
        return {"conversations": conversations}
        
    except Exception as e:
        logger.error(f"History error: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch history")

@router.delete("/history")
async def clear_chat_history(
    current_user: User = Depends(get_current_user),
    mongo_db = Depends(get_mongo_db)
):
    """Clear user's chat history"""
    try:
        assistant = get_gpt_assistant()
        assistant.clear_history(current_user.id)
        
        mongo_db.conversations.delete_many({"user_id": current_user.id})
        
        return {"message": "Chat history cleared"}
        
    except Exception as e:
        logger.error(f"Clear history error: {e}")
        raise HTTPException(status_code=500, detail="Failed to clear history")

from datetime import datetime
# ==========================================
# AI ADVISOR ENDPOINTS  
# ==========================================

from app.services.student_advisor import StudentAdvisor

@router.get("/advisor/analyze")
async def analyze_student(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Analyze student profile and performance"""
    try:
        advisor = StudentAdvisor(db)
        analysis = advisor.analyze_student_profile(current_user.id)
        return analysis
    except Exception as e:
        logger.error(f"Analysis error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to analyze student: {str(e)}")

@router.post("/advisor/ask")
async def ask_advisor(
    request: ChatMessage,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Ask AI advisor for personalized advice"""
    try:
        advisor = StudentAdvisor(db)
        analysis = advisor.analyze_student_profile(current_user.id)
        advice = advisor.get_ai_advice(current_user.id, request.message)
        
        return {
            'question': request.message,
            'advice': advice,
            'analysis_summary': {
                'overall_score': analysis['overall_score'],
                'strengths_count': len(analysis['strengths']),
                'weaknesses_count': len(analysis['weaknesses']),
                'recommendations_count': len(analysis['recommendations'])
            }
        }
    except Exception as e:
        logger.error(f"Advisor ask error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get advice: {str(e)}")
