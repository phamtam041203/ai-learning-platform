/**
 * Teacher API Service
 */

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api';

// Lấy token
const getAuthHeader = () => {
  const token = localStorage.getItem('token') || localStorage.getItem('access_token');
  console.log('🔑 Getting token:', token ? 'Found' : 'Not found');
  return token ? { Authorization: `Bearer ${token}` } : {};
};

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
    throw new Error(error.detail || `HTTP ${response.status}`);
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
      body: JSON.stringify(courseData)
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

  // Create lesson with file upload
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
  }
};

export default teacherAPI;