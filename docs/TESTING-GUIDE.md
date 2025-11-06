# Space Adventures - Testing Guide

**Version:** Phase 1, Week 3
**Date:** 2025-11-06
**Status:** Godot Foundation Complete - Ready for Testing

## Overview

This guide provides step-by-step instructions for testing the Space Adventures game client and backend services. The current build includes all core autoload singletons and a test scene for verification.

## Prerequisites

### Required Software

- **Godot Engine:** 4.2 or higher (tested with 4.5.1)
- **Docker Desktop:** Latest version
- **Git:** For version control
- **Terminal/Command Line:** For running commands

### Optional (for AI features)

- **Ollama:** For local AI (free, no API key) - https://ollama.ai
- **API Keys:** Anthropic Claude or OpenAI (if not using Ollama)

## Setup Instructions

### 1. Start Backend Services

```bash
# Navigate to project directory
cd /path/to/space-adventures

# Start Docker services
docker compose up -d

# Verify services are running
docker compose ps

# Expected output:
# NAME                      STATUS
# space-adventures-gateway  Up (healthy)
# space-adventures-ai       Up (healthy)
# space-adventures-redis    Up (healthy)
```

### 2. Verify Service Health

```bash
# Test Gateway (should return JSON with "status": "healthy")
curl http://localhost:17010/health

# Test AI Service
curl http://localhost:17011/health

# Test aggregate health
curl http://localhost:17010/health/all
```

**Expected Response:**
```json
{
  "status": "degraded",
  "services": {
    "gateway": {"status": "healthy"},
    "ai-service": {"status": "healthy"},
    "whisper-service": {"status": "unreachable"}
  }
}
```

Note: Whisper service is optional and only runs with `--profile voice`

### 3. Configure AI Provider (Optional)

If you want to test AI chat functionality:

**Option A: Use Ollama (Local, Free)**
```bash
# Install Ollama
brew install ollama  # macOS
# or visit https://ollama.ai for other platforms

# Pull model
ollama pull llama3.2:3b

# Start Ollama server
ollama serve
```

**Option B: Use Claude or OpenAI**
```bash
# Copy environment template
cp .env.example .env

# Edit .env and add your API key
# For Claude:
ANTHROPIC_API_KEY=sk-ant-your-key-here

# For OpenAI:
OPENAI_API_KEY=sk-your-key-here

# Restart services
docker compose restart ai-service
```

## Testing the Godot Client

### Launch Godot

```bash
# Open Godot project
godot godot/project.godot

# Or from Godot launcher:
# File → Open Project → Navigate to godot/project.godot
```

### Run the Test Scene

1. In Godot Editor: Press **F5** to run the project
2. The main menu test scene should open automatically
3. Window size: 1920x1080 (can be resized)

## Test Cases

### Test 1: Singleton Initialization

**Purpose:** Verify all autoload singletons load correctly

**Steps:**
1. Launch the game (F5)
2. Check the Output Log (bottom section)

**Expected Results:**
```
✓ ServiceManager loaded
✓ GameState loaded
✓ SaveManager loaded
✓ AIService loaded
✓ EventBus loaded
✓ Connected to EventBus signals
```

**Pass Criteria:** All 5 singletons show green checkmarks

**Failure Modes:**
- Red ✗ with error message → Check Godot Output tab for script errors
- Missing singleton → Check project.godot autoload section

---

### Test 2: Service Connectivity

**Purpose:** Verify backend service communication

**Steps:**
1. Observe "Service Status" section on main menu
2. Wait 1-2 seconds for auto-check to complete
3. Click **[Test Service Connection]** button to refresh

**Expected Results:**
```
Gateway: OK
AI: OK
Whisper: OFFLINE
```

**Pass Criteria:**
- Gateway shows green "OK"
- AI shows green "OK"
- Whisper shows red "OFFLINE" (unless using --profile voice)

**Output Log Should Show:**
```
✓ Gateway service: AVAILABLE
✓ AI service: AVAILABLE
✗ Whisper service: UNAVAILABLE - [Errno -2] Name or service not known
```

**Failure Modes:**
- All services OFFLINE → Check Docker services are running
- Gateway OFFLINE → Check port 17010 not in use
- AI OFFLINE → Check port 17011 not in use

**Troubleshooting:**
```bash
# Check Docker status
docker compose ps

# Restart services
docker compose restart

# Check port conflicts
lsof -i :17010
lsof -i :17011
```

---

### Test 3: AI Chat Integration

**Purpose:** Verify end-to-end AI communication

**Prerequisites:** AI provider configured (Ollama, Claude, or OpenAI)

**Steps:**
1. Click **[Test AI Chat]** button
2. Wait 5-10 seconds for response
3. Check Output Log for results

**Expected Results:**

