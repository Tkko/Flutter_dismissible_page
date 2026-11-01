#!/usr/bin/env bash

# Flutter Integration Performance Profiling Script
# macOS Desktop: Profiles native rendering performance with TimelineSummary
# Web (Chrome):  Runs E2E performance scenarios on Chrome Web Server

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXAMPLE_DIR="$PROJECT_ROOT/example"
TEST_TARGET="integration_test/dismissible_perf_test.dart"
DRIVER="test_driver/perf_driver.dart"

export PATH="$HOME/bin:$PATH"

echo -e "${BLUE}================================================================${NC}"
echo -e "${BOLD}${BLUE}   Dismissible Page - E2E Performance Benchmarking              ${NC}"
echo -e "${BLUE}================================================================${NC}\n"

cd "$EXAMPLE_DIR"

# 1. macOS Desktop Benchmark
run_macos() {
  echo -e "${YELLOW}▶ Running benchmark on macOS Desktop (--profile)...${NC}"
  flutter drive \
    --driver="$DRIVER" \
    --target="$TEST_TARGET" \
    -d macos \
    --profile
  echo -e "${GREEN}✓ macOS Desktop benchmark completed!${NC}\n"
}

# 2. Chrome Web Benchmark
run_web() {
  local HEADLESS_FLAG="--headless"
  if [ "$GUI_MODE" = "true" ]; then
    HEADLESS_FLAG="--no-headless"
    echo -e "${YELLOW}▶ Running benchmark on Chrome Web (--profile, GUI mode)...${NC}"
  else
    echo -e "${YELLOW}▶ Running benchmark on Chrome Web (--profile, headless)...${NC}"
  fi

  if ! command -v chromedriver &> /dev/null; then
    echo -e "${YELLOW}chromedriver not found. Fetching ChromeDriver for macOS ARM64...${NC}"
    mkdir -p "$HOME/bin"
    curl -sSL "https://storage.googleapis.com/chrome-for-testing-public/156.0.8078.80/mac-arm64/chromedriver-mac-arm64.zip" -o /tmp/cd.zip
    unzip -q -o /tmp/cd.zip -d /tmp
    mv -f /tmp/chromedriver-mac-arm64/chromedriver "$HOME/bin/chromedriver"
    rm -rf /tmp/cd.zip /tmp/chromedriver-mac-arm64
    chmod +x "$HOME/bin/chromedriver"
    xattr -d com.apple.quarantine "$HOME/bin/chromedriver" 2>/dev/null || true
  fi

  # Start ChromeDriver in background on port 4444
  chromedriver --port=4444 &
  CHROMEDRIVER_PID=$!

  cleanup() {
    kill "$CHROMEDRIVER_PID" 2>/dev/null || true
  }
  trap cleanup EXIT

  sleep 1

  flutter drive \
    --driver="$DRIVER" \
    --target="$TEST_TARGET" \
    -d web-server \
    --browser-name=chrome \
    $HEADLESS_FLAG \
    --profile

  cleanup
  trap - EXIT
  echo -e "${GREEN}✓ Chrome Web benchmark completed!${NC}\n"
}

# 3. iOS Benchmark
run_ios() {
  echo -e "${YELLOW}▶ Running on iOS Simulator...${NC}"
  UDID=$(xcrun simctl list devices available 'iPhone' 2>/dev/null | grep -m 1 -E 'iPhone [0-9]+' | awk -F '[()]' '{print $2}' || true)
  if [ -z "$UDID" ]; then
    echo -e "${RED}No available iPhone simulator found.${NC}"
    exit 1
  fi
  flutter drive \
    --driver="$DRIVER" \
    --target="$TEST_TARGET" \
    -d "$UDID"
  echo -e "${GREEN}✓ iOS test completed!${NC}\n"
}

TARGET="--macos"
GUI_MODE="false"

for arg in "$@"; do
  case "$arg" in
    --web|--chrome|--ios|--macos|--all)
      TARGET="$arg"
      ;;
    --gui|--no-headless)
      GUI_MODE="true"
      ;;
    --headless)
      GUI_MODE="false"
      ;;
  esac
done

case "$TARGET" in
  --web|--chrome)
    run_web
    ;;
  --ios)
    run_ios
    ;;
  --all)
    run_macos
    run_web
    ;;
  --macos|*)
    run_macos
    ;;
esac

echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}   Benchmark run completed! Results saved to example/build/     ${NC}"
echo -e "${GREEN}================================================================${NC}"
