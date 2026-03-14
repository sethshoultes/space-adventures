import { useGameStore } from '../stores/gameStore';
import { useChatStore } from '../stores/chatStore';
import type { GameState, WSMessage } from '../types/game';

const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:8000';
const WS_BASE = import.meta.env.VITE_WS_URL || 'ws://localhost:8000';

// ── REST Client ─────────────────────────────────────────────

async function apiFetch<T>(path: string, options?: RequestInit): Promise<T> {
  const sessionId = useGameStore.getState().sessionId;
  const res = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(sessionId ? { 'X-Session-ID': sessionId } : {}),
      ...options?.headers,
    },
  });
  if (!res.ok) {
    throw new Error(`API error ${res.status}: ${res.statusText}`);
  }
  return res.json();
}

export async function startNewGame(): Promise<GameState> {
  return apiFetch<GameState>('/api/game/new', { method: 'POST' });
}

export async function loadGame(slot: number): Promise<GameState> {
  return apiFetch<GameState>(`/api/game/load/${slot}`);
}

export async function saveGame(slot: number): Promise<void> {
  await apiFetch('/api/game/save', {
    method: 'POST',
    body: JSON.stringify({ slot }),
  });
}

export async function sendAction(action: string): Promise<void> {
  await apiFetch('/api/game/action', {
    method: 'POST',
    body: JSON.stringify({ action }),
  });
}

export async function sendChoice(choiceId: string): Promise<void> {
  await apiFetch('/api/game/choice', {
    method: 'POST',
    body: JSON.stringify({ choice_id: choiceId }),
  });
}

export async function getGameState(): Promise<GameState> {
  return apiFetch<GameState>('/api/game/state');
}

// ── WebSocket Client ────────────────────────────────────────

let ws: WebSocket | null = null;
let reconnectAttempt = 0;
const MAX_RECONNECT_DELAY = 30000;

function handleWSMessage(event: MessageEvent) {
  try {
    const msg: WSMessage = JSON.parse(event.data);
    const chat = useChatStore.getState();
    const game = useGameStore.getState();

    switch (msg.type) {
      case 'narrative':
        chat.addNarrative(
          msg.payload.content as string,
          msg.payload.sender as string | undefined,
        );
        break;

      case 'choices':
        chat.addChoices(msg.payload.choices as { id: string; text: string }[]);
        break;

      case 'state_update':
        game.updateState(msg.payload as Partial<GameState>);
        break;

      case 'system':
        chat.addSystem(msg.payload.content as string);
        break;

      case 'error':
        chat.addError(msg.payload.message as string);
        break;

      case 'stream_start': {
        chat.startStreaming();
        break;
      }

      case 'stream_chunk': {
        const streamId = chat.streamingMessageId;
        if (streamId) {
          chat.appendToStream(streamId, msg.payload.chunk as string);
        }
        break;
      }

      case 'stream_end': {
        const endId = chat.streamingMessageId;
        if (endId) {
          chat.endStreaming(endId);
        }
        break;
      }
    }
  } catch (err) {
    console.error('Failed to parse WS message:', err);
  }
}

export function connectWebSocket(sessionId: string) {
  if (ws?.readyState === WebSocket.OPEN) return;

  ws = new WebSocket(`${WS_BASE}/ws/game?session_id=${sessionId}`);

  ws.onopen = () => {
    console.log('[WS] Connected');
    useGameStore.getState().setConnected(true);
    reconnectAttempt = 0;
  };

  ws.onmessage = handleWSMessage;

  ws.onclose = () => {
    console.log('[WS] Disconnected');
    useGameStore.getState().setConnected(false);
    scheduleReconnect(sessionId);
  };

  ws.onerror = (err) => {
    console.error('[WS] Error:', err);
  };
}

function scheduleReconnect(sessionId: string) {
  const delay = Math.min(1000 * Math.pow(2, reconnectAttempt), MAX_RECONNECT_DELAY);
  reconnectAttempt++;
  console.log(`[WS] Reconnecting in ${delay}ms (attempt ${reconnectAttempt})`);
  setTimeout(() => connectWebSocket(sessionId), delay);
}

export function sendWSMessage(type: string, payload: Record<string, unknown>) {
  if (ws?.readyState !== WebSocket.OPEN) {
    console.warn('[WS] Not connected, cannot send message');
    return;
  }
  ws.send(JSON.stringify({ type, payload }));
}

export function disconnectWebSocket() {
  if (ws) {
    ws.close();
    ws = null;
  }
}
