"""
setup.py - Automates local setup for devops-crm-project (Twenty CRM app)
Usage: python setup.py
"""
import subprocess
import sys
import shutil

REQUIRED_NODE_VERSION = "24.5.0"
REQUIRED_YARN_VERSION = "4.13.0"

def run(command, cwd=None, check=True):
    print(f"\n>>> Running: {command}")
    result = subprocess.run(command, shell=True, cwd=cwd)
    if check and result.returncode != 0:
        print(f"Command failed: {command}")
        sys.exit(1)
    return result.returncode

def check_tool(name, version_cmd):
    if shutil.which(name) is None:
        print(f"ERROR: '{name}' not found on PATH. Please install it first.")
        sys.exit(1)
    run(version_cmd, check=False)

def main():
    print("=== Checking prerequisites ===")
    check_tool("node", "node -v")
    check_tool("docker", "docker --version")

    print("\n=== Enabling corepack + Yarn ===")
    run("corepack enable")
    run(f"corepack prepare yarn@{REQUIRED_YARN_VERSION} --activate")
    run("yarn -v")

    print("\n=== Installing dependencies ===")
    run("yarn install")

    print("\n=== Starting local Twenty server (Docker) ===")
    run("yarn twenty docker:start")

    print("\n=== Checking server status ===")
    run("yarn twenty docker:status")

    print("\nSetup complete. Open http://localhost:2020")
    print("Login: tim@apple.dev / tim@apple.dev")
    print("\nNote: 'yarn twenty dev' (app sync) has a known Windows path-separator")
    print("bug in twenty-sdk 2.35.1 — see TASK3.md for details.")

if __name__ == "__main__":
    main()