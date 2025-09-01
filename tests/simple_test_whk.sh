#!/usr/bin/env bash

# Simplified test script for whk - Webhook Manager
# Tests: Core functionality with proper mocking

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
# CORE FUNCTIONALITY TESTS
# ========================================

# Test 1: Help command
run_test_with_output "Help command" \
    "HOME='${TEST_DIR}' ${PWD}/bin/whk help" \
    "whk - Webhook Manager"

# Test 2: Create webhook with valid data
run_test_with_file_content "Create webhook with valid data" \
    "HOME='${TEST_DIR}' echo -e 'test_webhook\nhttps://example.com/webhook\n' | ${PWD}/bin/whk create" \
    "test_webhook|https://example.com/webhook" \
    "${WEBHOOKS_FILE}"

# Test 3: Create webhook logs action
run_test_with_log_content "Create webhook logs action" \
    "HOME='${TEST_DIR}' echo -e 'test_webhook\nhttps://example.com/webhook\n' | ${PWD}/bin/whk create" \
    "CREATE: Webhook 'test_webhook' created"

# Test 4: List webhooks (empty)
run_test_with_output "List webhooks (empty)" \
    "HOME='${TEST_DIR}' ${PWD}/bin/whk list" \
    "No webhooks found"

# Test 5: List webhooks (with data)
run_test "List webhooks (with data)" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://example.com/webhook' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk list > /dev/null"

# Test 6: Delete non-existent webhook
run_test "Delete non-existent webhook" \
    "mkdir -p \"${WHK_DIR}/logs\" && touch \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e 'non_existent\nn' | ${PWD}/bin/whk delete > /dev/null 2>&1" 1

# Test 7: Delete webhook with 'y' confirmation
run_test_with_file_content "Delete webhook with 'y' confirmation" \
    "mkdir -p \"${WHK_DIR}/logs\" && echo 'test_webhook|https://example.com/webhook' > \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e 'test_webhook\ny' | ${PWD}/bin/whk delete > /dev/null 2>&1" \
    "" \
    "${WEBHOOKS_FILE}"

# Test 8: Trigger non-existent webhook
run_test "Trigger non-existent webhook" \
    "mkdir -p \"${WHK_DIR}/logs\" && touch \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk trigger non_existent > /dev/null 2>&1" 1

# Test 9: Dry-run non-existent webhook
run_test "Dry-run non-existent webhook" \
    "mkdir -p \"${WHK_DIR}/logs\" && touch \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk dry-run non_existent > /dev/null 2>&1" 1

# Test 10: Schedule non-existent webhook
run_test "Schedule non-existent webhook" \
    "mkdir -p \"${WHK_DIR}/logs\" && touch \"${WEBHOOKS_FILE}\" && HOME=\"${TEST_DIR}\" echo -e 'non_existent\n* * * * *\n' | ${PWD}/bin/whk schedule > /dev/null 2>&1" 1

# Test 11: Valid https URL
run_test_with_file_content "Valid https URL" \
    "HOME='${TEST_DIR}' echo -e 'test_webhook\nhttps://example.com\n' | ${PWD}/bin/whk create" \
    "test_webhook|https://example.com" \
    "${WEBHOOKS_FILE}"

# Test 12: Valid http URL
run_test_with_file_content "Valid http URL" \
    "HOME='${TEST_DIR}' echo -e 'test_webhook\nhttp://example.com\n' | ${PWD}/bin/whk create" \
    "test_webhook|http://example.com" \
    "${WEBHOOKS_FILE}"

# Test 13: Initialization creates .whk directory
run_test "Initialization creates .whk directory" \
    "rm -rf \"${TEST_DIR}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk list > /dev/null && test -d \"${WHK_DIR}\""

# Test 14: Initialization creates webhooks file
run_test "Initialization creates webhooks file" \
    "rm -rf \"${TEST_DIR}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk list > /dev/null && test -f \"${WEBHOOKS_FILE}\""

# Test 15: Initialization creates logs directory
run_test "Initialization creates logs directory" \
    "rm -rf \"${TEST_DIR}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk list > /dev/null && test -d \"${WHK_DIR}/logs\""

# Test 16: Initialization creates log file
run_test "Initialization creates log file" \
    "rm -rf \"${TEST_DIR}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk list > /dev/null && test -f \"${LOG_FILE}\""

# Test 17: Initialization logs action
run_test_with_log_content "Initialization logs action" \
    "rm -rf \"${TEST_DIR}\" && HOME=\"${TEST_DIR}\" ${PWD}/bin/whk list > /dev/null" \
    "INIT: Created data directory"

# Show summary
summarize_tests