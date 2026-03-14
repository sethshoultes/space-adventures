import { create } from 'zustand';

type ActiveView = 'game' | 'loading' | 'menu';

interface UIStore {
  systemsPanelOpen: boolean;
  activeView: ActiveView;

  toggleSystemsPanel: () => void;
  setSystemsPanelOpen: (open: boolean) => void;
  setActiveView: (view: ActiveView) => void;
}

export const useUIStore = create<UIStore>((set) => ({
  systemsPanelOpen: false,
  activeView: 'game',

  toggleSystemsPanel: () =>
    set((s) => ({ systemsPanelOpen: !s.systemsPanelOpen })),

  setSystemsPanelOpen: (systemsPanelOpen) => set({ systemsPanelOpen }),

  setActiveView: (activeView) => set({ activeView }),
}));
