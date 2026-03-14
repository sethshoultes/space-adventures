import { useEffect, useRef } from 'react';
import ReactMarkdown from 'react-markdown';
import { useChatStore } from '../stores/chatStore';
import { sendWSMessage, sendMessage } from '../api/client';
import { useGameStore } from '../stores/gameStore';
import type { ChatMessage } from '../types/game';

function MessageBubble({ message }: { message: ChatMessage }) {
  switch (message.type) {
    case 'narrative':
      return (
        <div className="chat-msg chat-msg--narrative">
          {message.sender && (
            <span className="chat-msg__sender">[{message.sender}]</span>
          )}
          <div className="chat-msg__body">
            <ReactMarkdown>{message.content}</ReactMarkdown>
            {message.isStreaming && <span className="chat-msg__cursor">▌</span>}
          </div>
        </div>
      );

    case 'choice':
      return (
        <div className="chat-msg chat-msg--choices">
          {message.choices?.map((choice) => (
            <ChoiceButton key={choice.id} choice={choice} />
          ))}
        </div>
      );

    case 'player':
      return (
        <div className="chat-msg chat-msg--player">
          <span className="chat-msg__sender">{message.sender}</span>
          <span className="chat-msg__body">{message.content}</span>
        </div>
      );

    case 'system':
      return (
        <div className="chat-msg chat-msg--system">
          <span className="chat-msg__body">{message.content}</span>
        </div>
      );

    case 'memory':
      return (
        <div className="chat-msg chat-msg--memory">
          <span className="chat-msg__label">Captain's Log</span>
          <span className="chat-msg__body">{message.content}</span>
        </div>
      );

    case 'event':
      return (
        <div className="chat-msg chat-msg--event">
          <span className="chat-msg__body">{message.content}</span>
        </div>
      );

    case 'error':
      return (
        <div className="chat-msg chat-msg--error">
          <span className="chat-msg__body">{message.content}</span>
        </div>
      );

    default:
      return null;
  }
}

function ChoiceButton({ choice }: { choice: { id: string; text: string; disabled?: boolean } }) {
  const connected = useGameStore((s) => s.connected);
  const sessionId = useGameStore((s) => s.sessionId);
  const isStreaming = useChatStore((s) => s.isStreaming);

  const handleClick = () => {
    if (choice.disabled || isStreaming) return;
    useChatStore.getState().addPlayerMessage(choice.text);
    // Send choice text as a message — the Game Master handles it narratively
    if (connected) {
      sendWSMessage(choice.text);
    } else if (sessionId) {
      sendMessage(sessionId, choice.text).then((res) => {
        useChatStore.getState().addNarrative(res.response, 'GM');
      }).catch((err) => {
        useChatStore.getState().addError(`Choice failed: ${err.message}`);
      });
    }
  };

  return (
    <button
      className="chat-choice-btn"
      onClick={handleClick}
      disabled={choice.disabled || isStreaming}
    >
      ▸ {choice.text}
    </button>
  );
}

export default function ChatPanel() {
  const messages = useChatStore((s) => s.messages);
  const scrollRef = useRef<HTMLDivElement>(null);

  // Auto-scroll on new messages
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  return (
    <div className="chat-panel">
      <div className="chat-panel__header">
        <span>Ship's Log</span>
      </div>
      <div className="chat-panel__messages" ref={scrollRef}>
        {messages.length === 0 && (
          <div className="chat-panel__empty">
            <p>Awaiting orders, Captain...</p>
          </div>
        )}
        {messages.map((msg) => (
          <MessageBubble key={msg.id} message={msg} />
        ))}
      </div>
    </div>
  );
}
