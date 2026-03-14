import { useGameStore } from '../stores/gameStore';
import { SYSTEM_NAMES } from '../types/game';

function systemColor(health: number, active: boolean): string {
  if (!active) return '#555';
  if (health > 70) return '#44ff44';
  if (health > 30) return '#ffaa00';
  return '#ff4444';
}

function formatSystemName(name: string): string {
  return name.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

export default function StatusHUD() {
  const player = useGameStore((s) => s.player);
  const ship = useGameStore((s) => s.ship);
  const world = useGameStore((s) => s.world);
  const connected = useGameStore((s) => s.connected);

  const xpPercent = player.xp_to_next > 0
    ? Math.round((player.xp / player.xp_to_next) * 100)
    : 0;

  return (
    <header className="status-hud">
      {/* Left: Ship & Connection */}
      <div className="status-hud__left">
        <span className="status-hud__ship-name">{ship.name}</span>
        <span className="status-hud__classification">{ship.classification}</span>
        <span
          className="status-hud__connection"
          title={connected ? 'Connected' : 'Disconnected'}
          style={{ color: connected ? '#44ff44' : '#ff4444' }}
        >
          ●
        </span>
      </div>

      {/* Center: System Status Dots */}
      <div className="status-hud__systems">
        {SYSTEM_NAMES.map((name) => {
          const sys = ship.systems[name];
          if (!sys) return null;
          return (
            <span
              key={name}
              className="status-hud__dot"
              title={`${formatSystemName(name)}: Lv${sys.level} ${sys.health}%`}
              style={{ backgroundColor: systemColor(sys.health, sys.active) }}
            />
          );
        })}
      </div>

      {/* Right: Player Stats */}
      <div className="status-hud__right">
        <span className="status-hud__location">📍 Phase {world.phase}</span>
        <span className="status-hud__credits">⚡ {player.credits} CR</span>
        <div className="status-hud__level">
          <span>★ Lv.{player.level}</span>
          <div className="status-hud__xp-bar">
            <div
              className="status-hud__xp-fill"
              style={{ width: `${xpPercent}%` }}
            />
          </div>
        </div>
      </div>
    </header>
  );
}
