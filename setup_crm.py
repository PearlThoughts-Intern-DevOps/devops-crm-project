#!/usr/bin/env python3
"""
setup_crm.py

Automates the local build/run process for this Twenty CRM "App" project,
without using shell scripts.

Usage:
    python3 setup_crm.py

What it does:
    1. Verifies it is being run from the correct project directory
    2. Checks required tools are installed (node, yarn, docker, git) and
       displays their versions
    3. Verifies the Node version matches what this project requires
    4. Checks whether Docker is actually running (not just installed)
    5. Installs project dependencies (yarn install)
    6. Checks whether the Twenty CRM server is already running; if not,
       starts it (yarn twenty docker:start)
    7. Verifies the server reports a healthy status
    8. Displays the local URL and default login
    9. Starts the app dev/sync process (yarn twenty dev)

Design notes:
    - No hard-coded user-specific paths: the project directory is resolved
      from this script's own location.
    - Every external command is run through subprocess with explicit
      error handling instead of assuming success.
"""

import json
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

# ---------- simple coloured status output (falls back gracefully) ----------
class Color:
    RED = "\033[0;31m"
    GREEN = "\033[0;32m"
    YELLOW = "\033[1;33m"
    BLUE = "\033[0;34m"
    RESET = "\033[0m"


def info(msg: str) -> None:
    print(f"{Color.BLUE}[INFO]{Color.RESET} {msg}")


def ok(msg: str) -> None:
    print(f"{Color.GREEN}[OK]{Color.RESET} {msg}")


def warn(msg: str) -> None:
    print(f"{Color.YELLOW}[WARN]{Color.RESET} {msg}")


def error(msg: str) -> None:
    print(f"{Color.RED}[ERROR]{Color.RESET} {msg}")


def die(msg: str, code: int = 1) -> None:
    error(msg)
    sys.exit(code)


# ---------- helper to run a command and capture output ----------
def run(cmd: list[str], cwd: Path | None = None, timeout: int | None = None,
        check: bool = False) -> subprocess.CompletedProcess:
    """Run a command, returning the CompletedProcess. Never raises on
    non-zero exit unless check=True; callers inspect returncode themselves
    so we can print clear, specific error messages."""
    try:
        return subprocess.run(
            cmd,
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=check,
        )
    except FileNotFoundError:
        return subprocess.CompletedProcess(cmd, 127, "", f"{cmd[0]}: command not found")
    except subprocess.TimeoutExpired:
        return subprocess.CompletedProcess(cmd, 124, "", f"{' '.join(cmd)}: timed out")


def run_live(cmd: list[str], cwd: Path | None = None) -> int:
    """Run a command and stream its output live (used for long-running /
    interactive steps like docker:start and twenty dev)."""
    process = subprocess.run(cmd, cwd=cwd)
    return process.returncode


# =========================================================
# Step 1: Resolve and verify the project directory
# =========================================================
SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_DIR = SCRIPT_DIR

info("Checking project directory...")

package_json_path = PROJECT_DIR / "package.json"
if not package_json_path.exists():
    die(
        "package.json not found next to this script. "
        "Place setup_crm.py in the project root and re-run it."
    )

try:
    package_data = json.loads(package_json_path.read_text())
except json.JSONDecodeError as e:
    die(f"package.json exists but could not be parsed: {e}")

if "twenty-sdk" not in package_data.get("devDependencies", {}) and \
   "twenty-sdk" not in package_data.get("dependencies", {}):
    die("This does not look like the devops-crm-project (twenty-sdk not found in package.json).")

ok(f"Running from a valid project directory: {PROJECT_DIR}")

# =========================================================
# Step 2: Check required tools are installed + versions
# =========================================================
info("Checking required tools...")

REQUIRED_TOOLS = {
    "node": ["node", "-v"],
    "yarn": ["yarn", "-v"],
    "docker": ["docker", "--version"],
    "git": ["git", "--version"],
}

missing = []
versions = {}

for tool, version_cmd in REQUIRED_TOOLS.items():
    if shutil.which(tool) is None:
        error(f"{tool} is not installed or not on PATH")
        missing.append(tool)
        continue
    result = run(version_cmd)
    if result.returncode != 0:
        error(f"{tool} found on PATH but failed to report a version "
              f"(is another program shadowing it? try 'which -a {tool}')")
        missing.append(tool)
        continue
    version_str = result.stdout.strip()
    versions[tool] = version_str
    ok(f"{tool} found — {version_str}")

