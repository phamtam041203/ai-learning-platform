import { useEffect, useMemo, useState } from 'react';
import { useLocation, useNavigate, useParams } from 'react-router-dom';
import { ArrowLeft, FileUp, Pencil, Plus, Save, Trash2 } from 'lucide-react';
import teacherAPI from '../../services/teacherAPI';
import TeacherLayout from '../../components/TeacherLayout';
import './QuizManagerPage.css';

const createEmptyQuestion = () => ({
  question_text: '',
  option_a: '',
  option_b: '',
  option_c: '',
  option_d: '',
  correct_answer: 'a',
  explanation: '',
  points: 1,
});

const createEmptyQuizForm = () => ({
  title: '',
  description: '',
  lesson_id: '',
  is_published: false,
  questions: [createEmptyQuestion()],
});

const mapQuizDetailToForm = (detail) => ({
  title: detail.title || '',
  description: detail.description || '',
  lesson_id: detail.lesson_id ? String(detail.lesson_id) : '',
  is_published: Boolean(detail.is_published),
  questions: (detail.questions || []).map((question) => ({
    question_text: question.question_text || '',
    option_a: question.option_a || '',
    option_b: question.option_b || '',
    option_c: question.option_c || '',
    option_d: question.option_d || '',
    correct_answer: question.correct_answer || 'a',
    explanation: question.explanation || '',
    points: question.points || 1,
  })),
});

