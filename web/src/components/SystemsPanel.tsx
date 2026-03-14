import { useGameStore } from '../stores/gameStore';
import { useUIStore } from '../stores/uiStore';
import { SYSTEM_NAMES } from '../types/game';

function formatSystemName(name: string): string {
  return name.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

function healthColor(health: number): string {
  if (health > 70) return '#44ff44';
  if (health > 30) return '#ffaa00';
  return '#ff4444';
}

function levelBar(level: number, maxLevel: number): string {
  const filled = '█'.repeat(level);
  const empty = '░'.repeat(maxLevel - level);
  return filled + empty;
}

export default function SystemsPanel() {
  const isOpen = useUIStore((s) => s.systemsPanelOpen);
  const toggle = useUIStore((s) => s.toggleSystemsPanel);
  const ship = useGameStore((s) => s.ship);

  return (
    <>
      {/* Toggle button */}
      <button
        className="systems-toggle"
        onClick={toggle}
        title="Toggle Systems Panel"
      >
        {isOpen ? '◂' : '▸'} SYS
      </button>

      {/* Panel */}
      <div className={`systems-panel ${isOpen ? 'systems-panel--open' : ''}`}>
        <div className="systems-panel__header">
          <h3>Ship Systems</h3>
          <span className="systems-panel__power">
            ⚡ {ship.powerAvailable}/{ship.powerTotal} PWR
          </span>
        </div>
        <div className="systems-panel__list">
          {SYSTEM_NAMES.map((name) => {
            const sys = ship.systems[name];
            if (!sys) return null;
            return (
              <div key={name} className="systems-panel__item">
                <div className="systems-panel__item-header">
                  <span className="systems-panel__item-name">
                    {formatSystemName(name)}
                  </span>
                  <span
                    className="systems-panel__item-status"
                    style={{ color: sys.active ? '#44ff44' : '#666' }}
                  >
                    {sys.active ? 'ONLINE' : 'OFFLINE'}
                  </span>
                </div>
                <div className="systems-panel__item-details">
                  <span className="systems-panel__item-level" title={`Level ${sys.level}/${sys.maxLevel}`}>
                    {levelBar(sys.level, sys.maxLevel)}
                  </span>
                  <span
                    className="systems-panel__item-health"
                    style={{ color: healthColor(sys.health) }}
                  >
                    {sys.health}%
                  </span>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </>
  );
}
