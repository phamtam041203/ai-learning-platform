import { Component, useEffect, useMemo, useRef, useState } from 'react';
import { Bot, Loader2, Mic, MicOff, Minimize2, Send, User, Volume2 } from 'lucide-react';
import { chatbotAPI } from '../services/api';
import LessonTutorNpcScene from './LessonTutorNpcScene';
import './LessonAssistant.css';

const GOOGLE_TTS_VOICE_PRESETS = {
  female: {
    label: 'Google AI Sulafat',
    description: 'Giọng nữ AI Google, ấm và tự nhiên'
  },
  male: {
    label: 'Google AI Orus',
    description: 'Giọng nam AI Google, rõ và tự nhiên'
  }
};
const DEFAULT_VOICE_VOLUME = 0.85;
const MAX_SPOKEN_TEXT_LENGTH = 420;
const VLU_TUTOR_NAME = 'VLU Mentor';

const getSpeechRecognitionConstructor = () => {
  if (typeof window === 'undefined') {
    return null;
  }

  return window.SpeechRecognition || window.webkitSpeechRecognition || null;
};

const getMediaDevices = () => {
  if (typeof navigator === 'undefined') {
    return null;
  }

  return navigator.mediaDevices && typeof navigator.mediaDevices.getUserMedia === 'function'
    ? navigator.mediaDevices
    : null;
};

const detectBrowserSupport = async () => {
  if (typeof navigator === 'undefined') {
    return { isBrave: false };
  }

  try {
    const isBrave = typeof navigator.brave?.isBrave === 'function'
      ? await navigator.brave.isBrave()
      : false;

    return { isBrave };
  } catch {
    return { isBrave: false };
  }
};

const normalizeRecognitionError = (errorCode) => {
  switch (errorCode) {
    case 'not-allowed':
    case 'service-not-allowed':
      return 'Trình duyệt chưa được cấp quyền microphone. Hãy bấm biểu tượng ổ khóa cạnh thanh địa chỉ và cho phép Microphone rồi thử lại.';
    case 'audio-capture':
      return 'Không tìm thấy microphone khả dụng. Hãy kiểm tra thiết bị ghi âm của máy rồi thử lại.';
    case 'no-speech':
      return 'Không nghe thấy giọng nói. Hãy nói rõ hơn hoặc đưa micro lại gần rồi thử lại.';
    case 'network':
      return 'Trình duyệt không thể kết nối dịch vụ nhận diện giọng nói lúc này. Hãy kiểm tra mạng rồi thử lại.';
    case 'aborted':
      return '';
    default:
      return 'Không thể nhận diện giọng nói lúc này. Hãy thử lại bằng Chrome hoặc Edge.';
  }
};

const requestMicrophoneAccess = async () => {
  const mediaDevices = getMediaDevices();
  if (!mediaDevices) {
    return {
      ok: false,
      message: 'Trình duyệt hoặc môi trường hiện tại chưa cho phép truy cập microphone. Hãy mở ứng dụng bằng Chrome hoặc Edge trên localhost/HTTPS.'
    };
  }

  try {
    const stream = await mediaDevices.getUserMedia({ audio: true });
    stream.getTracks().forEach((track) => track.stop());
    return { ok: true };
  } catch (accessError) {
    const errorName = accessError?.name;
    if (errorName === 'NotAllowedError' || errorName === 'PermissionDeniedError') {
      return {
        ok: false,
        message: 'Bạn đã chặn quyền microphone. Hãy cho phép Microphone trong trình duyệt rồi thử lại.'
      };
    }

    if (errorName === 'NotFoundError' || errorName === 'DevicesNotFoundError') {
      return {
        ok: false,
        message: 'Máy hiện không có microphone khả dụng. Hãy cắm hoặc bật thiết bị ghi âm rồi thử lại.'
      };
    }

    return {
      ok: false,
      message: 'Không thể truy cập microphone lúc này. Hãy kiểm tra quyền trình duyệt và thiết bị âm thanh rồi thử lại.'
    };
  }
};

