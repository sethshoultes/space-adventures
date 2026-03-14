// ── Game Types (match server snake_case JSON) ──────────────

export interface PlayerState {
  name: string;
  level: number;
  xp: number;
  xp_to_next: number;
  credits: number;
  skill_points: number;
  skills: Record<string, number>;
}

export interface ShipSystem {
  name: string;
  display_name: string;
  level: number;
  health: number;
  active: boolean;
  installed_part: string | null;
  power_cost: number;
}

export interface ShipState {
  name: string;
  classification: string;
  systems: Record<string, ShipSystem>;
  inventory: InventoryItem[];
  hull_hp: number;
  max_hull_hp: number;
  power_available: number;
  power_total: number;
}

export interface WorldState {
  phase: number;
  completed_missions: string[];
  active_mission_id: string | null;
  active_stage_id: string | null;
  discovered_locations: string[];
  discovered_parts: string[];
  major_choices: string[];
  active_effects: string[];
  factions: Record<string, number>;
  active_events: string[];
}

export interface GameState {
  session_id: string;
  player: PlayerState;
  ship: ShipState;
  world: WorldState;
  turn_count: number;
}

export interface InventoryItem {
  item_id: string;
  name: string;
  description: string;
  quantity: number;
  rarity: string;
  weight: number;
  system_type: string | null;
  level: number;
}

// ── Chat Types ──────────────────────────────────────────────

export type MessageType = 'narrative' | 'choice' | 'system' | 'memory' | 'event' | 'player' | 'error';

export interface ChatChoice {
  id: string;
  text: string;
  disabled?: boolean;
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

// ── WebSocket Message Types ─────────────────────────────────

export interface WSMessage {
  type: 'narrative' | 'state_update' | 'error' | 'stream_start' | 'stream_chunk' | 'stream_end' | 'pong';
  payload: Record<string, unknown>;
}

// ── API Response Types ──────────────────────────────────────

export interface NewGameResponse {
  session_id: string;
  message: string;
}

export interface MessageResponse {
  session_id: string;
  response: string;
  turn: number;
}

export interface SaveListResponse {
  saves: Array<{
    session_id: string;
    player_name: string;
    player_level: number;
    phase: number;
    turn_count: number;
    created_at: string;
    updated_at: string;
  }>;
}

// ── Ship system names constant ──────────────────────────────

export const SYSTEM_NAMES = [
  'hull', 'power', 'propulsion', 'warp', 'life_support',
  'computer', 'sensors', 'shields', 'weapons', 'communications',
] as const;

export type SystemName = typeof SYSTEM_NAMES[number];

// ── Default states ──────────────────────────────────────────

export const DEFAULT_PLAYER: PlayerState = {
  name: 'Captain',
  level: 1,
  xp: 0,
  xp_to_next: 100,
  credits: 0,
  skill_points: 0,
  skills: { engineering: 0, diplomacy: 0, combat: 0, science: 0 },
};

const makeSystem = (name: string): ShipSystem => ({
  name,
  display_name: name.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase()),
  level: 0,
  health: 100,
  active: false,
  installed_part: null,
  power_cost: 0,
});

export const DEFAULT_SHIP: ShipState = {
  name: 'Unnamed Vessel',
  classification: 'Hulk',
  systems: Object.fromEntries(SYSTEM_NAMES.map(n => [n, makeSystem(n)])),
  inventory: [],
  hull_hp: 0,
  max_hull_hp: 0,
  power_available: 0,
  power_total: 0,
};

export const DEFAULT_WORLD: WorldState = {
  phase: 1,
  completed_missions: [],
  active_mission_id: null,
  active_stage_id: null,
  discovered_locations: [],
  discovered_parts: [],
  major_choices: [],
  active_effects: [],
  factions: {},
  active_events: [],
};
