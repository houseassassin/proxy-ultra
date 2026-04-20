#!/usr/bin/env bats
# File: tests/core.bats
# Runs with: bats tests/core.bats

setup() {
    export PXU_INSTALL_DIR="$BATS_TEST_DIRNAME/.."
    export PXU_STATE_FILE="${BATS_TMPDIR}/pxu_test_state"
    touch "$PXU_STATE_FILE"
}

teardown() {
    rm -f "$PXU_STATE_FILE"
}

@test "Crypto library generates 16 char string" {
    source "${PXU_INSTALL_DIR}/lib/lib_crypto.sh"
    result=$(lib_crypto_generate_string 16)
    [ "${#result}" -eq 16 ]
}

@test "Crypto library generates custom length string" {
    source "${PXU_INSTALL_DIR}/lib/lib_crypto.sh"
    result=$(lib_crypto_generate_string 32)
    [ "${#result}" -eq 32 ]
}

@test "Logger successfully renders INFO output" {
    source "${PXU_INSTALL_DIR}/core/02-logger.sh"
    run pxu_logger_info "Automated Test Message"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Automated Test Message"* ]]
    [[ "$output" == *"[INFO]"* ]]
}
