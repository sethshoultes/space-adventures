#!/usr/bin/env python3
"""
Sync CLAUDE.md files with PROJECT-STATE.json

This script reads the single source of truth (PROJECT-STATE.json) and updates
all CLAUDE.md files throughout the project to reflect the current project state.

Usage:
    python scripts/sync-claude-md.py

After running:
    git diff CLAUDE.md docs/*/CLAUDE.md
    git commit -m "docs: Sync CLAUDE.md (M1 at XX%)"
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Any


class ClaudeMdSyncer:
    """Syncs CLAUDE.md files with PROJECT-STATE.json"""

    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.state_file = project_root / "PROJECT-STATE.json"
        self.state = self._load_state()
        self.changes_made = []

    def _load_state(self) -> Dict[str, Any]:
        """Load PROJECT-STATE.json"""
        if not self.state_file.exists():
            raise FileNotFoundError(f"PROJECT-STATE.json not found at {self.state_file}")

        with open(self.state_file, 'r') as f:
            return json.load(f)

    def _read_file(self, file_path: Path) -> str:
        """Read a CLAUDE.md file"""
        if not file_path.exists():
            raise FileNotFoundError(f"CLAUDE.md not found at {file_path}")

        with open(file_path, 'r') as f:
            return f.read()

    def _write_file(self, file_path: Path, content: str):
        """Write updated content to a CLAUDE.md file"""
        with open(file_path, 'w') as f:
            f.write(content)

    def _update_milestone_status(self, content: str) -> str:
        """Update milestone status in CLAUDE.md files"""
        milestone = self.state['milestone']

        # Pattern: **Current Milestone:** ...
        pattern = r'\*\*Current Milestone:\*\* [^\n]+'
        replacement = f"**Current Milestone:** Milestone {milestone['current']} - {milestone['name']} ({milestone['progress']}% complete)"

        new_content = re.sub(pattern, replacement, content)

        # Also update status line if present
        pattern2 = r'\*\*Status:\*\* [^\n]+'
        replacement2 = f"**Status:** {milestone['status']}"
        new_content = re.sub(pattern2, replacement2, new_content)

        return new_content

    def _update_singletons_count(self, content: str) -> str:
        """Update singleton count references (5 → 10)"""
        singletons_count = self.state['singletons']['count']

        # Pattern: "5 autoload singletons" → "10 autoload singletons"
        patterns = [
            (r'\b5 autoload singletons\b', f'{singletons_count} autoload singletons'),
            (r'\b5 singletons\b', f'{singletons_count} singletons'),
            (r'\bAll 5 singletons\b', f'All {singletons_count} singletons'),
        ]

        new_content = content
        for pattern, replacement in patterns:
            new_content = re.sub(pattern, replacement, new_content, flags=re.IGNORECASE)

        return new_content

    def _format_singleton_list(self) -> str:
        """Format singleton list for insertion into CLAUDE.md"""
        lines = []
        for singleton in self.state['singletons']['list']:
            lines.append(f"- `{singleton['name']}`: {singleton['description']}")
        return '\n'.join(lines)

    def _format_advanced_systems(self) -> str:
        """Format advanced systems list for insertion into CLAUDE.md"""
        lines = []
        for system in self.state['advanced_systems']:
            lines.append(f"- **{system['name']}**: {system['description']}")
            lines.append(f"  - {system['features']}")
        return '\n'.join(lines)

    def sync_root_claude_md(self):
        """Sync /CLAUDE.md"""
        file_path = self.project_root / "CLAUDE.md"
        print(f"\nSyncing: {file_path.relative_to(self.project_root)}")

        content = self._read_file(file_path)
        original_content = content

        # Update milestone status
        content = self._update_milestone_status(content)

        # Update singleton counts
        content = self._update_singletons_count(content)

        # Update current task in Project Status section
        milestone = self.state['milestone']
        pattern = r'\*\*Current Task:\*\* [^\n]+'
        replacement = f"**Current Task:** {milestone['status']}"
        content = re.sub(pattern, replacement, content)

        if content != original_content:
            self._write_file(file_path, content)
            self.changes_made.append(str(file_path.relative_to(self.project_root)))
            print("  ✓ Updated milestone status and singleton counts")
        else:
            print("  - No changes needed")

    def sync_docs_claude_md(self):
        """Sync /docs/CLAUDE.md"""
        file_path = self.project_root / "docs" / "CLAUDE.md"
        print(f"\nSyncing: {file_path.relative_to(self.project_root)}")

        content = self._read_file(file_path)
        original_content = content

        # Update milestone status
        content = self._update_milestone_status(content)

        # Update singleton counts
        content = self._update_singletons_count(content)

        # Update EventBus signal count (50+ → 55+)
        content = re.sub(r'\b50\+ signals\b', '55+ signals', content)

        if content != original_content:
            self._write_file(file_path, content)
            self.changes_made.append(str(file_path.relative_to(self.project_root)))
            print("  ✓ Updated milestone status and singleton counts")
        else:
            print("  - No changes needed")

    def sync_developer_guides_claude_md(self):
        """Sync /docs/02-developer-guides/CLAUDE.md"""
        file_path = self.project_root / "docs" / "02-developer-guides" / "CLAUDE.md"
        print(f"\nSyncing: {file_path.relative_to(self.project_root)}")

        content = self._read_file(file_path)
        original_content = content

        # Update milestone status
        content = self._update_milestone_status(content)

        # Update singleton counts
        content = self._update_singletons_count(content)

        # Update progress percentage
        milestone = self.state['milestone']
        pattern = r'Milestone 1 \(\d+% complete\)'
        replacement = f"Milestone 1 ({milestone['progress']}% complete)"
        content = re.sub(pattern, replacement, content)

        # Update EventBus signal count
        content = re.sub(r'\b50\+ signals\b', '55+ signals', content)

        if content != original_content:
            self._write_file(file_path, content)
            self.changes_made.append(str(file_path.relative_to(self.project_root)))
            print("  ✓ Updated milestone status and singleton counts")
        else:
            print("  - No changes needed")

    def sync_architecture_claude_md(self):
        """Sync /docs/02-developer-guides/architecture/CLAUDE.md"""
        file_path = self.project_root / "docs" / "02-developer-guides" / "architecture" / "CLAUDE.md"
        print(f"\nSyncing: {file_path.relative_to(self.project_root)}")

        content = self._read_file(file_path)
        original_content = content

        # Update singleton counts
        content = self._update_singletons_count(content)

        # Update EventBus signal count
        content = re.sub(r'\b50\+ signals\b', '55+ signals', content)

        if content != original_content:
            self._write_file(file_path, content)
            self.changes_made.append(str(file_path.relative_to(self.project_root)))
            print("  ✓ Updated singleton counts")
        else:
            print("  - No changes needed")

    def sync_project_management_claude_md(self):
        """Sync /docs/02-developer-guides/project-management/CLAUDE.md"""
        file_path = self.project_root / "docs" / "02-developer-guides" / "project-management" / "CLAUDE.md"
        print(f"\nSyncing: {file_path.relative_to(self.project_root)}")

        content = self._read_file(file_path)
        original_content = content

        # Update milestone status
        content = self._update_milestone_status(content)

        # Update singleton counts
        content = self._update_singletons_count(content)

        if content != original_content:
            self._write_file(file_path, content)
            self.changes_made.append(str(file_path.relative_to(self.project_root)))
            print("  ✓ Updated milestone status and singleton counts")
        else:
            print("  - No changes needed")

    def sync_game_design_claude_md(self):
        """Sync /docs/03-game-design/CLAUDE.md"""
        file_path = self.project_root / "docs" / "03-game-design" / "CLAUDE.md"
        print(f"\nSyncing: {file_path.relative_to(self.project_root)}")

        content = self._read_file(file_path)
        original_content = content

        # Update milestone status
        content = self._update_milestone_status(content)

        # Update progress percentage
        milestone = self.state['milestone']
        pattern = r'Milestone 1 \(\d+% complete\)'
        replacement = f"Milestone 1 ({milestone['progress']}% complete)"
        content = re.sub(pattern, replacement, content)

        if content != original_content:
            self._write_file(file_path, content)
            self.changes_made.append(str(file_path.relative_to(self.project_root)))
            print("  ✓ Updated milestone status")
        else:
            print("  - No changes needed")

    def sync_future_features_claude_md(self):
        """Sync /docs/03-game-design/future-features/CLAUDE.md"""
        file_path = self.project_root / "docs" / "03-game-design" / "future-features" / "CLAUDE.md"
        print(f"\nSyncing: {file_path.relative_to(self.project_root)}")

        content = self._read_file(file_path)
        original_content = content

        # Update milestone status
        content = self._update_milestone_status(content)

        if content != original_content:
            self._write_file(file_path, content)
            self.changes_made.append(str(file_path.relative_to(self.project_root)))
            print("  ✓ Updated milestone status")
        else:
            print("  - No changes needed")

    def sync_all(self):
        """Sync all CLAUDE.md files"""
        print("=" * 70)
        print("CLAUDE.md Sync Script")
        print("=" * 70)
        print(f"\nProject: {self.project_root}")
        print(f"State: {self.state_file.name}")
        print(f"\nCurrent State:")
        print(f"  Milestone: {self.state['milestone']['current']} - {self.state['milestone']['name']}")
        print(f"  Progress: {self.state['milestone']['progress']}%")
        print(f"  Status: {self.state['milestone']['status']}")
        print(f"  Singletons: {self.state['singletons']['count']}")
        print(f"  Advanced Systems: {len(self.state['advanced_systems'])}")

        # Sync all files
        self.sync_root_claude_md()
        self.sync_docs_claude_md()
        self.sync_developer_guides_claude_md()
        self.sync_architecture_claude_md()
        self.sync_project_management_claude_md()
        self.sync_game_design_claude_md()
        self.sync_future_features_claude_md()

        # Summary
        print("\n" + "=" * 70)
        print("SUMMARY")
        print("=" * 70)

        if self.changes_made:
            print(f"\n✓ Updated {len(self.changes_made)} file(s):")
            for file in self.changes_made:
                print(f"  - {file}")
            print("\nNext steps:")
            print("  1. Review changes: git diff CLAUDE.md docs/*/CLAUDE.md")
            print(f"  2. Commit: git commit -m \"docs: Sync CLAUDE.md (M{self.state['milestone']['current']} at {self.state['milestone']['progress']}%)\"")
        else:
            print("\n✓ All CLAUDE.md files are already up to date!")

        print("\n" + "=" * 70)


def main():
    """Main entry point"""
    # Find project root (where PROJECT-STATE.json is)
    current_dir = Path(__file__).parent.parent  # scripts/ → project root

    try:
        syncer = ClaudeMdSyncer(current_dir)
        syncer.sync_all()
        return 0
    except FileNotFoundError as e:
        print(f"Error: {e}")
        return 1
    except Exception as e:
        print(f"Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        return 1


if __name__ == "__main__":
    exit(main())
