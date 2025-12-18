#!/bin/bash

# Interactive script runner for Palakat monorepo
# Lists all available scripts and lets you choose which one to run
# Or run directly with: ./run.sh <script-name>

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts"

# Get all .sh files
scripts=()
script_names=()
while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    scripts+=("$filename")
    # Store name without .sh extension for matching
    script_names+=("${filename%.sh}")
done < <(find "$SCRIPTS_DIR" -maxdepth 1 -name "*.sh" -print0 | sort -z)

if [[ ${#scripts[@]} -eq 0 ]]; then
    echo "No scripts found in $SCRIPTS_DIR"
    exit 1
fi

show_help() {
    echo "Usage: $0 [SCRIPT_NAME] [SCRIPT_OPTIONS...]"
    echo ""
    echo "Run without arguments for interactive mode, or specify a script directly."
    echo ""
    echo "Available scripts:"
    for name in "${script_names[@]}"; do
        echo "  - $name"
    done
    echo ""
    echo "Examples:"
    echo "  $0                    # Interactive mode"
    echo "  $0 backend            # Run backend.sh directly"
    echo "  $0 admin --device chrome"
    echo "  $0 android"
    echo "  $0 super_admin --release"
    echo ""
    echo "Options:"
    echo "  -h, --help            Show this help message"
    echo "  -l, --list            List available scripts"
}

# Handle help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Handle list flag
if [[ "$1" == "-l" || "$1" == "--list" ]]; then
    echo "Available scripts:"
    for name in "${script_names[@]}"; do
        echo "  - $name"
    done
    exit 0
fi

# If argument provided, try to match and run directly
if [[ -n "$1" ]]; then
    target="$1"
    shift  # Remove script name from arguments, keep the rest for passing through
    
    # Try exact match first (with or without .sh)
    matched=""
    for i in "${!scripts[@]}"; do
        if [[ "${script_names[$i]}" == "$target" || "${scripts[$i]}" == "$target" ]]; then
            matched="${scripts[$i]}"
            break
        fi
    done
    
    # If no exact match, try partial match
    if [[ -z "$matched" ]]; then
        matches=()
        for i in "${!scripts[@]}"; do
            if [[ "${script_names[$i]}" == *"$target"* ]]; then
                matches+=("${scripts[$i]}")
            fi
        done
        
        if [[ ${#matches[@]} -eq 1 ]]; then
            matched="${matches[0]}"
        elif [[ ${#matches[@]} -gt 1 ]]; then
            echo "Multiple matches found for '$target':"
            for m in "${matches[@]}"; do
                echo "  - ${m%.sh}"
            done
            echo ""
            echo "Please be more specific."
            exit 1
        fi
    fi
    
    if [[ -n "$matched" ]]; then
        echo "Running: $matched"
        echo "────────────────────────────────────────"
        exec bash "$SCRIPTS_DIR/$matched" "$@"
    else
        echo "Script not found: $target"
        echo ""
        echo "Available scripts:"
        for name in "${script_names[@]}"; do
            echo "  - $name"
        done
        exit 1
    fi
fi

# Interactive mode
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
echo "Tip: Run './run.sh <name>' to skip this menu (e.g., ./run.sh backend)"
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
exec bash "$SCRIPTS_DIR/$selected"
