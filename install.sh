#!/usr/bin/env bash
# install.sh - Install stm32-stlink skill to ~/.claude/skills/stm32-stlink/
# Creates a symlink so edits in this project directory are immediately reflected.
# Usage: bash install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="stm32-stlink"
INSTALL_BASE="$HOME/.claude/skills"
INSTALL_TARGET="$INSTALL_BASE/$SKILL_NAME"

echo "=== Installing $SKILL_NAME Claude Code skill ==="
echo ""
echo "Source : $SCRIPT_DIR"
echo "Target : $INSTALL_TARGET"
echo ""

# Ensure ~/.claude/skills/ exists
if [ ! -d "$INSTALL_BASE" ]; then
    echo "Creating $INSTALL_BASE..."
    mkdir -p "$INSTALL_BASE"
fi

# Handle existing installation
if [ -L "$INSTALL_TARGET" ]; then
    EXISTING="$(readlink "$INSTALL_TARGET")"
    if [ "$EXISTING" = "$SCRIPT_DIR" ]; then
        echo "Already installed: symlink already points to this directory."
        echo ""
        echo "Skill is up to date. No action needed."
    else
        echo "Updating existing symlink (was: $EXISTING)"
        rm "$INSTALL_TARGET"
        ln -s "$SCRIPT_DIR" "$INSTALL_TARGET"
        echo "Symlink updated: $INSTALL_TARGET -> $SCRIPT_DIR"
    fi
elif [ -e "$INSTALL_TARGET" ]; then
    echo "ERROR: $INSTALL_TARGET exists but is not a symlink." >&2
    echo "Remove it manually and re-run:" >&2
    echo "  rm -rf $INSTALL_TARGET" >&2
    exit 1
else
    # Make scripts executable
    echo "Setting script permissions..."
    chmod +x "$SCRIPT_DIR/scripts/"*.sh
    chmod +x "$SCRIPT_DIR/install.sh"

    # Create symlink
    ln -s "$SCRIPT_DIR" "$INSTALL_TARGET"
    echo "Symlink created: $INSTALL_TARGET -> $SCRIPT_DIR"
fi

# Verify SKILL.md is present at install location
if [ ! -f "$INSTALL_TARGET/SKILL.md" ]; then
    echo "ERROR: SKILL.md not found at $INSTALL_TARGET/SKILL.md" >&2
    echo "Installation may be incomplete." >&2
    exit 1
fi

echo ""
echo "=== Installation complete ==="
echo ""
echo "The '$SKILL_NAME' skill is now available in Claude Code."
echo "Invoke it with: /stm32-stlink"
echo ""
echo "Quick verification:"
echo "  ~/.claude/skills/$SKILL_NAME/scripts/check_tools.sh"
echo ""
echo "To uninstall:"
echo "  rm ~/.claude/skills/$SKILL_NAME"
