/**
 * API Service for AI Learning Platform
 * Handles all API calls to backend
 */

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api';

// Helper function to get auth header
const getAuthHeader = () => {
  const token = localStorage.getItem('token') || sessionStorage.getItem('token') || localStorage.getItem('access_token');
  if (token) {
    console.log('🔐 [getAuthHeader] Token:', `${token.substring(0, 20)}...${token.substring(token.length - 10)}`);
  } else {
    console.log('🔐 [getAuthHeader] No token found');
  }
  return token ? { Authorization: `Bearer ${token}` } : {};
};

// Helper function for API calls
const apiCall = async (endpoint, options = {}) => {
  const authHeader = getAuthHeader();
  const defaultHeaders = {
    'Content-Type': 'application/json',
    ...authHeader
  };

  const config = {
    ...options,
    headers: {
      ...defaultHeaders,
      ...options.headers
    }
  };

  const response = await fetch(`${API_URL}${endpoint}`, config);

  if (response.status === 401) {
    console.log('🔓 [apiCall] Unauthorized (401) - Clearing storage and redirecting to login');
    localStorage.clear();
    sessionStorage.clear();
    window.location.href = '/login';
    throw new Error('Unauthorized - Redirecting to login');
  }

  if (!response.ok) {
    const error = await response.json().catch(() => ({ detail: 'Network error' }));
    throw new Error(error.detail || 'API Error');
  }

  return response.json();
};

// ==========================================
// AUTH APIs
// ==========================================

export const authAPI = {
  login: async (email, password) => {
    const formData = new URLSearchParams();
    formData.append('username', email);
    formData.append('password', password);

    const response = await fetch(`${API_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: formData
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.detail || 'Login failed');
    }

    return response.json();
  },

  register: async (userData) => {
    return apiCall('/auth/register', {
      method: 'POST',
      body: JSON.stringify(userData)
    });
  },

  getCurrentUser: async () => {
    return apiCall('/auth/me');
  },

  changePassword: async (currentPassword, newPassword) => {
    return apiCall('/auth/change-password', {
      method: 'POST',
      body: JSON.stringify({
        current_password: currentPassword,
        new_password: newPassword
      })
    });
  }
};

// ==========================================
// STUDENT APIs
// ==========================================

export const studentAPI = {
  // Get student dashboard data
  getDashboard: async () => {
    return apiCall('/student/dashboard');
  },

  // Get all grades
  getGrades: async () => {
    return apiCall('/student/grades');
  },

  // Get detailed statistics
  getStatistics: async () => {
    return apiCall('/student/statistics');
  },

  // Get recommended courses
  getRecommendedCourses: async () => {
    return apiCall('/student/courses/recommended');
  },

  // Get courses by student's specialization
  getSpecializationCourses: async () => {
    return apiCall('/student/specialization-courses');
  },

  // Get curriculum roadmap with status
  getCurriculumStatus: async () => {
    return apiCall('/student/curriculum-status');
  },

  // Get intake assessment template for personalized roadmap
  getIntakeAssessmentTemplate: async () => {
    return apiCall('/student/personalization/intake-assessment');
  },

  // Analyze intake assessment and return AI roadmap unlock plan
  analyzeIntakeAssessment: async (answers) => {
    return apiCall('/student/personalization/intake-assessment', {
      method: 'POST',
      body: JSON.stringify({ answers })
    });
  },

  // Get per-skill confidence profile
  getSkillProfile: async () => {
    return apiCall('/student/skill-profile');
  },

  // Get learning analytics and early-warning data
  getLearningAnalytics: async () => {
    return apiCall('/student/learning-analytics');
  },

  // Generate (or regenerate) a personalised weekly study plan
  generateStudyPlan: async (goal = '') => {
    return apiCall('/student/study-plan', {
      method: 'POST',
      body: JSON.stringify({ goal })
    });
  }
};

// ==========================================
// TEACHER APIs
// ==========================================

export const teacherAPI = {
  // Get teacher profile
  getProfile: async () => {
    return apiCall('/teacher/profile');
  },

  // Get dashboard stats
  getDashboard: async () => {
    return apiCall('/teacher/dashboard');
  },

  // Get all teacher's courses
  getCourses: async () => {
    return apiCall('/teacher/courses');
  },

  // Create new course
  createCourse: async (courseData) => {
    return apiCall('/teacher/courses', {
      method: 'POST',
      body: JSON.stringify(courseData)
    });
  },

  // Get course detail
  getCourseDetail: async (courseId) => {
    return apiCall(`/teacher/courses/${courseId}`);
  },

  // Create lesson (with file upload)
  createLesson: async (lessonData) => {
    const formData = new FormData();
    formData.append('title', lessonData.title);
    formData.append('description', lessonData.description);
    formData.append('course_id', lessonData.course_id);
    
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
      const error = await response.json();
      throw new Error(error.detail || 'Failed to create lesson');
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

    const token = localStorage.getItem('token') || localStorage.getItem('access_token');
    const response = await fetch(`${API_URL}/teacher/quizzes/from-docx`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`
      },
      body: formData
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.detail || 'Failed to create quiz');
    }

    return response.json();
  },

  // Get all students
  getStudents: async () => {
    return apiCall('/teacher/students');
  },

  // Get pending enrollment approvals
  getPendingApprovals: async () => {
    return apiCall('/teacher/pending-approvals');
  },

  // Approve/reject enrollment
  approveEnrollment: async (enrollmentId, approve) => {
    return apiCall(`/teacher/enrollments/${enrollmentId}/approve`, {
      method: 'POST',
      body: JSON.stringify({ approve })
    });
  }
};

