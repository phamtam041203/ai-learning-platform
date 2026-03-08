# backend/app/ml/chatbot/bert_qa.py
from transformers import (
    AutoTokenizer, 
    AutoModelForQuestionAnswering,
    pipeline
)
import torch
from typing import List, Dict, Tuple
import logging

logger = logging.getLogger(__name__)

class BERTQuestionAnswering:
    """
    BERT-based Question Answering system for course materials
    Using PhoBERT for Vietnamese language support
    """
    
    def __init__(self, model_name: str = "vinai/phobert-base"):
        self.model_name = model_name
        self.tokenizer = None
        self.model = None
        self.qa_pipeline = None
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        
        self._load_model()
    
    def _load_model(self):
        """Load BERT model and tokenizer"""
        try:
            logger.info(f"Loading BERT model: {self.model_name}")
            
            # For Vietnamese, use PhoBERT
            self.tokenizer = AutoTokenizer.from_pretrained(
                self.model_name,
                use_fast=False
            )
            
            # Load model for QA
            # Note: PhoBERT base needs to be fine-tuned for QA
            # For production, use a QA-specific model or fine-tune
            self.model = AutoModelForQuestionAnswering.from_pretrained(
                "nguyenvulebinh/vi-mrc-base"  # Vietnamese MRC model
            )
            
            self.model.to(self.device)
            
            # Create pipeline
            self.qa_pipeline = pipeline(
                "question-answering",
                model=self.model,
                tokenizer=self.tokenizer,
                device=0 if self.device == "cuda" else -1
            )
            
            logger.info("BERT model loaded successfully")
            
        except Exception as e:
            logger.error(f"Error loading BERT model: {e}")
            raise
    
    def answer_question(self, 
                       question: str, 
                       context: str,
                       top_k: int = 3) -> List[Dict]:
        """
        Answer a question based on given context
        
        Args:
            question: User's question
            context: Text context to search answer from
            top_k: Number of candidate answers
            
        Returns:
            List of answer candidates with scores
        """
        try:
            result = self.qa_pipeline(
                question=question,
                context=context,
                top_k=top_k,
                max_answer_len=200,
                handle_impossible_answer=True
            )
            
            # Ensure result is a list
            if isinstance(result, dict):
                result = [result]
            
            # Format results
            answers = []
            for ans in result:
                answers.append({
                    'answer': ans['answer'],
                    'score': float(ans['score']),
                    'start': ans['start'],
                    'end': ans['end']
                })
            
            return answers
            
        except Exception as e:
            logger.error(f"Error in question answering: {e}")
            return [{'answer': 'Xin lỗi, tôi không thể trả lời câu hỏi này.', 
                    'score': 0.0}]
    
    def batch_answer(self, 
                    questions: List[str],
                    contexts: List[str]) -> List[Dict]:
        """Answer multiple questions at once"""
        results = []
        
        for question, context in zip(questions, contexts):
            answer = self.answer_question(question, context, top_k=1)
            results.append(answer[0] if answer else None)
        
        return results

# backend/app/ml/chatbot/gpt_assistant.py
import openai
from typing import List, Dict, Optional
import logging
from app.config import settings

logger = logging.getLogger(__name__)

