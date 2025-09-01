#!/usr/bin/env bash

# Utility functions for whk - Webhook Manager

# Data directory
WHK_DIR="${HOME}/.whk"
WEBHOOKS_FILE="${WHK_DIR}/webhooks"
LOG_FILE="${WHK_DIR}/logs/whk.log"

# Initialize data directory
init_data_dir() {
    # Create .whk directory if it doesn't exist
    if [[ ! -d "${WHK_DIR}" ]]; then
        mkdir -p "${WHK_DIR}/logs"
        touch "${WEBHOOKS_FILE}"
        log_action "INIT" "Created data directory"
    fi
    
    # Create logs directory if it doesn't exist
    if [[ ! -d "${WHK_DIR}/logs" ]]; then
        mkdir -p "${WHK_DIR}/logs"
        log_action "INIT" "Created logs directory"
    fi
    
    # Create webhooks file if it doesn't exist
    if [[ ! -f "${WEBHOOKS_FILE}" ]]; then
        touch "${WEBHOOKS_FILE}"
        log_action "INIT" "Created webhooks file"
    fi
    
    # Create log file if it doesn't exist
    if [[ ! -f "${LOG_FILE}" ]]; then
        touch "${LOG_FILE}"
        log_action "INIT" "Created log file"
    fi
}

# Log actions with timestamp
log_action() {
    local action="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] ${action}: ${message}" >> "${LOG_FILE}"
}

