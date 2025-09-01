#!/usr/bin/env bash

# Comprehensive test script for whk - Webhook Manager
# Tests: 50+ automated tests covering all functionality

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# Test data directory
TEST_DIR="/tmp/whk_test_$$"
WHK_DIR="${TEST_DIR}/.whk"
WEBHOOKS_FILE="${WHK_DIR}/webhooks"
LOG_FILE="${WHK_DIR}/logs/whk.log"

# Function to run before each test
setup_test() {
    # Remove any existing test directory
    rm -rf "${TEST_DIR}"
    # Create test directory structure
    mkdir -p "${WHK_DIR}/logs"
    touch "${WEBHOOKS_FILE}"
    touch "${LOG_FILE}"
    
    # Set environment variable to use test directory
    export HOME="${TEST_DIR}"
}

# Function to run after each test
teardown_test() {
    # Remove test directory
    rm -rf "${TEST_DIR}"
}

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_exit_code="${3:-0}"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    echo -n "Test ${TEST_COUNT}: ${test_name} ... "
    
    # Setup test environment
    setup_test
    
    # Run the test command
    eval "${test_command}" > /dev/null 2>&1
    local exit_code=$?
    
    # Teardown test environment
    teardown_test
    
    # Check result
    if [[ ${exit_code} -eq ${expected_exit_code} ]]; then
        echo -e "${GREEN}PASS${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo -e "${RED}FAIL${NC} (expected exit code ${expected_exit_code}, got ${exit_code})"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