const buildWelcomeMessage = (title, mode) => ({
  id: `welcome-${mode}-${title}`,
  role: 'assistant',
  content: mode === 'lesson'
    ? `Tôi đang bám theo bài "${title}". Hỏi trực tiếp phần bạn cần giải thích, tóm tắt hoặc ví dụ.`
    : 'Đặt câu hỏi trực tiếp. Tôi sẽ trả lời ngắn gọn và tập trung vào việc học của bạn.',
  source: 'system'
});

const stringifyAssistantValue = (value) => {
  if (typeof value === 'string') {
    return value.trim();
  }

  if (typeof value === 'number' || typeof value === 'boolean') {
    return String(value);
  }

  if (Array.isArray(value)) {
    return value.map(stringifyAssistantValue).filter(Boolean).join('\n');
  }

  if (!value || typeof value !== 'object') {
    return '';
  }

  const sections = [];

  if (value.title) {
    sections.push(String(value.title).trim());
  }

  if (value.description) {
    sections.push(String(value.description).trim());
  }

  if (value.detail) {
    sections.push(String(value.detail).trim());
  }

  if (Array.isArray(value.actions) && value.actions.length) {
    sections.push(value.actions.map((item) => `- ${stringifyAssistantValue(item)}`).join('\n'));
  }

  if (sections.length) {
    return sections.join('\n\n');
  }

  try {
    return JSON.stringify(value, null, 2);
  } catch {
    return '';
  }
};

const normalizeAssistantContent = (response) => {
  const primaryContent = response?.answer
    ?? response?.advice
    ?? response?.response
    ?? response?.message
    ?? response?.detail
    ?? response?.analysis_summary;

  const normalized = stringifyAssistantValue(primaryContent);
  return normalized || 'Tôi chưa thể trả lời lúc này.';
};

const normalizeSpeechErrorMessage = (message = '') => {
  const normalized = String(message || '').trim();
  if (!normalized) {
    return 'Không thể tạo giọng đọc Google AI lúc này.';
  }

  return normalized;
};

const isQuotaSpeechError = (message = '') => {
  const normalized = String(message || '').toLowerCase();
  return normalized.includes('quota') || normalized.includes('resource_exhausted') || normalized.includes('429');
};

const buildSpeechText = (content) => {
  const plainText = stringifyAssistantValue(content)
    .replace(/[*_#`>-]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

  if (!plainText) {
    return '';
  }

  const sentenceParts = plainText.split(/(?<=[.!?])\s+/).filter(Boolean);
  const shortened = [];
  let totalLength = 0;

  for (const sentence of sentenceParts) {
    const nextLength = totalLength + sentence.length;
    if (nextLength > MAX_SPOKEN_TEXT_LENGTH && shortened.length > 0) {
      break;
    }

    shortened.push(sentence);
    totalLength = nextLength;

    if (totalLength >= MAX_SPOKEN_TEXT_LENGTH) {
      break;
    }
  }

  const result = (shortened.join(' ') || plainText).trim();
  return result.length > MAX_SPOKEN_TEXT_LENGTH
    ? `${result.slice(0, MAX_SPOKEN_TEXT_LENGTH).trim()}...`
    : result;
};

const TutorSceneFallback = ({ compact = false, message = 'NPC đang sẵn sàng hỗ trợ' }) => (
  <div className={`lesson-assistant-scene lesson-assistant-scene-fallback ${compact ? 'compact' : ''}`}>
    {!compact ? <span className="lesson-assistant-scene-fallback-label">{message}</span> : null}
  </div>
);

class TutorSceneErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error) {
    console.error('Tutor scene failed to render:', error);
  }

  render() {
    if (this.state.hasError) {
      return <TutorSceneFallback compact={this.props.compact} message="Hiệu ứng 3D đang tạm tắt để ưu tiên phần chat" />;
    }

    return this.props.children;
  }
}

const VluMark = () => (
  <div className="lesson-assistant-vlu-mark" aria-label="VLU">
    <span>VLU</span>
  </div>
);

