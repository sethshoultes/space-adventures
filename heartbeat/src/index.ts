// ── Space Adventures Heartbeat Agent ────────────────────────
// Cloudflare Worker that runs every 15 minutes via cron trigger.
// Fetches game world state, calls Workers AI to generate events,
// and posts them to the game server's event queue.

export interface Env {
  AI: Ai;
  GAME_SERVER_URL: string;
}

// ── Event Types ─────────────────────────────────────────────

interface WorldEvent {
  type: 'world_event';
  description: string;
  location: string;
  severity: 'low' | 'medium' | 'high';
}

interface SideQuest {
  type: 'side_quest';
  title: string;
  hook: string;
  difficulty: number;
  reward_hint: string;
}

interface FactionShift {
  type: 'faction_shift';
  faction: string;
  direction: 'up' | 'down';
  reason: string;
}

interface ShipAlert {
  type: 'ship_alert';
  system: string;
  issue: string;
  severity: 'low' | 'medium' | 'high';
}

type GameEvent = WorldEvent | SideQuest | FactionShift | ShipAlert;

// ── World State (from game server) ──────────────────────────

interface WorldState {
  phase: number;
  location: string;
  ship_systems: Record<string, { level: number; health: number }>;
  player_level: number;
  completed_missions: string[];
}

// ── AI Prompt ───────────────────────────────────────────────

function buildPrompt(state: WorldState): string {
  const systemsSummary = Object.entries(state.ship_systems || {})
    .map(([name, s]) => `${name}:L${s.level},${s.health}%`)
    .join(', ');

  // Keep prompt under 200 tokens to stay within free tier
  return `You are a game event generator for a sci-fi space game.

World: phase=${state.phase}, location="${state.location}", player_level=${state.player_level}, missions_done=${(state.completed_missions || []).length}
Ship: ${systemsSummary || 'none'}

Generate 0-2 brief events as JSON array. Each event must have one of these exact shapes:
- {"type":"world_event","description":"...","location":"...","severity":"low|medium|high"}
- {"type":"side_quest","title":"...","hook":"...","difficulty":1-5,"reward_hint":"..."}
- {"type":"faction_shift","faction":"...","direction":"up|down","reason":"..."}
- {"type":"ship_alert","system":"...","issue":"...","severity":"low|medium|high"}

Return ONLY a JSON array. No text outside the array. If nothing interesting, return [].`;
}

// ── Event Parsing ───────────────────────────────────────────

const VALID_TYPES = new Set(['world_event', 'side_quest', 'faction_shift', 'ship_alert']);
const VALID_SEVERITIES = new Set(['low', 'medium', 'high']);

function parseEvents(raw: string): GameEvent[] {
  // Extract JSON array from response (handle markdown fences)
  const match = raw.match(/\[[\s\S]*\]/);
  if (!match) return [];

  let parsed: unknown[];
  try {
    parsed = JSON.parse(match[0]);
  } catch {
    console.error('Failed to parse AI response as JSON:', raw);
    return [];
  }

  if (!Array.isArray(parsed)) return [];

  // Validate and filter to max 2 events
  return parsed
    .filter((e): e is GameEvent => {
      if (!e || typeof e !== 'object') return false;
      const obj = e as Record<string, unknown>;
      if (!VALID_TYPES.has(obj.type as string)) return false;

      switch (obj.type) {
        case 'world_event':
          return (
            typeof obj.description === 'string' &&
            typeof obj.location === 'string' &&
            VALID_SEVERITIES.has(obj.severity as string)
          );
        case 'side_quest':
          return (
            typeof obj.title === 'string' &&
            typeof obj.hook === 'string' &&
            typeof obj.difficulty === 'number' &&
            obj.difficulty >= 1 && obj.difficulty <= 5 &&
            typeof obj.reward_hint === 'string'
          );
        case 'faction_shift':
          return (
            typeof obj.faction === 'string' &&
            (obj.direction === 'up' || obj.direction === 'down') &&
            typeof obj.reason === 'string'
          );
        case 'ship_alert':
          return (
            typeof obj.system === 'string' &&
            typeof obj.issue === 'string' &&
            VALID_SEVERITIES.has(obj.severity as string)
          );
        default:
          return false;
      }
    })
    .slice(0, 2);
}

// ── Scheduled Handler ───────────────────────────────────────

async function handleScheduled(env: Env): Promise<void> {
  const serverUrl = env.GAME_SERVER_URL;
  console.log(`[heartbeat] Running at ${new Date().toISOString()}`);

  // 1. Fetch world state from game server
  let worldState: WorldState;
  try {
    const res = await fetch(`${serverUrl}/api/game/world-state`);
    if (!res.ok) {
      console.log(`[heartbeat] No active game state (${res.status}), skipping`);
      return;
    }
    worldState = await res.json() as WorldState;
  } catch (err) {
    console.error('[heartbeat] Failed to fetch world state:', err);
    return;
  }

  // 2. Call Workers AI
  const prompt = buildPrompt(worldState);
  let aiResponse: string;
  try {
    const result = await env.AI.run('@cf/meta/llama-3.1-8b-instruct-fp8', {
      messages: [{ role: 'user', content: prompt }],
      max_tokens: 250,
      temperature: 0.7,
    }) as { response?: string };

    aiResponse = result.response || '[]';
    console.log(`[heartbeat] AI response: ${aiResponse.substring(0, 200)}`);
  } catch (err) {
    console.error('[heartbeat] AI call failed:', err);
    return;
  }

  // 3. Parse events
  const events = parseEvents(aiResponse);
  if (events.length === 0) {
    console.log('[heartbeat] No events generated, done');
    return;
  }

  console.log(`[heartbeat] Generated ${events.length} event(s)`);

  // 4. Post events to game server
  try {
    const res = await fetch(`${serverUrl}/api/game/events`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ events, source: 'heartbeat', timestamp: Date.now() }),
    });

    if (!res.ok) {
      console.error(`[heartbeat] Failed to post events: ${res.status}`);
      return;
    }

    console.log(`[heartbeat] Posted ${events.length} event(s) successfully`);
  } catch (err) {
    console.error('[heartbeat] Failed to post events:', err);
  }
}

// ── Worker Export ────────────────────────────────────────────

export default {
  // Cron trigger handler
  async scheduled(
    _controller: ScheduledController,
    env: Env,
    _ctx: ExecutionContext,
  ): Promise<void> {
    await handleScheduled(env);
  },

  // HTTP handler for manual trigger / health check
  async fetch(request: Request, env: Env, _ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === '/health') {
      return new Response(JSON.stringify({ status: 'ok', worker: 'space-adventures-heartbeat' }), {
        headers: { 'Content-Type': 'application/json' },
      });
    }

    if (url.pathname === '/trigger' && request.method === 'POST') {
      await handleScheduled(env);
      return new Response(JSON.stringify({ triggered: true }), {
        headers: { 'Content-Type': 'application/json' },
      });
    }

    return new Response('Space Adventures Heartbeat Agent\n\nGET /health - health check\nPOST /trigger - manual trigger', {
      status: 200,
    });
  },
} satisfies ExportedHandler<Env>;
