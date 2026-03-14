import { create } from 'zustand';
import type { PlayerState, ShipState, WorldState, InventoryItem, GameState } from '../types/game';
import { DEFAULT_PLAYER, DEFAULT_SHIP, DEFAULT_WORLD } from '../types/game';

interface GameStore {
  // State
  player: PlayerState;
  ship: ShipState;
  world: WorldState;
  inventory: InventoryItem[];
  connected: boolean;
  sessionId: string | null;

  // Actions
  updatePlayer: (partial: Partial<PlayerState>) => void;
  updateShip: (partial: Partial<ShipState>) => void;
  updateWorld: (partial: Partial<WorldState>) => void;
  setConnected: (connected: boolean) => void;
  setSessionId: (id: string) => void;
  addInventoryItem: (item: InventoryItem) => void;
  resetState: () => void;

  /** Apply full game state from server REST response. */
  setFromServer: (state: GameState) => void;

  /** Apply partial state update from WS state_update message. */
  applyServerState: (data: Record<string, unknown>) => void;
}

export const useGameStore = create<GameStore>((set) => ({
  player: { ...DEFAULT_PLAYER },
  ship: { ...DEFAULT_SHIP },
  world: { ...DEFAULT_WORLD },
  inventory: [],
  connected: false,
  sessionId: null,

  updatePlayer: (partial) =>
    set((s) => ({ player: { ...s.player, ...partial } })),

  updateShip: (partial) =>
    set((s) => ({ ship: { ...s.ship, ...partial } })),

  updateWorld: (partial) =>
    set((s) => ({ world: { ...s.world, ...partial } })),

  setConnected: (connected) => set({ connected }),
  setSessionId: (sessionId) => set({ sessionId }),

  addInventoryItem: (item) =>
    set((s) => {
      const existing = s.inventory.find((i) => i.item_id === item.item_id);
      if (existing) {
        return {
          inventory: s.inventory.map((i) =>
            i.item_id === item.item_id ? { ...i, quantity: i.quantity + item.quantity } : i
          ),
        };
      }
      return { inventory: [...s.inventory, item] };
    }),

  resetState: () =>
    set({
      player: { ...DEFAULT_PLAYER },
      ship: { ...DEFAULT_SHIP },
      world: { ...DEFAULT_WORLD },
      inventory: [],
      sessionId: null,
    }),

  setFromServer: (state) =>
    set({
      sessionId: state.session_id,
      player: state.player,
      ship: state.ship,
      world: state.world,
      inventory: state.ship?.inventory ?? [],
    }),

  applyServerState: (data) =>
    set((s) => {
      const updates: Partial<GameStore> = {};
      if (data.player) updates.player = { ...s.player, ...(data.player as Partial<PlayerState>) };
      if (data.ship) updates.ship = { ...s.ship, ...(data.ship as Partial<ShipState>) };
      if (data.world) updates.world = { ...s.world, ...(data.world as Partial<WorldState>) };
      // WS state_update sends flat fields for quick updates
      if (data.player_name !== undefined || data.player_level !== undefined || data.credits !== undefined) {
        const p = updates.player ?? { ...s.player };
        if (data.player_name !== undefined) p.name = data.player_name as string;
        if (data.player_level !== undefined) p.level = data.player_level as number;
        if (data.credits !== undefined) p.credits = data.credits as number;
        if (data.xp !== undefined) p.xp = data.xp as number;
        updates.player = p;
      }
      if (data.phase !== undefined) {
        const w = updates.world ?? { ...s.world };
        w.phase = data.phase as number;
        if (data.active_mission !== undefined) w.active_mission_id = data.active_mission as string | null;
        updates.world = w;
      }
      if (data.turn !== undefined) {
        // turn_count tracked implicitly
      }
      return updates;
    }),
}));
