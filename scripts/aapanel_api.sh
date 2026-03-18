#!/bin/bash
# aaPanel API Client
# Usage: bash aapanel_api.sh <category> <action> [params_json]
#
# Categories: system, files, site, database, ftp, firewall, crontab, plugin, ssl, nodejs, python, proxy, config, logs, safe
#
# Examples:
#   bash aapanel_api.sh system GetSystemTotal
#   bash aapanel_api.sh files GetDir '{"path":"/www/wwwroot"}'
#   bash aapanel_api.sh database AddDatabase '{"name":"mydb","db_user":"myuser","password":"pass123","codeing":"utf8mb4","address":"127.0.0.1","dtype":"MySQL","ps":"My DB"}'

set -euo pipefail

# --- Configuration ---
AAPANEL_URL="${AAPANEL_URL:-https://168.231.92.99:17198}"
AAPANEL_API_KEY="${AAPANEL_API_KEY:-b4uzdFJT7wJSqGnemqa1vRKhyrIKYeDp}"

# --- Auth signature ---
generate_auth() {
    local timestamp
    timestamp=$(date +%s)
    local key_md5
    key_md5=$(echo -n "$AAPANEL_API_KEY" | md5sum | awk '{print $1}' 2>/dev/null || echo -n "$AAPANEL_API_KEY" | md5 -q 2>/dev/null)
    local token
    token=$(echo -n "${timestamp}${key_md5}" | md5sum | awk '{print $1}' 2>/dev/null || echo -n "${timestamp}${key_md5}" | md5 -q 2>/dev/null)
    echo "request_time=${timestamp}&request_token=${token}"
}

# --- Build endpoint URL ---
build_url() {
    local category="$1"
    local action="$2"

    case "$category" in
        system)
            echo "${AAPANEL_URL}/system?action=${action}" ;;
        ajax)
            echo "${AAPANEL_URL}/ajax?action=${action}" ;;
        site)
            echo "${AAPANEL_URL}/site?action=${action}" ;;
        files)
            echo "${AAPANEL_URL}/files?action=${action}" ;;
        database)
            echo "${AAPANEL_URL}/database?action=${action}" ;;
        ftp)
            echo "${AAPANEL_URL}/ftp?action=${action}" ;;
        firewall)
            echo "${AAPANEL_URL}/firewall?action=${action}" ;;
        crontab)
            echo "${AAPANEL_URL}/crontab?action=${action}" ;;
        plugin)
            echo "${AAPANEL_URL}/plugin?action=${action}" ;;
        ssl|acme)
            echo "${AAPANEL_URL}/acme?action=${action}" ;;
        config)
            echo "${AAPANEL_URL}/config?action=${action}" ;;
        data)
            echo "${AAPANEL_URL}/data?action=${action}" ;;
        nodejs)
            echo "${AAPANEL_URL}/project/nodejs/${action}/1" ;;
        python)
            echo "${AAPANEL_URL}/project/python/${action}/1" ;;
        proxy)
            echo "${AAPANEL_URL}/project/proxy/${action}/1" ;;
        safe)
            echo "${AAPANEL_URL}/safe/firewall/${action}" ;;
        safe_ssh)
            echo "${AAPANEL_URL}/safe/ssh/${action}" ;;
        logs)
            echo "${AAPANEL_URL}/logs/panel/${action}" ;;
        server)
            echo "${AAPANEL_URL}/server?action=${action}" ;;
        *)
            echo "ERROR: Unknown category: $category" >&2
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
    # Convert JSON to key=value pairs using python (available on most systems)
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

# --- Main ---
main() {
    if [ $# -lt 2 ]; then
        echo "Usage: bash $0 <category> <action> [params_json]"
        echo ""
        echo "Categories: system, ajax, site, files, database, ftp, firewall, crontab,"
        echo "            plugin, ssl, config, data, nodejs, python, proxy, safe, safe_ssh,"
        echo "            logs, server"
        echo ""
        echo "Examples:"
        echo "  bash $0 system GetSystemTotal"
        echo "  bash $0 files GetDir '{\"path\":\"/www/wwwroot\"}'"
        echo "  bash $0 nodejs get_project_list"
        echo "  bash $0 firewall AddAcceptPort '{\"port\":\"3000\",\"type\":\"tcp\",\"ps\":\"React\"}'"
        exit 1
    fi

    local category="$1"
    local action="$2"
    local params="${3:-}"

    local url
    url=$(build_url "$category" "$action")

    local auth
    auth=$(generate_auth)

    local form_data="$auth"
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
