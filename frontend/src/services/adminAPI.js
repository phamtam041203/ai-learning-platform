/**
 * Admin API Service
 */

import { API_URL } from '../config/api';

const getAuthHeader = () => {
  const token = localStorage.getItem('token') || localStorage.getItem('access_token');
  return token ? { Authorization: `Bearer ${token}` } : {};
};

const formatApiError = (detail, fallbackMessage) => {
  if (Array.isArray(detail)) {
    return detail.map((item) => item?.msg || item?.message || JSON.stringify(item)).join(' | ');
  }

  if (detail && typeof detail === 'object') {
    return detail.message || detail.msg || JSON.stringify(detail);
  }

  return detail || fallbackMessage;
};

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

  const response = await fetch(`${API_URL}${endpoint}`, config);
  if (!response.ok) {
    const error = await response.json().catch(() => ({ detail: 'API Error' }));
    throw new Error(formatApiError(error.detail, `HTTP ${response.status}`));
  }

  return response.json();
};

const adminAPI = {
  getOverview: async () => {
    return apiCall('/admin/overview');
  },

  getTeachers: async () => {
    return apiCall('/admin/teachers');
  },

  getStudents: async () => {
    return apiCall('/admin/students');
  },

  getCourses: async () => {
    return apiCall('/admin/courses');
  },

  getAssessments: async () => {
    return apiCall('/admin/assessments');
  },

  getCourseDetail: async (courseId) => {
    return apiCall(`/courses/${courseId}`);
  },

  createTeacher: async (teacherData) => {
    const formData = new FormData();
    Object.entries(teacherData).forEach(([key, value]) => {
      if (value !== undefined && value !== null && value !== '') {
        formData.append(key, value);
      }
    });

    const token = localStorage.getItem('token') || localStorage.getItem('access_token');
    const response = await fetch(`${API_URL}/admin/teachers`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`
      },
      body: formData
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({ detail: 'Create failed' }));
      throw new Error(formatApiError(error.detail, 'Create failed'));
    }

    return response.json();
  },

  createStudent: async (studentData) => {
    const formData = new FormData();
    Object.entries(studentData).forEach(([key, value]) => {
      if (value !== undefined && value !== null && value !== '') {
        formData.append(key, value);
      }
    });

    const token = localStorage.getItem('token') || localStorage.getItem('access_token');
    const response = await fetch(`${API_URL}/admin/students`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`
      },
      body: formData
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({ detail: 'Create failed' }));
      throw new Error(formatApiError(error.detail, 'Create failed'));
    }

    return response.json();
  },

  updateUserStatus: async (userId, isActive) => {
    const formData = new FormData();
    formData.append('is_active', isActive);

    const token = localStorage.getItem('token') || localStorage.getItem('access_token');
    const response = await fetch(`${API_URL}/admin/users/${userId}/status`, {
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${token}`
      },
      body: formData
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({ detail: 'Update failed' }));
      throw new Error(formatApiError(error.detail, 'Update failed'));
    }

    return response.json();
  },

  deleteUser: async (userId) => {
    if (!userId) {
      throw new Error('Missing user id');
    }
    const token = localStorage.getItem('token') || localStorage.getItem('access_token');
    const response = await fetch(`${API_URL}/admin/users/${encodeURIComponent(userId)}`, {
      method: 'DELETE',
      headers: {
        Authorization: `Bearer ${token}`
      }
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({ detail: 'Delete failed' }));
      throw new Error(formatApiError(error.detail, 'Delete failed'));
    }

    return response.json();
  },

  createAssessment: async (assessmentData) => {
    const formData = new FormData();
    Object.entries(assessmentData).forEach(([key, value]) => {
      if (value !== undefined && value !== null && value !== '') {
        formData.append(key, value);
      }
    });

    const token = localStorage.getItem('token') || localStorage.getItem('access_token');
    const response = await fetch(`${API_URL}/admin/assessments`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`
      },
      body: formData
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({ detail: 'Create failed' }));
      throw new Error(formatApiError(error.detail, 'Create failed'));
    }

    return response.json();
  }
};

export default adminAPI;
