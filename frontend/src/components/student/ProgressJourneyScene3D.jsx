import { Suspense, memo, useMemo, useRef } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { Cloud, Float, Html, OrbitControls, PerspectiveCamera, Sparkles, Stars } from '@react-three/drei';
import * as THREE from 'three';

const BASE_POINT = new THREE.Vector3(-10, -3.2, 4.5);
const STAGE_POINTS = [
  new THREE.Vector3(-6.6, -2.25, 2.9),
  new THREE.Vector3(-3.2, -1.1, 1.5),
  new THREE.Vector3(0.3, 0.35, 0.15),
  new THREE.Vector3(3.8, 1.9, -1.15),
  new THREE.Vector3(7.1, 3.65, -2.7)
];

const SCENE_CONFIG = {
  1: {
    sky: '#d9f99d',
    fog: '#f0fdf4',
    path: '#facc15',
    accent: '#22c55e',
    terrain: '#65a30d',
    ridge: '#3f6212'
  },
  2: {
    sky: '#fde68a',
    fog: '#fff7ed',
    path: '#fb923c',
    accent: '#f59e0b',
    terrain: '#84cc16',
    ridge: '#4d7c0f'
  },
  3: {
    sky: '#bae6fd',
    fog: '#eff6ff',
    path: '#38bdf8',
    accent: '#0ea5e9',
    terrain: '#16a34a',
    ridge: '#14532d'
  },
  4: {
    sky: '#ddd6fe',
    fog: '#eef2ff',
    path: '#8b5cf6',
    accent: '#7c3aed',
    terrain: '#7c3aed',
    ridge: '#312e81'
  },
  5: {
    sky: '#fecaca',
    fog: '#fff7ed',
    path: '#ef4444',
    accent: '#f97316',
    terrain: '#fb7185',
    ridge: '#7f1d1d'
  }
};

const STAGE_CHARACTERS = {
  1: {
    title: 'Seed Scout',
    body: '#22c55e',
    head: '#fef3c7',
    accent: '#f472b6',
    aura: '#86efac'
  },
  2: {
    title: 'Sun Climber',
    body: '#f59e0b',
    head: '#fff7ed',
    accent: '#fde68a',
    aura: '#fdba74'
  },
  3: {
    title: 'Code Ranger',
    body: '#0ea5e9',
    head: '#e0f2fe',
    accent: '#38bdf8',
    aura: '#7dd3fc'
  },
  4: {
    title: 'Crystal Sage',
    body: '#8b5cf6',
    head: '#ede9fe',
    accent: '#c4b5fd',
    aura: '#ddd6fe'
  },
  5: {
    title: 'Summit Hero',
    body: '#ef4444',
    head: '#fff7ed',
    accent: '#f59e0b',
    aura: '#fdba74'
  }
};

const getCurve = () => new THREE.CatmullRomCurve3([BASE_POINT, ...STAGE_POINTS]);

const lerpPoint = (start, end, ratio) => start.clone().lerp(end, ratio);

const getTotalSteps = (phase) => (phase?.required_total || 0) + (phase?.elective_min_select || 0);

const getCompletedSteps = (phase) => (phase?.required_completed || 0) + Math.min(phase?.elective_completed || 0, phase?.elective_min_select || 0);

const FloatingGroup = memo(function FloatingGroup({ children, speed = 1, amplitude = 0.12 }) {
  const groupRef = useRef(null);

  useFrame((state) => {
    if (!groupRef.current) {
      return;
    }
    groupRef.current.position.y += Math.sin((state.clock.elapsedTime * speed)) * amplitude * 0.0025;
  });

  return <group ref={groupRef}>{children}</group>;
});

