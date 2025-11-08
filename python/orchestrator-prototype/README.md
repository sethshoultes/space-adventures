# AI Orchestrator Prototype

This prototype validates the OpenAI Agents Python + LiteLLM architecture for managing multiple AI agents across different providers.

## What This Validates

1. **Multi-Provider Support** - Ollama (local), Anthropic Claude, and OpenAI working together
2. **Agent Communication** - Each of the 4 AI personalities can process messages
3. **Function Calling** - ATLAS can call game functions to interact with ship systems
4. **Agent Handoffs** - Agents can pass context to each other
5. **Performance** - Response times are acceptable for game use

## Agents

- **ATLAS** (Ollama llama3.2:3b) - Ship's computer, operational tasks, can call functions
- **Storyteller** (Claude 3.5 Sonnet) - Narrative generation, mission content
- **Tactical** (OpenAI GPT-3.5-turbo) - Combat analysis and strategy
- **Companion** (Ollama llama3.2:3b) - Personal AI friend

## Setup

### 1. Install Dependencies

```bash
cd python/orchestrator-prototype
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Configure Environment

```bash
cp .env.example .env
```

Edit `.env` and configure:

**Required for Ollama (free, local):**
```bash
# Make sure Ollama is running
ollama serve

# Pull required models
ollama pull llama3.2:3b
```

**Optional for Claude (Storyteller):**
```bash
ANTHROPIC_API_KEY=sk-ant-your-key-here
```

**Optional for OpenAI (Tactical):**
```bash
OPENAI_API_KEY=sk-your-key-here
```

**Note:** The prototype will work with just Ollama. Claude and OpenAI are optional but recommended to test multi-provider functionality.

### 3. Run Prototype

```bash
python prototype.py
```

## What the Prototype Does

The prototype runs 3 tests:

### Test 1: Multi-Provider Communication
- Sends a test message to each of the 4 agents
- Validates each provider (Ollama, Claude, OpenAI) responds correctly
- Checks response quality and latency

### Test 2: Function Calling
- Tests ATLAS calling game functions:
  - `get_ship_status()` - Get current ship status
  - `get_power_budget()` - Get power availability
  - `upgrade_system(system_name)` - Upgrade a system
- Validates function results are returned correctly

### Test 3: Agent Handoff
- Simulates ATLAS handing off to TACTICAL
- Validates context is preserved during handoff
- Tests inter-agent communication pattern

## Expected Output

```
AI ORCHESTRATOR PROTOTYPE - Multi-Agent System
================================================================================

✅ OpenAI SDK imported successfully
✅ LiteLLM imported successfully

Configuration:
  ATLAS Provider: ollama
  Storyteller Provider: anthropic
  Tactical Provider: openai
  Companion Provider: ollama

================================================================================
TEST 1: Multi-Provider Communication
================================================================================

────────────────────────────────────────────────────────────────────────────────
Agent: ATLAS
Message: What is the current ship status?
────────────────────────────────────────────────────────────────────────────────
🤖 Calling ATLAS agent with model: ollama/llama3.2:3b
✅ Model: ollama/llama3.2:3b
Response: The current ship status is: All systems nominal...

[... additional test output ...]

================================================================================
PROTOTYPE VALIDATION COMPLETE
================================================================================

✅ Multi-provider support validated
✅ Agent communication validated
✅ Function calling capability demonstrated
✅ Agent handoff pattern demonstrated
```

## Architecture

```
┌─────────────────────────────────────────────────────┐
│              SimpleOrchestrator                     │
│  ┌───────────────────────────────────────────────┐ │
│  │         LiteLLM Completion API                │ │
│  └───────────────────────────────────────────────┘ │
│         │              │              │             │
│         ▼              ▼              ▼             │
│   ┌─────────┐   ┌──────────┐   ┌─────────┐       │
│   │ Ollama  │   │ Anthropic│   │ OpenAI  │       │
│   │  Local  │   │  Claude  │   │  GPT    │       │
│   └─────────┘   └──────────┘   └─────────┘       │
└─────────────────────────────────────────────────────┘
         │              │              │
         ▼              ▼              ▼
    ┌────────┐    ┌────────┐    ┌────────┐
    │ ATLAS  │    │STORY   │    │TACTICAL│
    │COMPAN. │    │TELLER  │    │        │
    └────────┘    └────────┘    └────────┘
```

## Files

- `prototype.py` - Main prototype script
- `requirements.txt` - Python dependencies
- `.env.example` - Environment configuration template
- `README.md` - This file

## Implementation Notes

### Why Not Use OpenAI Agents Python Directly?

The prototype uses LiteLLM directly instead of the full OpenAI Agents Python framework for simplicity. The official `openai-agents` package:

1. May not be available yet as a stable release
2. Has complex setup requirements
3. Is primarily designed for OpenAI models

LiteLLM provides the core multi-provider functionality we need without the complexity.

### Simplified Design

This prototype uses a simple `SimpleOrchestrator` class that:

- Manages conversation history per agent
- Routes requests to correct provider via LiteLLM
- Handles function calling for ATLAS
- Simulates agent handoffs

The production implementation will add:

- FastAPI endpoints
- Database persistence
- Intelligent routing
- Streaming responses
- Production error handling
- Caching
- Rate limiting

## Next Steps

After validating this prototype:

1. **Integrate into AI Service** - Add orchestrator to `python/ai-service/`
2. **Add FastAPI Endpoints** - Create `/api/chat/orchestrate` endpoint
3. **Implement Persistence** - Save conversation history to database
4. **Add Streaming** - Stream responses via Server-Sent Events
5. **Production Hardening** - Error handling, retries, fallbacks
6. **Update Godot Client** - Connect game to orchestrator endpoint

## Troubleshooting

### Ollama Not Running

```bash
# Start Ollama
ollama serve

# Pull models
ollama pull llama3.2:3b
```

### LiteLLM Import Error

```bash
pip install litellm
```

### API Key Errors

- Claude: Get key from https://console.anthropic.com/
- OpenAI: Get key from https://platform.openai.com/

### Model Not Found

Make sure models are pulled:

```bash
# Ollama models
ollama list
ollama pull llama3.2:3b

# Claude models (API-based, no download needed)
# OpenAI models (API-based, no download needed)
```

## Performance Expectations

- **Ollama (local):** 1-5 seconds depending on hardware
- **Claude API:** 1-3 seconds (network dependent)
- **OpenAI API:** 1-2 seconds (network dependent)

For game use, these latencies are acceptable since AI interactions are not real-time critical.

## License

Part of the Space Adventures project.
