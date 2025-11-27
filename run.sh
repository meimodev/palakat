#!/bin/bash

# Interactive script runner for Palakat monorepo
# Lists all available scripts and lets you choose which one to run

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts"

# Get all .sh files
scripts=()
while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    scripts+=("$filename")
done < <(find "$SCRIPTS_DIR" -maxdepth 1 -name "*.sh" -print0 | sort -z)

if [[ ${#scripts[@]} -eq 0 ]]; then
    echo "No scripts found in $SCRIPTS_DIR"
    exit 1
fi

echo "╔════════════════════════════════════════╗"
echo "║     Palakat Script Runner              ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Available scripts:"
echo ""

for i in "${!scripts[@]}"; do
    printf "  %2d) %s\n" $((i + 1)) "${scripts[$i]}"
done

echo ""
echo "   0) Exit"
echo ""

read -p "Enter your choice [0-${#scripts[@]}]: " choice

# Validate input
if [[ ! "$choice" =~ ^[0-9]+$ ]]; then
    echo "Invalid input. Please enter a number."
    exit 1
fi

if [[ "$choice" -eq 0 ]]; then
    echo "Exiting..."
    exit 0
fi

if [[ "$choice" -lt 1 || "$choice" -gt ${#scripts[@]} ]]; then
    echo "Invalid choice. Please select a number between 0 and ${#scripts[@]}."
    exit 1
fi

selected="${scripts[$((choice - 1))]}"
echo ""
echo "Running: $selected"
echo "────────────────────────────────────────"

# Execute the selected script
"$SCRIPTS_DIR/$selected" "$@"
