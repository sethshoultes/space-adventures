// ── Game Types ──────────────────────────────────────────────

export interface PlayerState {
  name: string;
  level: number;
  xp: number;
  xpToNext: number;
  credits: number;
  skills: Record<string, number>;
}

export interface ShipSystem {
  name: string;
  level: number;
  maxLevel: number;
  health: number;
  maxHealth: number;
  active: boolean;
  powerCost: number;
}

export interface ShipState {
  name: string;
  classification: string;
  systems: Record<string, ShipSystem>;
  hullHp: number;
  maxHullHp: number;
  powerAvailable: number;
  powerTotal: number;
}

export interface WorldState {
  phase: number;
  currentLocation: string;
  activeMission: string | null;
  completedMissions: string[];
  discoveredLocations: string[];
}

export interface GameState {
  player: PlayerState;
  ship: ShipState;
  world: WorldState;
  inventory: InventoryItem[];
}

export interface InventoryItem {
  id: string;
  name: string;
  type: string;
  rarity: 'common' | 'uncommon' | 'rare' | 'legendary';
  quantity: number;
  description: string;
}

// ── Chat Types ──────────────────────────────────────────────

export type MessageType = 'narrative' | 'choice' | 'system' | 'memory' | 'event' | 'player' | 'error';

export interface ChatChoice {
  id: string;
  text: string;
  disabled?: boolean;
  requiresLevel?: number;
}

export interface ChatMessage {
  id: string;
  type: MessageType;
  content: string;
  sender?: string;
  choices?: ChatChoice[];
  timestamp: number;
  isStreaming?: boolean;
}

// ── API Types ───────────────────────────────────────────────

export interface WSMessage {
  type: 'narrative' | 'choices' | 'state_update' | 'system' | 'error' | 'stream_start' | 'stream_chunk' | 'stream_end';
  payload: Record<string, unknown>;
}

export interface APIResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: string;
}

// ── Ship system names constant ──────────────────────────────

export const SYSTEM_NAMES = [
  'hull', 'power_core', 'propulsion', 'warp_drive', 'life_support',
  'computer_core', 'sensors', 'shields', 'weapons', 'communications',
] as const;

export type SystemName = typeof SYSTEM_NAMES[number];

// ── Default states ──────────────────────────────────────────

export const DEFAULT_PLAYER: PlayerState = {
  name: 'Captain',
  level: 1,
  xp: 0,
  xpToNext: 200,
  credits: 100,
  skills: { engineering: 0, diplomacy: 0, combat: 0, science: 0 },
};

const makeSystem = (name: string): ShipSystem => ({
  name,
  level: 0,
  maxLevel: 5,
  health: 100,
  maxHealth: 100,
  active: false,
  powerCost: 0,
});

export const DEFAULT_SHIP: ShipState = {
  name: 'Unnamed Vessel',
  classification: 'Unclassified',
  systems: Object.fromEntries(SYSTEM_NAMES.map(n => [n, makeSystem(n)])),
  hullHp: 0,
  maxHullHp: 100,
  powerAvailable: 0,
  powerTotal: 0,
};

export const DEFAULT_WORLD: WorldState = {
  phase: 1,
  currentLocation: 'Abandoned Shipyard',
  activeMission: null,
  completedMissions: [],
  discoveredLocations: ['Abandoned Shipyard'],
};