class GPTAssistant:
    """
    GPT-based conversational assistant for general queries
    and personalized guidance
    """
    
    def __init__(self):
        openai.api_key = settings.OPENAI_API_KEY
        self.model = settings.GPT_MODEL_NAME
        self.conversation_history = {}
        
    def _build_system_prompt(self) -> str:
        """Build system prompt for the assistant"""
        return """Bạn là trợ giảng AI thông minh của Đại học Văn Lang, khoa Công nghệ Thông tin.
        
Nhiệm vụ của bạn:
1. Trả lời câu hỏi của sinh viên về nội dung học tập
2. Giải thích các khái niệm phức tạp một cách dễ hiểu
3. Đưa ra lời khuyên về phương pháp học tập
4. Gợi ý tài liệu và bài tập phù hợp
5. Động viên và hỗ trợ sinh viên

Phong cách:
- Thân thiện, nhiệt tình
- Giải thích rõ ràng, có ví dụ cụ thể
- Khuyến khích tư duy phản biện
- Tôn trọng và kiên nhẫn

Hãy luôn trả lời bằng tiếng Việt và điều chỉnh độ khó phù hợp với trình độ sinh viên."""
    
    def chat(self, 
            user_id: int,
            message: str,
            context: Optional[Dict] = None,
            max_history: int = 10) -> str:
        """
        Chat with GPT assistant
        
        Args:
            user_id: User ID for maintaining conversation history
            message: User's message
            context: Additional context (user profile, current course, etc.)
            max_history: Maximum conversation history to maintain
        """
        try:
            # Initialize conversation history for user
            if user_id not in self.conversation_history:
                self.conversation_history[user_id] = []
            
            # Build messages
            messages = [
                {"role": "system", "content": self._build_system_prompt()}
            ]
            
            # Add context if provided
            if context:
                context_msg = self._format_context(context)
                messages.append({
                    "role": "system", 
                    "content": f"Thông tin sinh viên: {context_msg}"
                })
            
            # Add conversation history
            history = self.conversation_history[user_id][-max_history:]
            messages.extend(history)
            
            # Add current message
            messages.append({"role": "user", "content": message})
            
            # Call GPT API
            response = openai.ChatCompletion.create(
                model=self.model,
                messages=messages,
                temperature=0.7,
                max_tokens=500,
                top_p=0.9,
                frequency_penalty=0.3,
                presence_penalty=0.3
            )
            
            assistant_message = response.choices[0].message.content
            
            # Update conversation history
            self.conversation_history[user_id].extend([
                {"role": "user", "content": message},
                {"role": "assistant", "content": assistant_message}
            ])
            
            # Trim history if too long
            if len(self.conversation_history[user_id]) > max_history * 2:
                self.conversation_history[user_id] = \
                    self.conversation_history[user_id][-max_history*2:]
            
            return assistant_message
            
        except Exception as e:
            logger.error(f"Error in GPT chat: {e}")
            return "Xin lỗi, tôi gặp sự cố kỹ thuật. Vui lòng thử lại sau."
    
    def _format_context(self, context: Dict) -> str:
        """Format context information"""
        parts = []
        
        if 'name' in context:
            parts.append(f"Tên: {context['name']}")
        if 'course' in context:
            parts.append(f"Môn học: {context['course']}")
        if 'level' in context:
            parts.append(f"Trình độ: {context['level']}")
        if 'interests' in context:
            parts.append(f"Sở thích: {', '.join(context['interests'])}")
        
        return ", ".join(parts)
    
    def clear_history(self, user_id: int):
        """Clear conversation history for a user"""
        if user_id in self.conversation_history:
            del self.conversation_history[user_id]
    
    def summarize_content(self, content: str, max_length: int = 200) -> str:
        """Summarize course content"""
        try:
            prompt = f"""Hãy tóm tắt nội dung sau thành {max_length} từ, 
            bằng tiếng Việt, giữ lại các ý chính:

{content}

Tóm tắt:"""
            
            response = openai.ChatCompletion.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": "Bạn là chuyên gia tóm tắt nội dung học tập."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.5,
                max_tokens=max_length * 2
            )
            
            return response.choices[0].message.content
            
        except Exception as e:
            logger.error(f"Error in summarization: {e}")
            return "Không thể tóm tắt nội dung này."
    
    def explain_concept(self, concept: str, level: str = "beginner") -> str:
        """Explain a concept at appropriate level"""
        level_prompts = {
            "beginner": "dễ hiểu cho người mới bắt đầu, có ví dụ đơn giản",
            "intermediate": "chi tiết hơn với các ví dụ thực tế",
            "advanced": "chuyên sâu với các khía cạnh kỹ thuật"
        }
        
        prompt = f"""Hãy giải thích khái niệm '{concept}' một cách {level_prompts.get(level, level_prompts['beginner'])}.

Giải thích:"""
        
        try:
            response = openai.ChatCompletion.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": self._build_system_prompt()},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=400
            )
            
            return response.choices[0].message.content
            
        except Exception as e:
            logger.error(f"Error in explanation: {e}")
            return f"Không thể giải thích khái niệm '{concept}'."