const QuizManagerPage = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { courseId } = useParams();
  const lessonIdFromQuery = useMemo(() => {
    const rawValue = new URLSearchParams(location.search).get('lessonId');
    return rawValue ? String(Number(rawValue)) : '';
  }, [location.search]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);
  const [course, setCourse] = useState(null);
  const [lessons, setLessons] = useState([]);
  const [quizzes, setQuizzes] = useState([]);
  const [selectedQuizId, setSelectedQuizId] = useState(null);
  const [quizForm, setQuizForm] = useState(createEmptyQuizForm());
  const [docxForm, setDocxForm] = useState({ title: '', description: '', lesson_id: '', docx_file: null });
  const [selectedLessonFilter, setSelectedLessonFilter] = useState(lessonIdFromQuery);

  const fetchQuizzes = async (preferredQuizId = null) => {
    try {
      setLoading(true);
      setError(null);
      const [response, courseDetail] = await Promise.all([
        teacherAPI.getCourseQuizzes(courseId),
        teacherAPI.getCourseDetail(courseId),
      ]);
      setCourse(response.course);
      setLessons(courseDetail.lessons || []);
      setQuizzes(response.quizzes || []);

      const quizToOpen = preferredQuizId || selectedQuizId || response.quizzes?.[0]?.id || null;
      if (quizToOpen) {
        const detail = await teacherAPI.getQuizDetail(quizToOpen);
        setSelectedQuizId(detail.id);
        setQuizForm(mapQuizDetailToForm(detail));
      } else {
        setSelectedQuizId(null);
        setQuizForm(createEmptyQuizForm());
      }
    } catch (err) {
      setError(err.message || 'Không thể tải dữ liệu quiz');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchQuizzes();
  }, [courseId]);

  useEffect(() => {
    setSelectedLessonFilter(lessonIdFromQuery);
    setDocxForm((current) => ({ ...current, lesson_id: lessonIdFromQuery }));
    setQuizForm((current) => current.lesson_id || !lessonIdFromQuery ? current : { ...current, lesson_id: lessonIdFromQuery });
  }, [lessonIdFromQuery]);

  const handleSelectQuiz = async (quizId) => {
    try {
      const detail = await teacherAPI.getQuizDetail(quizId);
      setSelectedQuizId(detail.id);
      setQuizForm(mapQuizDetailToForm(detail));
    } catch (err) {
      setError(err.message || 'Không thể tải chi tiết quiz');
    }
  };

  const filteredQuizzes = useMemo(() => {
    if (!selectedLessonFilter) {
      return quizzes;
    }
    return quizzes.filter((quiz) => String(quiz.lesson_id || '') === String(selectedLessonFilter));
  }, [quizzes, selectedLessonFilter]);

  const updateQuestion = (index, field, value) => {
    setQuizForm((current) => ({
      ...current,
      questions: current.questions.map((question, questionIndex) => (
        questionIndex === index ? { ...question, [field]: value } : question
      )),
    }));
  };

  const handleSaveQuiz = async (event) => {
    event.preventDefault();
    try {
      setSaving(true);
      setError(null);
      const payload = {
        course_id: Number(courseId),
        lesson_id: quizForm.lesson_id ? Number(quizForm.lesson_id) : null,
        title: quizForm.title,
        description: quizForm.description,
        is_published: quizForm.is_published,
        questions: quizForm.questions.map((question) => ({
          ...question,
          points: Number(question.points || 1),
        })),
      };

      const saved = selectedQuizId
        ? await teacherAPI.updateQuiz(selectedQuizId, payload)
        : await teacherAPI.createQuiz(payload);

      await fetchQuizzes(saved.id);
    } catch (err) {
      setError(err.message || 'Không thể lưu quiz');
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteQuiz = async () => {
    if (!selectedQuizId) {
      return;
    }
    const confirmed = window.confirm('Bạn có chắc chắn muốn xóa quiz này không?');
    if (!confirmed) {
      return;
    }

    try {
      setSaving(true);
      await teacherAPI.deleteQuiz(selectedQuizId);
      setSelectedQuizId(null);
      setQuizForm(createEmptyQuizForm());
      await fetchQuizzes();
    } catch (err) {
      setError(err.message || 'Không thể xóa quiz');
    } finally {
      setSaving(false);
    }
  };

  const handleImportDocx = async (event) => {
    event.preventDefault();
    if (!docxForm.docx_file) {
      setError('Bạn cần chọn file DOCX trước khi import');
      return;
    }

    try {
      setSaving(true);
      setError(null);
      const created = await teacherAPI.createQuizFromDocx({
        ...docxForm,
        course_id: Number(courseId),
      });
      setDocxForm({ title: '', description: '', lesson_id: selectedLessonFilter, docx_file: null });
      await fetchQuizzes(created.id);
    } catch (err) {
      setError(err.message || 'Không thể import quiz từ DOCX');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <TeacherLayout>
        <div className="quiz-manager-page">
          <div className="quiz-manager-state">Đang tải dữ liệu quiz...</div>
        </div>
      </TeacherLayout>
    );
  }

  return (
    <TeacherLayout>
      <div className="quiz-manager-page">
        <div className="quiz-manager-header">
          <button className="back-link" onClick={() => navigate(`/teacher/courses/${courseId}`)}>
            <ArrowLeft size={18} />
            Quay lại khóa học
          </button>

          <div>
            <span className="quiz-kicker">Quiz management</span>
            <h1>{course?.title || 'Quản lý quiz'}</h1>
            <p>Tạo quiz theo từng bài học, import từ DOCX, chỉnh sửa câu hỏi và phát hành cho sinh viên.</p>
          </div>
        </div>

        {error ? <div className="quiz-manager-error">{error}</div> : null}

        <div className="quiz-manager-grid">
          <section className="quiz-sidebar-panel">
            <div className="panel-heading">
              <h2>Danh sách quiz</h2>
              <button
                className="ghost-button"
                onClick={() => {
                  setSelectedQuizId(null);
                  setQuizForm(createEmptyQuizForm());
                }}
              >
                <Plus size={16} />
                Quiz mới
              </button>
            </div>

            <div className="quiz-list">
              <label className="lesson-select-field">
                Lọc theo bài học
                <select
                  value={selectedLessonFilter}
                  onChange={(event) => setSelectedLessonFilter(event.target.value)}
                >
                  <option value="">Tất cả bài học trong khóa</option>
                  {lessons.map((lesson) => (
                    <option key={lesson.id} value={lesson.id}>{lesson.title}</option>
                  ))}
                </select>
              </label>

              {filteredQuizzes.length === 0 ? (
                <div className="empty-box">{selectedLessonFilter ? 'Bài học này chưa có quiz nào.' : 'Chưa có quiz nào.'}</div>
              ) : (
                filteredQuizzes.map((quiz) => (
                  <button
                    key={quiz.id}
                    className={`quiz-list-item ${selectedQuizId === quiz.id ? 'active' : ''}`}
                    onClick={() => handleSelectQuiz(quiz.id)}
                  >
                    <strong>{quiz.title}</strong>
                    <span>{quiz.lesson_title || 'Quiz cấp khóa học'}</span>
                    <span>{quiz.questions_count || 0} câu hỏi</span>
                    <span className={`quiz-badge ${quiz.is_published ? 'published' : 'draft'}`}>
                      {quiz.is_published ? 'Đã phát hành' : 'Bản nháp'}
                    </span>
                  </button>
                ))
              )}
            </div>

            <form className="docx-form" onSubmit={handleImportDocx}>
              <div className="panel-heading compact">
                <h2>Import DOCX</h2>
              </div>
              <input
                type="text"
                placeholder="Tiêu đề quiz"
                value={docxForm.title}
                onChange={(event) => setDocxForm((current) => ({ ...current, title: event.target.value }))}
                required
              />
              <textarea
                rows="3"
                placeholder="Mô tả quiz"
                value={docxForm.description}
                onChange={(event) => setDocxForm((current) => ({ ...current, description: event.target.value }))}
              />
              <label className="lesson-select-field">
                Gắn với bài học
                <select
                  value={docxForm.lesson_id}
                  onChange={(event) => setDocxForm((current) => ({ ...current, lesson_id: event.target.value }))}
                >
                  <option value="">Không gắn bài học cụ thể</option>
                  {lessons.map((lesson) => (
                    <option key={lesson.id} value={lesson.id}>{lesson.title}</option>
                  ))}
                </select>
              </label>
              <label className="file-input">
                <FileUp size={16} />
                <span>{docxForm.docx_file?.name || 'Chọn file DOCX'}</span>
                <input
                  type="file"
                  accept=".docx"
                  onChange={(event) => setDocxForm((current) => ({ ...current, docx_file: event.target.files?.[0] || null }))}
                />
              </label>
              <button className="primary-button" type="submit" disabled={saving}>
                {saving ? 'Đang import...' : 'Import quiz'}
              </button>
            </form>
          </section>

          <section className="quiz-editor-panel">
            <form className="quiz-editor-form" onSubmit={handleSaveQuiz}>
              <div className="panel-heading">
                <h2>{selectedQuizId ? 'Chỉnh sửa quiz' : 'Tạo quiz thủ công'}</h2>
                <div className="editor-actions">
                  {selectedQuizId ? (
                    <button type="button" className="danger-button" onClick={handleDeleteQuiz} disabled={saving}>
                      <Trash2 size={16} />
                      Xóa
                    </button>
                  ) : null}
                  <button type="submit" className="primary-button" disabled={saving}>
                    <Save size={16} />
                    {saving ? 'Đang lưu...' : 'Lưu quiz'}
                  </button>
                </div>
              </div>

              <div className="quiz-editor-meta">
                <label>
                  Tiêu đề quiz
                  <input
                    type="text"
                    value={quizForm.title}
                    onChange={(event) => setQuizForm((current) => ({ ...current, title: event.target.value }))}
                    required
                  />
                </label>
                <label>
                  Mô tả
                  <textarea
                    rows="3"
                    value={quizForm.description}
                    onChange={(event) => setQuizForm((current) => ({ ...current, description: event.target.value }))}
                  />
                </label>
                <label>
                  Gắn với bài học
                  <select
                    value={quizForm.lesson_id}
                    onChange={(event) => setQuizForm((current) => ({ ...current, lesson_id: event.target.value }))}
                  >
                    <option value="">Không gắn bài học cụ thể</option>
                    {lessons.map((lesson) => (
                      <option key={lesson.id} value={lesson.id}>{lesson.title}</option>
                    ))}
                  </select>
                </label>
                <label className="publish-toggle">
                  <input
                    type="checkbox"
                    checked={quizForm.is_published}
                    onChange={(event) => setQuizForm((current) => ({ ...current, is_published: event.target.checked }))}
                  />
                  <span>Phát hành ngay sau khi lưu</span>
                </label>
              </div>

              <div className="question-stack">
                {quizForm.questions.map((question, index) => (
                  <article key={`question-${index}`} className="question-card">
                    <div className="question-card-header">
                      <h3>Câu hỏi {index + 1}</h3>
                      <button
                        type="button"
                        className="ghost-button"
                        onClick={() => setQuizForm((current) => ({
                          ...current,
                          questions: current.questions.length === 1
                            ? current.questions
                            : current.questions.filter((_, questionIndex) => questionIndex !== index)
                        }))}
                        disabled={quizForm.questions.length === 1}
                      >
                        <Trash2 size={14} />
                        Xóa câu
                      </button>
                    </div>

                    <label>
                      Nội dung câu hỏi
                      <textarea
                        rows="3"
                        value={question.question_text}
                        onChange={(event) => updateQuestion(index, 'question_text', event.target.value)}
                        required
                      />
                    </label>

                    <div className="options-grid">
                      <label>A<input type="text" value={question.option_a} onChange={(event) => updateQuestion(index, 'option_a', event.target.value)} required /></label>
                      <label>B<input type="text" value={question.option_b} onChange={(event) => updateQuestion(index, 'option_b', event.target.value)} required /></label>
                      <label>C<input type="text" value={question.option_c} onChange={(event) => updateQuestion(index, 'option_c', event.target.value)} required /></label>
                      <label>D<input type="text" value={question.option_d} onChange={(event) => updateQuestion(index, 'option_d', event.target.value)} required /></label>
                    </div>

                    <div className="question-bottom-row">
                      <label>
                        Đáp án đúng
                        <select value={question.correct_answer} onChange={(event) => updateQuestion(index, 'correct_answer', event.target.value)}>
                          <option value="a">A</option>
                          <option value="b">B</option>
                          <option value="c">C</option>
                          <option value="d">D</option>
                        </select>
                      </label>
                      <label>
                        Điểm
                        <input type="number" min="0.5" step="0.5" value={question.points} onChange={(event) => updateQuestion(index, 'points', event.target.value)} />
                      </label>
                    </div>

                    <label>
                      Giải thích
                      <textarea
                        rows="2"
                        value={question.explanation}
                        onChange={(event) => updateQuestion(index, 'explanation', event.target.value)}
                      />
                    </label>
                  </article>
                ))}
              </div>

              <button
                type="button"
                className="ghost-button add-question-button"
                onClick={() => setQuizForm((current) => ({ ...current, questions: [...current.questions, createEmptyQuestion()] }))}
              >
                <Plus size={16} />
                Thêm câu hỏi
              </button>
            </form>
          </section>
        </div>
      </div>
    </TeacherLayout>
  );
};

export default QuizManagerPage;