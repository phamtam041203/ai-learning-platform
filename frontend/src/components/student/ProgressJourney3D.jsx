import { useEffect, useMemo, useState } from 'react';
import './ProgressJourney3D.css';

const STAGE_VISUALS = {
  1: {
    shortName: 'Cơ sở ngành',
    accent: '#22c55e',
    glow: 'rgba(34, 197, 94, 0.28)',
    mood: 'Chân núi cỏ xanh và hoa nở đầu mùa.',
    companion: 'Seed Scout',
    scene: 'Đồng cỏ hoa và nền trời trong',
    capsule: 'Nền móng'
  },
  2: {
    shortName: 'Nền tảng chuyên ngành',
    accent: '#f59e0b',
    glow: 'rgba(245, 158, 11, 0.28)',
    mood: 'Lên cao hơn với nắng, mây và không khí thoáng đãng.',
    companion: 'Sun Climber',
    scene: 'Mây trời, ánh nắng và đường dốc rõ hơn',
    capsule: 'Bắt nhịp'
  },
  3: {
    shortName: 'Chuyên ngành CNPM',
    accent: '#0ea5e9',
    glow: 'rgba(14, 165, 233, 0.28)',
    mood: 'Sườn núi có rừng thông, cột mốc và dấu ấn kỹ năng chuyên sâu.',
    companion: 'Code Ranger',
    scene: 'Rừng thông, không khí mát và trụ kỹ năng',
    capsule: 'Chuyên sâu'
  },
  4: {
    shortName: 'Nâng cao',
    accent: '#8b5cf6',
    glow: 'rgba(139, 92, 246, 0.28)',
    mood: 'Vùng cao có sương lạnh, tinh thể và thách thức nâng cao.',
    companion: 'Crystal Sage',
    scene: 'Sương, tinh thể và những chặng khó hơn',
    capsule: 'Bứt phá'
  },
  5: {
    shortName: 'Tốt nghiệp',
    accent: '#ef4444',
    glow: 'rgba(239, 68, 68, 0.28)',
    mood: 'Đỉnh núi sáng vàng, cờ hiệu và vạch đích tốt nghiệp.',
    companion: 'Summit Hero',
    scene: 'Đỉnh cao, cờ hiệu và ánh sáng chiến thắng',
    capsule: 'Đích đến'
  }
};

const getRequiredMilestones = (phase) => (phase?.required_total || 0) + (phase?.elective_min_select || 0);

const getCompletedMilestones = (phase) => (phase?.required_completed || 0) + Math.min(phase?.elective_completed || 0, phase?.elective_min_select || 0);

const getPhasePercentage = (phase) => {
  const total = getRequiredMilestones(phase);
  if (!total) {
    return phase?.is_completed ? 100 : 0;
  }
  return Math.round((getCompletedMilestones(phase) / total) * 100);
};

const getPendingCourses = (phase) => {
  if (!phase) {
    return [];
  }

  const pendingRequired = (phase.required_courses || []).filter((course) => !course.is_completed);
  const electivesNeeded = Math.max(0, (phase.elective_min_select || 0) - (phase.elective_completed || 0));
  const pendingElectives = (phase.elective_courses || []).filter((course) => !course.is_completed);

  return [
    ...pendingRequired,
    ...pendingElectives.slice(0, electivesNeeded || pendingElectives.length)
  ];
};

const getRecommendedCourse = (phase) => {
  const pendingCourses = getPendingCourses(phase);

  return pendingCourses.find((course) => course.is_enrolled && !course.is_locked && course.course_id)
    || pendingCourses.find((course) => !course.is_locked && course.course_id)
    || null;
};

const getTotalCoursesForStage = (phase) => (phase?.required_total || 0) + (phase?.elective_min_select || 0);

const getCompletedCoursesForStage = (phase) => (phase?.required_completed || 0) + Math.min(phase?.elective_completed || 0, phase?.elective_min_select || 0);

const STAGE_TOP_BOUNDS = {
  desktop: { start: 860, end: 80 },
  compact: { start: 920, end: 120 },
  mobile: { start: 980, end: 180 }
};

const getStageTopBounds = (viewportWidth) => {
  if (viewportWidth <= 768) {
    return STAGE_TOP_BOUNDS.mobile;
  }

  if (viewportWidth <= 1200) {
    return STAGE_TOP_BOUNDS.compact;
  }

  return STAGE_TOP_BOUNDS.desktop;
};

