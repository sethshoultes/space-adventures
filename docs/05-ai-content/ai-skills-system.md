# AI Skills System - Self-Improving Agent Capabilities

**Status**: Phase 1 (Basic Functions) - In Progress
**Owner**: AI Development
**Created**: 2025-11-08

## Vision

Enable AI agents (especially ATLAS) to dynamically create, save, and reuse custom "skills" - essentially user-defined functions that combine existing primitives to answer specific queries or generate custom reports about the game state.

**Example Use Case:**
```
Player: "What's the ship name?"
ATLAS: "I don't have a function for that. Let me create one..."
[ATLAS creates a 'get_ship_name' skill using get_field primitive]
ATLAS: "Your ship is named 'Unnamed Vessel'. I've saved this skill for future use."

Player: "What's the ship name?" (later)
ATLAS: [Uses saved skill] "Your ship is named 'Starlight Explorer'."
```

## Three-Phase Approach

### Phase 1: Expanded Static Functions (MVP - Now)
**Goal**: Provide comprehensive, flexible functions that cover most use cases.

**Implementation**: Expand existing function registry with better queries

**New Functions to Add:**
```python
{
  "name": "get_ship_info",
  "description": "Get information about the player's ship",
  "parameters": {
    "field": {
      "type": "string",
      "enum": ["name", "class", "power_total", "power_available", "hull_hp",
               "max_hull_hp", "all_systems", "operational_systems", "all"],
      "description": "Which ship information to retrieve"
    }
  }
}

{
  "name": "get_mission_context",
  "description": "Get current mission details and story context",
  "parameters": {
    "include_history": {
      "type": "boolean",
      "default": false,
      "description": "Include previous mission stages"
    }
  }
}

{
  "name": "get_player_info",
  "description": "Get player information",
  "parameters": {
    "field": {
      "type": "string",
      "enum": ["name", "level", "rank", "xp", "skills", "all"],
      "description": "Which player information to retrieve"
    }
  }
}

{
  "name": "get_system_details",
  "description": "Get detailed information about a specific ship system",
  "parameters": {
    "system_name": {
      "type": "string",
      "enum": ["hull", "power", "propulsion", "warp", "life_support",
               "computer", "sensors", "shields", "weapons", "communications"],
      "description": "Which system to query"
    }
  }
}
```

**Benefits:**
- ✅ Safe (no code execution)
- ✅ Fast to implement (just add to function registry)
- ✅ Immediately useful
- ✅ Works with all LLM providers

**Timeline**: 1-2 hours

---

### Phase 2: Function Composition System (Skills)
**Goal**: Let AI create reusable "skills" by combining primitive operations.

**Architecture:**

```
┌─────────────────────────────────────────────────────┐
│           AI Agent (ATLAS, etc.)                    │
└───────────────┬─────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────┐
│        Skill Executor (Python)                      │
│  - Validates skill definition                       │
│  - Executes steps sequentially                      │
│  - Returns final result                             │
└───────────────┬─────────────────────────────────────┘
                │
      ┌─────────┴─────────┐
      ▼                   ▼
┌──────────────┐   ┌──────────────┐
│  Primitives  │   │ Skill Store  │
│   Library    │   │   (Redis)    │
└──────────────┘   └──────────────┘
```

**Primitive Operations:**
```python
PRIMITIVES = {
    # Data Access
    "get_field": lambda data, path: deep_get(data, path.split(".")),
    "get_keys": lambda data: list(data.keys()),
    "get_values": lambda data: list(data.values()),

    # Filtering
    "filter_list": lambda items, key, value: [x for x in items if x.get(key) == value],
    "filter_gt": lambda items, key, value: [x for x in items if x.get(key) > value],
    "filter_lt": lambda items, key, value: [x for x in items if x.get(key) < value],

    # Aggregation
    "count": lambda items: len(items),
    "sum_field": lambda items, field: sum(x.get(field, 0) for x in items),
    "max_field": lambda items, field: max(x.get(field, 0) for x in items),
    "min_field": lambda items, field: min(x.get(field, 0) for x in items),

    # Formatting
    "format_string": lambda template, **kwargs: template.format(**kwargs),
    "join_strings": lambda items, separator: separator.join(str(x) for x in items),

    # Logic
    "if_else": lambda condition, true_val, false_val: true_val if condition else false_val,
    "equals": lambda a, b: a == b,
    "greater_than": lambda a, b: a > b,
}
```

