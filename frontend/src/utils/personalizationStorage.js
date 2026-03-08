const LEGACY_PERSONALIZATION_STORAGE_KEY = 'student_intake_personalization_v1';
const PERSONALIZATION_STORAGE_KEY_PREFIX = 'student_intake_personalization_v2';

const getCurrentUser = () => {
  try {
    const rawValue = localStorage.getItem('currentUser');
    return rawValue ? JSON.parse(rawValue) : null;
  } catch {
    return null;
  }
};

export const getCurrentPersonalizationUserId = () => {
  const currentUser = getCurrentUser();
  return currentUser?.id || currentUser?.studentId || currentUser?.email || null;
};

export const getPersonalizationStorageKey = (userId = getCurrentPersonalizationUserId()) => {
  if (!userId) {
    return null;
  }

  return `${PERSONALIZATION_STORAGE_KEY_PREFIX}_${userId}`;
};

export const clearLegacyPersonalizationStorage = () => {
  localStorage.removeItem(LEGACY_PERSONALIZATION_STORAGE_KEY);
};

export const getStoredPersonalization = () => {
  clearLegacyPersonalizationStorage();

  const storageKey = getPersonalizationStorageKey();
  if (!storageKey) {
    return null;
  }

  try {
    const rawValue = localStorage.getItem(storageKey);
    if (!rawValue) {
      return null;
    }

    const parsedValue = JSON.parse(rawValue);
    if (parsedValue && typeof parsedValue === 'object' && 'data' in parsedValue) {
      return parsedValue.data || null;
    }

    return parsedValue;
  } catch {
    return null;
  }
};

export const setStoredPersonalization = (personalization) => {
  clearLegacyPersonalizationStorage();

  const userId = getCurrentPersonalizationUserId();
  const storageKey = getPersonalizationStorageKey(userId);
  if (!storageKey || !personalization) {
    return false;
  }

  const payload = {
    userId,
    updatedAt: new Date().toISOString(),
    data: personalization,
  };

  localStorage.setItem(storageKey, JSON.stringify(payload));
  return true;
};

export const clearStoredPersonalization = () => {
  clearLegacyPersonalizationStorage();

  const storageKey = getPersonalizationStorageKey();
  if (!storageKey) {
    return;
  }

  localStorage.removeItem(storageKey);
};