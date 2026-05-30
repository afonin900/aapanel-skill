#!/bin/bash
# aaPanel API Client
# Usage: aapanel [--server <name>] <category> <action> [params_json]
#        aapanel servers list|add|remove|default
#
# Config file: ~/.aapanel/servers.conf
# Format (space/tab delimited, # comments):
#   # name  url  api_key  [default]
#   hetzner  https://159.69.216.152:17198  myapikey123  default
#   prod     https://10.0.0.1:17198        otherapikey
#
# Categories: system, files, site, database, ftp, firewall, crontab, plugin, ssl, nodejs, python, proxy, config, logs, safe

set -euo pipefail

SERVERS_CONF="${HOME}/.aapanel/servers.conf"

# --- Config file helpers ---

# Load server entry by name. Prints: url api_key is_default
# If name is empty, returns the default (or first) server.
load_server() {
    local target_name="$1"

    if [ ! -f "$SERVERS_CONF" ]; then
        echo "Error: Config file not found: $SERVERS_CONF" >&2
        echo "Add a server with: aapanel servers add <name> <url> <api_key> [default]" >&2
        exit 1
    fi

    local first_name="" first_url="" first_key=""
    local found_name="" found_url="" found_key=""
    local default_name="" default_url="" default_key=""

    while IFS= read -r line || [ -n "$line" ]; do
        # Strip leading whitespace, skip blank lines and comments
        line="${line#"${line%%[![:space:]]*}"}"
        [ -z "$line" ] && continue
        [[ "$line" == \#* ]] && continue

        # Parse fields (space or tab separated)
        read -r name url key rest <<< "$line"
        [ -z "$name" ] || [ -z "$url" ] || [ -z "$key" ] && continue

        # Track first entry as fallback
        if [ -z "$first_name" ]; then
            first_name="$name"
            first_url="$url"
            first_key="$key"
        fi

        # Track default entry
        if [ "$rest" = "default" ]; then
            default_name="$name"
            default_url="$url"
            default_key="$key"
        fi

        # Track target entry if name was specified
        if [ -n "$target_name" ] && [ "$name" = "$target_name" ]; then
            found_name="$name"
            found_url="$url"
            found_key="$key"
        fi
    done < "$SERVERS_CONF"

    if [ -n "$target_name" ]; then
        if [ -z "$found_name" ]; then
            echo "Error: Server '$target_name' not found in $SERVERS_CONF" >&2
            exit 1
        fi
        echo "$found_url $found_key"
        return
    fi

    # No target specified — prefer default, fall back to first
    if [ -n "$default_name" ]; then
        echo "$default_url $default_key"
    elif [ -n "$first_name" ]; then
        echo "$first_url $first_key"
    else
        echo "Error: No servers configured in $SERVERS_CONF" >&2
        echo "Add a server with: aapanel servers add <name> <url> <api_key> [default]" >&2
        exit 1
    fi
}

# --- Auth signature ---
generate_auth() {
    local api_key="$1"
    local timestamp
    timestamp=$(date +%s)
    local key_md5
    key_md5=$(echo -n "$api_key" | md5sum | awk '{print $1}' 2>/dev/null \
        || echo -n "$api_key" | md5 -q 2>/dev/null)
    local token
    token=$(echo -n "${timestamp}${key_md5}" | md5sum | awk '{print $1}' 2>/dev/null \
        || echo -n "${timestamp}${key_md5}" | md5 -q 2>/dev/null)
    echo "request_time=${timestamp}&request_token=${token}"
}

# --- Build endpoint URL ---
# Categories using /v2/<category> API (action passed in POST body, not URL)
is_v2_category() {
    case "$1" in
        crontab) return 0 ;;
        *) return 1 ;;
    esac
}

build_url() {
    local base_url="$1"
    local category="$2"
    local action="$3"

    case "$category" in
        system)   echo "${base_url}/system?action=${action}" ;;
        ajax)     echo "${base_url}/ajax?action=${action}" ;;
        site)     echo "${base_url}/site?action=${action}" ;;
        files)    echo "${base_url}/files?action=${action}" ;;
        database) echo "${base_url}/database?action=${action}" ;;
        ftp)      echo "${base_url}/ftp?action=${action}" ;;
        firewall) echo "${base_url}/firewall?action=${action}" ;;
        crontab)  echo "${base_url}/v2/crontab" ;;
        plugin)   echo "${base_url}/plugin?action=${action}" ;;
        ssl|acme) echo "${base_url}/acme?action=${action}" ;;
        config)   echo "${base_url}/config?action=${action}" ;;
        data)     echo "${base_url}/data?action=${action}" ;;
        nodejs)   echo "${base_url}/project/nodejs/${action}/1" ;;
        python)   echo "${base_url}/project/python/${action}/1" ;;
        proxy)    echo "${base_url}/project/proxy/${action}/1" ;;
        safe)     echo "${base_url}/safe/firewall/${action}" ;;
        safe_ssh) echo "${base_url}/safe/ssh/${action}" ;;
        logs)     echo "${base_url}/logs/panel/${action}" ;;
        server)   echo "${base_url}/server?action=${action}" ;;
        *)
            echo "Error: Unknown category: $category" >&2
            exit 1 ;;
    esac
}