const getStageTops = (totalStages, viewportWidth) => {
  const { start, end } = getStageTopBounds(viewportWidth);

  if (totalStages <= 1) {
    return [start];
  }

  const step = (start - end) / (totalStages - 1);
  return Array.from({ length: totalStages }, (_, index) => Math.round(start - (step * index)));
};

const STAGE_CARD_LAYOUTS = {
  1: { side: 'left' },
  2: { side: 'left' },
  3: { side: 'left' },
  4: { side: 'left' },
  5: { side: 'left' }
};

const getTravelerTop = (phases, activeStageId, stageTops) => {
  if (!phases.length) {
    return stageTops[0];
  }

  const activeStageIndex = Math.max(0, phases.findIndex((phase) => phase.id === activeStageId));
  return stageTops[activeStageIndex] ?? stageTops[0];
};

const getRankMeta = (overallPercentage) => {
  if (overallPercentage >= 90) {
    return { title: 'Summit Legend', nextAt: 100 };
  }

  if (overallPercentage >= 75) {
    return { title: 'Master Climber', nextAt: 90 };
  }

  if (overallPercentage >= 55) {
    return { title: 'Challenger', nextAt: 75 };
  }

  if (overallPercentage >= 35) {
    return { title: 'Trail Explorer', nextAt: 55 };
  }

  return { title: 'Rookie Hiker', nextAt: 35 };
};

const StageProgressDots = ({ total, completed }) => {
  return (
    <div className="stage-step-track">
      {Array.from({ length: total || 0 }).map((_, index) => (
        <span
          key={`stage-dot-${index}`}
          className={`stage-step-chip ${index < completed ? 'done' : ''}`}
        />
      ))}
    </div>
  );
};

const CompanionAvatar = ({ stageId, variant = 'card' }) => (
  <div className={`companion-avatar ${variant} companion-stage-${stageId || 1}`} aria-hidden="true">
    <span className="companion-aura" />
    <span className="companion-head" />
    <span className="companion-body" />
    <span className="companion-accent companion-accent-one" />
    <span className="companion-accent companion-accent-two" />
  </div>
);

