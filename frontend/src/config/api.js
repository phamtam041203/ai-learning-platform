const trimTrailingSlash = (value) => value.replace(/\/+$/, '');

const joinUrl = (baseUrl, path = '') => {
  if (!path) {
    return baseUrl;
  }

  if (/^https?:\/\//i.test(path)) {
    return path;
  }

  const normalizedPath = path.startsWith('/') ? path : `/${path}`;
  return `${baseUrl}${normalizedPath}`;
};

export const API_BASE_URL = trimTrailingSlash(
  import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000'
);

export const API_URL = trimTrailingSlash(
  import.meta.env.VITE_API_URL || `${API_BASE_URL}/api`
);

export const buildApiUrl = (path = '') => joinUrl(API_URL, path);

export const buildBackendUrl = (path = '') => joinUrl(API_BASE_URL, path);