const MountainMass = memo(function MountainMass({ color, ridge }) {
  return (
    <group position={[0, -2.8, -4.6]}>
      <mesh position={[-5.5, 1.1, 0]} castShadow receiveShadow>
        <coneGeometry args={[4.2, 7.8, 6]} />
        <meshStandardMaterial color={ridge} roughness={0.92} />
      </mesh>
      <mesh position={[-0.8, 1.9, -0.3]} castShadow receiveShadow>
        <coneGeometry args={[5.4, 10.5, 7]} />
        <meshStandardMaterial color={color} roughness={0.88} />
      </mesh>
      <mesh position={[5.1, 3.1, -0.8]} castShadow receiveShadow>
        <coneGeometry args={[4.3, 12, 7]} />
        <meshStandardMaterial color={ridge} roughness={0.9} />
      </mesh>
    </group>
  );
});

const Tree = memo(function Tree({ position, scale = 1, tint = '#166534' }) {
  return (
    <group position={position} scale={scale}>
      <mesh position={[0, 0.22, 0]} castShadow>
        <cylinderGeometry args={[0.06, 0.08, 0.45, 8]} />
        <meshStandardMaterial color="#7c3f18" roughness={0.95} />
      </mesh>
      <mesh position={[0, 0.7, 0]} castShadow>
        <coneGeometry args={[0.34, 0.88, 8]} />
        <meshStandardMaterial color={tint} roughness={0.82} />
      </mesh>
    </group>
  );
});

const FlowerPatch = memo(function FlowerPatch({ position }) {
  const offsets = [[0, 0, 0], [0.28, 0.02, 0.16], [-0.24, 0.01, 0.18], [0.15, 0, -0.18]];

  return (
    <group position={position}>
      <mesh receiveShadow rotation={[-Math.PI / 2, 0, 0]}>
        <circleGeometry args={[0.68, 24]} />
        <meshStandardMaterial color="#65a30d" roughness={1} />
      </mesh>
      {offsets.map((offset, index) => (
        <group key={index} position={offset}>
          <mesh position={[0, 0.06, 0]} castShadow>
            <sphereGeometry args={[0.06, 16, 16]} />
            <meshStandardMaterial color={index % 2 === 0 ? '#f472b6' : '#fb7185'} roughness={0.65} />
          </mesh>
          <mesh position={[0, 0.02, 0]} castShadow>
            <cylinderGeometry args={[0.012, 0.018, 0.08, 8]} />
            <meshStandardMaterial color="#15803d" roughness={0.92} />
          </mesh>
        </group>
      ))}
    </group>
  );
});

const CrystalCluster = memo(function CrystalCluster({ position, color = '#8b5cf6' }) {
  return (
    <group position={position}>
      {[0, 1, 2].map((index) => (
        <Float key={index} speed={1 + index * 0.3} rotationIntensity={0.08} floatIntensity={0.2}>
          <mesh
            position={[index * 0.22 - 0.2, 0.2 + index * 0.08, index % 2 === 0 ? 0.12 : -0.1]}
            rotation={[0.15, index * 0.3, 0]}
            castShadow
          >
            <octahedronGeometry args={[0.18 + index * 0.04, 0]} />
            <meshStandardMaterial color={color} emissive={color} emissiveIntensity={0.35} roughness={0.22} metalness={0.3} />
          </mesh>
        </Float>
      ))}
    </group>
  );
});

const RuneCluster = memo(function RuneCluster({ position, color = '#38bdf8' }) {
  return (
    <group position={position}>
      {[0, 1].map((index) => (
        <Float key={index} speed={1.4 + index * 0.2} rotationIntensity={0.4} floatIntensity={0.35}>
          <mesh position={[index * 0.34 - 0.16, 0.46 + index * 0.12, index === 0 ? 0.1 : -0.1]} castShadow>
            <torusKnotGeometry args={[0.1, 0.03, 70, 8, 2, 3]} />
            <meshStandardMaterial color={color} emissive={color} emissiveIntensity={0.45} roughness={0.25} metalness={0.6} />
          </mesh>
        </Float>
      ))}
    </group>
  );
});

