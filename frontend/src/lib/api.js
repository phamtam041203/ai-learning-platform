const API_URL = 'http://localhost:8000';

export const apiFetch = (url, options = {}) =>
  fetch(`${API_URL}${url}`, {
    headers: {
      'Content-Type': 'application/json',
      ...(options.headers || {}),
    },
    ...options,
  });
