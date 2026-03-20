/**
 * Teacher API Service
 */

import { API_URL } from '../config/api';

// Lấy token
const getAuthHeader = () => {
  const token = localStorage.getItem('token') || localStorage.getItem('access_token');
  console.log('🔑 Getting token:', token ? 'Found' : 'Not found');
  return token ? { Authorization: `Bearer ${token}` } : {};
};

const parseApiErrorDetail = (detail) => {
  if (Array.isArray(detail)) {
    return detail
      .map((item) => {
        if (typeof item === 'string') {
          return item;
        }

        if (item?.field && item?.message) {
          return `${item.field}: ${item.message}`;
        }

        if (item?.msg) {
          return item.msg;
        }

        return JSON.stringify(item);
      })
      .join(' | ');
  }

  if (detail && typeof detail === 'object') {
    return detail.message || JSON.stringify(detail);
  }

  return detail;
};

const normalizeCoursePayload = (courseData = {}) => ({
  title: String(courseData.title ?? courseData.course_name ?? courseData.name ?? '').trim(),
  description: String(courseData.description ?? courseData.course_description ?? '').trim(),
  category: String(courseData.category ?? courseData.specialization ?? courseData.major ?? 'programming').trim() || 'programming'
});

const normalizeQuizPayload = (quizData = {}) => ({
  ...quizData,
  lesson_id: quizData.lesson_id ? Number(quizData.lesson_id) : null
});

// API call helper
const apiCall = async (endpoint, options = {}) => {
  const defaultHeaders = {
    'Content-Type': 'application/json',
    ...getAuthHeader()
  };

  const config = {
    ...options,
    headers: {
      ...defaultHeaders,
      ...options.headers
    }
  };

  console.log(`📡 Calling: ${endpoint}`);
  const response = await fetch(`${API_URL}${endpoint}`, config);

  if (!response.ok) {
    console.error(`❌ API Error: ${response.status}`, endpoint);
    const error = await response.json().catch(() => ({ detail: 'API Error' }));
    throw new Error(parseApiErrorDetail(error.detail) || `HTTP ${response.status}`);
  }

  const data = await response.json();
  console.log(`✅ Success: ${endpoint}`, data);
  return data;
};

// ==========================================
// TEACHER APIs
// ==========================================

const teacherAPI = {
  // Get teacher profile
  getProfile: async () => {
    return apiCall('/teacher/profile');
  },

  // Dashboard stats
  getDashboard: async () => {
    return apiCall('/teacher/dashboard');
  },

  // Teacher analytics
  getAnalytics: async () => {
    return apiCall('/teacher/analytics');
  },

  // Get all courses
  getCourses: async () => {
    return apiCall('/teacher/courses');
  },

  // Get course detail
  getCourseDetail: async (courseId) => {
    return apiCall(`/teacher/courses/${courseId}`);
  },

  // Create course
  createCourse: async (courseData) => {
    return apiCall('/teacher/courses', {
      method: 'POST',
      body: JSON.stringify(normalizeCoursePayload(courseData))
    });
  },

  // Update course
  updateCourse: async (courseId, courseData) => {
    return apiCall(`/teacher/courses/${courseId}`, {
      method: 'PUT',
      body: JSON.stringify(normalizeCoursePayload(courseData))
    });
  },

  // Delete course
  deleteCourse: async (courseId) => {
    return apiCall(`/teacher/courses/${courseId}`, {
      method: 'DELETE'
    });
  },

  // Get all students
  getStudents: async () => {
    return apiCall('/teacher/students');
  },

  // Get pending approvals
  getPendingApprovals: async () => {
    return apiCall('/teacher/pending-approvals');
  },

  // Approve/reject enrollment
  approveEnrollment: async (enrollmentId, approve) => {
    return apiCall(`/teacher/enrollments/${enrollmentId}/approve`, {
      method: 'POST',
      body: JSON.stringify({ approve })
    });
  },

  // Ask advisor about a student in teacher scope
  askStudentAdvisor: async ({ student_id, message, course_id = null }) => {
    return apiCall('/teacher/students/advisor/ask', {
      method: 'POST',
      body: JSON.stringify({ student_id, message, course_id })
    });
  },

  // Fetch chat history for a specific student in teacher scope
  getStudentAdvisorHistory: async (studentId, courseId = null, limit = 60) => {
    const params = new URLSearchParams({ limit: String(limit) });
    if (courseId) {
      params.set('course_id', String(courseId));
    }
    return apiCall(`/teacher/students/${studentId}/advisor/history?${params.toString()}`);
  },

  // Generate 7-day intervention checklist
  generate7DayInterventionPlan: async ({ student_id, course_id = null }) => {
    return apiCall('/teacher/students/advisor/plan-7-days', {
      method: 'POST',
      body: JSON.stringify({ student_id, course_id })
    });
  },

  // Create lesson with file upload
  createLesson: async (lessonData) => {
    const formData = new FormData();
    formData.append('title', lessonData.title);
    formData.append('description', lessonData.description);
    formData.append('course_id', lessonData.course_id);
    formData.append('activity_type', lessonData.activity_type || 'quiz');
    formData.append('activity_prompt', lessonData.activity_prompt || '');
    
    if (lessonData.file) {
      formData.append('file', lessonData.file);
    }
    if (lessonData.video_url) {
      formData.append('video_url', lessonData.video_url);
    }

    const token = localStorage.getItem('token') || localStorage.getItem('access_token');
    const response = await fetch(`${API_URL}/teacher/lessons`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`
      },
      body: formData
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({ detail: 'Upload failed' }));
      throw new Error(error.detail || 'Upload failed');
    }

    return response.json();
  },

  // Create quiz from DOCX
  createQuizFromDocx: async (quizData) => {
    const formData = new FormData();
    formData.append('title', quizData.title);
    formData.append('description', quizData.description);
    formData.append('course_id', quizData.course_id);
    formData.append('docx_file', quizData.docx_file);
    if (quizData.lesson_id) {
      formData.append('lesson_id', Number(quizData.lesson_id));
    }

    const token = localStorage.getItem('token') || localStorage.getItem('access_token');
    const response = await fetch(`${API_URL}/teacher/quizzes/from-docx`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`
      },
      body: formData
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({ detail: 'Quiz creation failed' }));
      throw new Error(error.detail || 'Quiz creation failed');
    }

    return response.json();
  },

  // Get quizzes for a course
  getCourseQuizzes: async (courseId) => {
    return apiCall(`/teacher/courses/${courseId}/quizzes`);
  },

  // Get quiz detail
  getQuizDetail: async (quizId) => {
    return apiCall(`/teacher/quizzes/${quizId}`);
  },

  // Create quiz manually
  createQuiz: async (quizData) => {
    return apiCall('/teacher/quizzes', {
      method: 'POST',
      body: JSON.stringify(normalizeQuizPayload(quizData))
    });
  },

  // Update quiz
  updateQuiz: async (quizId, quizData) => {
    return apiCall(`/teacher/quizzes/${quizId}`, {
      method: 'PUT',
      body: JSON.stringify(normalizeQuizPayload(quizData))
    });
  },

  // Delete quiz
  deleteQuiz: async (quizId) => {
    return apiCall(`/teacher/quizzes/${quizId}`, {
      method: 'DELETE'
    });
  }
};

export default teacherAPI;