const SummitFlag = memo(function SummitFlag({ position }) {
  return (
    <group position={position}>
      <mesh position={[0, 0.62, 0]} castShadow>
        <cylinderGeometry args={[0.03, 0.03, 1.2, 12]} />
        <meshStandardMaterial color="#f8fafc" roughness={0.4} metalness={0.2} />
      </mesh>
      <mesh position={[0.3, 0.95, 0]} rotation={[0, 0, -0.08]} castShadow>
        <boxGeometry args={[0.55, 0.28, 0.03]} />
        <meshStandardMaterial color="#fb7185" emissive="#fb7185" emissiveIntensity={0.28} roughness={0.45} />
      </mesh>
      <mesh position={[0, 0.08, 0]} receiveShadow>
        <cylinderGeometry args={[0.36, 0.48, 0.18, 20]} />
        <meshStandardMaterial color="#f59e0b" roughness={0.72} />
      </mesh>
    </group>
  );
});

const StageAvatar = memo(function StageAvatar({ stageId, position, selected = false }) {
  const character = STAGE_CHARACTERS[stageId] || STAGE_CHARACTERS[1];

  return (
    <Float speed={1.1 + (stageId * 0.08)} rotationIntensity={0.16} floatIntensity={0.24}>
      <group position={position}>
        <mesh position={[0, 0.95, 0]} castShadow>
          <sphereGeometry args={[0.25, 24, 24]} />
          <meshStandardMaterial color={character.head} roughness={0.32} />
        </mesh>

        <mesh position={[0, 0.48, 0]} castShadow>
          <capsuleGeometry args={[0.16, 0.42, 8, 14]} />
          <meshStandardMaterial color={character.body} emissive={character.body} emissiveIntensity={selected ? 0.3 : 0.14} roughness={0.34} />
        </mesh>

        <mesh position={[-0.12, 0.48, 0]} rotation={[0, 0, Math.PI / 3.8]} castShadow>
          <capsuleGeometry args={[0.04, 0.22, 6, 10]} />
          <meshStandardMaterial color={character.body} roughness={0.5} />
        </mesh>
        <mesh position={[0.12, 0.48, 0]} rotation={[0, 0, -Math.PI / 3.8]} castShadow>
          <capsuleGeometry args={[0.04, 0.22, 6, 10]} />
          <meshStandardMaterial color={character.body} roughness={0.5} />
        </mesh>

        <mesh position={[-0.07, 0.12, 0]} rotation={[0, 0, Math.PI / 15]} castShadow>
          <capsuleGeometry args={[0.05, 0.26, 6, 10]} />
          <meshStandardMaterial color={character.body} roughness={0.5} />
        </mesh>
        <mesh position={[0.07, 0.12, 0]} rotation={[0, 0, -Math.PI / 15]} castShadow>
          <capsuleGeometry args={[0.05, 0.26, 6, 10]} />
          <meshStandardMaterial color={character.body} roughness={0.5} />
        </mesh>

        <mesh position={[0, 1.35, 0]}>
          <torusGeometry args={[0.36, 0.04, 12, 40]} />
          <meshBasicMaterial color={character.aura} transparent opacity={selected ? 0.55 : 0.28} />
        </mesh>

        <mesh position={[0.16, 0.62, 0.08]} castShadow>
          <octahedronGeometry args={[0.08, 0]} />
          <meshStandardMaterial color={character.accent} emissive={character.accent} emissiveIntensity={0.4} roughness={0.24} metalness={0.18} />
        </mesh>
      </group>
    </Float>
  );
});

