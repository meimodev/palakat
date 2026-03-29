#!/usr/bin/env bash

normalize_env_name() {
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]'
}

is_supported_env_name() {
    case "$(normalize_env_name "$1")" in
        local|staging|production)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

supported_env_names_text() {
    printf 'local, staging, production'
}

env_file_has_sections() {
    local source_file="$1"
    grep -Eq '^[[:space:]]*\[[^]]+\][[:space:]]*$' "$source_file"
}

extract_env_section_to_file() {
    local source_file="$1"
    local selected_env
    selected_env="$(normalize_env_name "$2")"
    local output_file="$3"

    if [ ! -f "$source_file" ]; then
        return 1
    fi

    if ! env_file_has_sections "$source_file"; then
        if [ "$selected_env" != "local" ]; then
            return 2
        fi

        cp "$source_file" "$output_file"
        return 0
    fi

    awk -v target_env="$selected_env" '
        function trim(value) {
            sub(/^[[:space:]]+/, "", value)
            sub(/[[:space:]]+$/, "", value)
            return value
        }

        {
            line = $0
            sub(/\r$/, "", line)

            if (match(line, /^[[:space:]]*\[[^]]+\][[:space:]]*$/)) {
                saw_sections = 1
                current_section = line
                gsub(/^[[:space:]]*\[/, "", current_section)
                gsub(/\][[:space:]]*$/, "", current_section)
                current_section = tolower(trim(current_section))
                in_target_section = (current_section == target_env)
                if (in_target_section) {
                    found_target_section = 1
                }
                next
            }

            if (!saw_sections) {
                common_lines[common_count++] = line
                next
            }

            if (in_target_section) {
                selected_lines[selected_count++] = line
            }
        }

        END {
            if (!found_target_section) {
                exit 42
            }

            for (i = 0; i < common_count; i++) {
                print common_lines[i]
            }

            for (i = 0; i < selected_count; i++) {
                print selected_lines[i]
            }
        }
    ' "$source_file" > "$output_file"
    local status=$?

    if [ $status -eq 42 ]; then
        rm -f "$output_file"
        return 2
    fi

    if [ $status -ne 0 ]; then
        rm -f "$output_file"
        return 3
    fi

    return 0
}

env_file_has_key() {
    local source_file="$1"
    local key="$2"
    grep -Eq "^[[:space:]]*${key}=" "$source_file"
}

missing_env_keys_text() {
    local source_file="$1"
    shift

    local missing_keys=()
    local key
    for key in "$@"; do
        if ! env_file_has_key "$source_file" "$key"; then
            missing_keys+=("$key")
        fi
    done

    local missing_text=""
    local missing_key
    for missing_key in "${missing_keys[@]}"; do
        if [ -n "$missing_text" ]; then
            missing_text="$missing_text, "
        fi
        missing_text="$missing_text$missing_key"
    done

    printf '%s' "$missing_text"
}

create_temp_env_file() {
    local prefix="$1"
    local temp_dir="${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"

    if [ ! -d "$temp_dir" ]; then
        temp_dir="/tmp"
    fi

    mktemp "${temp_dir%/}/${prefix}.XXXXXX.env"
}
