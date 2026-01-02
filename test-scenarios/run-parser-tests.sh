#!/bin/bash
#
# BYOI Builder - Parser Test Suite
# =================================
# Tests the Packer file parser without running actual builds.
#
# Usage:
#   ./run-parser-tests.sh [test-number]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=================================================="
echo "       BYOI Builder - Parser Test Suite           "
echo "=================================================="
echo ""

# Create test generator
cat > "$REPO_DIR/cmd_test_generator.go" << 'GOEOF'
//go:build ignore

package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/harness/byoi-builder/internal/packer"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run cmd_test_generator.go <packer-file>")
		os.Exit(1)
	}

	inputFile := os.Args[1]
	if !filepath.IsAbs(inputFile) {
		wd, _ := os.Getwd()
		inputFile = filepath.Join(wd, inputFile)
	}

	outputDir := filepath.Dir(inputFile)
	outputFile := filepath.Join(outputDir, ".harness-generated-packer.pkr.hcl")

	config := packer.GeneratorConfig{
		InputFile:   inputFile,
		OutputFile:  outputFile,
		ImageName:   "test-account-my-image-v1",
		ProjectID:   "harness-byoi-test",
		Zone:        "us-central1-a",
		TargetOS:    "linux",
		TargetArch:  "amd64",
		BaseOS:      "ubuntu",
		BaseVersion: "22.04",
	}

	generator := packer.NewGenerator(config)
	result, err := generator.Generate()
	if err != nil {
		fmt.Printf("ERROR: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Generated: %s\n", result)

	data, _ := os.ReadFile(result)
	content := string(data)

	fmt.Println("\n=== Validation ===")

	checks := []struct {
		name    string
		pattern string
	}{
		{"Harness source block", `source "googlecompute" "harness-byoi"`},
		{"Image name variable", `variable "image_name"`},
		{"Project ID variable", `variable "project_id"`},
		{"Zone variable", `variable "zone"`},
		{"GCP access token variable", `variable "gcp_access_token"`},
		{"Access token sensitive", `sensitive = true`},
		{"Pre-install provisioner", `Harness BYOI: Pre-install`},
		{"Cleanup provisioner", `Harness BYOI: Cleanup`},
	}

	allPassed := true
	for _, check := range checks {
		if strings.Contains(content, check.pattern) {
			fmt.Printf("  ✅ %s\n", check.name)
		} else {
			fmt.Printf("  ❌ %s\n", check.name)
			allPassed = false
		}
	}

	os.Remove(result)

	if !allPassed {
		os.Exit(1)
	}
	fmt.Println("\n=== Test Passed ===")
}
GOEOF

run_test() {
    local test_dir="$1"
    local test_name=$(basename "$test_dir")
    local packer_file="$test_dir/packer.pkr.hcl"
    
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Test: ${test_name}${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ ! -f "$packer_file" ]; then
        echo -e "${RED}  ❌ Packer file not found${NC}"
        return 1
    fi
    
    echo "Input: $packer_file"
    echo ""
    
    cd "$REPO_DIR"
    if go run cmd_test_generator.go "$packer_file"; then
        echo -e "${GREEN}  ✅ TEST PASSED${NC}"
        return 0
    else
        echo -e "${RED}  ❌ TEST FAILED${NC}"
        return 1
    fi
}

FAILED=0
PASSED=0

if [ -n "$1" ]; then
    test_dir="$SCRIPT_DIR/$1-"*
    if [ -d $test_dir ]; then
        if run_test $test_dir; then
            PASSED=$((PASSED + 1))
        else
            FAILED=$((FAILED + 1))
        fi
    else
        echo -e "${RED}Test not found: $1${NC}"
        exit 1
    fi
else
    for test_dir in "$SCRIPT_DIR"/[0-9][0-9]-*/; do
        if [ -d "$test_dir" ]; then
            echo ""
            if run_test "$test_dir"; then
                PASSED=$((PASSED + 1))
            else
                FAILED=$((FAILED + 1))
            fi
        fi
    done
fi

rm -f "$REPO_DIR/cmd_test_generator.go"

echo "=================================================="
echo "                    SUMMARY                       "
echo "=================================================="
echo -e "  ${GREEN}Passed: $PASSED${NC}"
echo -e "  ${RED}Failed: $FAILED${NC}"
echo "=================================================="

[ $FAILED -gt 0 ] && exit 1
echo -e "\n${GREEN}All parser tests passed!${NC}"

