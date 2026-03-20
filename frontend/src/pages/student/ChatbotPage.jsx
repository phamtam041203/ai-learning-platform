import { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Send, Paperclip, Mic, MoreVertical, Sparkles,
  BookOpen, Code, FileText, MessageCircle, X,
  Copy, ThumbsUp, ThumbsDown, RefreshCw, Volume2
} from 'lucide-react';
import StudentSidebar from '../../components/StudentSidebar';
import './ChatbotPage.css';

const ChatbotPage = () => {
  const navigate = useNavigate();
  const [darkMode, setDarkMode] = useState(localStorage.getItem('darkMode') === 'true');
  const [messages, setMessages] = useState([
    {
      id: 1,
      type: 'bot',
      content: 'Xin chào! Tôi là trợ lý AI của bạn. Tôi có thể giúp bạn:\n- Giải thích khái niệm và lý thuyết\n- Hướng dẫn làm bài tập\n- Tóm tắt tài liệu\n- Trả lời câu hỏi về khóa học\n\nBạn cần hỗ trợ gì hôm nay?',
      timestamp: new Date(),
      suggestions: [
        'Giải thích về Neural Networks',
        'Hướng dẫn làm bài tập Python',
        'Tóm tắt bài giảng tuần này'
      ]
    }
  ]);
  const [inputMessage, setInputMessage] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const [selectedFile, setSelectedFile] = useState(null);
  const messagesEndRef = useRef(null);
  const fileInputRef = useRef(null);

  // Initialize dark mode
  useEffect(() => {
    const storedDarkMode = localStorage.getItem('darkMode') === 'true';
    setDarkMode(storedDarkMode);
    if (storedDarkMode) {
      document.documentElement.setAttribute('data-theme', 'dark');
    }
  }, []);

  const toggleDarkMode = () => {
    const newDarkMode = !darkMode;
    setDarkMode(newDarkMode);
    localStorage.setItem('darkMode', newDarkMode);
    if (newDarkMode) {
      document.documentElement.setAttribute('data-theme', 'dark');
    } else {
      document.documentElement.removeAttribute('data-theme');
    }
  };

  // Auto scroll to bottom
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const quickActions = [
    { icon: <BookOpen className="w-5 h-5" />, label: 'Giải thích khái niệm', action: 'explain' },
    { icon: <Code className="w-5 h-5" />, label: 'Debug code', action: 'debug' },
    { icon: <FileText className="w-5 h-5" />, label: 'Tóm tắt tài liệu', action: 'summarize' },
    { icon: <MessageCircle className="w-5 h-5" />, label: 'Hỏi đáp', action: 'qa' }
  ];

  const exampleQuestions = [
    'Sự khác biệt giữa Supervised và Unsupervised Learning là gì?',
    'Hướng dẫn tôi cách implement Binary Search Tree',
    'Giải thích thuật toán XGBoost hoạt động như thế nào?',
    'Python list comprehension là gì?'
  ];

  const handleSendMessage = async () => {
    if (!inputMessage.trim() && !selectedFile) return;

    const userMessage = {
      id: Date.now(),
      type: 'user',
      content: inputMessage,
      timestamp: new Date(),
      file: selectedFile
    };

    setMessages(prev => [...prev, userMessage]);
    setInputMessage('');
    setSelectedFile(null);
    setIsTyping(true);

    // Simulate AI response
    setTimeout(() => {
      const botMessage = {
        id: Date.now() + 1,
        type: 'bot',
        content: generateMockResponse(inputMessage),
        timestamp: new Date(),
        codeBlock: inputMessage.toLowerCase().includes('code') || inputMessage.toLowerCase().includes('python')
      };
      setMessages(prev => [...prev, botMessage]);
      setIsTyping(false);
    }, 1500);
  };

  const generateMockResponse = (question) => {
    if (question.toLowerCase().includes('neural network')) {
      return `**Neural Network** (Mạng nơ-ron nhân tạo) là một mô hình học máy lấy cảm hứng từ cách hoạt động của não người.\n\n**Cấu trúc:**\n1. **Input Layer** - Nhận dữ liệu đầu vào\n2. **Hidden Layers** - Xử lý và trích xuất features\n3. **Output Layer** - Đưa ra kết quả dự đoán\n\n**Ví dụ code Python:**\n\`\`\`python\nimport tensorflow as tf\n\nmodel = tf.keras.Sequential([\n    tf.keras.layers.Dense(128, activation='relu', input_shape=(784,)),\n    tf.keras.layers.Dense(64, activation='relu'),\n    tf.keras.layers.Dense(10, activation='softmax')\n])\n\nmodel.compile(optimizer='adam',\n              loss='categorical_crossentropy',\n              metrics=['accuracy'])\n\`\`\`\n\nBạn có muốn tôi giải thích chi tiết về từng layer không?`;
    }
    
    if (question.toLowerCase().includes('python')) {
      return `Đây là hướng dẫn về Python:\n\n\`\`\`python\n# Example Python code\ndef calculate_sum(numbers):\n    return sum(numbers)\n\n# Usage\nresult = calculate_sum([1, 2, 3, 4, 5])\nprint(f"Sum: {result}")\n\`\`\`\n\nBạn có câu hỏi gì về đoạn code này không?`;
    }

    return `Tôi hiểu câu hỏi của bạn về "${question}". \n\nĐây là câu trả lời chi tiết:\n\n1. Trước tiên, chúng ta cần hiểu khái niệm cơ bản\n2. Sau đó áp dụng vào ví dụ thực tế\n3. Cuối cùng là các best practices\n\nBạn có muốn tôi giải thích chi tiết hơn phần nào không?`;
  };

  const handleFileSelect = (e) => {
    const file = e.target.files[0];
    if (file) {
      setSelectedFile({
        name: file.name,
        size: (file.size / 1024).toFixed(2) + ' KB',
        type: file.type
      });
    }
  };

  const handleSuggestionClick = (suggestion) => {
    setInputMessage(suggestion);
  };

  const handleQuickAction = (action) => {
    const prompts = {
      explain: 'Giải thích cho tôi về ',
      debug: 'Giúp tôi debug đoạn code này: ',
      summarize: 'Tóm tắt nội dung này: ',
      qa: 'Tôi có câu hỏi: '
    };
    setInputMessage(prompts[action]);
  };

  const copyMessage = (content) => {
    navigator.clipboard.writeText(content);
  };

  const handleFeedback = (messageId, type) => {
    console.log(`Feedback for message ${messageId}: ${type}`);
    // TODO: Send feedback to backend
  };

  return (
    <div className="student-page-shell">
      <StudentSidebar darkMode={darkMode} onToggleDarkMode={toggleDarkMode} />
      <div className="student-page-main chatbot-page">
      {/* Header */}
      <div className="chatbot-header">
        <div className="header-left">
          <div className="ai-avatar">
            <Sparkles className="w-6 h-6" />
          </div>
          <div className="header-info">
            <h2 className="header-title">AI Teaching Assistant</h2>
            <p className="header-status">
              <span className="status-dot"></span>
              Online • Sẵn sàng hỗ trợ
            </p>
          </div>
        </div>
        <div className="header-actions">
          <button className="header-button">
            <Volume2 className="w-5 h-5" />
          </button>
          <button className="header-button">
            <RefreshCw className="w-5 h-5" />
          </button>
          <button className="header-button">
            <MoreVertical className="w-5 h-5" />
          </button>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="quick-actions">
        {quickActions.map((action, index) => (
          <button
            key={index}
            className="quick-action-btn"
            onClick={() => handleQuickAction(action.action)}
          >
            {action.icon}
            <span>{action.label}</span>
          </button>
        ))}
      </div>

      {/* Messages Container */}
      <div className="messages-container">
        {messages.length === 1 && (
          <div className="welcome-section">
            <div className="welcome-icon">
              <Sparkles className="w-12 h-12" />
            </div>
            <h3 className="welcome-title">Xin chào! Tôi là AI Assistant VLU</h3>
            <p className="welcome-description">
              Tôi được huấn luyện bằng GPT-4 và BERT để hỗ trợ bạn học tập
            </p>
            <div className="example-questions">
              <p className="example-label">Câu hỏi mẫu:</p>
              {exampleQuestions.map((question, index) => (
                <button
                  key={index}
                  className="example-question"
                  onClick={() => handleSuggestionClick(question)}
                >
                  {question}
                </button>
              ))}
            </div>
          </div>
        )}

        {messages.map((message) => (
          <div key={message.id} className={`message ${message.type}`}>
            <div className="message-avatar">
              {message.type === 'bot' ? (
                <Sparkles className="w-5 h-5" />
              ) : (
                <span>👨‍🎓</span>
              )}
            </div>
            <div className="message-content-wrapper">
              <div className="message-header">
                <span className="message-sender">
                  {message.type === 'bot' ? 'AI Assistant' : 'Bạn'}
                </span>
                <span className="message-time">
                  {message.timestamp.toLocaleTimeString('vi-VN', {
                    hour: '2-digit',
                    minute: '2-digit'
                  })}
                </span>
              </div>
              <div className="message-content">
                {message.file && (
                  <div className="message-file">
                    <FileText className="w-4 h-4" />
                    <div>
                      <div className="file-name">{message.file.name}</div>
                      <div className="file-size">{message.file.size}</div>
                    </div>
                  </div>
                )}
                <div className="message-text">
                  {formatMessage(message.content)}
                </div>
                {message.suggestions && (
                  <div className="message-suggestions">
                    {message.suggestions.map((suggestion, index) => (
                      <button
                        key={index}
                        className="suggestion-chip"
                        onClick={() => handleSuggestionClick(suggestion)}
                      >
                        {suggestion}
                      </button>
                    ))}
                  </div>
                )}
              </div>
              {message.type === 'bot' && (
                <div className="message-actions">
                  <button
                    className="action-btn"
                    onClick={() => copyMessage(message.content)}
                    title="Copy"
                  >
                    <Copy className="w-4 h-4" />
                  </button>
                  <button
                    className="action-btn"
                    onClick={() => handleFeedback(message.id, 'up')}
                    title="Hữu ích"
                  >
                    <ThumbsUp className="w-4 h-4" />
                  </button>
                  <button
                    className="action-btn"
                    onClick={() => handleFeedback(message.id, 'down')}
                    title="Không hữu ích"
                  >
                    <ThumbsDown className="w-4 h-4" />
                  </button>
                </div>
              )}
            </div>
          </div>
        ))}

        {isTyping && (
          <div className="message bot">
            <div className="message-avatar">
              <Sparkles className="w-5 h-5" />
            </div>
            <div className="message-content-wrapper">
              <div className="typing-indicator">
                <span></span>
                <span></span>
                <span></span>
              </div>
            </div>
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>

      {/* Input Area */}
      <div className="input-area">
        {selectedFile && (
          <div className="selected-file">
            <FileText className="w-4 h-4" />
            <span>{selectedFile.name}</span>
            <button
              className="remove-file"
              onClick={() => setSelectedFile(null)}
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        )}
        <div className="input-wrapper">
          <input
            type="file"
            ref={fileInputRef}
            style={{ display: 'none' }}
            onChange={handleFileSelect}
            accept=".pdf,.doc,.docx,.txt,.py,.js,.jsx"
          />
          <button
            className="input-action-btn"
            onClick={() => fileInputRef.current?.click()}
          >
            <Paperclip className="w-5 h-5" />
          </button>
          <input
            type="text"
            className="message-input"
            placeholder="Nhập câu hỏi của bạn..."
            value={inputMessage}
            onChange={(e) => setInputMessage(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
          />
          <button className="input-action-btn">
            <Mic className="w-5 h-5" />
          </button>
          <button
            className="send-button"
            onClick={handleSendMessage}
            disabled={!inputMessage.trim() && !selectedFile}
          >
            <Send className="w-5 h-5" />
          </button>
        </div>
        <p className="input-hint">
          AI có thể mắc lỗi. Hãy kiểm tra thông tin quan trọng.
        </p>
      </div>
      </div>
    </div>
  );
};

// Helper function to format message with markdown
const formatMessage = (content) => {
  const lines = content.split('\n');
  return lines.map((line, index) => {
    // Code block
    if (line.startsWith('```')) {
      return null;
    }
    // Bold
    if (line.includes('**')) {
      const parts = line.split('**');
      return (
        <p key={index}>
          {parts.map((part, i) =>
            i % 2 === 1 ? <strong key={i}>{part}</strong> : part
          )}
        </p>
      );
    }
    // Regular line
    return <p key={index}>{line}</p>;
  });
};

export default ChatbotPage;