const StepNodes = memo(function StepNodes({ phase, index, selectedStageId }) {
  const totalSteps = getTotalSteps(phase);
  const completedSteps = getCompletedSteps(phase);
  const start = index === 0 ? BASE_POINT : STAGE_POINTS[index - 1];
  const end = STAGE_POINTS[index];
  const accent = (SCENE_CONFIG[phase.id] || SCENE_CONFIG[1]).accent;

  if (!totalSteps) {
    return null;
  }

  return (
    <group>
      {Array.from({ length: totalSteps }).map((_, stepIndex) => {
        const ratio = (stepIndex + 1) / totalSteps;
        const point = lerpPoint(start, end, ratio);
        const isDone = stepIndex < completedSteps;
        const isSelectedPhase = selectedStageId === phase.id;

        return (
          <group key={`${phase.id}-step-${stepIndex}`} position={[point.x, point.y + 0.08, point.z]}>
            <mesh castShadow>
              <sphereGeometry args={[isSelectedPhase ? 0.09 : 0.07, 16, 16]} />
              <meshStandardMaterial
                color={isDone ? accent : '#e2e8f0'}
                emissive={isDone ? accent : '#94a3b8'}
                emissiveIntensity={isDone ? (isSelectedPhase ? 0.6 : 0.34) : 0.04}
                roughness={0.26}
                metalness={0.12}
              />
            </mesh>
          </group>
        );
      })}
    </group>
  );
});

const StageEnvironment = memo(function StageEnvironment({ stageId, point }) {
  switch (stageId) {
    case 1:
      return (
        <group position={point.toArray()}>
          <FlowerPatch position={[-0.65, -0.08, 0.3]} />
          <FlowerPatch position={[0.62, -0.08, -0.18]} />
        </group>
      );
    case 2:
      return (
        <group position={point.toArray()}>
          <Cloud position={[-0.8, 1.25, -0.35]} opacity={0.5} speed={0.15} width={1.8} depth={0.4} segments={18} />
          <Cloud position={[0.8, 1.5, 0.3]} opacity={0.45} speed={0.12} width={1.5} depth={0.4} segments={18} />
          <Float speed={1.1} rotationIntensity={0.12} floatIntensity={0.22}>
            <mesh position={[0.9, 1.95, -0.7]}>
              <sphereGeometry args={[0.28, 24, 24]} />
              <meshStandardMaterial color="#fde68a" emissive="#facc15" emissiveIntensity={0.45} roughness={0.25} />
            </mesh>
          </Float>
        </group>
      );
    case 3:
      return (
        <group position={point.toArray()}>
          <Tree position={[-0.6, 0.06, 0.3]} scale={0.92} tint="#166534" />
          <Tree position={[0.56, 0.04, -0.18]} scale={1.04} tint="#14532d" />
          <RuneCluster position={[0.08, 0.12, 0]} color="#38bdf8" />
        </group>
      );
    case 4:
      return (
        <group position={point.toArray()}>
          <CrystalCluster position={[0.05, 0.06, 0]} color="#a78bfa" />
          <mesh position={[0, 0.03, 0]} rotation={[-Math.PI / 2, 0, 0]}>
            <circleGeometry args={[1.25, 28]} />
            <meshBasicMaterial color="#e9d5ff" transparent opacity={0.16} />
          </mesh>
        </group>
      );
    case 5:
      return (
        <group position={point.toArray()}>
          <SummitFlag position={[0.2, 0.1, 0]} />
          <Sparkles count={28} scale={[2.8, 1.6, 2.8]} size={4} color="#fde68a" position={[0, 1.6, 0]} speed={0.4} />
        </group>
      );
    default:
      return null;
  }
});