**Skill Definition Format:**
```json
{
  "skill_id": "get_ship_name",
  "description": "Returns the name of the player's ship",
  "created_by": "atlas",
  "conversation_id": "workshop_1699564320",
  "steps": [
    {
      "operation": "get_field",
      "args": {
        "data": "$game_state",
        "path": "ship.name"
      },
      "store_as": "ship_name"
    },
    {
      "operation": "format_string",
      "args": {
        "template": "Your ship is named '{name}'.",
        "name": "$ship_name"
      },
      "store_as": "result"
    }
  ],
  "return": "$result"
}
```

**Skill Execution:**
```python
async def execute_skill(skill_def: dict, game_state: dict) -> Any:
    """Execute a skill definition safely"""
    context = {"game_state": game_state}

    for step in skill_def["steps"]:
        operation = step["operation"]
        if operation not in PRIMITIVES:
            raise ValueError(f"Unknown operation: {operation}")

        # Resolve arguments (replace $variables with context values)
        args = resolve_variables(step["args"], context)

        # Execute primitive
        result = PRIMITIVES[operation](**args)

        # Store result in context
        if "store_as" in step:
            context[step["store_as"]] = result

    # Return final value
    return_var = skill_def["return"]
    return context[return_var.lstrip("$")]
```

**Storage in Redis:**
```python
# Key: skill:{skill_id}
# Value: JSON skill definition
# TTL: None (persist until explicitly deleted)

redis.set("skill:get_ship_name", json.dumps(skill_def))

# Also maintain an index per conversation
redis.sadd(f"conversation:{conv_id}:skills", "get_ship_name")
```

**LLM Function for Skill Creation:**
```python
{
  "name": "create_skill",
  "description": "Create a new reusable skill by composing primitive operations",
  "parameters": {
    "skill_id": {"type": "string", "description": "Unique identifier for the skill"},
    "description": {"type": "string", "description": "What this skill does"},
    "steps": {
      "type": "array",
      "description": "Sequence of primitive operations to execute",
      "items": {
        "type": "object",
        "properties": {
          "operation": {"type": "string", "enum": [...list of primitives...]},
          "args": {"type": "object"},
          "store_as": {"type": "string"}
        }
      }
    }
  }
}

{
  "name": "use_skill",
  "description": "Execute a previously created skill",
  "parameters": {
    "skill_id": {"type": "string", "description": "ID of skill to execute"}
  }
}

{
  "name": "list_skills",
  "description": "List all skills created in this conversation"
}
```

**Benefits:**
- ✅ Safe (no arbitrary code execution)
- ✅ Reusable (skills persist in Redis)
- ✅ Flexible (AI can combine primitives creatively)
- ✅ Transparent (skill definitions are readable JSON)
- ✅ Debugging-friendly (can inspect each step)

**Challenges:**
- Designing a good primitive library
- Teaching the LLM how to compose primitives effectively
- Error handling when skills fail

**Timeline**: 2-3 days

---

### Phase 3: Restricted Code Interpreter (Advanced)
**Goal**: Let AI write actual Python code for maximum flexibility, but in a heavily restricted sandbox.

**Approach**: Use Python's `ast` module to parse and validate code before execution.

**Restrictions:**
- ✅ Only pure data transformations
- ✅ No imports (except safe builtins: math, itertools, functools)
- ✅ No file I/O
- ✅ No network access
- ✅ No exec/eval
- ✅ Read-only access to game_state
- ✅ Timeout after 1 second
- ✅ Memory limit

