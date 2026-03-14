import { useEffect, useState, useCallback } from 'react';
import StatusHUD from './components/StatusHUD';
import ShipViewer from './components/ShipViewer';
import ChatPanel from './components/ChatPanel';
import InputBar from './components/InputBar';
import SystemsPanel from './components/SystemsPanel';
import { useGameStore } from './stores/gameStore';
import { useChatStore } from './stores/chatStore';
import { startNewGame, getGameState, connectWebSocket, disconnectWebSocket } from './api/client';
import './styles/app.css';

export default function App() {
  const sessionId = useGameStore((s) => s.sessionId);
  const [loading, setLoading] = useState(false);

  const handleNewGame = useCallback(async () => {
    setLoading(true);
    try {
      // Create game on server
      const { session_id, message } = await startNewGame('Captain');
      useGameStore.getState().setSessionId(session_id);

      // Fetch full state
      const state = await getGameState(session_id);
      useGameStore.getState().setFromServer(state);

      // Show opening narrative
      useChatStore.getState().addNarrative(message, 'GM');

      // Connect WebSocket for real-time interaction
      connectWebSocket(session_id);
    } catch (err) {
      useChatStore.getState().addError(
        `Failed to start game: ${err instanceof Error ? err.message : String(err)}`
      );
    } finally {
      setLoading(false);
    }
  }, []);

  // Cleanup WS on unmount
  useEffect(() => {
    return () => disconnectWebSocket();
  }, []);

  // If no session, show start screen
  if (!sessionId) {
    return (
      <div className="app">
        <div className="app__start-screen">
          <h1 className="app__title">Space Adventures</h1>
          <p className="app__subtitle">A sci-fi adventure powered by AI</p>
          <button
            className="app__start-btn"
            onClick={handleNewGame}
            disabled={loading}
          >
            {loading ? 'Launching...' : 'New Game'}
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="app">
      <StatusHUD />

      <main className="app__main">
        <div className="app__scene">
          <ShipViewer />
          <SystemsPanel />
        </div>
        <div className="app__chat">
          <ChatPanel />
        </div>
      </main>

      <InputBar />
    </div>
  );
}