# --- Parse JSON params to form data ---
json_to_form() {
    local json="$1"
    if [ -z "$json" ] || [ "$json" = "{}" ]; then
        echo ""
        return
    fi
    python3 -c "
import json, sys, urllib.parse
data = json.loads(sys.argv[1])
pairs = []
for k, v in data.items():
    if isinstance(v, (list, dict)):
        pairs.append(f'{k}={urllib.parse.quote(json.dumps(v))}')
    elif isinstance(v, bool):
        pairs.append(f'{k}={str(v).lower()}')
    else:
        pairs.append(f'{k}={urllib.parse.quote(str(v))}')
print('&'.join(pairs))
" "$json" 2>/dev/null || echo ""
}

# --- Servers subcommands ---
cmd_servers() {
    local subcmd="${1:-}"
    shift || true

    case "$subcmd" in
        list)
            if [ ! -f "$SERVERS_CONF" ]; then
                echo "No servers configured. Use: aapanel servers add <name> <url> <api_key> [default]"
                exit 0
            fi
            local has_any=0
            while IFS= read -r line || [ -n "$line" ]; do
                line="${line#"${line%%[![:space:]]*}"}"
                [ -z "$line" ] && continue
                [[ "$line" == \#* ]] && continue
                read -r name url key rest <<< "$line"
                [ -z "$name" ] || [ -z "$url" ] || [ -z "$key" ] && continue
                has_any=1
                if [ "$rest" = "default" ]; then
                    printf "* %-20s %s\n" "$name" "$url"
                else
                    printf "  %-20s %s\n" "$name" "$url"
                fi
            done < "$SERVERS_CONF"
            if [ "$has_any" -eq 0 ]; then
                echo "No servers configured. Use: aapanel servers add <name> <url> <api_key> [default]"
            fi
            ;;

        add)
            local name="${1:-}" url="${2:-}" key="${3:-}" mark="${4:-}"
            if [ -z "$name" ] || [ -z "$url" ] || [ -z "$key" ]; then
                echo "Usage: aapanel servers add <name> <url> <api_key> [default]" >&2
                exit 1
            fi
            mkdir -p "${HOME}/.aapanel"
            touch "$SERVERS_CONF"

            # Check for duplicate name
            if grep -qE "^[[:space:]]*${name}[[:space:]]" "$SERVERS_CONF" 2>/dev/null; then
                echo "Error: Server '$name' already exists. Remove it first with: aapanel servers remove $name" >&2
                exit 1
            fi

            # If adding as default, remove default marker from others
            if [ "$mark" = "default" ]; then
                local tmp
                tmp=$(mktemp)
                while IFS= read -r line || [ -n "$line" ]; do
                    # Strip trailing 'default' marker from existing entries
                    line="${line%% default}"
                    line="${line%%	default}"
                    printf '%s\n' "$line"
                done < "$SERVERS_CONF" > "$tmp"
                mv "$tmp" "$SERVERS_CONF"
                printf '%s\t%s\t%s\tdefault\n' "$name" "$url" "$key" >> "$SERVERS_CONF"
            else
                printf '%s\t%s\t%s\n' "$name" "$url" "$key" >> "$SERVERS_CONF"
            fi
            echo "Added server '$name' ($url)"
            ;;

        remove)
            local name="${1:-}"
            if [ -z "$name" ]; then
                echo "Usage: aapanel servers remove <name>" >&2
                exit 1
            fi
            if [ ! -f "$SERVERS_CONF" ]; then
                echo "Error: No config file found." >&2; exit 1
            fi
            local tmp
            tmp=$(mktemp)
            local removed=0
            while IFS= read -r line || [ -n "$line" ]; do
                stripped="${line#"${line%%[![:space:]]*}"}"
                if [ -z "$stripped" ] || [[ "$stripped" == \#* ]]; then
                    printf '%s\n' "$line" >> "$tmp"
                    continue
                fi
                read -r n _ <<< "$stripped"
                if [ "$n" = "$name" ]; then
                    removed=1
                else
                    printf '%s\n' "$line" >> "$tmp"
                fi
            done < "$SERVERS_CONF"
            if [ "$removed" -eq 0 ]; then
                rm "$tmp"
                echo "Error: Server '$name' not found." >&2; exit 1
            fi
            mv "$tmp" "$SERVERS_CONF"
            echo "Removed server '$name'"
            ;;

        default)
            local name="${1:-}"
            if [ -z "$name" ]; then
                echo "Usage: aapanel servers default <name>" >&2
                exit 1
            fi
            if [ ! -f "$SERVERS_CONF" ]; then
                echo "Error: No config file found." >&2; exit 1
            fi
            local tmp
            tmp=$(mktemp)
            local found=0
            while IFS= read -r line || [ -n "$line" ]; do
                stripped="${line#"${line%%[![:space:]]*}"}"
                if [ -z "$stripped" ] || [[ "$stripped" == \#* ]]; then
                    printf '%s\n' "$line" >> "$tmp"
                    continue
                fi
                read -r n url key rest <<< "$stripped"
                if [ "$n" = "$name" ]; then
                    found=1
                    printf '%s\t%s\t%s\tdefault\n' "$n" "$url" "$key" >> "$tmp"
                else
                    # Strip any existing default marker
                    printf '%s\t%s\t%s\n' "$n" "$url" "$key" >> "$tmp"
                fi
            done < "$SERVERS_CONF"
            if [ "$found" -eq 0 ]; then
                rm "$tmp"
                echo "Error: Server '$name' not found." >&2; exit 1
            fi
            mv "$tmp" "$SERVERS_CONF"
            echo "Server '$name' is now the default"
            ;;

        *)
            echo "Usage: aapanel servers list|add|remove|default" >&2
            exit 1
            ;;
    esac
}

# --- Usage ---
usage() {
    echo "Usage: aapanel [--server <name>] <category> <action> [params_json]"
    echo "       aapanel servers list|add|remove|default"
    echo ""
    echo "Categories: system, ajax, site, files, database, ftp, firewall, crontab,"
    echo "            plugin, ssl, config, data, nodejs, python, proxy, safe, safe_ssh,"
    echo "            logs, server"
    echo ""
    echo "Config file: ~/.aapanel/servers.conf"
    echo ""
    echo "Examples:"
    echo "  aapanel system GetSystemTotal"
    echo "  aapanel --server hetzner files GetDir '{\"path\":\"/www/wwwroot\"}'"
    echo "  aapanel nodejs get_project_list"
    echo "  aapanel firewall AddAcceptPort '{\"port\":\"3000\",\"type\":\"tcp\",\"ps\":\"React\"}'"
    echo "  aapanel servers list"
    echo "  aapanel servers add hetzner https://159.69.216.152:17198 myapikey123 default"
    echo "  aapanel servers remove old-server"
    echo "  aapanel servers default hetzner"
}

# --- Main ---
main() {
    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi

    # Handle --server flag as first argument
    local server_name=""
    if [ "$1" = "--server" ]; then
        if [ $# -lt 2 ]; then
            echo "Error: --server requires a name argument" >&2
            exit 1
        fi
        server_name="$2"
        shift 2
    fi

    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi

    # Handle 'servers' subcommand
    if [ "$1" = "servers" ]; then
        shift
        cmd_servers "$@"
        return
    fi

    # Regular API call
    if [ $# -lt 2 ]; then
        usage
        exit 1
    fi

    local category="$1"
    local action="$2"
    local params="${3:-}"

    # Resolve server config
    local server_info
    server_info=$(load_server "$server_name")
    local base_url api_key
    read -r base_url api_key <<< "$server_info"

    local url
    url=$(build_url "$base_url" "$category" "$action")

    local auth
    auth=$(generate_auth "$api_key")

    local form_data="$auth"
    # v2 API endpoints receive action in POST body, not the URL
    if is_v2_category "$category"; then
        form_data="action=${action}&${form_data}"
    fi
    if [ -n "$params" ]; then
        local extra
        extra=$(json_to_form "$params")
        if [ -n "$extra" ]; then
            form_data="${form_data}&${extra}"
        fi
    fi

    # Execute request
    /usr/bin/curl -sk -X POST "$url" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "$form_data" \
        2>/dev/null

    echo ""
}

main "$@"
