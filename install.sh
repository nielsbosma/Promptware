#!/bin/zsh
# Install Promptware skills into Claude Code
skills_dir="$HOME/.claude/skills"
source_dir="$(dirname "$0")/skills/promptware"
target_dir="$skills_dir/promptware"

if [[ -e "$target_dir" ]]; then
    echo "Promptware skill already installed at $target_dir"
    echo "To reinstall, remove it first: rm '$target_dir'"
    exit 0
fi

mkdir -p "$skills_dir"
ln -s "$(realpath "$source_dir")" "$target_dir"
echo "Installed! Use /promptware in Claude Code to scaffold a new module."