**Safe Code Parser:**
```python
import ast

ALLOWED_NODES = {
    ast.Module, ast.FunctionDef, ast.Return, ast.Assign, ast.Name,
    ast.Load, ast.Store, ast.Call, ast.Attribute, ast.Subscript,
    ast.List, ast.Dict, ast.Tuple, ast.Constant,
    ast.BinOp, ast.UnaryOp, ast.Compare, ast.BoolOp,
    ast.IfExp, ast.ListComp, ast.DictComp,
    # Math operators
    ast.Add, ast.Sub, ast.Mult, ast.Div, ast.Mod,
    ast.Eq, ast.NotEq, ast.Lt, ast.LtE, ast.Gt, ast.GtE,
    ast.And, ast.Or, ast.Not
}

ALLOWED_BUILTINS = {
    'len', 'sum', 'max', 'min', 'sorted', 'reversed',
    'enumerate', 'zip', 'filter', 'map', 'any', 'all',
    'int', 'float', 'str', 'bool', 'list', 'dict', 'tuple', 'set'
}

def validate_code(code_string: str) -> bool:
    """Check if code is safe to execute"""
    try:
        tree = ast.parse(code_string)
    except SyntaxError:
        return False

    # Check all nodes
    for node in ast.walk(tree):
        if type(node) not in ALLOWED_NODES:
            raise ValueError(f"Forbidden node type: {type(node).__name__}")

        # Check for forbidden function calls
        if isinstance(node, ast.Call):
            if isinstance(node.func, ast.Name):
                if node.func.id not in ALLOWED_BUILTINS:
                    raise ValueError(f"Forbidden function: {node.func.id}")

    return True

def safe_execute(code: str, game_state: dict) -> Any:
    """Execute validated Python code safely"""
    if not validate_code(code):
        raise ValueError("Code validation failed")

    # Create restricted namespace
    namespace = {
        '__builtins__': {name: __builtins__[name] for name in ALLOWED_BUILTINS},
        'game_state': game_state  # Read-only
    }

    # Execute with timeout
    with time_limit(1):  # 1 second max
        exec(code, namespace)
        return namespace.get('result')
```

**Example AI-Generated Code:**
```python
def get_damaged_systems(game_state):
    """Returns list of systems with health < 100"""
    systems = game_state['ship']['systems']
    damaged = [
        name for name, system in systems.items()
        if system.get('health', 100) < 100
    ]
    return damaged

result = get_damaged_systems(game_state)
```

**LLM Function:**
```python
{
  "name": "execute_python",
  "description": "Execute Python code to query or transform game data (read-only)",
  "parameters": {
    "code": {
      "type": "string",
      "description": "Python code to execute. Must define 'result' variable with return value."
    },
    "description": {
      "type": "string",
      "description": "What this code does (for logging)"
    }
  }
}
```

**Benefits:**
- ✅ Maximum flexibility - AI can do anything
- ✅ Natural for LLMs trained on code
- ✅ Can handle complex queries easily

**Risks:**
- ⚠️ Security: Must be airtight sandbox
- ⚠️ Reliability: AI-generated code might have bugs
- ⚠️ Performance: Code validation has overhead

**Timeline**: 1 week (mostly security testing)

---

## Implementation Roadmap

### Week 1: Phase 1 - Enhanced Functions ✅ COMPLETE
- [x] Add `get_ship_info(field)` function
- [x] Add `get_player_info(field)` function
- [x] Add `get_system_details(system_name)` function
- [x] Add `get_mission_context()` function
- [x] Update ATLAS system prompt to use new functions
- [x] Test all new functions with Ollama
- [x] Document in function registry

**Completion Date**: 2025-11-08
**Test Results**: All three new functions working correctly with Ollama llama3.2:latest
- `get_ship_info("name")` → Successfully answers "What is the ship name?"
- `get_player_info("level")` → Successfully answers "What level is the captain?"
- `get_mission_context()` → Ready for mission integration

### Week 2-3: Phase 2 - Skills System
- [ ] Design primitive operations library (15-20 primitives)
- [ ] Implement skill executor with step-by-step execution
- [ ] Add Redis storage for skill definitions
- [ ] Create `create_skill`, `use_skill`, `list_skills` functions
- [ ] Update ATLAS prompt with skill creation examples
- [ ] Test skill creation, execution, and reuse
- [ ] Add skill management UI (optional)

### Week 4+: Phase 3 - Code Interpreter
- [ ] Implement AST-based code validator
- [ ] Create restricted execution environment
- [ ] Add timeout and memory limits
- [ ] Implement `execute_python` function
- [ ] Extensive security testing
- [ ] Add code review/approval step (optional safety measure)
- [ ] Performance benchmarking

---

## Success Criteria

