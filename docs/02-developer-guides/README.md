# Developer Guides

**Purpose:** Technical implementation guides, architecture documentation, and project management for developers.

## Directory Structure

### [architecture/](./architecture/)
System architecture, integration patterns, and technical design.

### [project-management/](./project-management/)
Development organization, roadmaps, and planning documents.

### [deployment/](./deployment/)
CI/CD pipelines, deployment procedures, and infrastructure.

## Overview

This directory contains all technical documentation for developers working on Space Adventures. It covers system design, development workflows, and deployment strategies.

## Quick Navigation

### Architecture & Design
- **[Technical Architecture](./architecture/technical-architecture.md)** - Complete system design
- **[Integration Guide](./architecture/INTEGRATION-GUIDE.md)** - Godot ↔ Backend integration

### Planning & Organization
- **[Development Organization](./project-management/development-organization.md)** - Master development plan
- **[MVP Roadmap](./project-management/mvp-roadmap.md)** - Week-by-week breakdown

### Deployment
- **[CI/CD Deployment](./deployment/ci-cd-deployment.md)** - Automated deployment system

## For New Developers

**Start Here:**
1. [Setup](../00-getting-started/DEVELOPER-SETUP.md) - Get environment running
2. [Technical Architecture](./architecture/technical-architecture.md) - Understand the system
3. [Integration Guide](./architecture/INTEGRATION-GUIDE.md) - Learn integration patterns
4. [Development Organization](./project-management/development-organization.md) - See the plan

## For Experienced Developers

**Jump To:**
- Architecture diagrams → [technical-architecture.md](./architecture/technical-architecture.md)
- API reference → [INTEGRATION-GUIDE.md](./architecture/INTEGRATION-GUIDE.md)
- Current phase → [development-organization.md](./project-management/development-organization.md)
- Deployment → [ci-cd-deployment.md](./deployment/ci-cd-deployment.md)

## Related Documentation

- **Setup:** [../00-getting-started/DEVELOPER-SETUP.md](../00-getting-started/DEVELOPER-SETUP.md)
- **Testing:** [../01-user-guides/testing/TESTING-GUIDE.md](../01-user-guides/testing/TESTING-GUIDE.md)
- **Game Design:** [../03-game-design/](../03-game-design/)
- **Ports:** [../06-technical-reference/PORT-MAPPING.md](../06-technical-reference/PORT-MAPPING.md)

## Key Concepts

### Microservices Architecture
- Gateway (17010) - Entry point and routing
- AI Service (17011) - Content generation
- Whisper (17012) - Voice transcription (optional)
- Redis (17014) - Caching layer

### Godot Integration
- 5 autoload singletons (ServiceManager, GameState, SaveManager, EventBus, AIService)
- HTTP communication via HTTPRequest nodes
- Event-driven architecture
- JSON save/load system

### Development Phases
- **Phase 1:** Foundation & Core Services (Weeks 1-4) ✅
- **Phase 2:** Game Systems & Ship Building (Weeks 5-8)
- **Phase 3:** Content & Missions (Weeks 9-12)
- **Phase 4:** Polish & Testing (Weeks 13-16)
- **Phase 5:** Launch Preparation (Weeks 17-20)

---

**Navigation:**
- [📚 Documentation Index](../README.md)
- [🤖 AI Agent Context](../CLAUDE.md)
- [🎮 Project Root](../../)