// ==========================================
// COURSE APIs
// ==========================================

export const courseAPI = {
  // Get all courses with optional filters
  getCourses: async (params = {}) => {
    const queryParams = new URLSearchParams();
    if (params.major) queryParams.append('major', params.major);
    if (params.level) queryParams.append('level', params.level);
    if (params.search) queryParams.append('search', params.search);
    if (params.page) queryParams.append('page', params.page);
    if (params.limit) queryParams.append('limit', params.limit);

    const queryString = queryParams.toString();
    return apiCall(`/courses${queryString ? '?' + queryString : ''}`);
  },

  // Get all majors
  getMajors: async () => {
    return apiCall('/courses/majors');
  },

  // Get enrolled courses
  getMyCourses: async (statusFilter = null) => {
    const queryString = statusFilter ? `?status_filter=${statusFilter}` : '';
    return apiCall(`/courses/my-courses${queryString}`);
  },

  // Get course detail
  getCourseDetail: async (courseId) => {
    return apiCall(`/courses/${courseId}`);
  },

  // Enroll in a course
  enrollCourse: async (courseId) => {
    return apiCall(`/courses/${courseId}/enroll`, {
      method: 'POST'
    });
  },

  // Get grades summary
  getGradesSummary: async () => {
    return apiCall('/courses/my-grades/summary');
  },

  // Get learning stats
  getLearningStats: async () => {
    return apiCall('/courses/my-stats/learning');
  },

  // Get courses by major
  getCoursesByMajor: async (major) => {
    return apiCall(`/courses/by-major/${major}`);
  }
};

// ==========================================
// LEARNING ACTIVITY APIs
// ==========================================

export const learningAPI = {
  // Record learning activity
  recordActivity: async (activityData) => {
    return apiCall('/learning/activity', {
      method: 'POST',
      body: JSON.stringify(activityData)
    });
  },

  // Get recent activities
  getRecentActivities: async (limit = 10) => {
    return apiCall(`/learning/activities?limit=${limit}`);
  }
};

// ==========================================
// ASSESSMENT APIs
// ==========================================

