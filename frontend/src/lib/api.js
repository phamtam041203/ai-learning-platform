import { API_BASE_URL } from '../config/api';

export const apiFetch = (url, options = {}) =>
  fetch(`${API_BASE_URL}${url}`, {
    headers: {
      'Content-Type': 'application/json',
      ...(options.headers || {}),
    },
    ...options,
  });
