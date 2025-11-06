# AI & Content Systems Documentation

**Purpose:** AI integration, content generation, and voice transcription systems.

## Files in This Directory

### [ai-integration.md](./ai-integration.md)
Multi-provider AI integration (Claude, OpenAI, Ollama).

### [ai-chat-storytelling-system.md](./ai-chat-storytelling-system.md)
AI chat system with 4 personalities (ATLAS, Companion, MENTOR, CHIEF).

### [whisper-voice-transcription.md](./whisper-voice-transcription.md)
Voice-to-text system using OpenAI Whisper (optional feature).

## Overview

This directory documents the AI-powered content generation systems that make Space Adventures dynamic and replayable.

## AI Providers

**Supported:**
- **Claude** (Anthropic) - High-quality narrative
- **OpenAI** (GPT-4) - Versatile content generation
- **Ollama** (Local) - Privacy-first, no cost

**Configuration:** Set `AI_PROVIDER` in `.env` file

## The 4 AI Personalities

1. **ATLAS** - Ship computer (formal, analytical)
2. **Companion** - Friendly advisor (warm, supportive)
3. **MENTOR** - Veteran commander (experienced, tactical)
4. **CHIEF** - Engineer (practical, technical)

## Features

- Mission generation (6 types)
- Dynamic dialogue
- Encounter creation
- Chat with personality consistency
- Response caching (24h TTL)

---

**Navigation:**
- [📚 Documentation Index](../README.md)
- [🤖 AI Agent Context](../CLAUDE.md)
