import { Suspense, useRef } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { ContactShadows, Float, Sparkles as SceneSparkles } from '@react-three/drei';
import * as THREE from 'three';

const TutorNpcModel = ({ mode }) => {
  const groupRef = useRef(null);
  const haloRef = useRef(null);
  const orbRef = useRef(null);
  const bookRef = useRef(null);

  useFrame((state) => {
    const elapsed = state.clock.elapsedTime;
    const bob = Math.sin(elapsed * 1.8) * 0.08;
    const sway = Math.sin(elapsed * 0.85) * 0.18;
    const tilt = mode === 'listening'
      ? Math.sin(elapsed * 3.4) * 0.16
      : mode === 'thinking'
        ? Math.sin(elapsed * 2.4) * 0.08
        : Math.sin(elapsed * 1.5) * 0.05;

    if (groupRef.current) {
      groupRef.current.position.y = bob;
      groupRef.current.rotation.y = sway;
      groupRef.current.rotation.z = tilt;
    }

    if (haloRef.current) {
      haloRef.current.scale.setScalar(1 + ((Math.sin(elapsed * 2.6) + 1) * 0.04));
      haloRef.current.material.opacity = mode === 'speaking'
        ? 0.64
        : mode === 'listening'
          ? 0.54
          : mode === 'thinking'
            ? 0.48
            : 0.36;
    }

    if (orbRef.current) {
      orbRef.current.position.x = Math.sin(elapsed * 1.4) * 0.12;
      orbRef.current.position.z = Math.cos(elapsed * 1.4) * 0.12;
    }

    if (bookRef.current) {
      bookRef.current.rotation.y = elapsed * 0.75;
      bookRef.current.position.y = 0.58 + (Math.sin(elapsed * 2.1) * 0.05);
    }
  });

  const aura = mode === 'speaking'
    ? '#f59e0b'
    : mode === 'listening'
      ? '#fca5a5'
      : mode === 'thinking'
        ? '#f59e0b'
        : '#ef4444';

  return (
    <group ref={groupRef} position={[0, 0.2, 0]}>
      <mesh ref={haloRef} position={[0, 1.42, 0]} rotation={[-Math.PI / 2, 0, 0]}>
        <ringGeometry args={[0.46, 0.68, 48]} />
        <meshBasicMaterial color={aura} transparent opacity={0.4} side={THREE.DoubleSide} />
      </mesh>

      <Float speed={2.1} rotationIntensity={0.14} floatIntensity={0.28}>
        <group>
          <mesh position={[0, 1.46, 0]} castShadow>
            <cylinderGeometry args={[0.22, 0.28, 0.12, 32]} />
            <meshStandardMaterial color="#f59e0b" roughness={0.42} metalness={0.2} />
          </mesh>

          <mesh position={[0, 1.52, 0]} rotation={[0, 0, 0.18]} castShadow>
            <boxGeometry args={[0.34, 0.04, 0.34]} />
            <meshStandardMaterial color="#7f1d1d" roughness={0.36} metalness={0.16} />
          </mesh>

          <mesh position={[0, 1.02, 0]} castShadow>
            <sphereGeometry args={[0.28, 32, 32]} />
            <meshStandardMaterial color="#fff1e6" roughness={0.32} metalness={0.04} />
          </mesh>

          <mesh position={[0, 0.56, 0]} castShadow>
            <capsuleGeometry args={[0.22, 0.52, 10, 16]} />
            <meshStandardMaterial color="#b91c1c" emissive="#7f1d1d" emissiveIntensity={0.16} roughness={0.4} />
          </mesh>

          <mesh position={[0, 0.7, 0.2]} castShadow>
            <boxGeometry args={[0.12, 0.36, 0.04]} />
            <meshStandardMaterial color="#f8fafc" roughness={0.52} />
          </mesh>

          <mesh position={[0.06, 0.62, 0.22]} rotation={[0, 0, -0.42]} castShadow>
            <boxGeometry args={[0.06, 0.42, 0.03]} />
            <meshStandardMaterial color="#f59e0b" roughness={0.34} metalness={0.1} />
          </mesh>

          <mesh position={[-0.18, 0.58, 0]} rotation={[0, 0, Math.PI / 4.5]} castShadow>
            <capsuleGeometry args={[0.06, 0.24, 8, 12]} />
            <meshStandardMaterial color="#dc2626" roughness={0.46} />
          </mesh>

          <mesh position={[0.18, 0.58, 0]} rotation={[0, 0, -Math.PI / 4.5]} castShadow>
            <capsuleGeometry args={[0.06, 0.24, 8, 12]} />
            <meshStandardMaterial color="#dc2626" roughness={0.46} />
          </mesh>

          <mesh position={[-0.1, 0.1, 0]} rotation={[0, 0, Math.PI / 10]} castShadow>
            <capsuleGeometry args={[0.07, 0.26, 8, 12]} />
            <meshStandardMaterial color="#7f1d1d" roughness={0.48} />
          </mesh>

          <mesh position={[0.1, 0.1, 0]} rotation={[0, 0, -Math.PI / 10]} castShadow>
            <capsuleGeometry args={[0.07, 0.26, 8, 12]} />
            <meshStandardMaterial color="#7f1d1d" roughness={0.48} />
          </mesh>

          <mesh position={[-0.1, 1.05, 0.24]} castShadow>
            <sphereGeometry args={[0.03, 16, 16]} />
            <meshStandardMaterial color="#0f172a" emissive="#0f172a" emissiveIntensity={0.12} />
          </mesh>

          <mesh position={[0.1, 1.05, 0.24]} castShadow>
            <sphereGeometry args={[0.03, 16, 16]} />
            <meshStandardMaterial color="#0f172a" emissive="#0f172a" emissiveIntensity={0.12} />
          </mesh>

          <mesh position={[0, 0.92, 0.26]} castShadow>
            <torusGeometry args={[0.08, 0.012, 12, 24, Math.PI]} />
            <meshStandardMaterial color="#7f1d1d" emissive="#ef4444" emissiveIntensity={0.16} />
          </mesh>

          <group ref={bookRef} position={[-0.4, 0.58, 0.12]}>
            <mesh castShadow>
              <boxGeometry args={[0.18, 0.05, 0.24]} />
              <meshStandardMaterial color="#f8fafc" roughness={0.4} />
            </mesh>
            <mesh position={[0, 0.005, 0]} castShadow>
              <boxGeometry args={[0.16, 0.014, 0.22]} />
              <meshStandardMaterial color="#b91c1c" roughness={0.3} />
            </mesh>
          </group>

          <mesh ref={orbRef} position={[0.38, 1.18, 0]} castShadow>
            <icosahedronGeometry args={[0.08, 1]} />
            <meshStandardMaterial color={aura} emissive={aura} emissiveIntensity={0.85} roughness={0.18} metalness={0.3} />
          </mesh>
        </group>
      </Float>
    </group>
  );
};