**Success:**
```
Testing AI chat...
Sending chat message to ATLAS...
✓ Chat successful!
ATLAS: [AI response text]
Event: Chat message from ATLAS: [message]
```

**Expected Response Time:** 1-5 seconds (faster if cached)

**Pass Criteria:**
- Status shows "✓ Chat successful!"
- ATLAS response appears in cyan text
- No error messages

**Failure Modes:**

1. **Service Unavailable:**
   ```
   ✗ AI service not available
   ```
   - Solution: Verify Docker services running

2. **Ollama Not Running:**
   ```
   ✗ Chat failed: Client error '404 Not Found'
   ```
   - Solution: Start Ollama with `ollama serve`

3. **No API Key:**
   ```
   ✗ Chat failed: HTTP 401
   ```
   - Solution: Add API key to .env file

4. **Timeout:**
   ```
   ✗ Chat failed: HTTP request failed
   ```
   - Solution: Increase timeout or check network

---

### Test 4: Save/Load System

**Purpose:** Verify game state persistence

**Steps:**
1. Click **[Test Save/Load]** button
2. Observe the process in Output Log
3. Check save file created

**Expected Results:**

**Output Log:**
```
Testing save/load system...
Modifying game state...
Event: Gained 50 XP (from: test)
Event: Skill increased: engineering (5)
Saving to slot 1...
✓ Save successful!
Event: Game saved to slot 1
Loading from slot 1...
✓ Load successful!
Event: Game loaded from slot 1

Save file info:
  Player: Test Captain (Level 1 Cadet)
  Ship: USS Test Ship (None)
  Missions: 0 | Playtime: 0s
  Saved: [timestamp]
```

**UI Updates:**
- "Player" label changes to "Test Captain"
- Ship name changes to "USS Test Ship"

**Pass Criteria:**
- Save shows green "✓ Save successful!"
- Load shows green "✓ Load successful!"
- Save file info displays correctly
- UI updates with new values

**Verify Save File Exists:**

**macOS:**
```bash
ls ~/Library/Application\ Support/Godot/app_userdata/Space\ Adventures/saves/
# Should show: save_slot_1.json
```

**Linux:**
```bash
ls ~/.local/share/godot/app_userdata/Space\ Adventures/saves/
```

**Windows:**
```cmd
dir %APPDATA%\Godot\app_userdata\Space Adventures\saves\
```

**Save File Format:**
```json
{
  "metadata": {
    "slot": 1,
    "timestamp": 1234567890,
    "player_name": "Test Captain",
    "player_level": 1,
    "ship_name": "USS Test Ship"
  },
  "game_state": {
    "version": "1.0.0",
    "player": {...},
    "ship": {...}
  }
}
```

**Failure Modes:**
- "Save failed" → Check file permissions
- "Load failed" → Verify save file exists and is valid JSON
- No file created → Check Godot user data directory exists

---

### Test 5: EventBus System

**Purpose:** Verify event-driven architecture

**Automatic Test:** Events trigger during other tests

**Events to Observe:**

1. **XP Gained Event** (during save/load test):
   ```
   Event: Gained 50 XP (from: test)
   ```

2. **Skill Increased Event:**
   ```
   Event: Skill increased: engineering (5)
   ```

3. **Save/Load Events:**
   ```
   Event: Game saved to slot 1
   Event: Game loaded from slot 1
   ```

4. **Chat Events** (during AI chat test):
   ```
   Event: Chat message from ATLAS: [message]
   ```

**Pass Criteria:**
- All events appear in Output Log with "Event:" prefix
- Events trigger in correct order
- No duplicate events

**Failure Modes:**
- Missing events → Check EventBus connections
- Duplicate events → Check signal connections not duplicated

---

### Test 6: Game State Management

**Purpose:** Verify GameState singleton functionality

**Automatic Test:** Runs during save/load test

**Verify Game State Updates:**

1. **Player Data:**
   - Name changes to "Test Captain"
   - XP increases by 50
   - Engineering skill increases by 5

2. **Ship Data:**
   - Name changes to "USS Test Ship"
   - Ship class remains "None" (no systems installed)

3. **UI Updates:**
   - "GameStateInfo" label updates automatically
   - Shows current player and ship info

**Pass Criteria:**
- All game state changes persist through save/load
- UI reflects current game state
- No data loss

---

## Performance Benchmarks

### Service Response Times

| Endpoint | Expected | Acceptable | Warning |
|----------|----------|------------|---------|
| /health | <50ms | <100ms | >200ms |
| /api/chat/message | 1-3s | <5s | >10s |
| Save to disk | <50ms | <100ms | >200ms |
| Load from disk | <50ms | <100ms | >200ms |

### Memory Usage