# Function to run a test with output checking
run_test_with_output() {
    local test_name="$1"
    local test_command="$2"
    local expected_output="$3"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    echo -n "Test ${TEST_COUNT}: ${test_name} ... "
    
    # Setup test environment
    setup_test
    
    # Run the test command and capture output
    local output=$(eval "${test_command}" 2>&1)
    local exit_code=$?
    
    # Teardown test environment
    teardown_test
    
    # Check result
    if [[ ${exit_code} -eq 0 ]] && [[ "${output}" == *"${expected_output}"* ]]; then
        echo -e "${GREEN}PASS${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Expected: ${expected_output}"
        echo "  Actual: ${output}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

# Function to run a test with file content checking
run_test_with_file_content() {
    local test_name="$1"
    local test_command="$2"
    local expected_content="$3"
    local file_to_check="$4"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    echo -n "Test ${TEST_COUNT}: ${test_name} ... "
    
    # Setup test environment
    setup_test
    
    # Run the test command
    eval "${test_command}" > /dev/null 2>&1
    local exit_code=$?
    
    # Check file content
    local file_content=""
    if [[ -f "${file_to_check}" ]]; then
        file_content=$(cat "${file_to_check}")
    fi
    
    # Teardown test environment
    teardown_test
    
    # Check result
    if [[ ${exit_code} -eq 0 ]] && [[ "${file_content}" == *"${expected_content}"* ]]; then
        echo -e "${GREEN}PASS${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Expected: ${expected_content}"
        echo "  Actual: ${file_content}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

# Function to run a test with log content checking
run_test_with_log_content() {
    local test_name="$1"
    local test_command="$2"
    local expected_log_content="$3"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    echo -n "Test ${TEST_COUNT}: ${test_name} ... "
    
    # Setup test environment
    setup_test
    
    # Run the test command
    eval "${test_command}" > /dev/null 2>&1
    
    # Check log content
    local log_content=""
    if [[ -f "${LOG_FILE}" ]]; then
        log_content=$(cat "${LOG_FILE}")
    fi
    
    # Teardown test environment
    teardown_test
    
    # Check result
    if [[ "${log_content}" == *"${expected_log_content}"* ]]; then
        echo -e "${GREEN}PASS${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Expected: ${expected_log_content}"
        echo "  Actual: ${log_content}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

# Function to summarize tests
summarize_tests() {
    echo
    echo "===================="
    echo "Test Results Summary"
    echo "===================="
    echo "Total tests: ${TEST_COUNT}"
    echo -e "${GREEN}Passed: ${PASS_COUNT}${NC}"
    echo -e "${RED}Failed: ${FAIL_COUNT}${NC}"
    
    if [[ ${FAIL_COUNT} -eq 0 ]]; then
        echo
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo
        echo -e "${RED}Some tests failed!${NC}"
        exit 1
    fi
}

# ========================================
# BASIC COMMAND TESTS (1-10)
# ========================================

# Test 1: Help command
run_test_with_output "Help command" \
    "HOME='${TEST_DIR}' ${PWD}/bin/whk help" \
    "whk - Webhook Manager"

# Test 2: Help command with --help
run_test_with_output "Help command with --help" \
    "HOME='${TEST_DIR}' ${PWD}/bin/whk --help" \
    "whk - Webhook Manager"

# Test 3: Help command with -h
run_test_with_output "Help command with -h" \
    "HOME='${TEST_DIR}' ${PWD}/bin/whk -h" \
    "whk - Webhook Manager"

# Test 4: Help command with no arguments
run_test_with_output "Help command with no arguments" \
    "HOME='${TEST_DIR}' ${PWD}/bin/whk" \
    "whk - Webhook Manager"

# Test 5: Invalid command
run_test "Invalid command" \
    "HOME='${TEST_DIR}' ${PWD}/bin/whk invalid_command" 1

# Test 6: List webhooks (empty)
run_test_with_output "List webhooks (empty)" \
    "HOME='${TEST_DIR}' ${PWD}/bin/whk list" \
    "No webhooks found"

# Test 7: List webhooks (with data)
run_test "List webhooks (with data)" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://example.com/webhook' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk list > /dev/null"

# Test 8: List webhooks shows correct data
run_test_with_output "List webhooks shows correct data" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://example.com/webhook' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk list" \
    "Name: test_webhook"

# Test 9: List webhooks shows multiple webhooks
run_test_with_output "List webhooks shows multiple webhooks" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo -e 'webhook1|https://example.com/webhook1
webhook2|https://example.com/webhook2' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk list" \
    "Name: webhook1"

# Test 10: List webhooks shows headers
run_test_with_output "List webhooks shows headers" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://example.com/webhook|Authorization: Bearer token' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk list" \
    "Headers: Authorization: Bearer token"

# ========================================
# CREATE WEBHOOK TESTS (11-20)
# ========================================

# Test 11: Create webhook with valid data
run_test_with_file_content "Create webhook with valid data" \
    "HOME='${TEST_DIR}' echo -e 'test_webhook
https://example.com/webhook
' | ${PWD}/bin/whk create" \
    "test_webhook|https://example.com/webhook" \
    "${WEBHOOKS_FILE}"

# Test 12: Create webhook logs action
run_test_with_log_content "Create webhook logs action" \
    "HOME='${TEST_DIR}' echo -e 'test_webhook
https://example.com/webhook
' | ${PWD}/bin/whk create" \
    "CREATE: Webhook 'test_webhook' created"

# Test 13: Create webhook with headers
run_test_with_file_content "Create webhook with headers" \
    "HOME='${TEST_DIR}' echo -e 'test_webhook
https://example.com/webhook
Authorization: Bearer token' | ${PWD}/bin/whk create" \
    "test_webhook|https://example.com/webhook|Authorization: Bearer token" \
    "${WEBHOOKS_FILE}"

# Test 14: Create webhook with no headers
run_test_with_file_content "Create webhook with no headers" \
    "HOME='${TEST_DIR}' echo -e 'test_webhook
https://example.com/webhook
' | ${PWD}/bin/whk create" \
    "test_webhook|https://example.com/webhook" \
    "${WEBHOOKS_FILE}"

# Test 15: Create webhook with empty name fails
run_test "Create webhook with empty name fails" \
    "HOME='${TEST_DIR}' echo -e '
https://example.com/webhook
' | ${PWD}/bin/whk create" 1

# Test 16: Create webhook with empty URL fails
run_test "Create webhook with empty URL fails" \
    "HOME='${TEST_DIR}' echo -e 'test_webhook

' | ${PWD}/bin/whk create" 1

# Test 17: Create webhook with invalid URL fails
run_test "Create webhook with invalid URL fails" \
    "HOME='${TEST_DIR}' echo -e 'test_webhook
invalid-url
' | ${PWD}/bin/whk create" 1

# Test 18: Create webhook with http URL succeeds
run_test_with_file_content "Create webhook with http URL succeeds" \
    "HOME='${TEST_DIR}' echo -e 'test_webhook
http://example.com/webhook
' | ${PWD}/bin/whk create" \
    "test_webhook|http://example.com/webhook" \
    "${WEBHOOKS_FILE}"

# Test 19: Create duplicate webhook fails
run_test "Create duplicate webhook fails" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://example.com/webhook' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e 'test_webhook
https://example.com/webhook2
' | ${PWD}/bin/whk create" 1

# Test 20: Create webhook logs error for duplicate
run_test_with_log_content "Create webhook logs error for duplicate" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://example.com/webhook' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e 'test_webhook
https://example.com/webhook2
' | ${PWD}/bin/whk create" \
    "CREATE_ERROR: Webhook 'test_webhook' already exists"

# ========================================
# DELETE WEBHOOK TESTS (21-30)
# ========================================

# Test 21: Delete non-existent webhook
run_test "Delete non-existent webhook" \
    "mkdir -p \"${WHK_DIR}/logs\" && touch \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e 'non_existent
n' | ${PWD}/bin/whk delete > /dev/null 2>&1" 1

# Test 22: Delete non-existent webhook logs error
run_test_with_log_content "Delete non-existent webhook logs error" \
    "mkdir -p \"${WHK_DIR}/logs\" && touch \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e 'non_existent
n' | ${PWD}/bin/whk delete > /dev/null 2>&1" \
    "DELETE_ERROR: Webhook 'non_existent' not found"

# Test 23: Delete webhook with 'n' confirmation
run_test_with_file_content "Delete webhook with 'n' confirmation" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://example.com/webhook' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e 'test_webhook
n' | ${PWD}/bin/whk delete > /dev/null 2>&1" \
    "test_webhook|https://example.com/webhook" \
    "${WEBHOOKS_FILE}"

# Test 24: Delete webhook with 'n' confirmation logs cancellation
run_test_with_log_content "Delete webhook with 'n' confirmation logs cancellation" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://example.com/webhook' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e 'test_webhook
n' | ${PWD}/bin/whk delete > /dev/null 2>&1" \
    "DELETE_CANCELLED: Deletion of 'test_webhook' cancelled"

# Test 25: Delete webhook with 'y' confirmation
run_test_with_file_content "Delete webhook with 'y' confirmation" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://example.com/webhook' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e 'test_webhook
y' | ${PWD}/bin/whk delete > /dev/null 2>&1" \
    "" \
    "${WEBHOOKS_FILE}"

# Test 26: Delete webhook with 'y' confirmation logs deletion
run_test_with_log_content "Delete webhook with 'y' confirmation logs deletion" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://example.com/webhook' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e 'test_webhook
y' | ${PWD}/bin/whk delete > /dev/null 2>&1" \
    "DELETE: Webhook 'test_webhook' deleted"

# Test 27: Delete webhook with uppercase 'Y' confirmation
run_test_with_file_content "Delete webhook with uppercase 'Y' confirmation" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://example.com/webhook' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e 'test_webhook
Y' | ${PWD}/bin/whk delete > /dev/null 2>&1" \
    "" \
    "${WEBHOOKS_FILE}"

# Test 28: Delete webhook with empty name fails
run_test "Delete webhook with empty name fails" \
    "mkdir -p \"${WHK_DIR}/logs\" && touch \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e '
n' | ${PWD}/bin/whk delete > /dev/null 2>&1" 1

# Test 29: Delete webhook logs error for empty name
run_test_with_log_content "Delete webhook logs error for empty name" \
    "mkdir -p \"${WHK_DIR}/logs\" && touch \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e '
n' | ${PWD}/bin/whk delete > /dev/null 2>&1" \
    "DELETE_ERROR: Empty webhook name"

# Test 30: Delete multiple webhooks (first one)
run_test_with_file_content "Delete multiple webhooks (first one)" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo -e 'webhook1|https://example.com/webhook1
webhook2|https://example.com/webhook2' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e 'webhook1
y' | ${PWD}/bin/whk delete > /dev/null 2>&1" \
    "webhook2|https://example.com/webhook2" \
    "${WEBHOOKS_FILE}"

# ========================================
# TRIGGER WEBHOOK TESTS (31-40)
# ========================================

# Test 31: Trigger non-existent webhook
run_test "Trigger non-existent webhook" \
    "mkdir -p \"${WHK_DIR}/logs\" && touch \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk trigger non_existent > /dev/null 2>&1" 1

# Test 32: Trigger non-existent webhook logs error
run_test_with_log_content "Trigger non-existent webhook logs error" \
    "mkdir -p \"${WHK_DIR}/logs\" && touch \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk trigger non_existent > /dev/null 2>&1" \
    "TRIGGER_ERROR: Webhook 'non_existent' not found"

# Test 33: Trigger webhook by name\nrun_test \"Trigger webhook by name\" \\\n    \"mkdir -p \\\"${WHK_DIR}/logs\\\" && echo 'test_webhook|https://example.com/webhook' > \\\"${WEBHOOKS_FILE}\\\" && HOME=\\\"${TEST_DIR}\\\" PATH=\\\"${PWD}/tests/mock_bin:/usr/local/bin:/usr/bin:/bin\\\" ${PWD}/bin/whk trigger test_webhook >/dev/null 2>&1\"

# Test 34: Trigger webhook with payload\nrun_test \"Trigger webhook with payload\" \n    \"mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://example.com/webhook' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" PATH=\"${PWD}/tests/mock_bin:/usr/local/bin:/usr/bin:/bin\" ${PWD}/bin/whk trigger test_webhook '{\"key\":\"value\"}' >/dev/null 2>&1; exit_code=\\\$?; [ \\\$exit_code -eq 0 ] || exit \\\$exit_code"

# Test 35: Trigger webhook logs action
run_test_with_log_content "Trigger webhook logs action" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://example.com/webhook' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" PATH=\"${PWD}/tests/mock_bin:/usr/local/bin:/usr/bin:/bin\" ${PWD}/bin/whk trigger test_webhook >/dev/null 2>&1 || true" \
    "TRIGGER: Webhook 'test_webhook' triggered"

# Test 36: Trigger webhook with headers
run_test "Trigger webhook with headers" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://example.com/webhook|Authorization: Bearer token' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" PATH=\"${PWD}/tests/mock_bin:/usr/local/bin:/usr/bin:/bin\" ${PWD}/bin/whk trigger test_webhook >/dev/null 2>&1"

# Test 37: Trigger webhook with headers and payload
run_test "Trigger webhook with headers and payload" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://example.com/webhook|Authorization: Bearer token' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" PATH=\"${PWD}/tests/mock_bin:/usr/local/bin:/usr/bin:/bin\" ${PWD}/bin/whk trigger test_webhook '{\"key\":\"value\"}' >/dev/null 2>&1"

# Test 38: Trigger webhook with multiple headers
run_test "Trigger webhook with multiple headers" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://example.com/webhook|Authorization: Bearer token,Content-Type: application/json' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" PATH=\"${PWD}/tests/mock_bin:/usr/local/bin:/usr/bin:/bin\" ${PWD}/bin/whk trigger test_webhook >/dev/null 2>&1; exit_code=$?; [ $exit_code -eq 0 ] || exit $exit_code"

# Test 39: Trigger first of multiple webhooks\nrun_test \"Trigger first of multiple webhooks\" \\\n    \"mkdir -p \\\"${WHK_DIR}/logs\\\" && echo -e 'webhook1|https://example.com/webhook1\\nwebhook2|https://example.com/webhook2' > \\\"${WEBHOOKS_FILE}\\\" && HOME=\\\"${TEST_DIR}\\\" PATH=\\\"${PWD}/tests/mock_bin:/usr/local/bin:/usr/bin:/bin\\\" ${PWD}/bin/whk trigger webhook1 >/dev/null 2>&1; exit_code=\\\$?; [ \\\$exit_code -eq 0 ] || exit \\\$exit_code\"

# Test 40: Trigger second of multiple webhooks
run_test "Trigger second of multiple webhooks" 
    "mkdir -p "${WHK_DIR}/logs" && echo -e 'webhook1|https://example.com/webhook1
webhook2|https://example.com/webhook2' > "${WEBHOOKS_FILE}" && HOME="${TEST_DIR}" PATH="${PWD}/tests/mock_bin:/usr/local/bin:/usr/bin:/bin" ${PWD}/bin/whk trigger webhook2 >/dev/null 2>&1; exit_code=\$?; [ \$exit_code -eq 0 ] || exit \$exit_code"

# ========================================
# DRY RUN WEBHOOK TESTS (41-45)
# ========================================

# Test 41: Dry-run non-existent webhook
run_test "Dry-run non-existent webhook" \
    "mkdir -p \"${WHK_DIR}/logs\" && touch \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk dry-run non_existent > /dev/null 2>&1" 1

# Test 42: Dry-run non-existent webhook logs error
run_test_with_log_content "Dry-run non-existent webhook logs error" \
    "mkdir -p \"${WHK_DIR}/logs\" && touch \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk dry-run non_existent > /dev/null 2>&1" \
    "DRY_RUN_ERROR: Webhook 'non_existent' not found"

# Test 43: Dry-run webhook by name\nrun_test_with_output \"Dry-run webhook by name\" \\\n    \"mkdir -p \\\"${WHK_DIR}/logs\\\" && echo 'test_webhook|https://example.com/webhook' > \\\"${WEBHOOKS_FILE}\\\" && HOME=\\\"${TEST_DIR}\\\" ${PWD}/bin/whk dry-run test_webhook\" \\\n    \"Dry run for webhook 'test_webhook'\"

# Test 44: Dry-run webhook logs action
run_test_with_log_content "Dry-run webhook logs action" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://example.com/webhook' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk dry-run test_webhook >/dev/null 2>&1 || true" \
    "DRY_RUN: Webhook 'test_webhook' dry run"

# Test 45: Dry-run webhook with payload\nrun_test_with_output \"Dry-run webhook with payload\" \\\n    \"mkdir -p \\\"${WHK_DIR}/logs\\\" && echo 'test_webhook|https://example.com/webhook' > \\\"${WEBHOOKS_FILE}\\\" && HOME=\\\"${TEST_DIR}\\\" ${PWD}/bin/whk dry-run test_webhook '{\\\"key\\\":\\\"value\\\"}'\" \\\n    \"Dry run for webhook 'test_webhook'\"

# ========================================
# SCHEDULE WEBHOOK TESTS (46-50)
# ========================================

# Test 46: Schedule non-existent webhook
run_test "Schedule non-existent webhook" \
    "mkdir -p \"${WHK_DIR}/logs\" && touch \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e 'non_existent
* * * * *
' | ${PWD}/bin/whk schedule > /dev/null 2>&1" 1

# Test 47: Schedule non-existent webhook logs error
run_test_with_log_content "Schedule non-existent webhook logs error" \
    "mkdir -p \"${WHK_DIR}/logs\" && touch \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e 'non_existent
* * * * *
' | ${PWD}/bin/whk schedule > /dev/null 2>&1" \
    "SCHEDULE_ERROR: Webhook 'non_existent' not found"

# Test 48: Schedule webhook with valid cron
run_test "Schedule webhook with valid cron" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://httpbin.org/post' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e 'test_webhook
* * * * *
' | ${PWD}/bin/whk schedule > /dev/null 2>&1"

# Test 49: Schedule webhook logs action
run_test_with_log_content "Schedule webhook logs action" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://httpbin.org/post' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e 'test_webhook
* * * * *
' | ${PWD}/bin/whk schedule > /dev/null 2>&1" \
    "SCHEDULE: Webhook 'test_webhook' scheduled"

# Test 50: Schedule webhook with empty cron fails
run_test "Schedule webhook with empty cron fails" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://httpbin.org/post' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e 'test_webhook

' | ${PWD}/bin/whk schedule > /dev/null 2>&1" 1

# ========================================
# URL VALIDATION TESTS (51-55)
# ========================================

# Test 51: Valid https URL
run_test_with_file_content "Valid https URL" \
    "HOME='${TEST_DIR}' echo -e 'test_webhook
https://example.com
' | ${PWD}/bin/whk create" \
    "test_webhook|https://example.com" \
    "${WEBHOOKS_FILE}"

# Test 52: Valid http URL
run_test_with_file_content "Valid http URL" \
    "HOME='${TEST_DIR}' echo -e 'test_webhook
http://example.com
' | ${PWD}/bin/whk create" \
    "test_webhook|http://example.com" \
    "${WEBHOOKS_FILE}"

# Test 53: Invalid URL without protocol
run_test "Invalid URL without protocol" \
    "HOME='${TEST_DIR}' echo -e 'test_webhook
example.com
' | ${PWD}/bin/whk create" 1

# Test 54: Invalid URL without domain
run_test "Invalid URL without domain" \
    "HOME='${TEST_DIR}' echo -e 'test_webhook
https://
' | ${PWD}/bin/whk create" 1

# Test 55: Invalid URL with spaces
run_test "Invalid URL with spaces" \
    "HOME='${TEST_DIR}' echo -e 'test_webhook
https:// example.com
' | ${PWD}/bin/whk create" 1

# ========================================
# INITIALIZATION TESTS (56-60)
# ========================================

# Test 56: Initialization creates .whk directory
run_test "Initialization creates .whk directory" \
    "rm -rf \"${TEST_DIR}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk list > /dev/null && test -d \"${WHK_DIR}\""

# Test 57: Initialization creates webhooks file
run_test "Initialization creates webhooks file" \
    "rm -rf \"${TEST_DIR}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk list > /dev/null && test -f \"${WEBHOOKS_FILE}\""

# Test 58: Initialization creates logs directory
run_test "Initialization creates logs directory" \
    "rm -rf \"${TEST_DIR}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk list > /dev/null && test -d \"${WHK_DIR}/logs\""

# Test 59: Initialization creates log file
run_test "Initialization creates log file" \
    "rm -rf \"${TEST_DIR}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk list > /dev/null && test -f \"${LOG_FILE}\""

# Test 60: Initialization logs action
run_test_with_log_content "Initialization logs action" \
    "rm -rf \"${TEST_DIR}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk list > /dev/null" \
    "INIT: Created data directory"

# Show summary
summarize_tests