# Validate URL
validate_url() {
    local url="$1"
    if [[ $url =~ ^https?://[a-zA-Z0-9._-]+\.[a-zA-Z]{2,} ]]; then
        return 0
    else
        return 1
    fi
}

# Create a new webhook
create_webhook() {
    echo "Creating a new webhook..."
    
    # Get webhook name
    read -p "Enter webhook name: " name
    if [[ -z "${name}" ]]; then
        echo "Error: Webhook name cannot be empty"
        log_action "CREATE_ERROR" "Empty webhook name"
        return 1
    fi
    
    # Check if webhook already exists
    if grep -q "^${name}|" "${WEBHOOKS_FILE}"; then
        echo "Error: Webhook '${name}' already exists"
        log_action "CREATE_ERROR" "Webhook '${name}' already exists"
        return 1
    fi
    
    # Get webhook URL
    read -p "Enter webhook URL: " url
    if ! validate_url "${url}"; then
        echo "Error: Invalid URL format"
        log_action "CREATE_ERROR" "Invalid URL format for '${name}'"
        return 1
    fi
    
    # Get optional headers
    read -p "Enter headers (optional, format: 'Key: Value', press Enter to skip): " headers
    
    # Save webhook
    if [[ -n "${headers}" ]]; then
        echo "${name}|${url}|${headers}" >> "${WEBHOOKS_FILE}"
    else
        echo "${name}|${url}" >> "${WEBHOOKS_FILE}"
    fi
    
    echo "Webhook '${name}' created successfully"
    log_action "CREATE" "Webhook '${name}' created"
}

# List all webhooks
list_webhooks() {
    if [[ ! -s "${WEBHOOKS_FILE}" ]]; then
        echo "No webhooks found"
        log_action "LIST" "No webhooks found"
        return 0
    fi
    
    echo "Webhooks:"
    echo "---------"
    while IFS='|' read -r name url headers; do
        echo "Name: ${name}"
        echo "URL:  ${url}"
        if [[ -n "${headers}" ]]; then
            echo "Headers: ${headers}"
        fi
        echo "---------"
    done < "${WEBHOOKS_FILE}"
    
    log_action "LIST" "Listed webhooks"
}

# Delete a webhook
delete_webhook() {
    echo "Deleting a webhook..."
    
    # Get webhook name
    read -p "Enter webhook name to delete: " name
    if [[ -z "${name}" ]]; then
        echo "Error: Webhook name cannot be empty"
        log_action "DELETE_ERROR" "Empty webhook name"
        return 1
    fi
    
    # Check if webhook exists
    if ! grep -q "^${name}|" "${WEBHOOKS_FILE}"; then
        echo "Error: Webhook '${name}' not found"
        log_action "DELETE_ERROR" "Webhook '${name}' not found"
        return 1
    fi
    
    # Confirm deletion
    read -p "Are you sure you want to delete '${name}'? (y/N): " confirm
    if [[ ! "${confirm}" =~ ^[Yy]$ ]]; then
        echo "Deletion cancelled"
        log_action "DELETE_CANCELLED" "Deletion of '${name}' cancelled"
        return 0
    fi
    
    # Delete webhook
    grep -v "^${name}|" "${WEBHOOKS_FILE}" > "${WEBHOOKS_FILE}.tmp" && mv "${WEBHOOKS_FILE}.tmp" "${WEBHOOKS_FILE}"
    
    echo "Webhook '${name}' deleted successfully"
    log_action "DELETE" "Webhook '${name}' deleted"
}

# Trigger a webhook
trigger_webhook() {
    local name="$1"
    local payload="$2"
    
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
    eval "${curl_cmd}"
    
    echo ""
    echo "Webhook '${name}' triggered successfully"
    log_action "TRIGGER" "Webhook '${name}' triggered"
}

# Dry run a webhook (simulate without sending request)
dry_run_webhook() {
    local name="$1"
    local payload="$2"
    
    if [[ -z "${name}" ]]; then
        echo "Dry running a webhook..."
        read -p "Enter webhook name: " name
    fi
    
    # Check if webhook exists
    local webhook_line=$(grep "^${name}|" "${WEBHOOKS_FILE}")
    if [[ -z "${webhook_line}" ]]; then
        echo "Error: Webhook '${name}' not found"
        log_action "DRY_RUN_ERROR" "Webhook '${name}' not found"
        return 1
    fi
    
    # Parse webhook data
    IFS='|' read -r webhook_name url headers <<< "${webhook_line}"
    
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
    
    # Show what would be executed
    echo "Dry run for webhook '${name}':"
    echo "Command that would be executed: ${curl_cmd}"
    echo ""
    echo "No actual request was sent."
    
    log_action "DRY_RUN" "Webhook '${name}' dry run"
}

# Schedule a webhook trigger
schedule_webhook() {
    echo "Scheduling a webhook trigger..."
    
    # Get webhook name
    read -p "Enter webhook name: " name
    if [[ -z "${name}" ]]; then
        echo "Error: Webhook name cannot be empty"
        log_action "SCHEDULE_ERROR" "Empty webhook name"
        return 1
    fi
    
    # Check if webhook exists
    if ! grep -q "^${name}|" "${WEBHOOKS_FILE}"; then
        echo "Error: Webhook '${name}' not found"
        log_action "SCHEDULE_ERROR" "Webhook '${name}' not found"
        return 1
    fi
    
    # Get schedule time (cron format)
    echo "Enter schedule in cron format (minute hour day month weekday):"
    echo "Examples:"
    echo "  '* * * * *'       - Every minute"
    echo "  '0 * * * *'       - Every hour"
    echo "  '0 9 * * 1-5'     - Every weekday at 9 AM"
    echo "  '0 0 1 * *'       - First day of every month at midnight"
    read -p "Cron schedule: " cron_schedule
    
    # Validate cron format (basic validation)
    if [[ -z "${cron_schedule}" ]]; then
        echo "Error: Cron schedule cannot be empty"
        log_action "SCHEDULE_ERROR" "Empty cron schedule for '${name}'"
        return 1
    fi
    
    # Get payload
    read -p "Enter JSON payload (optional, press Enter to skip): " payload
    
    # Create a temporary script for the cron job
    local script_path="${WHK_DIR}/scheduled_${name}.sh"
    cat > "${script_path}" <<EOF
#!/usr/bin/env bash
# Scheduled webhook trigger for '${name}'

# Source utility functions
source "${SCRIPT_DIR}/../lib/utils.sh"

# Trigger the webhook
# Note: This is a simplified version that doesn't require user input
$(declare -f trigger_webhook)
trigger_webhook "${name}" '${payload}'
EOF
    
    # Make the script executable
    chmod +x "${script_path}"
    
    # Add to crontab
    # Note: This is a simplified approach. In a real implementation, you might want
    # to manage scheduled jobs in a separate file and have a daemon check them.
    local cron_entry="${cron_schedule} ${script_path}"
    (crontab -l 2>/dev/null; echo "${cron_entry}") | crontab -
    
    echo "Webhook '${name}' scheduled successfully"
    echo "Cron entry: ${cron_entry}"
    log_action "SCHEDULE" "Webhook '${name}' scheduled with cron '${cron_schedule}'"
}

# Show help page
show_help() {
    echo "whk - Webhook Manager"
    echo "===================="
    echo ""
    echo "A professional Linux CLI tool for managing webhooks"
    echo ""
    echo "Commands:"
    echo "  create     Create a new webhook"
    echo "  list       List all saved webhooks"
    echo "  delete     Delete a webhook by name"
    echo "  trigger    Trigger a webhook (with optional payload)"
    echo "  schedule   Schedule a webhook trigger using cron"
    echo "  dry-run    Simulate a trigger without sending requests"
    echo "  help       Display this help page"
    echo ""
    echo "Examples:"
    echo "  whk create              # Create a new webhook (interactive)"
    echo "  whk list                # List all webhooks"
    echo "  whk delete              # Delete a webhook (interactive)"
    echo "  whk trigger NAME        # Trigger a webhook by name"
    echo "  whk trigger NAME '{}'   # Trigger with JSON payload"
    echo "  whk schedule            # Schedule a webhook (interactive)"
    echo "  whk dry-run NAME        # Dry run a webhook by name"
    echo ""
    echo "Data is stored in ~/.whk/"
    echo "Logs are stored in ~/.whk/logs/whk.log"
}