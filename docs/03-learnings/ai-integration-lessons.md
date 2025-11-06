# AI Integration & Prompt Engineering Lessons

**Lessons learned while integrating Claude, OpenAI, and Ollama for procedural narrative generation.**

---

## 2024-11-05: SHA-256 Prompt Hashing for Cache Keys

**Context:** Implementing Redis caching for AI responses to reduce costs and improve performance.

**Problem:** Need consistent cache keys for identical prompts, but prompts are long strings (500-2000 characters). Using raw prompts as keys is inefficient and error-prone.

**Solution:** Hash prompts with SHA-256 to create consistent, compact cache keys:

```python
import hashlib
import json

def generate_cache_key(prompt: str, provider: str, model: str) -> str:
    """
    Generate consistent cache key for AI requests.

    Args:
        prompt: The full prompt text
        provider: AI provider (claude, openai, ollama)
        model: Specific model (claude-3-opus, gpt-4, llama2)

    Returns:
        Consistent cache key (SHA-256 hash)
    """
    # Include provider and model in hash to prevent collisions
    cache_data = {
        "prompt": prompt,
        "provider": provider,
        "model": model
    }
    cache_string = json.dumps(cache_data, sort_keys=True)
    return hashlib.sha256(cache_string.encode()).hexdigest()

# Usage
cache_key = generate_cache_key(prompt, "claude", "claude-3-opus-20240229")
# Returns: "a7f3d2c8e9b4..."

# Check Redis cache
cached_response = await redis.get(cache_key)
if cached_response:
    return json.loads(cached_response)

# Generate new response
response = await ai_provider.generate(prompt)

# Cache for 24 hours
await redis.setex(cache_key, 86400, json.dumps(response))
```

**Why This Matters:**
- Consistent keys for identical prompts (cache hit guaranteed)
- Compact keys (64 characters vs 2000+ for full prompt)
- Provider/model-specific caching (same prompt, different model = different cache)
- No collisions (SHA-256 cryptographically secure)

**Cost Savings:**
- Mission generation: $0.01-0.05 per call (cached = $0.00)
- 100 players testing same mission: 1 API call instead of 100
- 24-hour TTL balances freshness vs cost

**Gotchas:**
- Must include provider/model in hash (or risk collisions)
- JSON serialization order matters (use `sort_keys=True`)
- Cache invalidation strategy needed for game updates
- Don't cache errors (only successful responses)

**Resources:**
- Python hashlib: https://docs.python.org/3/library/hashlib.html
- Redis setex command: https://redis.io/commands/setex/

**Related Patterns:** Caching strategies, cost optimization, cache invalidation

---

## 2024-11-05: Multi-Provider Abstraction with Strategy Pattern

**Context:** Supporting Claude, OpenAI, and Ollama with different APIs and response formats.

**Problem:** Each AI provider has different client libraries, authentication, response formats, and error handling. Need clean abstraction to support all three without code duplication.

**Solution:** Abstract base class with provider-specific implementations:

