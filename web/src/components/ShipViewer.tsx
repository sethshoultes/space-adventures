import { useRef, useMemo } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { OrbitControls, Stars } from '@react-three/drei';
import * as THREE from 'three';
import { useGameStore } from '../stores/gameStore';
import { SYSTEM_NAMES } from '../types/game';

// ── Ship Model (basic geometry) ─────────────────────────────

function ShipModel() {
  const groupRef = useRef<THREE.Group>(null);
  const ship = useGameStore((s) => s.ship);

  // Slow auto-rotation
  useFrame((_, delta) => {
    if (groupRef.current) {
      groupRef.current.rotation.y += delta * 0.1;
    }
  });

  return (
    <group ref={groupRef}>
      {/* Main hull — elongated cylinder */}
      <mesh position={[0, 0, 0]} rotation={[0, 0, Math.PI / 2]}>
        <cylinderGeometry args={[0.3, 0.4, 3, 16]} />
        <meshStandardMaterial color="#334455" metalness={0.7} roughness={0.3} />
      </mesh>

      {/* Saucer section */}
      <mesh position={[1.6, 0.1, 0]}>
        <cylinderGeometry args={[0.8, 0.8, 0.12, 32]} />
        <meshStandardMaterial color="#445566" metalness={0.6} roughness={0.4} />
      </mesh>

      {/* Bridge dome */}
      <mesh position={[1.6, 0.2, 0]}>
        <sphereGeometry args={[0.15, 16, 8, 0, Math.PI * 2, 0, Math.PI / 2]} />
        <meshStandardMaterial color="#88ccff" emissive="#00d4ff" emissiveIntensity={0.3} />
      </mesh>

      {/* Left nacelle */}
      <mesh position={[-0.5, -0.1, 0.8]} rotation={[0, 0, Math.PI / 2]}>
        <cylinderGeometry args={[0.12, 0.12, 1.8, 8]} />
        <meshStandardMaterial color="#556677" metalness={0.8} roughness={0.2} />
      </mesh>

      {/* Right nacelle */}
      <mesh position={[-0.5, -0.1, -0.8]} rotation={[0, 0, Math.PI / 2]}>
        <cylinderGeometry args={[0.12, 0.12, 1.8, 8]} />
        <meshStandardMaterial color="#556677" metalness={0.8} roughness={0.2} />
      </mesh>

      {/* Nacelle pylons */}
      <mesh position={[0, -0.1, 0.5]} rotation={[Math.PI / 6, 0, 0]}>
        <boxGeometry args={[0.08, 0.04, 0.7]} />
        <meshStandardMaterial color="#445566" metalness={0.6} roughness={0.4} />
      </mesh>
      <mesh position={[0, -0.1, -0.5]} rotation={[-Math.PI / 6, 0, 0]}>
        <boxGeometry args={[0.08, 0.04, 0.7]} />
        <meshStandardMaterial color="#445566" metalness={0.6} roughness={0.4} />
      </mesh>

      {/* Engine glow - left */}
      <mesh position={[-1.4, -0.1, 0.8]}>
        <sphereGeometry args={[0.13, 8, 8]} />
        <meshStandardMaterial
          color="#00d4ff"
          emissive="#00d4ff"
          emissiveIntensity={1.5}
          transparent
          opacity={0.8}
        />
      </mesh>

      {/* Engine glow - right */}
      <mesh position={[-1.4, -0.1, -0.8]}>
        <sphereGeometry args={[0.13, 8, 8]} />
        <meshStandardMaterial
          color="#00d4ff"
          emissive="#00d4ff"
          emissiveIntensity={1.5}
          transparent
          opacity={0.8}
        />
      </mesh>

      {/* Deflector dish */}
      <mesh position={[0.3, -0.3, 0]}>
        <sphereGeometry args={[0.18, 16, 8, 0, Math.PI * 2, 0, Math.PI / 2]} />
        <meshStandardMaterial
          color="#ffd700"
          emissive="#ffd700"
          emissiveIntensity={0.5}
          transparent
          opacity={0.9}
        />
      </mesh>

      {/* System status points */}
      <SystemPoints systems={ship.systems} />
    </group>
  );
}

// ── System status dots on the ship ──────────────────────────

const SYSTEM_POSITIONS: Record<string, [number, number, number]> = {
  hull: [0, 0.35, 0],
  power_core: [-0.5, 0, 0],
  propulsion: [-1.2, -0.1, 0],
  warp_drive: [-0.5, -0.1, 0.8],
  life_support: [1.2, 0.15, 0],
  computer_core: [1.6, 0.3, 0],
  sensors: [1.6, 0.1, 0.6],
  shields: [0.5, 0.2, 0],
  weapons: [0.8, -0.2, 0],
  communications: [1.6, 0.1, -0.6],
};

function SystemPoints({ systems }: { systems: Record<string, { health: number; active: boolean; level: number }> }) {
  const points = useMemo(() => {
    return SYSTEM_NAMES.map((name) => {
      const sys = systems[name];
      if (!sys) return null;
      const pos = SYSTEM_POSITIONS[name] || [0, 0, 0];
      let color = '#555555';
      if (sys.active) {
        color = sys.health > 70 ? '#44ff44' : sys.health > 30 ? '#ffaa00' : '#ff4444';
      }
      return { name, pos, color, level: sys.level };
    }).filter(Boolean);
  }, [systems]);

  return (
    <>
      {points.map((p) => p && (
        <mesh key={p.name} position={p.pos as [number, number, number]}>
          <sphereGeometry args={[0.04, 8, 8]} />
          <meshStandardMaterial
            color={p.color}
            emissive={p.color}
            emissiveIntensity={p.level > 0 ? 1.0 : 0.2}
            transparent
            opacity={0.9}
          />
        </mesh>
      ))}
    </>
  );
}

// ── Main Scene ──────────────────────────────────────────────

export default function ShipViewer() {
  return (
    <div className="ship-viewer">
      <Canvas
        camera={{ position: [3, 2, 3], fov: 45 }}
        gl={{ antialias: true, alpha: true }}
      >
        {/* Lighting */}
        <ambientLight intensity={0.3} />
        <directionalLight position={[5, 5, 5]} intensity={0.8} color="#ffffff" />
        <pointLight position={[-3, 2, -3]} intensity={0.4} color="#00d4ff" />
        <pointLight position={[3, -1, 2]} intensity={0.3} color="#ffd700" />

        {/* Starfield */}
        <Stars radius={100} depth={50} count={3000} factor={4} saturation={0} fade speed={1} />

        {/* Ship */}
        <ShipModel />

        {/* Controls — subtle auto-rotate */}
        <OrbitControls
          enablePan={false}
          enableZoom={true}
          minDistance={2}
          maxDistance={8}
          autoRotate
          autoRotateSpeed={0.3}
        />
      </Canvas>
    </div>
  );
}
