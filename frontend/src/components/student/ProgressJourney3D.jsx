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

const STAGE_TOPS = [82, 64, 46, 28, 10];

const getTravelerTop = (phases, activeStageId) => {
  if (!phases.length) {
    return STAGE_TOPS[0];
  }

  const activeStageIndex = Math.max(0, phases.findIndex((phase) => phase.id === activeStageId));
  const activePhase = phases[activeStageIndex] || phases[0];
  const stageProgress = getPhasePercentage(activePhase) / 100;

  if (activeStageIndex === 0) {
    return 92 - ((92 - STAGE_TOPS[0]) * stageProgress);
  }

  const startTop = STAGE_TOPS[activeStageIndex - 1];
  const endTop = STAGE_TOPS[activeStageIndex];
  return startTop - ((startTop - endTop) * stageProgress);
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

const ProgressJourney3D = ({ roadmap, onCourseSelect, personalization = null }) => {
  const [selectedStageId, setSelectedStageId] = useState(null);

  const phases = roadmap?.phases || [];
  const activeStageId = roadmap?.active_phase?.id || phases.find((phase) => phase.is_active)?.id || phases.at(-1)?.id || 1;
  const preferredStageId = personalization?.recommended_phase_id || activeStageId;
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

  const selectedStage = useMemo(() => {
    return phases.find((phase) => phase.id === selectedStageId)
      || phases.find((phase) => phase.id === activeStageId)
      || phases[0]
      || null;
  }, [activeStageId, phases, selectedStageId]);

  const totalMilestones = phases.reduce((sum, phase) => sum + getRequiredMilestones(phase), 0);
  const completedMilestones = phases.reduce((sum, phase) => sum + getCompletedMilestones(phase), 0);
  const overallPercentage = totalMilestones > 0 ? Math.round((completedMilestones / totalMilestones) * 100) : 0;
  const completedStages = phases.filter((phase) => phase.is_completed).length;
  const selectedStagePercentage = getPhasePercentage(selectedStage);
  const selectedVisual = STAGE_VISUALS[selectedStage?.id] || STAGE_VISUALS[1];
  const recommendedCourse = getRecommendedCourse(selectedStage);
  const pendingCourses = getPendingCourses(selectedStage).slice(0, 4);
  const selectedStageTotalCourses = getTotalCoursesForStage(selectedStage);
  const selectedStageCompletedCourses = getCompletedCoursesForStage(selectedStage);
  const travelerTop = getTravelerTop(phases, activeStageId);
  const selectedStageReadiness = stageReadiness.get(selectedStage?.id);
  const aiHintForStage = (personalization?.recommended_course_hints || []).find((course) => course.phase_id === selectedStage?.id);

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
          <strong>Đang leo: {selectedStage?.name || 'Đang cập nhật'}</strong>
          <span>{selectedVisual.mood} Nhân vật đồng hành của chặng này là <strong>{selectedVisual.companion}</strong>.</span>
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

        <div className="progress-journey-stage-tabs">
          {phases.map((phase) => {
            const visual = STAGE_VISUALS[phase.id] || STAGE_VISUALS[1];

            return (
              <button
                key={phase.id}
                type="button"
                className={`progress-stage-tab ${selectedStage?.id === phase.id ? 'active' : ''} ${phase.is_completed ? 'completed' : phase.is_active ? 'current' : 'locked'} ${aiUnlockedPhaseIds.has(phase.id) ? 'ai-unlocked' : ''}`}
                style={{ '--stage-accent': visual.accent, '--stage-glow': visual.glow }}
                onClick={() => setSelectedStageId(phase.id)}
              >
                <span className="progress-stage-tab-step">Giai đoạn {phase.id}</span>
                <strong>{visual.shortName}</strong>
                {aiUnlockedPhaseIds.has(phase.id) ? <span className="progress-stage-ai-pill">AI mở trước</span> : null}
              </button>
            );
          })}
        </div>

        {selectedStage ? (
          <div className="progress-journey-course-panel stage-detail-panel" style={{ '--stage-accent': selectedVisual.accent, '--stage-glow': selectedVisual.glow }}>
            <div className="progress-journey-course-panel-top">
              <div>
                <div className="progress-journey-course-eyebrow">Trọng tâm giai đoạn</div>
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
                <strong>{selectedStage.is_completed ? 'Đã hoàn thành' : selectedStage.is_active ? 'Đang mở khóa' : 'Chưa tới lượt'}</strong>
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

      <div className="progress-journey-scene-card">
        <div className={`progress-journey-map stage-theme-${selectedStage?.id || 1}`}>
          <div className="progress-journey-map-hud">
            <div>
              <span className="journey-map-kicker">2D Journey Map</span>
              <h3>{selectedStage?.name || 'Lộ trình học tập'}</h3>
            </div>
            <div className="journey-map-meta">
              <strong>{overallPercentage}%</strong>
              <span>{roadmap?.program || 'CNPM'}</span>
            </div>
          </div>

          <div className="journey-skyline">
            <span className="sky-sun" />
            <span className="sky-cloud cloud-one" />
            <span className="sky-cloud cloud-two" />
            <span className="sky-cloud cloud-three" />
          </div>

          <div className={`journey-scene-layer stage-scene-${selectedStage?.id || 1}`} aria-hidden="true">
            <span className="scene-sky-glow" />
            <span className="scene-ground-shadow" />
            <span className="scene-haze" />
            <span className="scene-range range-back" />
            <span className="scene-range range-mid" />
            <span className="scene-range range-front" />
            <span className="scene-trail" />
            <span className="scene-ray ray-one" />
            <span className="scene-ray ray-two" />
            <span className="scene-wind wind-one" />
            <span className="scene-wind wind-two" />
            <span className="scene-flower flower-one" />
            <span className="scene-flower flower-two" />
            <span className="scene-flower flower-three" />
            <span className="scene-tree tree-one" />
            <span className="scene-tree tree-two" />
            <span className="scene-tree tree-three" />
            <span className="scene-marker marker-one" />
            <span className="scene-marker marker-two" />
            <span className="scene-crystal crystal-one" />
            <span className="scene-crystal crystal-two" />
            <span className="scene-mist mist-one" />
            <span className="scene-mist mist-two" />
            <span className="scene-peak" />
            <span className="scene-flag flag-one" />
            <span className="scene-flag flag-two" />
            <span className="scene-victory-glow" />
          </div>

          <div className={`journey-weather-layer stage-weather-${selectedStage?.id || 1}`} aria-hidden="true">
            {Array.from({ length: 14 }).map((_, index) => (
              <span
                key={`snow-${index}`}
                className={`journey-snowflake snow-${(index % 7) + 1}`}
              />
            ))}
          </div>

          <div className="journey-stage-bands">
            {phases.map((phase) => {
              const visual = STAGE_VISUALS[phase.id] || STAGE_VISUALS[1];
              return (
                <div
                  key={`band-${phase.id}`}
                  className={`journey-stage-band band-${phase.id} ${selectedStage?.id === phase.id ? 'active' : ''}`}
                  style={{ '--band-accent': visual.accent, '--band-glow': visual.glow }}
                >
                  <span className="band-aura" />
                  <span className="band-ridge ridge-back" />
                  <span className="band-ridge ridge-front" />
                  <span className="band-particle particle-one" />
                  <span className="band-particle particle-two" />
                  <span className="band-particle particle-three" />
                </div>
              );
            })}
          </div>

          <div className="journey-track">
            <div className="journey-rail" />
            <div className="journey-traveler" style={{ top: `${travelerTop}%`, '--traveler-accent': selectedVisual.accent }}>
              <span className="journey-traveler-core" />
              <span className="journey-traveler-label">Bạn đang ở đây</span>
            </div>

            {phases.map((phase, index) => {
              const visual = STAGE_VISUALS[phase.id] || STAGE_VISUALS[1];
              const stageCompleted = getCompletedCoursesForStage(phase);
              const stageTotal = getTotalCoursesForStage(phase);
              const isSelected = selectedStage?.id === phase.id;
              const cardSide = index % 2 === 0 ? 'left' : 'right';

              return (
                <button
                  type="button"
                  key={phase.id}
                  className={`journey-stage-card ${cardSide} ${isSelected ? 'selected' : ''} ${phase.is_completed ? 'completed' : phase.is_active ? 'current' : 'locked'} ${aiUnlockedPhaseIds.has(phase.id) ? 'ai-unlocked' : ''}`}
                  style={{
                    top: `${STAGE_TOPS[index]}%`,
                    '--stage-accent': visual.accent,
                    '--stage-glow': visual.glow
                  }}
                  onClick={() => setSelectedStageId(phase.id)}
                >
                  <span className="journey-stage-node" />
                  <div className="journey-stage-card-inner">
                    <div className={`journey-stage-avatar avatar-${phase.id}`}>
                      <span className="avatar-head" />
                      <span className="avatar-body" />
                    </div>

                    <div className="journey-stage-content">
                      <div className="journey-stage-topline">
                        <span className="journey-stage-tag">{visual.capsule}</span>
                        <strong>{phase.name}</strong>
                      </div>

                      {aiUnlockedPhaseIds.has(phase.id) ? (
                        <div className="journey-stage-ai-chip">AI unlock</div>
                      ) : null}

                      <p>{visual.scene}</p>

                      <div className="journey-stage-progress-row">
                        <span>{stageCompleted}/{stageTotal} môn</span>
                        <span>{getPhasePercentage(phase)}%</span>
                      </div>

                      <StageProgressDots total={stageTotal} completed={stageCompleted} />
                    </div>
                  </div>
                </button>
              );
            })}
          </div>

          <div className="journey-map-footer">
            <div>
              <strong>Nhân vật hiện tại</strong>
              <span>{selectedVisual.companion}</span>
            </div>
            <div>
              <strong>Khung cảnh</strong>
              <span>{selectedVisual.scene}</span>
            </div>
            <div>
              <strong>Bầu không khí</strong>
              <span>{selectedVisual.mood}</span>
            </div>
            {personalization ? (
              <div>
                <strong>AI mode</strong>
                <span>{personalization.recommended_difficulty} / {personalization.learning_style}</span>
              </div>
            ) : null}
          </div>
        </div>

        <div className="progress-journey-legend">
          <div>
            <span className="legend-dot legend-progress" />
            Cột mốc mỗi giai đoạn
          </div>
          <div>
            <span className="legend-dot legend-avatar" />
            Vị trí hiện tại của người học
          </div>
          <div>
            <span className="legend-dot legend-life" />
            Màu cảnh vật đổi theo từng chặng
          </div>
        </div>
      </div>
    </section>
  );
};

export default ProgressJourney3D;