- **Godot Client:** ~100-200 MB RAM
- **Gateway Service:** ~50 MB RAM
- **AI Service:** ~200-500 MB RAM (varies by provider)
- **Redis:** ~10-50 MB RAM

## Common Issues & Solutions

### Issue 1: "Failed to send request"

**Symptoms:** HTTP request errors in Output Log

**Causes:**
- Backend services not running
- Port conflicts
- Network issues

**Solutions:**
```bash
# Restart services
docker compose restart

# Check logs
docker compose logs gateway
docker compose logs ai-service

# Verify ports
netstat -an | grep 17010
netstat -an | grep 17011
```

---

### Issue 2: "AI service unavailable"

**Symptoms:** Chat test fails immediately

**Causes:**
- Docker container unhealthy
- AI provider not configured
- Service startup delay

**Solutions:**
```bash
# Check service health
curl http://localhost:17011/health

# Restart AI service
docker compose restart ai-service

# View logs
docker compose logs ai-service

# Wait 30 seconds after startup
```

---

### Issue 3: "Save file corrupted"

**Symptoms:** Load fails after successful save

**Causes:**
- Incomplete write
- Invalid JSON
- File permissions

**Solutions:**
```bash
# Check save file
cat ~/Library/Application\ Support/Godot/app_userdata/Space\ Adventures/saves/save_slot_1.json

# Validate JSON
cat save_slot_1.json | python3 -m json.tool

# Fix permissions
chmod 644 save_slot_1.json
```

---

### Issue 4: Godot Scripts Have Errors

**Symptoms:** Red errors in Godot Output tab

**Common Errors:**

1. **Type Mismatch:**
   ```
   Error: Invalid type in function call
   ```
   - Check variable types match function signatures

2. **Null Reference:**
   ```
   Error: Attempt to call function on null value
   ```
   - Check @onready vars are assigned
   - Verify nodes exist in scene

3. **Missing Node:**
   ```
   Error: Node not found
   ```
   - Check node paths in get_node() calls
   - Verify scene structure

**Solutions:**
- Check Godot Output tab for line numbers
- Review script at indicated line
- Verify scene structure matches script expectations

---

## Test Report Template

```markdown
# Test Report - Space Adventures
**Date:** YYYY-MM-DD
**Tester:** [Your Name]
**Build:** Phase 1, Week 3
**Platform:** macOS / Linux / Windows
**Godot Version:** [version]

## Test Results

### Test 1: Singleton Initialization
- [ ] PASS
- [ ] FAIL - [reason]

### Test 2: Service Connectivity
- [ ] PASS
- [ ] FAIL - [reason]

### Test 3: AI Chat Integration
- [ ] PASS
- [ ] FAIL - [reason]
- [ ] SKIPPED - No AI provider configured

### Test 4: Save/Load System
- [ ] PASS
- [ ] FAIL - [reason]

### Test 5: EventBus System
- [ ] PASS
- [ ] FAIL - [reason]

### Test 6: Game State Management
- [ ] PASS
- [ ] FAIL - [reason]

## Performance Observations

- Health check response time: [ms]
- Chat response time: [s]
- Save operation time: [ms]
- Load operation time: [ms]
- Memory usage: [MB]

## Issues Found

1. [Issue description]
   - Severity: Critical / Major / Minor
   - Steps to reproduce:
   - Expected behavior:
   - Actual behavior:

## Screenshots

[Attach screenshots of any issues or notable results]

## Additional Notes

[Any other observations or comments]
```

## Reporting Issues

When reporting issues, include:

1. **Environment:**
   - OS and version
   - Godot version
   - Docker version

2. **Steps to Reproduce:**
   - Clear, numbered steps
   - What you expected
   - What actually happened

3. **Logs:**
   - Godot Output tab contents
   - Docker logs: `docker compose logs`
   - Save file contents (if relevant)

4. **Screenshots:**
   - Error messages
   - UI state
   - Terminal output

**Submit to:** [Project issue tracker or team lead]

## Success Criteria

The build is ready for Week 4 if:

- ✅ All singletons load without errors
- ✅ Gateway and AI services are reachable
- ✅ Save/load creates valid files
- ✅ EventBus signals trigger correctly
- ✅ No critical errors in Godot Output
- ✅ UI responds to all button clicks
- ✅ (Optional) AI chat returns responses

---

## Next Steps After Testing

Once testing is complete and issues are resolved:

1. Report results using test report template
2. Document any bugs found
3. Verify fixes for any critical issues
4. Ready for Phase 1, Week 4 development:
   - Mission system implementation
   - Ship system UI
   - Workshop scene

---

**For Questions or Support:**
- Check docs/CLAUDE.md for architecture details
- Review godot/CLAUDE.md for Godot-specific info
- Check docs/development-organization.md for project plan

**Happy Testing! 🚀**
