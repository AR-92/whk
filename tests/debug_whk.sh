#!/usr/bin/env bash

# Debug version of whk for testing
# A professional Linux CLI tool for managing webhooks

# Don't exit on error for debugging
# set -e

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../bin/utils.sh"

# Override trigger_webhook for debugging
trigger_webhook() {
    local name="$1"
    local payload="$2"
    
    echo "DEBUG: trigger_webhook called with name='$name', payload='$payload'" >&2
    
    # Simple test to see if function is called
    echo "DEBUG: Function is executing" >&2
    
    if [[ -z "${name}" ]]; then
        echo "Triggering a webhook..."
        read -p "Enter webhook name: " name
    fi
    
    # Check if webhook exists
    local webhook_line=$(grep "^${name}|" "${WEBHOOKS_FILE}")
    if [[ -z "${webhook_line}" ]]; then
        echo "Error: Webhook '${name}' not found"
        log_action "TRIGGER_ERROR" "Webhook '${name}' not found"
        return 1
    fi
    
    # Parse webhook data
    IFS='|' read -r webhook_name url headers <<< "${webhook_line}"
    
    echo "DEBUG: webhook_name='$webhook_name', url='$url', headers='$headers'" >&2
    
    # Get payload if not provided
    if [[ -z "${payload}" ]]; then
        read -p "Enter JSON payload (optional, press Enter to skip): " payload
    fi
    
    # Prepare curl command
    local curl_cmd="curl -s -X POST"
    
    # Add headers if provided
    if [[ -n "${headers}" ]]; then
        # Split headers by comma and add each one
        IFS=',' read -ra HEADER_ARRAY <<< "${headers}"
        for header in "${HEADER_ARRAY[@]}"; do
            curl_cmd+=" -H \"${header}\""
        done
    fi
    
    # Add content type header if payload is provided
    if [[ -n "${payload}" ]]; then
        curl_cmd+=" -H \"Content-Type: application/json\""
        curl_cmd+=" -d '${payload}'"
    fi
    
    curl_cmd+=" \"${url}\""
    
    # Execute curl command
    echo "Triggering webhook '${name}'..."
    echo "Command: ${curl_cmd}"
    
    # Execute the command
    echo "DEBUG: Executing command: ${curl_cmd}" >&2
    eval "${curl_cmd}"
    echo "DEBUG: Command exit code: $?" >&2
    
    echo ""
    echo "Webhook '${name}' triggered successfully"
    log_action "TRIGGER" "Webhook '${name}' triggered"
}

# Main function
main() {
    # Initialize data directory
    init_data_dir
    
    # Parse command line arguments
    case "$1" in
        create)
            create_webhook
            ;;
        list)
            list_webhooks
            ;;
        delete)
            delete_webhook
            ;;
        trigger)
            trigger_webhook "$2" "$3"
            ;;
        schedule)
            schedule_webhook
            ;;
        dry-run)
            dry_run_webhook "$2" "$3"
            ;;
        help|--help|-h)
            show_help
            ;;
        "")
            show_help
            ;;
        *)
            echo "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"