```python
from abc import ABC, abstractmethod
from typing import Optional

class AIProvider(ABC):
    """Base class for AI providers"""

    @abstractmethod
    async def generate(self, prompt: str, temperature: float = 0.8) -> str:
        """Generate text from prompt"""
        pass

    @abstractmethod
    async def health_check(self) -> bool:
        """Check if provider is available"""
        pass

class ClaudeProvider(AIProvider):
    def __init__(self, api_key: str):
        self.client = Anthropic(api_key=api_key)

    async def generate(self, prompt: str, temperature: float = 0.8) -> str:
        response = await self.client.messages.create(
            model="claude-3-opus-20240229",
            max_tokens=2000,
            temperature=temperature,
            messages=[{"role": "user", "content": prompt}]
        )
        return response.content[0].text

class OpenAIProvider(AIProvider):
    def __init__(self, api_key: str):
        self.client = OpenAI(api_key=api_key)

    async def generate(self, prompt: str, temperature: float = 0.8) -> str:
        response = await self.client.chat.completions.create(
            model="gpt-4-turbo-preview",
            temperature=temperature,
            messages=[{"role": "user", "content": prompt}]
        )
        return response.choices[0].message.content

class OllamaProvider(AIProvider):
    def __init__(self, base_url: str, model: str):
        self.base_url = base_url
        self.model = model

    async def generate(self, prompt: str, temperature: float = 0.8) -> str:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/api/generate",
                json={"model": self.model, "prompt": prompt, "temperature": temperature}
            )
            return response.json()["response"]

# Factory function
def create_provider(config: dict) -> AIProvider:
    provider_type = config.get("provider", "ollama")

    if provider_type == "claude":
        return ClaudeProvider(api_key=config["api_key"])
    elif provider_type == "openai":
        return OpenAIProvider(api_key=config["api_key"])
    elif provider_type == "ollama":
        return OllamaProvider(
            base_url=config.get("ollama_base_url", "http://localhost:11434"),
            model=config.get("ollama_model", "llama2")
        )
    else:
        raise ValueError(f"Unknown provider: {provider_type}")
```

**Usage:**
```python
# Client code doesn't care about provider
provider = create_provider(settings.dict())
response = await provider.generate(prompt)  # Works for any provider
```

**Why This Matters:**
- Single interface for all providers
- Easy to add new providers (extend AIProvider)
- Client code provider-agnostic (swap providers without code changes)
- Testable (mock AIProvider for tests)

**Trade-offs:**
- More initial complexity
- Abstracts away provider-specific features
- May need provider-specific methods for advanced features

**When to Use:**
- Multiple implementations of same concept (providers, storage backends, etc.)
- Need to swap implementations at runtime
- Want to test with mocks

**Resources:**
- Strategy Pattern: https://refactoring.guru/design-patterns/strategy
- Python ABC: https://docs.python.org/3/library/abc.html

**Related Patterns:** Factory pattern, dependency injection, SOLID principles

---

## Template for New Lessons

```markdown
## [Date]: [Lesson Title]

**Context:** [What were you building?]

**Problem:** [What challenge did you face?]

**Solution:** [How did you solve it?]

**Code Example:**
```python
# Show the pattern with actual code
```

**Why This Matters:** [Why should future-you care?]

**Cost/Performance Impact:** [If applicable]

**Gotchas:** [Things that might trip you up]

**Resources:** [Links to docs, articles, etc.]

**Related Patterns:** [Cross-references]
```

---

## Topics to Document (As We Learn)

**Prompt Engineering:**
- [ ] Effective prompt structure for narrative generation
- [ ] Context management (how much to include)
- [ ] Temperature vs creativity trade-offs
- [ ] System messages vs user messages
- [ ] Few-shot examples vs zero-shot
- [ ] Prompt length vs cost/performance

**Caching Strategies:**
- [ ] When to cache vs regenerate
- [ ] TTL strategies (how long to cache)
- [ ] Cache invalidation patterns
- [ ] Handling cache misses gracefully
- [ ] Preloading strategies

**Error Handling:**
- [ ] Rate limiting (429 errors)
- [ ] Timeout strategies
- [ ] Retry logic with exponential backoff
- [ ] Fallback content when AI unavailable
- [ ] User-facing error messages

**Validation:**
- [ ] Pydantic models for AI responses
- [ ] Handling malformed responses
- [ ] Content filtering (inappropriate content)
- [ ] Structure validation (JSON parsing)
- [ ] Consistency checks

**Provider Differences:**
- [ ] Claude vs OpenAI response quality
- [ ] Ollama performance characteristics
- [ ] Cost per token (Claude vs OpenAI)
- [ ] Context window limits
- [ ] Model-specific prompt optimization

**Context Management:**
- [ ] How much game state to include
- [ ] Narrative continuity across requests
- [ ] Memory management (long conversations)
- [ ] Summarization strategies

---

**AI Agent:** Add lessons here as you discover AI integration patterns and prompt engineering techniques. Focus on problems specific to procedural narrative generation.
