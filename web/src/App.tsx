import { useEffect } from 'react';
import StatusHUD from './components/StatusHUD';
import ShipViewer from './components/ShipViewer';
import ChatPanel from './components/ChatPanel';
import InputBar from './components/InputBar';
import SystemsPanel from './components/SystemsPanel';
import { useChatStore } from './stores/chatStore';
import './styles/app.css';

export default function App() {
  // Welcome message on mount
  useEffect(() => {
    const chat = useChatStore.getState();
    chat.addNarrative(
      'The abandoned shipyard stretches before you, a graveyard of humanity\'s last great vessels. ' +
      'Somewhere among these ruins lies the parts you need to build a ship capable of reaching the stars.\n\n' +
      '*Your journey begins here, Captain.*',
      'ATLAS',
    );
    chat.addChoices([
      { id: 'explore_shipyard', text: 'Explore the shipyard' },
      { id: 'check_systems', text: 'Check ship systems' },
      { id: 'review_logs', text: 'Review mission logs' },
    ]);
  }, []);

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