const ProgressJourney3D = ({ roadmap, onCourseSelect, personalization = null }) => {
  const [selectedStageId, setSelectedStageId] = useState(null);
  const [viewportWidth, setViewportWidth] = useState(() => {
    if (typeof window === 'undefined') {
      return 1440;
    }

    return window.innerWidth;
  });

  const phases = roadmap?.phases || [];
  const currentStageId = roadmap?.current_phase?.id || phases.find((phase) => phase.is_current)?.id || roadmap?.active_phase?.id || phases.find((phase) => phase.is_active)?.id || phases.at(-1)?.id || 1;
  const preferredStageId = personalization?.recommended_phase_id || currentStageId;
  const aiUnlockedPhaseIds = new Set(personalization?.unlocked_phase_ids || []);
  const stageReadiness = new Map((personalization?.stage_readiness || []).map((item) => [item.phase_id, item]));

  useEffect(() => {
    if (!selectedStageId) {
      setSelectedStageId(preferredStageId);
      return;
    }

    if (selectedStageId && !phases.some((phase) => phase.id === selectedStageId)) {
      setSelectedStageId(preferredStageId);
    }
  }, [phases, preferredStageId, selectedStageId]);

  useEffect(() => {
    if (typeof window === 'undefined') {
      return undefined;
    }

    const handleResize = () => setViewportWidth(window.innerWidth);

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const selectedStage = useMemo(() => {
    return phases.find((phase) => phase.id === selectedStageId)
      || phases.find((phase) => phase.id === currentStageId)
      || phases[0]
      || null;
  }, [currentStageId, phases, selectedStageId]);
  const currentStage = useMemo(() => {
    return phases.find((phase) => phase.id === currentStageId)
      || phases[0]
      || null;
  }, [currentStageId, phases]);

  const totalMilestones = phases.reduce((sum, phase) => sum + getRequiredMilestones(phase), 0);
  const completedMilestones = phases.reduce((sum, phase) => sum + getCompletedMilestones(phase), 0);
  const overallPercentage = totalMilestones > 0 ? Math.round((completedMilestones / totalMilestones) * 100) : 0;
  const completedStages = phases.filter((phase) => phase.is_completed).length;
  const selectedStagePercentage = getPhasePercentage(selectedStage);
  const selectedVisual = STAGE_VISUALS[selectedStage?.id] || STAGE_VISUALS[1];
  const activeVisual = STAGE_VISUALS[currentStage?.id] || STAGE_VISUALS[1];
  const stageTops = useMemo(() => getStageTops(phases.length, viewportWidth), [phases.length, viewportWidth]);
  const recommendedCourse = getRecommendedCourse(selectedStage);
  const pendingCourses = getPendingCourses(selectedStage).slice(0, 4);
  const selectedStageTotalCourses = getTotalCoursesForStage(selectedStage);
  const selectedStageCompletedCourses = getCompletedCoursesForStage(selectedStage);
  const travelerTop = getTravelerTop(phases, currentStageId, stageTops);
  const selectedStageReadiness = stageReadiness.get(selectedStage?.id);
  const aiHintForStage = (personalization?.recommended_course_hints || []).find((course) => course.phase_id === selectedStage?.id);
  const rankMeta = getRankMeta(overallPercentage);
  const progressToNextRank = rankMeta.nextAt === 100
    ? overallPercentage
    : Math.max(0, Math.min(100, Math.round((overallPercentage / rankMeta.nextAt) * 100)));
  const evolutionTier = Math.max(0, Math.min(5, completedStages));

  return (
    <section className="progress-journey-shell">
      <div className="progress-journey-copy">
        <div className="progress-journey-kicker">Mountain Journey</div>
        <h2>5 chặng leo núi mở khóa theo từng giai đoạn học</h2>
        <p>
          Hành trình được chia thành 5 đoạn: <strong>Cơ sở ngành</strong>, <strong>Nền tảng chuyên ngành</strong>,
          <strong> Chuyên ngành CNPM</strong>, <strong>Nâng cao</strong> và <strong>Tốt nghiệp</strong>.
          Mỗi khi bạn vượt qua một giai đoạn, màu sắc và cảnh vật trên núi sẽ đổi theo.
        </p>

        <div className="progress-journey-status-card">
          <strong>Đang leo: {currentStage?.name || 'Đang cập nhật'}</strong>
          <span>
            {activeVisual.mood} Nhân vật đồng hành của chặng này là <strong>{activeVisual.companion}</strong>.
          </span>
        </div>

        {personalization ? (
          <div className="progress-journey-ai-card">
            <div className="progress-journey-ai-top">
              <div>
                <span className="progress-journey-ai-kicker">AI Unlock Plan</span>
                <strong>Gemini đã phân tích bài test đầu vào và gợi ý chặng nên mở trước</strong>
              </div>
              <div className="progress-journey-ai-score">{personalization.assessment_score}%</div>
            </div>

            <p>{personalization.ai_summary}</p>

            <div className="progress-journey-ai-tags">
              <span>Học phù hợp: <strong>{personalization.learning_style}</strong></span>
              <span>Độ khó mở đầu: <strong>{personalization.recommended_difficulty}</strong></span>
              <span>AI mở khóa: <strong>{(personalization.unlocked_phase_ids || []).join(', ')}</strong></span>
            </div>
          </div>
        ) : null}

        <div className="progress-journey-metrics">
          <div className="progress-journey-metric">
            <span className="progress-journey-metric-label">Tiến độ toàn hành trình</span>
            <strong>{overallPercentage}%</strong>
          </div>
          <div className="progress-journey-metric">
            <span className="progress-journey-metric-label">Chặng đã mở khóa</span>
            <strong>{completedStages}/{phases.length || 5}</strong>
          </div>
          <div className="progress-journey-metric">
            <span className="progress-journey-metric-label">Cột mốc đã đạt</span>
            <strong>{completedMilestones}/{totalMilestones || 0}</strong>
          </div>
        </div>

        <div className="progress-journey-tabs-section">
        <div className="progress-journey-stage-tabs">
          {phases.map((phase) => {
            const visual = STAGE_VISUALS[phase.id] || STAGE_VISUALS[1];
            const isSelected = selectedStage?.id === phase.id;
            const isCurrentStage = currentStage?.id === phase.id;

            return (
              <button
                key={phase.id}
                type="button"
                className={`progress-stage-tab ${isSelected ? 'active' : ''} ${phase.is_completed ? 'completed' : (phase.is_current || phase.is_active) ? 'current' : 'locked'} ${aiUnlockedPhaseIds.has(phase.id) ? 'ai-unlocked' : ''}`}
                style={{ '--stage-accent': visual.accent, '--stage-glow': visual.glow }}
                onClick={() => setSelectedStageId(phase.id)}
              >
                <span className="progress-stage-tab-step">Giai đoạn {phase.id}</span>
                <strong>{visual.shortName}</strong>
                <div className="progress-stage-pill-row">
                  {isCurrentStage ? <span className="progress-stage-state-pill current">Hiện tại</span> : null}
                  {isSelected && !isCurrentStage ? <span className="progress-stage-state-pill viewing">Đang xem</span> : null}
                  {aiUnlockedPhaseIds.has(phase.id) ? <span className="progress-stage-ai-pill">AI mở trước</span> : null}
                </div>
              </button>
            );
          })}
        </div>

        {selectedStage ? (
          <div className="progress-journey-course-panel stage-detail-panel" style={{ '--stage-accent': selectedVisual.accent, '--stage-glow': selectedVisual.glow }}>
            <div className="progress-journey-course-panel-top">
              <div>
                <div className="progress-journey-course-eyebrow">
                  {selectedStage?.id === currentStage?.id ? 'Chặng hiện tại' : 'Chặng đang xem'}
                </div>
                <h3>{selectedStage.name}</h3>
              </div>
              <div className="progress-journey-course-percent">{selectedStagePercentage}%</div>
            </div>

            <p className="stage-detail-description">{selectedStage.description}</p>

            <div className="progress-journey-course-stats">
              <div>
                <span>Bắt buộc</span>
                <strong>{selectedStage.required_completed || 0}/{selectedStage.required_total || 0}</strong>
              </div>
              <div>
                <span>Tự chọn</span>
                <strong>{Math.min(selectedStage.elective_completed || 0, selectedStage.elective_min_select || 0)}/{selectedStage.elective_min_select || 0}</strong>
              </div>
              <div>
                <span>Trạng thái</span>
                <strong>{selectedStage.is_completed ? 'Đã hoàn thành' : (selectedStage.is_current || selectedStage.is_active) ? 'Đang mở khóa' : 'Chưa tới lượt'}</strong>
              </div>
            </div>

            <div className="stage-step-progress">
              <div className="stage-step-progress-copy">
                <strong>1 môn = 1 bước leo</strong>
                <span>
                  Chặng này có {selectedStageTotalCourses} bước. Bạn đã leo {selectedStageCompletedCourses}/{selectedStageTotalCourses} bước để chạm mốc tiếp theo.
                </span>
              </div>
              <div className="stage-step-track" style={{ '--stage-accent': selectedVisual.accent }}>
                {Array.from({ length: selectedStageTotalCourses || 0 }).map((_, index) => (
                  <span
                    key={`step-${selectedStage?.id}-${index}`}
                    className={`stage-step-chip ${index < selectedStageCompletedCourses ? 'done' : ''}`}
                  />
                ))}
              </div>
            </div>

            {selectedStageReadiness ? (
              <div className="progress-journey-ai-stage-panel">
                <div>
                  <span className="stage-detail-label">Độ sẵn sàng do AI phân tích</span>
                  <strong>{selectedStageReadiness.readiness_score}%</strong>
                </div>
                <p>{selectedStageReadiness.reason}</p>
                {aiHintForStage ? (
                  <div className="progress-journey-ai-hint">
                    {aiHintForStage.is_locked
                      ? `AI gợi ý chuẩn bị trước cho ${aiHintForStage.course_name}, nhưng môn này vẫn đang khóa theo điều kiện lộ trình hiện tại.`
                      : `AI gợi ý ưu tiên ${aiHintForStage.course_name} ở chặng này để đi đúng năng lực hiện tại.`}
                  </div>
                ) : null}
              </div>
            ) : null}

            <div className="stage-detail-checklist">
              <span className="stage-detail-label">Cần hoàn thành tiếp</span>
              {pendingCourses.length ? (
                <div className="stage-detail-tags">
                  {pendingCourses.map((course) => (
                    <span key={course.code} className={`stage-detail-tag ${course.is_locked ? 'locked' : ''}`}>
                      {course.name}
                    </span>
                  ))}
                </div>
              ) : (
                <div className="stage-detail-empty">Giai đoạn này đã xong. Bạn có thể tiến lên chặng tiếp theo.</div>
              )}
            </div>

            {recommendedCourse ? (
              <div className="progress-journey-course-actions">
                <button
                  type="button"
                  className="progress-journey-open-course"
                  onClick={() => onCourseSelect?.({
                    courseId: recommendedCourse.course_id,
                    course: recommendedCourse.name
                  })}
                >
                  Tiếp tục với {recommendedCourse.name}
                </button>
              </div>
            ) : null}
          </div>
        ) : null}
        </div>
      </div>

      <div
        className={`progress-journey-scene-card new-2d-layout stage-vibe-${currentStage?.id || 1} evolution-tier-${evolutionTier}`}
        style={{ '--journey-accent': activeVisual.accent, '--journey-glow': activeVisual.glow }}
      >
        <div className="new-2d-header">
          <div className="new-2d-header-left">
            <span className="new-2d-kicker">2D JOURNEY MAP</span>
            <h2>{currentStage?.name ? `Giai đoạn ${currentStage.id}: ${currentStage.name}` : 'Lộ trình học tập'}</h2>
          </div>
          <div className="new-2d-header-right">
            <div className="journey-rank-title-row">
              <span className="journey-rank-badge">RANK</span>
              <strong>{rankMeta.title}</strong>
            </div>

            <div className="journey-rank-progress-row">
              <span>{overallPercentage}%</span>
              <span>Mốc {rankMeta.nextAt}%</span>
            </div>
            <div className="journey-rank-progress-track" role="presentation" aria-hidden="true">
              <span style={{ width: `${progressToNextRank}%` }}></span>
            </div>

            <div className="journey-rank-stats">
              <div>
                <span>Chặng mở</span>
                <strong>{completedStages}/{phases.length || 5}</strong>
              </div>
              <div>
                <span>Mốc đã leo</span>
                <strong>{completedMilestones}/{totalMilestones || 0}</strong>
              </div>
            </div>

            <span>{roadmap?.program || 'CÔNG NGHỆ PHẦN MỀM'}</span>
          </div>
        </div>
        <div className="new-2d-background">
          <div className="bg-sky"></div>
          <div className="bg-glow bg-glow-top"></div>
          <div className="bg-glow bg-glow-bottom"></div>
          <div className="bg-aurora bg-aurora-one"></div>
          <div className="bg-aurora bg-aurora-two"></div>
          <div className="bg-sun"></div>
          <div className="bg-cloud bg-cloud-one"></div>
          <div className="bg-cloud bg-cloud-two"></div>
          <div className="bg-cloud bg-cloud-three"></div>
          <div className="bg-evolution-beam"></div>
          <div className="bg-evolution-rings">
            <span className="evolution-ring ring-one"></span>
            <span className="evolution-ring ring-two"></span>
            <span className="evolution-ring ring-three"></span>
          </div>
          <div className="bg-evolution-comets">
            <span className="evolution-comet comet-one"></span>
            <span className="evolution-comet comet-two"></span>
            <span className="evolution-comet comet-three"></span>
          </div>
          <div className="bg-constellation">
            <span className="constellation-point point-one"></span>
            <span className="constellation-point point-two"></span>
            <span className="constellation-point point-three"></span>
            <span className="constellation-point point-four"></span>
            <span className="constellation-point point-five"></span>
            <span className="constellation-line line-one"></span>
            <span className="constellation-line line-two"></span>
            <span className="constellation-line line-three"></span>
            <span className="constellation-line line-four"></span>
          </div>
          <div className="bg-haze"></div>
          <div className="bg-floating-particles" aria-hidden="true">
            {Array.from({ length: 10 }).map((_, index) => (
              <span key={`bg-particle-${index}`} className={`bg-particle particle-${index + 1}`} />
            ))}
          </div>
          <div className="bg-mountains"></div>
          <div className="bg-summit bg-summit-one"><span></span></div>
          <div className="bg-summit bg-summit-two"><span></span></div>
          <div className="bg-summit bg-summit-three"><span></span></div>
          <div className="bg-evolution-victory"></div>
          <div className="bg-ground-light"></div>
        </div>

        <div className="new-2d-track">
          <div className="new-2d-line"></div>
          {phases.map((phase, index) => {
            const visual = STAGE_VISUALS[phase.id] || STAGE_VISUALS[1];

            return (
              <div
                key={`rail-node-${phase.id}`}
                className={`new-2d-rail-node ${currentStage?.id === phase.id ? 'active' : ''} ${phase.is_completed ? 'completed' : ''}`}
                style={{ top: `${stageTops[index]}px`, '--rail-node-color': visual.accent }}
                aria-hidden="true"
              >
                <CompanionAvatar stageId={phase.id} variant="rail" />
              </div>
            );
          })}
          
          <div className="new-2d-traveler" style={{ top: `${travelerTop}px`, '--traveler-node-color': activeVisual.accent }}>
            <div className="traveler-flag-icon">
              <span className="flag-bubble">BẠN ĐANG Ở ĐÂY</span>
              <div className="traveler-current-avatar">
                <CompanionAvatar stageId={currentStage?.id || 1} variant="rail" />
              </div>
              <span className="flag-pole"></span>
            </div>
          </div>

          {phases.map((phase, index) => {
            const visual = STAGE_VISUALS[phase.id] || STAGE_VISUALS[1];
            const stageCompleted = getCompletedCoursesForStage(phase);
            const stageTotal = getTotalCoursesForStage(phase);
            const isSelected = selectedStage?.id === phase.id;
            const isCurrentStage = currentStage?.id === phase.id;
            const cardLayout = STAGE_CARD_LAYOUTS[phase.id] || STAGE_CARD_LAYOUTS[1];
            const cardSide = cardLayout.side;
            
            return (
              <button
                type="button"
                key={phase.id}
                className={`new-2d-card-wrapper pos-${cardSide} ${isSelected?'selected':''} ${phase.is_completed?'completed':''} ${isCurrentStage?'current':''} stage-${phase.id}`}
                style={{ top: `${stageTops[index]}px`, '--stage-color': visual.accent, '--stage-glow': visual.glow }}
                onClick={() => setSelectedStageId(phase.id)}
              >
                <div className="new-2d-card">
                  <div className="new-2d-card-icon">
                    <CompanionAvatar stageId={phase.id} />
                  </div>
                  <div className="new-2d-card-content">
                    <div className="new-2d-card-pills">
                      <span className="pill-capsule" style={{ backgroundColor: visual.glow, color: visual.accent }}>{visual.capsule || 'CHẶNG'}</span>
                      {isCurrentStage && <span className="pill-current">HIỆN TẠI</span>}
                      {!isCurrentStage && isSelected ? <span className="pill-viewing">ĐANG XEM</span> : null}
                    </div>
                    <h3>Giai đoạn {phase.id}: {phase.name}</h3>
                    <p>{visual.scene}</p>
                    
                    <div className="new-2d-card-progress">
                      <div className="progress-text">
                        <span>{stageCompleted}/{stageTotal} MÔN</span>
                        <span>{getPhasePercentage(phase)}%</span>
                      </div>
                      <div className="progress-bars">
                        {Array.from({ length: stageTotal || 5 }).map((_, i) => (
                          <span className={`bar-segment ${i < stageCompleted ? 'done' : ''}`} key={i}></span>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              </button>
            );
          })}
        </div>

        <div className="new-2d-bottom-panels">
          <div className="new-2d-panel">
            <div className="panel-info">
              <span>NHÂN VẬT HIỆN TẠI</span>
              <strong>{activeVisual.companion || 'Summit Hero'}</strong>
            </div>
            <div className="panel-icon">🧭</div>
          </div>
          <div className="new-2d-panel">
            <div className="panel-info">
              <span>KHUNG CẢNH</span>
              <strong>{activeVisual.scene}</strong>
            </div>
            <div className="panel-icon">⛰️</div>
          </div>
          <div className="new-2d-panel">
            <div className="panel-info">
              <span>BẦU KHÔNG KHÍ</span>
              <strong>{activeVisual.mood}</strong>
            </div>
            <div className="panel-icon">✨</div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default ProgressJourney3D;
