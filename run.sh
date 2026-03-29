#!/bin/bash

# Interactive script runner for Palakat monorepo
# Lists all available scripts and lets you choose which one to run
# Or run directly with: ./run.sh <script-name>

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts"
ENV_UTILS="$SCRIPTS_DIR/env_utils.sh"

if [ -f "$ENV_UTILS" ]; then
    # shellcheck disable=SC1090
    source "$ENV_UTILS"
fi

is_env_aware_script() {
    case "$1" in
        backend|android|admin|super_admin)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Get all .sh files
scripts=()
script_names=()
while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    if [[ "$filename" == "env_utils.sh" ]]; then
        continue
    fi
    scripts+=("$filename")
    # Store name without .sh extension for matching
    script_names+=("${filename%.sh}")
done < <(find "$SCRIPTS_DIR" -maxdepth 1 -name "*.sh" -print0 | sort -z)

if [[ ${#scripts[@]} -eq 0 ]]; then
    echo "No scripts found in $SCRIPTS_DIR"
    exit 1
fi

OVERRIDE_IP=""
NEW_ARGS=()
while [[ $# -gt 0 ]]; do
    if [[ "$1" == "--ip" ]]; then
        if [[ -z "$2" ]]; then
            echo "❌ Missing value for --ip"
            exit 1
        fi
        OVERRIDE_IP="$2"
        shift 2
    else
        NEW_ARGS+=("$1")
        shift
    fi
done
set -- "${NEW_ARGS[@]}"

show_help() {
    echo "Usage: $0 [SCRIPT_NAME] [ENVIRONMENT] [SCRIPT_OPTIONS...]"
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
    echo "  $0 backend            # Run backend.sh with local env"
    echo "  $0 backend staging    # Run backend.sh with staging env"
    echo "  $0 admin production --device chrome"
    echo "  $0 android staging"
    echo "  $0 super_admin --release"
    echo ""
    echo "Environment-aware scripts default to 'local' when ENVIRONMENT is omitted."
    echo "Supported environments: local, staging, production"
    echo ""
    echo "Options:"
    echo "  --ip IP_ADDRESS       Override API_BASE_URL with the provided IP for local/staging"
    echo "  -h, --help            Show this help message"
    echo "  -l, --list            List available scripts"
}

get_app_env_file() {
    case "$1" in
        android) echo "apps/palakat/.env" ;;
        admin) echo "apps/palakat_admin/.env" ;;
        super_admin) echo "apps/palakat_super_admin/.env" ;;
        *) echo "" ;;
    esac
}

run_with_env_override() {
    local script_name="$1"
    shift
    local cmd=("$@")
    
    local env_file=""
    local full_env_file=""
    local backup_file=""
    
    if [[ -n "$OVERRIDE_IP" ]]; then
        env_file="$(get_app_env_file "$script_name")"
        if [[ -n "$env_file" ]]; then
            full_env_file="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$env_file"
            if [[ -f "$full_env_file" ]]; then
                backup_file="${full_env_file}.bak"
                cp "$full_env_file" "$backup_file"
                
                awk -v ip="$OVERRIDE_IP" '
                    /^[[:space:]]*\[.*\]/ {
                        section = $0;
                        gsub(/^[[:space:]]*\[|\][[:space:]]*$/, "", section);
                        section = tolower(section);
                    }
                    (section == "local" || section == "staging") && /^[[:space:]]*API_BASE_URL[[:space:]]*=/ {
                        sub(/=.*/, "=http://" ip)
                    }
                    { print }
                ' "$backup_file" > "$full_env_file"
                
                # Restore trap
                trap 'if [[ -f "$backup_file" ]]; then mv "$backup_file" "$full_env_file"; fi' EXIT INT TERM
            fi
        fi
    fi
    
    "${cmd[@]}"
    local exit_code=$?
    
    if [[ -n "$backup_file" && -f "$backup_file" ]]; then
        mv "$backup_file" "$full_env_file"
        trap - EXIT INT TERM
    fi
    
    exit $exit_code
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
        selected_script_name="${matched%.sh}"
        selected_env=""

        if is_env_aware_script "$selected_script_name"; then
            if [[ -n "$1" ]] && is_supported_env_name "$1"; then
                selected_env="$(normalize_env_name "$1")"
                shift
            else
                selected_env="local"
            fi
        fi

        echo "Running: $matched"
        if [[ -n "$selected_env" ]]; then
            echo "Environment: $selected_env"
        fi
        echo "────────────────────────────────────────"

        command=(bash "$SCRIPTS_DIR/$matched")
        if [[ -n "$selected_env" ]]; then
            command+=(--env "$selected_env")
        fi
        command+=("$@")

        run_with_env_override "$selected_script_name" "${command[@]}"
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
selected_script_name="${selected%.sh}"
selected_env=""

if is_env_aware_script "$selected_script_name"; then
    echo ""
    read -p "Environment [local/staging/production] (default: local): " env_choice
    env_choice="${env_choice:-local}"
    env_choice="$(normalize_env_name "$env_choice")"

    if ! is_supported_env_name "$env_choice"; then
        echo "Invalid environment. Supported values: local, staging, production."
        exit 1
    fi

    selected_env="$env_choice"
fi

echo ""
echo "Running: $selected"
if [[ -n "$selected_env" ]]; then
    echo "Environment: $selected_env"
fi
echo "────────────────────────────────────────"

# Execute the selected script
command=(bash "$SCRIPTS_DIR/$selected")
if [[ -n "$selected_env" ]]; then
    command+=(--env "$selected_env")
fi

run_with_env_override "$selected_script_name" "${command[@]}"
