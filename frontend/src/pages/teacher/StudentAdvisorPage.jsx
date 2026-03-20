import { useEffect, useMemo, useState } from 'react';
import { Bot, ClipboardCheck, Loader2, Search, Send, User } from 'lucide-react';
import TeacherLayout from '../../components/TeacherLayout';
import teacherAPI from '../../services/teacherAPI';
import './StudentAdvisorPage.css';

const starterQuestions = [
  'Sinh viên này đang có rủi ro gì?',
  'Nên can thiệp như thế nào trong tuần tới?',
  'Điểm yếu chính hiện tại là gì?',
  'Tiến độ theo từng môn đang ra sao?'
];

const StudentAdvisorPage = () => {
  const [students, setStudents] = useState([]);
  const [selectedStudent, setSelectedStudent] = useState(null);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [loadingHistory, setLoadingHistory] = useState(false);
  const [sending, setSending] = useState(false);
  const [planning, setPlanning] = useState(false);
  const [messages, setMessages] = useState([
    {
      role: 'assistant',
      text: 'Chọn một sinh viên để bắt đầu hỏi VLU Mentor for Teacher. Tôi sẽ trả lời dựa trên dữ liệu học tập trong phạm vi lớp bạn phụ trách.'
    }
  ]);
  const [input, setInput] = useState('');

  useEffect(() => {
    const fetchStudents = async () => {
      try {
        setLoading(true);
        const data = await teacherAPI.getStudents();
        setStudents(Array.isArray(data) ? data : []);
        if (Array.isArray(data) && data.length > 0) {
          setSelectedStudent(data[0]);
        }
      } catch (error) {
        console.error('Failed to load students:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchStudents();
  }, []);

  useEffect(() => {
    if (!selectedStudent) {
      return;
    }

    const loadHistory = async () => {
      try {
        setLoadingHistory(true);
        const history = await teacherAPI.getStudentAdvisorHistory(selectedStudent.id);
        const historyItems = Array.isArray(history?.items) ? history.items : [];

        if (historyItems.length === 0) {
          setMessages([
            {
              role: 'assistant',
              text: `Đã chuyển sang hồ sơ ${selectedStudent.full_name}. Bạn có thể hỏi về tiến độ, rủi ro, điểm số hoặc kế hoạch can thiệp.`
            }
          ]);
          return;
        }

        const mapped = historyItems.flatMap((item) => {
          const rows = [
            {
              role: 'teacher',
              text: item.message
            },
            {
              role: 'assistant',
              text: item.response,
              checklist: Array.isArray(item.checklist) ? item.checklist : []
            }
          ];
          return rows;
        });
        setMessages(mapped);
      } catch (error) {
        setMessages([
          {
            role: 'assistant',
            text: `Không tải được lịch sử hội thoại: ${error.message}`
          }
        ]);
      } finally {
        setLoadingHistory(false);
      }
    };

    loadHistory();
  }, [selectedStudent]);

  const filteredStudents = useMemo(() => {
    if (!search.trim()) {
      return students;
    }
    const term = search.toLowerCase();
    return students.filter((student) =>
      student.full_name?.toLowerCase().includes(term)
      || student.email?.toLowerCase().includes(term)
      || student.student_id?.toLowerCase().includes(term)
    );
  }, [students, search]);

  const sendQuestion = async (questionText) => {
    const question = (questionText || input).trim();
    if (!question || !selectedStudent || sending) {
      return;
    }

    setInput('');
    setSending(true);
    setMessages((prev) => [...prev, { role: 'teacher', text: question }]);

    try {
      const response = await teacherAPI.askStudentAdvisor({
        student_id: selectedStudent.id,
        message: question
      });

      setMessages((prev) => [
        ...prev,
        {
          role: 'assistant',
          text: response?.answer || 'Hiện chưa có phản hồi. Bạn vui lòng thử lại.'
        }
      ]);
    } catch (error) {
      setMessages((prev) => [
        ...prev,
        {
          role: 'assistant',
          text: `Không thể lấy tư vấn lúc này: ${error.message}`
        }
      ]);
    } finally {
      setSending(false);
    }
  };

  const generatePlan = async () => {
    if (!selectedStudent || planning) {
      return;
    }

    setPlanning(true);
    try {
      const response = await teacherAPI.generate7DayInterventionPlan({
        student_id: selectedStudent.id
      });

      setMessages((prev) => [
        ...prev,
        { role: 'teacher', text: 'Tạo kế hoạch can thiệp 7 ngày' },
        {
          role: 'assistant',
          text: response?.message || 'Đã tạo checklist 7 ngày.',
          checklist: Array.isArray(response?.checklist) ? response.checklist : []
        }
      ]);
    } catch (error) {
      setMessages((prev) => [
        ...prev,
        {
          role: 'assistant',
          text: `Không thể tạo checklist 7 ngày: ${error.message}`
        }
      ]);
    } finally {
      setPlanning(false);
    }
  };

  return (
    <TeacherLayout>
      <div className="teacher-advisor-page">
        <aside className="advisor-students-panel">
          <div className="panel-header">
            <h2>Hồ sơ sinh viên</h2>
            <p>Chọn sinh viên để hỏi trực tiếp</p>
          </div>

          <div className="panel-search">
            <Search size={16} />
            <input
              type="text"
              placeholder="Tìm theo tên, email, MSSV"
              value={search}
              onChange={(event) => setSearch(event.target.value)}
            />
          </div>

          {loading ? (
            <div className="students-loading">
              <Loader2 size={18} className="spin" />
              <span>Đang tải sinh viên...</span>
            </div>
          ) : (
            <div className="students-list">
              {filteredStudents.map((student) => (
                <button
                  key={student.id}
                  type="button"
                  className={`student-list-item ${selectedStudent?.id === student.id ? 'active' : ''}`}
                  onClick={() => setSelectedStudent(student)}
                >
                  <div className="student-initial">{student.full_name?.charAt(0) || 'S'}</div>
                  <div className="student-copy">
                    <strong>{student.full_name || 'Chưa cập nhật'}</strong>
                    <span>{student.student_id || student.email}</span>
                  </div>
                </button>
              ))}
              {filteredStudents.length === 0 && <p className="students-empty">Không có sinh viên phù hợp.</p>}
            </div>
          )}
        </aside>

        <section className="advisor-chat-panel">
          <header className="chat-header">
            <div className="chat-title">
              <Bot size={20} />
              <div>
                <h1>VLU Mentor for Teacher</h1>
                <p>
                  {selectedStudent
                    ? `Đang tư vấn cho: ${selectedStudent.full_name} (${selectedStudent.student_id || 'N/A'})`
                    : 'Chọn sinh viên để bắt đầu'}
                </p>
              </div>
            </div>
            <button
              type="button"
              className="plan-btn"
              disabled={!selectedStudent || planning || loadingHistory}
              onClick={generatePlan}
            >
              {planning ? <Loader2 size={16} className="spin" /> : <ClipboardCheck size={16} />}
              Tạo kế hoạch can thiệp 7 ngày
            </button>
          </header>

          <div className="quick-questions">
            {starterQuestions.map((question) => (
              <button
                key={question}
                type="button"
                onClick={() => sendQuestion(question)}
                disabled={!selectedStudent || sending}
              >
                {question}
              </button>
            ))}
          </div>

          <div className="chat-messages">
            {loadingHistory && (
              <div className="history-loading">
                <Loader2 size={16} className="spin" />
                <span>Đang tải lịch sử hội thoại...</span>
              </div>
            )}

            {messages.map((message, index) => (
              <div key={`${message.role}-${index}`} className={`chat-row ${message.role}`}>
                <div className="chat-avatar">
                  {message.role === 'assistant' ? <Bot size={16} /> : <User size={16} />}
                </div>
                <div className="chat-bubble">
                  {message.text}
                  {Array.isArray(message.checklist) && message.checklist.length > 0 && (
                    <div className="checklist-box">
                      {message.checklist.map((item) => (
                        <div key={`day-${item.day}`} className="checklist-day">
                          <h4>Ngày {item.day}: {item.title}</h4>
                          <ul>
                            {(item.items || []).map((task, taskIndex) => (
                              <li key={`task-${item.day}-${taskIndex}`}>{task}</li>
                            ))}
                          </ul>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            ))}
            {sending && (
              <div className="chat-row assistant">
                <div className="chat-avatar"><Bot size={16} /></div>
                <div className="chat-bubble typing">Đang phân tích dữ liệu sinh viên...</div>
              </div>
            )}
          </div>

          <form
            className="chat-input"
            onSubmit={(event) => {
              event.preventDefault();
              sendQuestion();
            }}
          >
            <textarea
              value={input}
              onChange={(event) => setInput(event.target.value)}
              placeholder="Ví dụ: Sinh viên này có dấu hiệu học chậm ở đâu và nên can thiệp thế nào?"
              rows={2}
              disabled={!selectedStudent || sending}
            />
            <button type="submit" disabled={!selectedStudent || sending || !input.trim()}>
              {sending ? <Loader2 size={18} className="spin" /> : <Send size={18} />}
              Gửi
            </button>
          </form>
        </section>
      </div>
    </TeacherLayout>
  );
};

export default StudentAdvisorPage;
