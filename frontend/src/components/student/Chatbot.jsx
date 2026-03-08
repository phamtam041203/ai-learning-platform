// ============================================
// 📁 frontend/src/components/ChatBot/ChatBot.jsx
// ============================================

import { useState, useEffect, useRef } from 'react';
import { Send, X, MessageSquare, Trash2, RefreshCw } from 'lucide-react';
import chatbotAPI from '../../api/chatbot.api';
import './ChatBot.css';

const ChatBot = ({ isOpen, onClose }) => {
  const [messages, setMessages] = useState([]);
  const [inputMessage, setInputMessage] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [suggestions, setSuggestions] = useState([]);
  const [showSuggestions, setShowSuggestions] = useState(true);
  const messagesEndRef = useRef(null);
  const inputRef = useRef(null);

  // Load chat history khi mở
  useEffect(() => {
    if (isOpen) {
      loadChatHistory();
      loadSuggestions();
      inputRef.current?.focus();
    }
  }, [isOpen]);

  // Auto scroll khi có tin nhắn mới
  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const loadChatHistory = async () => {
    try {
      const response = await chatbotAPI.getHistory(20);
      if (response.success) {
        setMessages(response.history);
        setShowSuggestions(response.history.length === 0);
      }
    } catch (error) {
      console.error('Load history error:', error);
    }
  };

  const loadSuggestions = async () => {
    try {
      const response = await chatbotAPI.getSuggestions();
      if (response.success) {
        setSuggestions(response.suggestions);
      }
    } catch (error) {
      console.error('Load suggestions error:', error);
    }
  };

  const handleSendMessage = async (messageText = null) => {
    const message = messageText || inputMessage.trim();
    if (!message) return;

    // Thêm tin nhắn user vào UI
    const userMessage = {
      chat_id: Date.now(),
      message: message,
      role: 'user',
      created_at: new Date().toISOString()
    };

    setMessages(prev => [...prev, userMessage]);
    setInputMessage('');
    setIsLoading(true);
    setShowSuggestions(false);

    try {
      const response = await chatbotAPI.sendMessage(message);
      
      if (response.success) {
        const aiMessage = {
          chat_id: Date.now() + 1,
          message: response.response,
          role: 'assistant',
          created_at: new Date().toISOString(),
          suggestions: response.suggestions
        };
        
        setMessages(prev => [...prev, aiMessage]);
      }
    } catch (error) {
      console.error('Send message error:', error);
      
      // Error message
      const errorMessage = {
        chat_id: Date.now() + 1,
        message: 'Xin lỗi, tôi đang gặp sự cố kỹ thuật. Vui lòng thử lại sau! 😔',
        role: 'assistant',
        created_at: new Date().toISOString(),
        isError: true
      };
      
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };

  const handleClearHistory = async () => {
    if (!window.confirm('Bạn có chắc muốn xóa toàn bộ lịch sử chat?')) {
      return;
    }

    try {
      await chatbotAPI.clearHistory();
      setMessages([]);
      setShowSuggestions(true);
    } catch (error) {
      console.error('Clear history error:', error);
      alert('Không thể xóa lịch sử');
    }
  };

  const handleSuggestionClick = (question) => {
    handleSendMessage(question);
  };

  const formatTime = (timestamp) => {
    const date = new Date(timestamp);
    return date.toLocaleTimeString('vi-VN', { 
      hour: '2-digit', 
      minute: '2-digit' 
    });
  };

  if (!isOpen) return null;

  return (
    <div className="chatbot-overlay">
      <div className="chatbot-container">
        {/* Header */}
        <div className="chatbot-header">
          <div className="chatbot-header-info">
            <div className="bot-avatar">🤖</div>
            <div>
              <h3>AI Learning Assistant</h3>
              <p className="bot-status">
                <span className="status-dot"></span>
                Trực tuyến
              </p>
            </div>
          </div>
          <div className="chatbot-header-actions">
            <button 
              className="icon-btn" 
              onClick={handleClearHistory}
              title="Xóa lịch sử"
            >
              <Trash2 size={18} />
            </button>
            <button 
              className="icon-btn" 
              onClick={onClose}
              title="Đóng"
            >
              <X size={20} />
            </button>
          </div>
        </div>

        {/* Messages */}
        <div className="chatbot-messages">
          {messages.length === 0 && showSuggestions ? (
            <div className="welcome-screen">
              <div className="welcome-icon">👋</div>
              <h2>Xin chào!</h2>
              <p>Tôi là trợ lý AI của bạn. Tôi có thể giúp gì cho bạn hôm nay?</p>
              
              <div className="suggestion-categories">
                {suggestions.map((category, idx) => (
                  <div key={idx} className="suggestion-category">
                    <h4>{category.icon} {category.category}</h4>
                    <div className="suggestion-buttons">
                      {category.questions.slice(0, 3).map((question, qIdx) => (
                        <button
                          key={qIdx}
                          className="suggestion-btn"
                          onClick={() => handleSuggestionClick(question)}
                        >
                          {question}
                        </button>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          ) : (
            <>
              {messages.map((msg) => (
                <div
                  key={msg.chat_id}
                  className={`message ${msg.role} ${msg.isError ? 'error' : ''}`}
                >
                  <div className="message-avatar">
                    {msg.role === 'user' ? '👤' : '🤖'}
                  </div>
                  <div className="message-content">
                    <div className="message-bubble">
                      {msg.message}
                    </div>
                    {msg.suggestions && msg.suggestions.length > 0 && (
                      <div className="message-suggestions">
                        <p className="suggestions-label">💡 Có thể bạn muốn hỏi:</p>
                        {msg.suggestions.map((sug, idx) => (
                          <button
                            key={idx}
                            className="suggestion-chip"
                            onClick={() => handleSuggestionClick(sug)}
                          >
                            {sug}
                          </button>
                        ))}
                      </div>
                    )}
                    <div className="message-time">
                      {formatTime(msg.created_at)}
                    </div>
                  </div>
                </div>
              ))}
              
              {isLoading && (
                <div className="message assistant">
                  <div className="message-avatar">🤖</div>
                  <div className="message-content">
                    <div className="typing-indicator">
                      <span></span>
                      <span></span>
                      <span></span>
                    </div>
                  </div>
                </div>
              )}
            </>
          )}
          <div ref={messagesEndRef} />
        </div>

        {/* Input */}
        <div className="chatbot-input-container">
          <div className="chatbot-input-wrapper">
            <textarea
              ref={inputRef}
              className="chatbot-input"
              placeholder="Nhập câu hỏi của bạn..."
              value={inputMessage}
              onChange={(e) => setInputMessage(e.target.value)}
              onKeyPress={handleKeyPress}
              rows={1}
              disabled={isLoading}
            />
            <button
              className="send-btn"
              onClick={() => handleSendMessage()}
              disabled={!inputMessage.trim() || isLoading}
            >
              <Send size={20} />
            </button>
          </div>
          <p className="chatbot-disclaimer">
            AI có thể mắc lỗi. Hãy kiểm tra thông tin quan trọng.
          </p>
        </div>
      </div>
    </div>
  );
};

export default ChatBot;

// ============================================
// 📁 frontend/src/components/ChatBot/ChatBotButton.jsx
// ============================================

import { useState } from 'react';
import { MessageSquare } from 'lucide-react';
import ChatBot from './student/ChatBot';
import './ChatBotButton.css';

const ChatBotButton = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [hasUnread, setHasUnread] = useState(false);

  return (
    <>
      <button
        className={`chatbot-fab ${isOpen ? 'active' : ''}`}
        onClick={() => setIsOpen(!isOpen)}
        aria-label="Mở chatbot"
      >
        {hasUnread && <span className="unread-badge"></span>}
        <MessageSquare size={24} />
      </button>

      <ChatBot 
        isOpen={isOpen} 
        onClose={() => setIsOpen(false)} 
      />
    </>
  );
};


// ============================================
// 📁 frontend/src/api/chatbot.api.js
// ============================================

import axios from './axios.config';

const chatbotAPI = {
  // Gửi tin nhắn
  sendMessage: async (message, context = {}) => {
    const response = await axios.post('/api/chatbot/send', {
      message,
      context
    });
    return response.data;
  },

  // Lấy lịch sử
  getHistory: async (limit = 50) => {
    const response = await axios.get('/api/chatbot/history', {
      params: { limit }
    });
    return response.data;
  },

  // Xóa lịch sử
  clearHistory: async () => {
    const response = await axios.delete('/api/chatbot/history');
    return response.data;
  },

  // Lấy gợi ý
  getSuggestions: async () => {
    const response = await axios.get('/api/chatbot/suggestions');
    return response.data;
  }
};