if missing:
    die(f"Missing or broken tools: {', '.join(missing)}. "
        f"Install/fix them before continuing.")

# ---- Node version sanity check against package.json's "engines" field ----
required_node = package_data.get("engines", {}).get("node", "")
node_version_match = re.search(r"(\d+)\.(\d+)\.(\d+)", versions["node"])
required_match = re.search(r"(\d+)\.(\d+)\.(\d+)", required_node)

if node_version_match and required_match:
    if node_version_match.groups() != required_match.groups():
        warn(f"Node {node_version_match.group(0)} is active, but this project "
             f"pins {required_node}. If you use nvm, run: nvm use "
             f"{required_match.group(0)}")
    else:
        ok(f"Node version matches the project's requirement ({required_node})")

ok("All required tools are present.")

# =========================================================
# Step 3: Check Docker is actually running (not just installed)
# =========================================================
info("Checking whether Docker is running...")

docker_ping = run(["docker", "ps"])
if docker_ping.returncode != 0:
    die(
        "Docker is installed but doesn't seem to be running.\n"
        "        On Windows/WSL: open Docker Desktop and make sure WSL "
        "integration is enabled for this distro, then retry."
    )
ok("Docker is running.")

# =========================================================
# Step 4: Install project dependencies
# =========================================================
info("Installing dependencies (yarn install)... this may take a few minutes.")

install_code = run_live(["yarn", "install"], cwd=PROJECT_DIR)
if install_code != 0:
    die("yarn install failed. Scroll up for the error output.")
ok("Dependencies installed.")

# =========================================================
# Step 5: Start (or confirm) the local Twenty CRM server
# =========================================================
info("Checking whether the Twenty CRM server is already running...")

status_result = run(["yarn", "twenty", "docker:status"], cwd=PROJECT_DIR, timeout=30)
already_running = status_result.returncode == 0 and "running" in status_result.stdout.lower()

if already_running:
    ok("Twenty server is already running — skipping docker:start.")
else:
    info("Starting the Twenty CRM server (yarn twenty docker:start)... "
         "first run downloads a large image and can take several minutes.")
    start_code = run_live(["yarn", "twenty", "docker:start"], cwd=PROJECT_DIR)
    if start_code != 0:
        warn("docker:start reported a non-zero exit. This can be a false "
             "alarm (a flaky first-boot health-check) — verifying with "
             "docker:status before deciding whether this is a real failure.")

# =========================================================
# Step 6: Verify the server is actually healthy (poll, don't one-shot check)
# =========================================================
info("Verifying server health (this can take a little while after a cold start)...")

MAX_HEALTH_CHECK_ATTEMPTS = 12   # 12 x 10s = up to 2 minutes
POLL_INTERVAL_SECONDS = 10

status_result = None
for attempt in range(1, MAX_HEALTH_CHECK_ATTEMPTS + 1):
    status_result = run(["yarn", "twenty", "docker:status"], cwd=PROJECT_DIR, timeout=30)
    if status_result.returncode == 0 and "healthy" in status_result.stdout.lower():
        break
    info(f"Not healthy yet (attempt {attempt}/{MAX_HEALTH_CHECK_ATTEMPTS})... "
         f"waiting {POLL_INTERVAL_SECONDS}s before rechecking.")
    time.sleep(POLL_INTERVAL_SECONDS)
else:
    error("Server did not report healthy after waiting.")
    error(f"Last docker:status output:\n{status_result.stdout}\n{status_result.stderr}")
    die("Run 'yarn twenty docker:logs' manually to inspect what went wrong.")

ok("Twenty server is running and healthy.")
print(status_result.stdout.strip())

# =========================================================
# Step 7: Display the local URL
# =========================================================
url_match = re.search(r"(https?://\S+)", status_result.stdout)
local_url = url_match.group(1) if url_match else "http://localhost:2020"
ok(f"Twenty CRM is available at: {local_url}")

# =========================================================
# Step 8: Start the app dev/sync process
# =========================================================
info("Starting app dev sync (yarn twenty dev)...")
info("If prompted to authenticate, open the printed URL in your browser "
     "and authorize IMMEDIATELY — the request times out after 120 seconds.")
info("Press Ctrl+C to stop once you've confirmed it's synced.")
print("")

try:
    run_live(["yarn", "twenty", "dev"], cwd=PROJECT_DIR)
except KeyboardInterrupt:
    info("Stopped by user.")