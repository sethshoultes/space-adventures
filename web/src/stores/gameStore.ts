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
  updateState: (state: Partial<GameState>) => void;
  setConnected: (connected: boolean) => void;
  setSessionId: (id: string) => void;
  addInventoryItem: (item: InventoryItem) => void;
  resetState: () => void;
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

  updateState: (state) =>
    set((s) => ({
      ...(state.player ? { player: { ...s.player, ...state.player } } : {}),
      ...(state.ship ? { ship: { ...s.ship, ...state.ship } } : {}),
      ...(state.world ? { world: { ...s.world, ...state.world } } : {}),
      ...(state.inventory ? { inventory: state.inventory } : {}),
    })),

  setConnected: (connected) => set({ connected }),
  setSessionId: (sessionId) => set({ sessionId }),

  addInventoryItem: (item) =>
    set((s) => {
      const existing = s.inventory.find((i) => i.id === item.id);
      if (existing) {
        return {
          inventory: s.inventory.map((i) =>
            i.id === item.id ? { ...i, quantity: i.quantity + item.quantity } : i
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
}));