const StageMarker = memo(function StageMarker({ phase, index, selectedStageId, onSelect }) {
  const point = STAGE_POINTS[index];
  const config = SCENE_CONFIG[phase.id] || SCENE_CONFIG[1];
  const isSelected = selectedStageId === phase.id;
  const labelClass = phase.is_completed ? 'completed' : phase.is_active ? 'current' : 'locked';
  const totalSteps = getTotalSteps(phase);
  const completedSteps = getCompletedSteps(phase);

  return (
    <group position={point.toArray()}>
      <mesh
        castShadow
        receiveShadow
        onClick={() => onSelect(phase.id)}
        onPointerOver={() => {
          document.body.style.cursor = 'pointer';
        }}
        onPointerOut={() => {
          document.body.style.cursor = 'default';
        }}
      >
        <cylinderGeometry args={[0.28, 0.42, 0.22, 20]} />
        <meshStandardMaterial color={config.accent} emissive={config.accent} emissiveIntensity={isSelected ? 0.38 : 0.18} roughness={0.36} metalness={0.14} />
      </mesh>
      <Float speed={1.2} rotationIntensity={0.08} floatIntensity={0.18}>
        <mesh position={[0, 0.38, 0]} castShadow>
          <sphereGeometry args={[0.2, 20, 20]} />
          <meshStandardMaterial color="#ffffff" emissive={config.accent} emissiveIntensity={isSelected ? 0.85 : 0.45} roughness={0.18} metalness={0.08} />
        </mesh>
      </Float>
      {isSelected ? (
        <mesh position={[0, 0.08, 0]} rotation={[-Math.PI / 2, 0, 0]}>
          <ringGeometry args={[0.48, 0.6, 36]} />
          <meshBasicMaterial color={config.accent} transparent opacity={0.5} />
        </mesh>
      ) : null}
      <StageAvatar stageId={phase.id} position={[0.72, 0.1, phase.id % 2 === 0 ? -0.22 : 0.22]} selected={isSelected || phase.is_active} />
      <Html position={[0, 0.86, 0]} center distanceFactor={9} style={{ pointerEvents: 'none' }}>
        <div className={`progress-journey-scene-label ${labelClass} ${isSelected ? 'selected' : ''}`}>
          <strong>Giai doan {phase.id}</strong>
          <span>{phase.name.replace(/^Giai doan \d+:\s*/i, '')}</span>
          <em>{completedSteps}/{totalSteps} mon</em>
        </div>
      </Html>
    </group>
  );
});

function SceneRig({ selectedStageId }) {
  const rigRef = useRef(null);

  useFrame((state) => {
    if (!rigRef.current) {
      return;
    }

    rigRef.current.rotation.y = THREE.MathUtils.lerp(
      rigRef.current.rotation.y,
      -0.18 + ((selectedStageId - 1) * 0.055) + (Math.sin(state.clock.elapsedTime * 0.18) * 0.02),
      0.04
    );
  });

  return <group ref={rigRef} />;
}