### Phase 1
- [x] AI can answer "What is the ship name?" without creating a function
- [x] AI can provide detailed system status on request
- [x] AI knows current mission context when chatting during missions
- [x] Function calls return useful data in natural language

### Phase 2
- [ ] AI can create a custom skill and reuse it later in the conversation
- [ ] Skills persist across game sessions (via conversation_id)
- [ ] AI can list available skills and explain what they do
- [ ] At least 5 useful skills created in real gameplay

### Phase 3
- [ ] AI can write Python code to answer complex queries
- [ ] Code validator catches all dangerous operations
- [ ] Zero security incidents in testing
- [ ] Code execution completes in < 1 second for 95% of queries

---

## Security Considerations

### Phase 1: Minimal Risk ✅
- Static functions only access provided game_state
- No user input executed as code
- All operations predefined and safe

### Phase 2: Low Risk ⚠️
- Limited to primitive operations
- No arbitrary code execution
- Skill definitions are declarative JSON
- Worst case: skill returns wrong data (not a security issue)

### Phase 3: High Risk 🚨
- **Must validate code before execution**
- **Must prevent**: imports, file access, network access, eval/exec
- **Must enforce**: timeout, memory limits, read-only game_state
- **Consider**: Manual review/approval before first execution
- **Testing**: Extensive penetration testing required

---

## Alternative Approaches Considered

### 1. Natural Language Only (No Functions)
**Approach**: Just give AI the full game state in every message.
**Rejected**: Too token-heavy, expensive, slow, hits context limits.

### 2. GraphQL-style Query Language
**Approach**: AI generates GraphQL queries to fetch specific data.
**Pros**: Declarative, safe, industry-standard.
**Cons**: Requires GraphQL server, adds complexity, less flexible than code.

### 3. SQL-style Queries
**Approach**: Treat game_state as a database, AI writes SELECT queries.
**Pros**: Declarative, familiar, powerful for data queries.
**Cons**: Requires data modeling, less intuitive for object graphs.

### 4. WebAssembly Sandbox
**Approach**: Compile Python to WASM, run in isolated environment.
**Pros**: True isolation, can't escape sandbox.
**Cons**: Significant engineering effort, adds dependencies.

---

## Resources & Research

**Academic Papers:**
- [Toolformer: Language Models Can Teach Themselves to Use Tools](https://arxiv.org/abs/2302.04761)
- [ReAct: Synergizing Reasoning and Acting in Language Models](https://arxiv.org/abs/2210.03629)
- [Gorilla: Large Language Model Connected with Massive APIs](https://arxiv.org/abs/2305.15334)

**Industry Examples:**
- ChatGPT Code Interpreter (OpenAI) - Phase 3 approach
- LangChain Tools - Phase 2 approach
- AutoGPT - Agent with self-improving capabilities

**Libraries:**
- [RestrictedPython](https://github.com/zopefoundation/RestrictedPython) - Safe Python execution
- [PyPy Sandboxing](https://doc.pypy.org/en/latest/sandbox.html) - OS-level isolation
- [LangChain](https://github.com/langchain-ai/langchain) - Agent framework

---

## Open Questions

1. **Skill Discovery**: How does AI know when to create a new skill vs use existing?
2. **Skill Versioning**: What if a skill needs to be updated?
3. **Skill Sharing**: Should skills be global (all conversations) or per-conversation?
4. **Error Recovery**: What happens if a skill fails mid-execution?
5. **Primitive Design**: What's the minimal set of primitives that's still useful?
6. **Performance**: How much overhead does skill execution add?
7. **UI**: Should players see when AI creates/uses skills? (Transparency)

---

## Next Steps

**Immediate** (This Session):
1. ✅ Implement Phase 1 enhanced functions
2. ✅ Add mission context to game_state
3. ✅ Test with real queries like "What is the ship name?"

**Short-term** (Next Session):
1. Design primitive operations library
2. Implement skill executor prototype
3. Test skill creation with ATLAS

**Long-term** (Future):
1. Phase 3 code interpreter (if needed)
2. Skill management UI
3. Analytics on which skills are most useful

---

**Document Owner**: AI Agent Development Team
**Last Updated**: 2025-11-08
**Status**: Phase 1 in progress, Phase 2 designed, Phase 3 planned
