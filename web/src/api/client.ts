/**
 * API Client — REST + WebSocket communication with the game server.
 *
 * REST endpoints match server/src/api/game.py routes.
 * WebSocket matches server/src/api/ws.py protocol.
 */

import { useGameStore } from '../stores/gameStore';
import { useChatStore } from '../stores/chatStore';
import type {
  GameState,
  NewGameResponse,
  MessageResponse,
  SaveListResponse,
  WSMessage,
} from '../types/game';

const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:8000';
const WS_BASE = import.meta.env.VITE_WS_URL || 'ws://localhost:8000';

// ── REST Client ─────────────────────────────────────────────

async function apiFetch<T>(path: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
  });
  if (!res.ok) {
    const body = await res.text().catch(() => '');
    throw new Error(`API ${res.status}: ${body || res.statusText}`);
  }
  return res.json();
}

/** Start a new game. Returns session_id and opening narrative. */
export async function startNewGame(playerName = 'Captain'): Promise<NewGameResponse> {
  return apiFetch<NewGameResponse>('/api/game/new', {
    method: 'POST',
    body: JSON.stringify({ player_name: playerName }),
  });
}

/** Get current game state for a session. */
export async function getGameState(sessionId: string): Promise<GameState> {
  return apiFetch<GameState>(`/api/game/state/${sessionId}`);
}

/** Send a player message to the Game Master (non-streaming). */
export async function sendMessage(sessionId: string, message: string): Promise<MessageResponse> {
  return apiFetch<MessageResponse>(`/api/game/message/${sessionId}`, {
    method: 'POST',
    body: JSON.stringify({ message }),
  });
}

/** Send a player message and get a streaming text response. */
export async function sendMessageStream(
  sessionId: string,
  message: string,
  onChunk: (chunk: string) => void,
): Promise<void> {
  const res = await fetch(`${API_BASE}/api/game/message/${sessionId}/stream`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ message }),
  });
  if (!res.ok || !res.body) {
    throw new Error(`Stream error ${res.status}`);
  }
  const reader = res.body.getReader();
  const decoder = new TextDecoder();
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    onChunk(decoder.decode(value, { stream: true }));
  }
}

/** Save current game state. */
export async function saveGame(sessionId: string): Promise<void> {
  await apiFetch(`/api/game/save/${sessionId}`, { method: 'POST' });
}

/** List all saved games. */
export async function listSaves(): Promise<SaveListResponse> {
  return apiFetch<SaveListResponse>('/api/game/saves');
}

/** Load a saved game. */
export async function loadGame(sessionId: string): Promise<GameState> {
  // Load returns summary; fetch full state
  await apiFetch(`/api/game/load/${sessionId}`, { method: 'POST' });
  return getGameState(sessionId);
}

/** Delete a saved game. */
export async function deleteSave(sessionId: string): Promise<void> {
  await apiFetch(`/api/game/save/${sessionId}`, { method: 'DELETE' });
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
        chat.addNarrative(msg.payload.content as string, msg.payload.sender as string | undefined);
        break;

      case 'state_update':
        game.applyServerState(msg.payload as Record<string, unknown>);
        break;

      case 'stream_start':
        chat.startStreaming();
        break;

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

      case 'error':
        chat.addError(msg.payload.content as string);
        break;

      case 'pong':
        break;
    }
  } catch (err) {
    console.error('[WS] Failed to parse message:', err);
  }
}

/**
 * Connect WebSocket to game session.
 * Server route: /ws/{session_id}
 */
export function connectWebSocket(sessionId: string) {
  if (ws?.readyState === WebSocket.OPEN) return;

  ws = new WebSocket(`${WS_BASE}/ws/${sessionId}`);

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

/**
 * Send a message via WebSocket.
 * Server expects: {"type": "message", "content": "..."}
 */
export function sendWSMessage(content: string) {
  if (ws?.readyState !== WebSocket.OPEN) {
    console.warn('[WS] Not connected');
    return;
  }
  ws.send(JSON.stringify({ type: 'message', content }));
}

export function sendWSPing() {
  if (ws?.readyState !== WebSocket.OPEN) return;
  ws.send(JSON.stringify({ type: 'ping' }));
}

export function disconnectWebSocket() {
  reconnectAttempt = Infinity; // Prevent reconnect
  if (ws) {
    ws.close();
    ws = null;
  }
}