function JourneyScene({ phases, selectedStageId, activeStageId, activeStageProgress, onSelectStage }) {
  const activeStageIndex = Math.max(0, phases.findIndex((phase) => phase.id === activeStageId));
  const selectedConfig = SCENE_CONFIG[selectedStageId] || SCENE_CONFIG[1];
  const curve = useMemo(() => getCurve(), []);

  const travelerPoint = useMemo(() => {
    if (!phases.length) {
      return BASE_POINT;
    }

    const allCompleted = phases.every((phase) => phase.is_completed);
    if (allCompleted) {
      return STAGE_POINTS[STAGE_POINTS.length - 1];
    }

    const start = activeStageIndex === 0 ? BASE_POINT : STAGE_POINTS[activeStageIndex - 1];
    const end = STAGE_POINTS[activeStageIndex] || STAGE_POINTS[0];
    return lerpPoint(start, end, activeStageProgress / 100);
  }, [activeStageIndex, activeStageProgress, phases]);

  return (
    <>
      <color attach="background" args={[selectedConfig.fog]} />
      <fog attach="fog" args={[selectedConfig.fog, 12, 28]} />
      <PerspectiveCamera makeDefault position={[7.8, 6.5, 12.5]} fov={42} />
      <ambientLight intensity={0.95} />
      <directionalLight position={[8, 12, 7]} intensity={1.6} castShadow shadow-mapSize-width={2048} shadow-mapSize-height={2048} />
      <pointLight position={[-5, 5, 6]} intensity={1.2} color={selectedConfig.sky} />
      <OrbitControls enablePan={false} enableZoom={false} minPolarAngle={0.85} maxPolarAngle={1.25} autoRotate autoRotateSpeed={0.28} target={[0, 0.4, 0]} />

      <SceneRig selectedStageId={selectedStageId} />

      <Stars radius={38} depth={20} count={selectedStageId >= 4 ? 1800 : 650} factor={selectedStageId >= 4 ? 3.2 : 1.2} fade speed={0.4} />
      <Sparkles count={selectedStageId >= 3 ? 90 : 40} scale={[16, 8, 12]} size={selectedStageId >= 4 ? 4.5 : 3} color={selectedConfig.accent} speed={0.32} opacity={0.4} />

      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -3.3, 0]} receiveShadow>
        <planeGeometry args={[38, 24]} />
        <meshStandardMaterial color={selectedConfig.terrain} roughness={1} />
      </mesh>

      <MountainMass color={selectedConfig.terrain} ridge={selectedConfig.ridge} />

      <mesh geometry={new THREE.TubeGeometry(curve, 120, 0.18, 14, false)} castShadow receiveShadow>
        <meshStandardMaterial color={selectedConfig.path} emissive={selectedConfig.path} emissiveIntensity={0.16} roughness={0.34} metalness={0.18} />
      </mesh>

      <mesh position={BASE_POINT.toArray()} receiveShadow>
        <cylinderGeometry args={[0.55, 0.75, 0.24, 20]} />
        <meshStandardMaterial color="#fbbf24" roughness={0.72} />
      </mesh>

      <Html position={[BASE_POINT.x, BASE_POINT.y + 0.72, BASE_POINT.z]} center distanceFactor={9} style={{ pointerEvents: 'none' }}>
        <div className="progress-journey-scene-label current">
          <strong>Bat dau</strong>
          <span>Khoi dong hanh trinh</span>
        </div>
      </Html>

      {phases.map((phase, index) => (
        <group key={phase.id}>
          <StepNodes phase={phase} index={index} selectedStageId={selectedStageId} />
          <StageEnvironment stageId={phase.id} point={STAGE_POINTS[index]} />
          <StageMarker
            phase={phase}
            index={index}
            selectedStageId={selectedStageId}
            onSelect={onSelectStage}
          />
        </group>
      ))}

      <FloatingGroup speed={1.9} amplitude={0.3}>
        <group position={travelerPoint.toArray()}>
          <StageAvatar stageId={activeStageId} position={[0, 0.06, 0]} selected />
          <mesh position={[0, -0.08, 0]} rotation={[-Math.PI / 2, 0, 0]}>
            <circleGeometry args={[0.44, 24]} />
            <meshBasicMaterial color="#fff7ed" transparent opacity={0.18} />
          </mesh>
        </group>
      </FloatingGroup>

      <mesh position={[travelerPoint.x, travelerPoint.y - 0.22, travelerPoint.z]} rotation={[-Math.PI / 2, 0, 0]}>
        <ringGeometry args={[0.26, 0.44, 30]} />
        <meshBasicMaterial color="#ffffff" transparent opacity={0.34} />
      </mesh>

      <Cloud position={[-7.5, 5.6, -3.4]} opacity={0.28} speed={0.1} width={4.2} depth={1.1} segments={24} />
      <Cloud position={[0.5, 7, -5.4]} opacity={0.24} speed={0.09} width={5.5} depth={1.6} segments={24} />
      <Cloud position={[8.2, 6.1, -2.8]} opacity={0.2} speed={0.12} width={3.8} depth={1.2} segments={24} />
    </>
  );
}

const ProgressJourneyScene3D = ({ phases, selectedStageId, activeStageId, activeStageProgress, onSelectStage }) => {
  return (
    <div className="progress-journey-canvas-shell">
      <Canvas className="progress-journey-canvas" shadows dpr={[1, 1.5]} gl={{ antialias: true }}>
        <Suspense fallback={null}>
          <JourneyScene
            phases={phases}
            selectedStageId={selectedStageId}
            activeStageId={activeStageId}
            activeStageProgress={activeStageProgress}
            onSelectStage={onSelectStage}
          />
        </Suspense>
      </Canvas>
    </div>
  );
};

export default ProgressJourneyScene3D;