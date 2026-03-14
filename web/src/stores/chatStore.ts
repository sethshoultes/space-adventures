import { create } from 'zustand';
import type { ChatMessage, ChatChoice } from '../types/game';

interface ChatStore {
  messages: ChatMessage[];
  isStreaming: boolean;
  streamingMessageId: string | null;

  addMessage: (msg: Omit<ChatMessage, 'id' | 'timestamp'>) => void;
  addNarrative: (content: string, sender?: string) => void;
  addChoices: (choices: ChatChoice[]) => void;
  addSystem: (content: string) => void;
  addPlayerMessage: (content: string) => void;
  addError: (content: string) => void;

  startStreaming: () => string;
  appendToStream: (messageId: string, chunk: string) => void;
  endStreaming: (messageId: string) => void;
  setStreaming: (streaming: boolean) => void;

  clearMessages: () => void;
}

let nextId = 1;
const genId = () => `msg_${nextId++}`;

export const useChatStore = create<ChatStore>((set, get) => ({
  messages: [],
  isStreaming: false,
  streamingMessageId: null,

  addMessage: (msg) => {
    const message: ChatMessage = {
      ...msg,
      id: genId(),
      timestamp: Date.now(),
    };
    set((s) => ({ messages: [...s.messages, message] }));
  },

  addNarrative: (content, sender) => {
    get().addMessage({ type: 'narrative', content, sender });
  },

  addChoices: (choices) => {
    get().addMessage({ type: 'choice', content: '', choices });
  },

  addSystem: (content) => {
    get().addMessage({ type: 'system', content });
  },

  addPlayerMessage: (content) => {
    get().addMessage({ type: 'player', content, sender: 'You' });
  },

  addError: (content) => {
    get().addMessage({ type: 'error', content });
  },

  startStreaming: () => {
    const id = genId();
    const message: ChatMessage = {
      id,
      type: 'narrative',
      content: '',
      sender: 'GM',
      timestamp: Date.now(),
      isStreaming: true,
    };
    set((s) => ({
      messages: [...s.messages, message],
      isStreaming: true,
      streamingMessageId: id,
    }));
    return id;
  },

  appendToStream: (messageId, chunk) => {
    set((s) => ({
      messages: s.messages.map((m) =>
        m.id === messageId ? { ...m, content: m.content + chunk } : m
      ),
    }));
  },

  endStreaming: (messageId) => {
    set((s) => ({
      messages: s.messages.map((m) =>
        m.id === messageId ? { ...m, isStreaming: false } : m
      ),
      isStreaming: false,
      streamingMessageId: null,
    }));
  },

  setStreaming: (isStreaming) => set({ isStreaming }),

  clearMessages: () => set({ messages: [], isStreaming: false, streamingMessageId: null }),
}));
