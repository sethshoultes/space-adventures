#!/bin/bash

# Move files to appropriate directories

# 00-getting-started
mv -n DEVELOPER-SETUP.md 00-getting-started/

# 01-user-guides/testing
mv -n TESTING-GUIDE.md 01-user-guides/testing/

# 02-developer-guides/architecture
mv -n technical-architecture.md 02-developer-guides/architecture/
mv -n INTEGRATION-GUIDE.md 02-developer-guides/architecture/

# 02-developer-guides/project-management
mv -n development-organization.md 02-developer-guides/project-management/
mv -n mvp-roadmap.md 02-developer-guides/project-management/

# 02-developer-guides/deployment
mv -n ci-cd-deployment.md 02-developer-guides/deployment/

# 03-game-design/core-systems
mv -n game-design-document.md 03-game-design/core-systems/
mv -n player-progression-system.md 03-game-design/core-systems/
mv -n resources-survival.md 03-game-design/core-systems/

# 03-game-design/ship-systems
mv -n ship-systems.md 03-game-design/ship-systems/
mv -n ship-classification-system.md 03-game-design/ship-systems/
mv -n ship-documentation.md 03-game-design/ship-systems/

# 03-game-design/content-systems
mv -n mission-framework.md 03-game-design/content-systems/
mv -n crew-companion-system.md 03-game-design/content-systems/

# 04-ui-graphics
mv -n UI-GRAPHICS-INDEX.md 04-ui-graphics/
mv -n ui-graphics-*.md 04-ui-graphics/
mv -n screen-designs.md 04-ui-graphics/
mv -n visual-features.md 04-ui-graphics/
mv -n dashboard-*.md 04-ui-graphics/

# 05-ai-content
mv -n ai-integration.md 05-ai-content/
mv -n ai-chat-storytelling-system.md 05-ai-content/
mv -n whisper-voice-transcription.md 05-ai-content/

# 06-technical-reference
mv -n PORT-MAPPING.md 06-technical-reference/
mv -n settings-system.md 06-technical-reference/

# 07-ai-agent-templates
mv -n claude-md-templates.md 07-ai-agent-templates/

echo "Files moved successfully"