const LessonAssistant = ({
  courseId,
  lessonId,
  lessonTitle = 'Bài học hiện tại',
  lessonDescription = '',
  mode = 'lesson'
}) => {
  const [messages, setMessages] = useState(() => [buildWelcomeMessage(lessonTitle, mode)]);
  const [question, setQuestion] = useState('');
  const [isSending, setIsSending] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const [isListening, setIsListening] = useState(false);
  const [isSpeaking, setIsSpeaking] = useState(false);
  const [responseMode, setResponseMode] = useState('voice');
  const [voiceGender, setVoiceGender] = useState('female');
  const [voiceVolume, setVoiceVolume] = useState(DEFAULT_VOICE_VOLUME);
  const [speechSupport, setSpeechSupport] = useState({ recognition: false, mediaDevices: false, isBrave: false });
  const [error, setError] = useState(null);
  const endRef = useRef(null);
  const recognitionRef = useRef(null);
  const audioRef = useRef(null);
  const lastAudioSignatureRef = useRef(null);

  const stopCurrentAudio = () => {
    const activeAudio = audioRef.current;
    if (activeAudio) {
      activeAudio.pause();
      activeAudio.currentTime = 0;
      activeAudio.onended = null;
      activeAudio.onerror = null;
      audioRef.current = null;
    }
    setIsSpeaking(false);
  };

  useEffect(() => {
    setMessages([buildWelcomeMessage(lessonTitle, mode)]);
    setQuestion('');
    setError(null);
    setIsOpen(false);
    lastAudioSignatureRef.current = null;
    stopCurrentAudio();
  }, [lessonId, lessonTitle, mode]);

  useEffect(() => {
    if (typeof window === 'undefined') {
      return undefined;
    }

    const savedVoiceVolume = window.localStorage.getItem('lesson-assistant-voice-volume');
    if (savedVoiceVolume) {
      const parsedVolume = Number(savedVoiceVolume);
      if (!Number.isNaN(parsedVolume)) {
        setVoiceVolume(Math.min(1, Math.max(0, parsedVolume)));
      }
    }

    const syncSupport = async () => {
      const browserSupport = await detectBrowserSupport();
      setSpeechSupport({
        recognition: Boolean(getSpeechRecognitionConstructor()),
        mediaDevices: Boolean(getMediaDevices()),
        isBrave: browserSupport.isBrave
      });
    };

    void syncSupport();

    return () => {
      recognitionRef.current?.stop?.();
      stopCurrentAudio();
    };
  }, []);

  useEffect(() => {
    if (typeof window !== 'undefined') {
      window.localStorage.setItem('lesson-assistant-voice-volume', String(voiceVolume));
    }

    if (audioRef.current) {
      audioRef.current.volume = voiceVolume;
    }
  }, [voiceVolume]);

  useEffect(() => {
    endRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, isSending]);

  useEffect(() => {
    const latestMessage = messages.at(-1);
    if (responseMode !== 'voice' || !latestMessage) {
      return;
    }

    if (latestMessage.role !== 'assistant' || latestMessage.source === 'system') {
      return;
    }

    const spokenText = buildSpeechText(latestMessage.content);
    if (!spokenText) {
      return;
    }

    const nextSignature = `${latestMessage.id}:${voiceGender}:${spokenText}`;
    if (lastAudioSignatureRef.current === nextSignature) {
      return;
    }

    let isDisposed = false;

    const speakWithGoogleTts = async () => {
      try {
        setError(null);
        stopCurrentAudio();
        setIsSpeaking(true);

        const speechResponse = await chatbotAPI.generateTutorSpeech(spokenText, voiceGender);
        if (isDisposed) {
          return;
        }

        const audioBase64 = speechResponse?.audio_base64;
        const mimeType = speechResponse?.mime_type || 'audio/wav';
        if (!audioBase64) {
          throw new Error('Google AI không trả về dữ liệu giọng nói.');
        }

        const audio = new Audio(`data:${mimeType};base64,${audioBase64}`);
        audio.volume = voiceVolume;
        audioRef.current = audio;
        lastAudioSignatureRef.current = nextSignature;

        audio.onended = () => {
          if (!isDisposed) {
            setIsSpeaking(false);
          }
        };

        audio.onerror = () => {
          if (!isDisposed) {
            setIsSpeaking(false);
            setError('Không thể phát giọng đọc Google AI lúc này.');
          }
        };

        await audio.play();
      } catch (speechError) {
        if (!isDisposed) {
          lastAudioSignatureRef.current = null;
          setIsSpeaking(false);
          const normalizedSpeechError = normalizeSpeechErrorMessage(speechError.message);
          if (isQuotaSpeechError(speechError.message)) {
            setResponseMode('text');
            setError('Google AI voice đang tạm hết quota. AI Tutor sẽ tiếp tục trả lời bằng chữ cho đến khi quota hồi lại.');
            return;
          }

          setError(`Google AI voice hiện chưa phát được. AI Tutor vẫn giữ câu trả lời bằng chữ. Chi tiết: ${normalizedSpeechError}`);
        }
      }
    };

    void speakWithGoogleTts();

    return () => {
      isDisposed = true;
      stopCurrentAudio();
    };
  }, [messages, responseMode, voiceGender, voiceVolume]);

  useEffect(() => {
    if (responseMode !== 'voice') {
      stopCurrentAudio();
    }
  }, [responseMode]);

  const suggestions = mode === 'lesson'
    ? [
        `Tóm tắt nhanh bài ${lessonTitle} theo kiểu mentor Văn Lang`,
        'Giải thích phần này bằng ví dụ gần với sinh viên hơn',
        'Cho tôi một tình huống thực hành để hiểu bài',
        'Nếu chỉ còn ít thời gian, tôi nên nhớ phần nào trước?'
      ]
    : [
        'Thiết kế cho tôi một tuần học đúng nhịp và bền',
        'Tôi nên ưu tiên môn nào để tiến độ bật lên nhanh nhất?',
        'Giữ động lực học kiểu Văn Lang nên bắt đầu từ đâu?',
        'Lập cho tôi một kế hoạch ôn tập ngắn nhưng hiệu quả'
      ];

  const sendQuestion = async (rawQuestion) => {
    const trimmedQuestion = rawQuestion.trim();
    if (!trimmedQuestion || isSending) {
      return;
    }

    const userMessage = {
      id: `user-${Date.now()}`,
      role: 'user',
      content: trimmedQuestion
    };

    setMessages((currentMessages) => [...currentMessages, userMessage]);
    setQuestion('');
    setError(null);
    setIsSending(true);

    try {
      const response = mode === 'lesson' && courseId && lessonId
        ? await chatbotAPI.askLessonAssistant(courseId, lessonId, trimmedQuestion)
        : await chatbotAPI.askAdvisor(trimmedQuestion);

      const assistantContent = normalizeAssistantContent(response);

      setMessages((currentMessages) => [
        ...currentMessages,
        {
          id: `assistant-${Date.now()}`,
          role: 'assistant',
          content: assistantContent,
          source: response.source || (mode === 'lesson' ? 'lesson_assistant' : 'advisor')
        }
      ]);
    } catch (apiError) {
      const fallbackError = apiError.message || 'Không thể gửi câu hỏi tới trợ lý AI';
      setError(fallbackError);
      setMessages((currentMessages) => [
        ...currentMessages,
        {
          id: `assistant-error-${Date.now()}`,
          role: 'assistant',
          content: `Tôi chưa thể trả lời ngay lúc này. Lý do: ${fallbackError}`,
          source: 'error'
        }
      ]);
    } finally {
      setIsSending(false);
    }
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    await sendQuestion(question);
  };

  const handleToggleListening = async () => {
    if (speechSupport.isBrave) {
      setError('Brave hiện không chạy ổn định tính năng hỏi bằng mic của AI Tutor. Hãy dùng Edge hoặc Chrome để nói, còn trong Brave bạn vẫn có thể nhập câu hỏi bằng chữ.');
      return;
    }

    if (!speechSupport.recognition) {
      setError('Trình duyệt hiện tại chưa hỗ trợ nhập câu hỏi bằng giọng nói. Hãy dùng Chrome hoặc Edge mới nhất.');
      return;
    }

    if (!speechSupport.mediaDevices) {
      setError('Trình duyệt hiện tại chưa cho phép truy cập microphone. Hãy mở ứng dụng trên localhost hoặc HTTPS bằng Chrome/Edge.');
      return;
    }

    if (isListening) {
      recognitionRef.current?.stop?.();
      setIsListening(false);
      return;
    }

    const Recognition = getSpeechRecognitionConstructor();
    if (!Recognition) {
      setError('Không tìm thấy Speech Recognition trong trình duyệt này.');
      return;
    }

    const accessResult = await requestMicrophoneAccess();
    if (!accessResult.ok) {
      setError(accessResult.message);
      return;
    }

    let transcriptBuffer = '';
    const recognition = new Recognition();
    recognition.lang = 'vi-VN';
    recognition.interimResults = true;
    recognition.continuous = false;
    recognition.maxAlternatives = 1;

    recognition.onstart = () => {
      setError(null);
      setIsListening(true);
    };

    recognition.onresult = (event) => {
      transcriptBuffer = Array.from(event.results)
        .map((result) => result[0]?.transcript || '')
        .join(' ')
        .trim();
      setQuestion(transcriptBuffer);
    };

    recognition.onerror = (event) => {
      const nextError = normalizeRecognitionError(event.error);
      if (nextError) {
        setError(nextError);
      }
      setIsListening(false);
    };

    recognition.onend = () => {
      setIsListening(false);
      recognitionRef.current = null;
      if (transcriptBuffer.trim()) {
        void sendQuestion(transcriptBuffer);
      }
    };

    recognitionRef.current = recognition;
    try {
      recognition.start();
    } catch (startError) {
      recognitionRef.current = null;
      setIsListening(false);
      setError(startError?.message
        ? `Không thể bật microphone lúc này. Chi tiết: ${startError.message}`
        : 'Không thể bật microphone lúc này. Hãy thử tải lại trang rồi thử lại.');
    }
  };

  const handleChangeResponseMode = (nextMode) => {
    if (nextMode !== 'voice') {
      stopCurrentAudio();
    }

    setResponseMode(nextMode);
    setError(null);
  };

  const handleChangeVoiceGender = (nextGender) => {
    setVoiceGender(nextGender);
    lastAudioSignatureRef.current = null;
    setError(null);
    stopCurrentAudio();
  };

  const handleVoiceVolumeChange = (event) => {
    const nextVolume = Number(event.target.value) / 100;
    setVoiceVolume(Math.min(1, Math.max(0, nextVolume)));
  };

  const selectedVoice = useMemo(() => GOOGLE_TTS_VOICE_PRESETS[voiceGender] || GOOGLE_TTS_VOICE_PRESETS.female, [voiceGender]);

  const npcMode = isSending
    ? 'thinking'
    : isListening
      ? 'listening'
      : isSpeaking
        ? 'speaking'
        : 'idle';

  return (
    <div className={`lesson-assistant-floating ${isOpen ? 'open' : 'collapsed'}`}>
      <button
        type="button"
        className={`lesson-assistant-launcher ${isOpen ? 'hidden' : ''}`}
        onClick={() => setIsOpen(true)}
      >
        <div className="lesson-assistant-launcher-scene">
          <TutorSceneErrorBoundary compact>
            <LessonTutorNpcScene mode={npcMode} compact />
          </TutorSceneErrorBoundary>
        </div>
        <div className="lesson-assistant-launcher-copy">
          <strong>{VLU_TUTOR_NAME}</strong>
          <span>{mode === 'lesson' ? 'Mở để hỏi theo bài học' : 'Mở để hỏi nhanh'}</span>
        </div>
      </button>

      {isOpen ? (
        <section className="lesson-assistant-section">
          <div className="lesson-assistant-panel-header">
            <div className="lesson-assistant-title-row">
              <div className="lesson-assistant-icon">
                <VluMark />
              </div>
              <div>
                <div className="lesson-assistant-kicker">Hỗ trợ học tập</div>
                <h2>{VLU_TUTOR_NAME}</h2>
                <p>
                  {mode === 'lesson'
                    ? 'Hỏi trực tiếp nội dung của bài học hiện tại.'
                    : 'Hỏi trực tiếp về kế hoạch học, ưu tiên môn và cách cải thiện tiến độ.'}
                </p>
              </div>
            </div>

            <button type="button" className="lesson-assistant-minimize" onClick={() => setIsOpen(false)}>
              <Minimize2 size={18} />
            </button>
          </div>

          <div className="lesson-assistant-hero">
            <TutorSceneErrorBoundary>
              <LessonTutorNpcScene mode={npcMode} />
            </TutorSceneErrorBoundary>

            <div className="lesson-assistant-hero-copy">
              <div className="lesson-assistant-context">
                <div className="lesson-assistant-context-topline">
                  <strong>{mode === 'lesson' ? lessonTitle : lessonTitle}</strong>
                </div>
                {lessonDescription ? <span>{lessonDescription}</span> : null}
              </div>

              <div className="lesson-assistant-status-row">
                <span className={`lesson-assistant-status-pill ${npcMode}`}>
                  {isSending ? 'Đang phân tích và cố vấn' : isListening ? 'Đang lắng nghe' : isSpeaking ? 'Đang trả lời bằng giọng nói' : 'Sẵn sàng đồng hành'}
                </span>
                <span className="lesson-assistant-status-pill muted">
                  {speechSupport.isBrave ? 'Mic bị giới hạn trên Brave' : speechSupport.recognition && speechSupport.mediaDevices ? 'Mic sẵn sàng' : 'Mic chưa khả dụng'}
                </span>
                <span className="lesson-assistant-status-pill brand">
                  {mode === 'lesson' ? 'Theo bài học' : 'Tư vấn nhanh'}
                </span>
              </div>

              <div className="lesson-assistant-settings">
                <div className="lesson-assistant-setting-block">
                  <span className="lesson-assistant-setting-label">Kiểu trả lời</span>
                  <div className="lesson-assistant-choice-group">
                    <button
                      type="button"
                      className={`lesson-assistant-choice-button ${responseMode === 'text' ? 'active' : ''}`}
                      onClick={() => handleChangeResponseMode('text')}
                    >
                      Trả lời bằng chữ
                    </button>
                    <button
                      type="button"
                      className={`lesson-assistant-choice-button ${responseMode === 'voice' ? 'active' : ''}`}
                      onClick={() => handleChangeResponseMode('voice')}
                    >
                      <Volume2 size={14} />
                      Chữ kèm giọng nói
                    </button>
                  </div>
                </div>

                <div className="lesson-assistant-setting-block">
                  <span className="lesson-assistant-setting-label">Giọng đọc</span>
                  <div className="lesson-assistant-choice-group">
                    <button
                      type="button"
                      className={`lesson-assistant-choice-button ${voiceGender === 'female' ? 'active' : ''}`}
                      onClick={() => handleChangeVoiceGender('female')}
                    >
                      Giọng nữ
                    </button>
                    <button
                      type="button"
                      className={`lesson-assistant-choice-button ${voiceGender === 'male' ? 'active' : ''}`}
                      onClick={() => handleChangeVoiceGender('male')}
                    >
                      Giọng nam
                    </button>
                  </div>
                  <span className="lesson-assistant-setting-hint">
                    {`Đang dùng: ${selectedVoice.label}. ${selectedVoice.description}.`}
                  </span>
                </div>

                <div className="lesson-assistant-setting-block">
                  <span className="lesson-assistant-setting-label">Âm lượng giọng nói</span>
                  <div className="lesson-assistant-volume-row">
                    <Volume2 size={16} />
                    <input
                      type="range"
                      min="0"
                      max="100"
                      step="5"
                      value={Math.round(voiceVolume * 100)}
                      onChange={handleVoiceVolumeChange}
                      className="lesson-assistant-volume-slider"
                    />
                    <span className="lesson-assistant-volume-value">{Math.round(voiceVolume * 100)}%</span>
                  </div>
                  <span className="lesson-assistant-setting-hint">
                    Âm lượng này chỉ áp dụng cho phần giọng đọc của {VLU_TUTOR_NAME}.
                  </span>
                </div>
              </div>
            </div>
          </div>

          <div className="lesson-assistant-suggestions">
            {suggestions.map((suggestion) => (
              <button
                key={suggestion}
                type="button"
                className="lesson-assistant-chip"
                onClick={() => {
                  setQuestion(suggestion);
                  void sendQuestion(suggestion);
                }}
              >
                {suggestion}
              </button>
            ))}
          </div>

          <div className="lesson-assistant-messages">
            {messages.map((message) => (
              <article
                key={message.id}
                className={`lesson-assistant-message lesson-assistant-message-${message.role}`}
              >
                <div className="lesson-assistant-avatar">
                  {message.role === 'assistant' ? <Bot size={18} /> : <User size={18} />}
                </div>
                <div className="lesson-assistant-bubble">
                  <div className="lesson-assistant-role">
                    {message.role === 'assistant' ? (mode === 'lesson' ? `${VLU_TUTOR_NAME} Theo Bài Học` : VLU_TUTOR_NAME) : 'Bạn'}
                  </div>
                  <div className="lesson-assistant-text">{message.content}</div>
                </div>
              </article>
            ))}

            {isSending ? (
              <article className="lesson-assistant-message lesson-assistant-message-assistant">
                <div className="lesson-assistant-avatar">
                  <Bot size={18} />
                </div>
                <div className="lesson-assistant-bubble lesson-assistant-bubble-loading">
                  <Loader2 size={18} className="lesson-assistant-spinner" />
                  <span>{mode === 'lesson' ? `${VLU_TUTOR_NAME} đang chuẩn bị câu trả lời theo bài học...` : `${VLU_TUTOR_NAME} đang chuẩn bị câu trả lời...`}</span>
                </div>
              </article>
            ) : null}

            <div ref={endRef} />
          </div>

          <form className="lesson-assistant-form" onSubmit={handleSubmit}>
            <textarea
              value={question}
              onChange={(event) => setQuestion(event.target.value)}
              rows={3}
              placeholder={mode === 'lesson'
                ? 'Hỏi nội dung bạn đang vướng trong bài này...'
                : 'Hỏi môn nên ưu tiên, kế hoạch học hoặc vấn đề bạn đang mắc...'}
            />
            <div className="lesson-assistant-form-footer">
              <div className="lesson-assistant-controls">
                <button
                  type="button"
                  className={`lesson-assistant-control-button ${isListening ? 'active' : ''}`}
                  onClick={handleToggleListening}
                  disabled={isSending || speechSupport.isBrave}
                >
                  {isListening ? <MicOff size={16} /> : <Mic size={16} />}
                  {speechSupport.isBrave ? 'Brave chưa hỗ trợ ổn định' : isListening ? 'Dừng nghe' : 'Hỏi bằng mic'}
                </button>

                <button
                  type="button"
                  className={`lesson-assistant-control-button ${responseMode === 'voice' ? 'active' : ''}`}
                  onClick={() => handleChangeResponseMode(responseMode === 'voice' ? 'text' : 'voice')}
                >
                  <Volume2 size={16} />
                  {responseMode === 'voice' ? 'Đang bật giọng nói' : 'Đang chỉ trả lời bằng chữ'}
                </button>
              </div>

              <button type="submit" className="lesson-assistant-submit" disabled={isSending || !question.trim()}>
                <Send size={16} />
                Gửi câu hỏi
              </button>
            </div>
          </form>

          <div className="lesson-assistant-hint-row">
            <span className="lesson-assistant-hint">
              {mode === 'lesson'
                ? `${VLU_TUTOR_NAME} ưu tiên trả lời theo bài học hiện tại.`
                : `${VLU_TUTOR_NAME} ưu tiên trả lời ngắn gọn theo câu hỏi của bạn.`}
            </span>
            {speechSupport.isBrave ? (
              <span className="lesson-assistant-hint">
                Brave thường chặn hoặc làm hỏng Web Speech API, nên chế độ hỏi bằng mic của AI Tutor hiện chỉ được hỗ trợ ổn định trên Edge và Chrome.
              </span>
            ) : null}
            {!speechSupport.recognition || !speechSupport.mediaDevices ? (
              <span className="lesson-assistant-hint">
                Mic hiện hoạt động tốt nhất trên Chrome hoặc Edge khi trang đang chạy bằng localhost hoặc HTTPS.
              </span>
            ) : null}
          </div>

          {error ? <div className="lesson-assistant-error">{error}</div> : null}
        </section>
      ) : null}
    </div>
  );
};

export default LessonAssistant;