export const assessmentAPI = {
  // Get assessments for a course
  getCourseAssessments: async (courseId) => {
    return apiCall(`/assessments/course/${courseId}`);
  },

  // Submit assessment
  submitAssessment: async (assessmentId, answers) => {
    return apiCall(`/assessments/${assessmentId}/submit`, {
      method: 'POST',
      body: JSON.stringify({ answers })
    });
  },

  // Get submission result
  getSubmissionResult: async (submissionId) => {
    return apiCall(`/assessments/submissions/${submissionId}`);
  }
};

// ==========================================
// AI RECOMMENDATION APIs
// ==========================================

export const aiAPI = {
  // Get AI recommendations
  getRecommendations: async () => {
    return apiCall('/ai/recommendations');
  },

  // Get learning path suggestion
  getLearningPath: async () => {
    return apiCall('/ai/learning-path');
  },

  // Chat with AI
  chat: async (message) => {
    return apiCall('/ai/chat', {
      method: 'POST',
      body: JSON.stringify({ message })
    });
  }
};

// ==========================================
// DISCUSSION APIs
// ==========================================

export const discussionAPI = {
  getComments: (lessonId) => apiCall(`/discussion/lesson/${lessonId}`),

  postComment: (lessonId, content, parentId = null) =>
    apiCall(`/discussion/lesson/${lessonId}`, {
      method: 'POST',
      body: JSON.stringify({ content, parent_id: parentId }),
    }),

  updateComment: (commentId, content) =>
    apiCall(`/discussion/${commentId}`, {
      method: 'PUT',
      body: JSON.stringify({ content }),
    }),

  deleteComment: (commentId) =>
    apiCall(`/discussion/${commentId}`, { method: 'DELETE' }).catch(() => null),

  toggleLike: (commentId) =>
    apiCall(`/discussion/${commentId}/like`, { method: 'POST' }),
};

// ==========================================
// NOTIFICATION APIs
// ==========================================

export const notificationAPI = {
  list: () => apiCall('/notifications'),
  unreadCount: () => apiCall('/notifications/unread-count'),
  markRead: (id) => apiCall(`/notifications/${id}/read`, { method: 'POST' }),
  markAllRead: () => apiCall('/notifications/read-all', { method: 'POST' }),
};

// ==========================================
// CHATBOT APIs
// ==========================================

export const chatbotAPI = {
  // Get student analysis for AI Advisor
  getStudentAnalysis: async () => {
    return apiCall('/chatbot/advisor/analyze');
  },

  // Ask AI inside a specific lesson context
  askLessonAssistant: async (courseId, lessonId, message) => {
    return apiCall('/chatbot/lesson-assistant', {
      method: 'POST',
      body: JSON.stringify({
        course_id: Number(courseId),
        lesson_id: Number(lessonId),
        message
      })
    });
  },

  // Ask AI Advisor (local)
  askAdvisor: async (message) => {
    return apiCall('/chatbot/advisor/ask', {
      method: 'POST',
      body: JSON.stringify({ 
        message,
        chat_type: 'advisor'
      })
    });
  },

  generateTutorSpeech: async (text, voiceGender = 'female') => {
    return apiCall('/chatbot/tts', {
      method: 'POST',
      body: JSON.stringify({
        text,
        voice_gender: voiceGender
      })
    });
  },

  // Ask Gemini (Google AI integration)
  askChatGPT: async (message) => {
    try {
      return await apiCall('/chatbot/gemini', {
        method: 'POST',
        body: JSON.stringify({ 
          message,
          context_type: 'advisor'
        })
      });
    } catch (error) {
      console.error('Gemini API error:', error);
      // Fallback to local advisor
      throw error;
    }
  }
};

// Export all APIs
export default {
  auth: authAPI,
  student: studentAPI,
  // teacher: teacherAPI,
  course: courseAPI,
  learning: learningAPI,
  assessment: assessmentAPI,
  ai: aiAPI,
  chatbot: chatbotAPI
};