const LessonTutorNpcScene = ({ mode = 'idle', compact = false }) => {
  return (
    <div className={`lesson-assistant-scene ${compact ? 'compact' : ''}`}>
      <Canvas shadows dpr={[1, 1.5]} camera={{ position: [0, 1.15, 3.4], fov: 34 }}>
        <Suspense fallback={null}>
          <color attach="background" args={[compact ? '#7f1d1d' : '#591717']} />
          <fog attach="fog" args={[compact ? '#7f1d1d' : '#591717', 4.8, 10]} />
          <ambientLight intensity={1.18} />
          <directionalLight position={[3.8, 5.2, 2.4]} intensity={1.9} castShadow shadow-mapSize-width={1024} shadow-mapSize-height={1024} />
          <pointLight position={[-2.6, 2.4, 2.1]} intensity={1.2} color="#fca5a5" />
          <pointLight position={[2.1, 2.8, 1.4]} intensity={1.25} color="#f59e0b" />

          <mesh position={[0, 1.15, -0.82]}>
            <boxGeometry args={[1.9, 1.9, 0.12]} />
            <meshStandardMaterial color="#7f1d1d" roughness={0.82} metalness={0.06} />
          </mesh>

          <mesh position={[0, 1.15, -0.74]}>
            <torusGeometry args={[0.72, 0.06, 16, 48]} />
            <meshStandardMaterial color="#f59e0b" emissive="#f59e0b" emissiveIntensity={0.2} roughness={0.34} />
          </mesh>

          <mesh position={[0, 0.9, -0.68]}>
            <boxGeometry args={[0.62, 0.06, 0.08]} />
            <meshStandardMaterial color="#fef3c7" roughness={0.45} />
          </mesh>

          <mesh rotation={[-Math.PI / 2, 0, 0]} receiveShadow position={[0, -0.24, 0]}>
            <circleGeometry args={[1.6, 48]} />
            <meshStandardMaterial color="#4c1d1d" roughness={0.9} />
          </mesh>

          <mesh position={[0, -0.06, 0]} receiveShadow>
            <cylinderGeometry args={[0.86, 1.02, 0.2, 32]} />
            <meshStandardMaterial color="#b91c1c" roughness={0.62} metalness={0.14} />
          </mesh>

          <TutorNpcModel mode={mode} />
          <SceneSparkles count={compact ? 24 : 42} scale={[4, 3, 4]} size={compact ? 2.2 : 3.2} speed={0.35} color="#fde68a" opacity={0.82} />
          <ContactShadows position={[0, -0.22, 0]} opacity={0.4} blur={2.4} scale={4} far={4} />
        </Suspense>
      </Canvas>
    </div>
  );
};

export default LessonTutorNpcScene;