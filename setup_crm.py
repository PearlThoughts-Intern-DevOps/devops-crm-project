#!/usr/bin/env python3
"""
setup_crm.py

Automates the local setup and startup of the devops-crm-project
(a Twenty CRM app built with Yarn 4 + the Twenty SDK).

Replicates, in order, the manual steps documented in SETUP.md:
    1. yarn install
    2. yarn twenty docker:start   (starts the local Twenty server)
    3. yarn twenty dev            (starts the dev server / syncs the app)
    4. open http://localhost:2020

Written in plain Python (no shell scripts), with tool checks, version
reporting, directory verification, port checking, and error handling
throughout. No user-specific paths are hard-coded — the script resolves
its own directory at runtime.

Usage:
    python setup_crm.py
Run this from the root of the cloned devops-crm-project repository.
"""

import json
import platform
import shutil
import socket
import subprocess
import sys
from pathlib import Path

IS_WINDOWS = platform.system() == "Windows"
PROJECT_ROOT = Path(__file__).resolve().parent
REQUIRED_NODE_VERSION = "24.5.0"   # from .nvmrc
APP_PORT = 2020                    # Twenty dev server port per SETUP.md


# ---------------------------------------------------------------------------
# Pretty printing
# ---------------------------------------------------------------------------
class C:
    RESET = "\033[0m"
    GREEN = "\033[1;32m"
    RED = "\033[1;31m"
    YELLOW = "\033[1;33m"
    BLUE = "\033[1;34m"


def info(msg):    print(f"{C.BLUE}[INFO]{C.RESET}  {msg}")
def success(msg): print(f"{C.GREEN}[ OK ]{C.RESET}  {msg}")
def warn(msg):    print(f"{C.YELLOW}[WARN]{C.RESET}  {msg}")
def error(msg):   print(f"{C.RED}[FAIL]{C.RESET}  {msg}")


def fail_and_exit(msg, code=1):
    error(msg)
    sys.exit(code)


def step(msg):
    print()
    print(f"{C.BLUE}==>{C.RESET} {msg}")


def run(cmd, cwd=None, check=True):
    """Run a command, streaming its output, raising/exiting on failure."""
    info("Running: " + " ".join(cmd))
    result = subprocess.run(cmd, cwd=cwd or PROJECT_ROOT, shell=IS_WINDOWS)
    if check and result.returncode != 0:
        fail_and_exit(f"Command failed ({' '.join(cmd)}) — exit code {result.returncode}")
    return result


def tool_exists(name):
    return shutil.which(name) is not None


def tool_version(cmd_list):
    try:
        result = subprocess.run(cmd_list, capture_output=True, text=True, shell=IS_WINDOWS)
        out = (result.stdout or result.stderr).strip()
        return out.splitlines()[0] if out else "unknown"
    except Exception:
        return "unknown"


def is_port_in_use(port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(1)
        return s.connect_ex(("localhost", port)) == 0


# ---------------------------------------------------------------------------
# 1. Check required tools
# ---------------------------------------------------------------------------
def check_tools():
    step("Checking required tools")

    checks = {
        "node": ["node", "--version"],
        "yarn": ["yarn", "--version"],
        "docker": ["docker", "--version"],
    }

    missing = []
    for tool, cmd in checks.items():
        if tool_exists(tool):
            success(f"{tool} found — {tool_version(cmd)}")
        else:
            error(f"{tool} is NOT installed or not on PATH")
            missing.append(tool)

    if missing:
        fail_and_exit(
            f"Missing required tool(s): {', '.join(missing)}. "
            "Install them and re-run this script.\n"
            "  - Node.js: https://nodejs.org (use the version in .nvmrc)\n"
            "  - Yarn 4:  corepack enable && corepack prepare yarn@4.13.0 --activate\n"
            "  - Docker:  https://www.docker.com/products/docker-desktop"
        )

    node_version = tool_version(["node", "--version"]).lstrip("v")
    if node_version != REQUIRED_NODE_VERSION:
        warn(
            f"Installed Node.js is {node_version}, but .nvmrc specifies "
            f"{REQUIRED_NODE_VERSION}. This may still work, but if you hit odd "
            f"errors, install the exact version (e.g. via nvm: nvm install {REQUIRED_NODE_VERSION})."
        )


# ---------------------------------------------------------------------------
# 2. Verify we're in the correct project directory
# ---------------------------------------------------------------------------
def verify_project_dir():
    step(f"Verifying project directory: {PROJECT_ROOT}")

    package_json = PROJECT_ROOT / "package.json"
    if not package_json.exists():
        fail_and_exit(f"package.json not found in {PROJECT_ROOT}. Place this script in the repo root and re-run.")

    try:
        data = json.loads(package_json.read_text())
    except Exception as e:
        fail_and_exit(f"Could not parse package.json: {e}")

    dev_deps = data.get("devDependencies", {})
    if not any("twenty" in name for name in dev_deps):
        warn("package.json doesn't look like the Twenty CRM app (no 'twenty-*' dependencies found). Continuing anyway.")
    else:
        success("Confirmed: this is the Twenty CRM app project directory.")

    if not (PROJECT_ROOT / "SETUP.md").exists():
        warn("SETUP.md not found — continuing, but double-check you're in the right folder.")


# ---------------------------------------------------------------------------
# 3. Install dependencies
# ---------------------------------------------------------------------------
def install_dependencies():
    step("Installing dependencies (yarn install)")
    run(["yarn", "install"])
    success("Dependencies installed successfully.")


# ---------------------------------------------------------------------------
# 4. Start the local Twenty server (Docker)
# ---------------------------------------------------------------------------
def start_twenty_docker_server():
    step("Starting local Twenty server (yarn twenty docker:start)")

    if not tool_exists("docker"):
        fail_and_exit("Docker is required to run the local Twenty server, but was not found.")

    run(["yarn", "twenty", "docker:start"])
    success("Local Twenty server started.")

    step("Checking Twenty server status")
    run(["yarn", "twenty", "docker:status"], check=False)


# ---------------------------------------------------------------------------
# 5. Check the app port before starting the dev server
# ---------------------------------------------------------------------------
def check_port():
    step(f"Checking port {APP_PORT}")
    if is_port_in_use(APP_PORT):
        warn(f"Port {APP_PORT} is already in use. The dev server may fail to bind, "
             f"or may already be running from a previous session.")
    else:
        success(f"Port {APP_PORT} is free.")


# ---------------------------------------------------------------------------
# 6. Start the dev server
# ---------------------------------------------------------------------------
def start_dev_server():
    step("Starting the development server (yarn twenty dev)")
    info("This runs in the foreground and syncs your app. Press Ctrl+C to stop.")
    print()
    success(f"Once started, open: http://localhost:{APP_PORT}")
    print(f"  Default dev credentials: tim@apple.dev / tim@apple.dev")
    print()

    # Foreground process — this call blocks until the user stops it.
    run(["yarn", "twenty", "dev"], check=False)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    print("=" * 70)
    print(" Twenty CRM App (devops-crm-project) — Automated Local Setup ")
    print("=" * 70)

    check_tools()
    verify_project_dir()
    install_dependencies()
    start_twenty_docker_server()
    check_port()
    start_dev_server()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print()
        warn("Interrupted by user. Exiting.")
        sys.exit(130)
