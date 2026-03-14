import { useState, useCallback, type KeyboardEvent } from 'react';
import { useChatStore } from '../stores/chatStore';
import { sendWSMessage, sendMessage } from '../api/client';
import { useGameStore } from '../stores/gameStore';

const COMMANDS: Record<string, string> = {
  '/help': 'Show available commands',
  '/save': 'Save your game',
  '/status': 'Show ship status',
  '/systems': 'Toggle systems panel',
};

export default function InputBar() {
  const [input, setInput] = useState('');
  const isStreaming = useChatStore((s) => s.isStreaming);
  const connected = useGameStore((s) => s.connected);
  const sessionId = useGameStore((s) => s.sessionId);
  const addPlayerMessage = useChatStore((s) => s.addPlayerMessage);
  const addSystem = useChatStore((s) => s.addSystem);

  const handleSubmit = useCallback(() => {
    const text = input.trim();
    if (!text) return;

    // Handle slash commands locally
    if (text.startsWith('/')) {
      const cmd = text.toLowerCase().split(' ')[0];
      if (cmd === '/help') {
        addSystem(
          'Available commands:\n' +
            Object.entries(COMMANDS)
              .map(([k, v]) => `  ${k} — ${v}`)
              .join('\n')
        );
        setInput('');
        return;
      }
    }

    addPlayerMessage(text);

    // Send via WebSocket if connected, otherwise REST fallback
    if (connected) {
      sendWSMessage(text);
    } else if (sessionId) {
      sendMessage(sessionId, text).then((res) => {
        useChatStore.getState().addNarrative(res.response, 'GM');
      }).catch((err) => {
        useChatStore.getState().addError(`Failed to send: ${err.message}`);
      });
    } else {
      useChatStore.getState().addError('No active session. Start a new game first.');
    }

    setInput('');
  }, [input, connected, sessionId, addPlayerMessage, addSystem]);

  const handleKeyDown = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSubmit();
    }
  };

  return (
    <footer className="input-bar">
      <div className="input-bar__container">
        <span className="input-bar__prompt">▸</span>
        <input
          type="text"
          className="input-bar__input"
          placeholder="What would you like to do?"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={handleKeyDown}
          disabled={isStreaming}
          autoFocus
        />
        <button
          className="input-bar__send"
          onClick={handleSubmit}
          disabled={isStreaming || !input.trim()}
          title="Send (Enter)"
        >
          ⏎
        </button>
      </div>
    </footer>
  );
}
