# Test 01: Minimal - Only Harness default provisioners
# This tests that an empty file still produces a valid image

# No variables, no provisioners
# Harness will add:
# 1. Pre-install (apt-get update, install basics)
# 2. Cleanup (apt-get clean, clear logs)

