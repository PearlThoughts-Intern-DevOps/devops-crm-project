import os
import shutil
import subprocess
import sys


def run_command(command):
    """Run a command and stop if it fails."""
    print(f"\n[INFO] Running: {' '.join(command)}")
    result = subprocess.run(command)

    if result.returncode != 0:
        print(f"[ERROR] Command failed: {' '.join(command)}")
        sys.exit(result.returncode)


def check_command(command, name):
    """Check whether a required command is available."""
    if shutil.which(command) is None:
        print(f"[ERROR] {name} is not installed or not available in PATH.")
        sys.exit(1)

    print(f"[OK] {name} is available.")


def main():
    print("=" * 60)
    print("Twenty CRM - Local Setup Automation")
    print("=" * 60)

    # Check project directory
    project_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(project_dir)

    print(f"[OK] Project directory: {project_dir}")

    # Check required tools
    check_command("node", "Node.js")
    check_command("yarn", "Yarn")

    # Check package.json
    if not os.path.exists("package.json"):
        print("[ERROR] package.json not found.")
        sys.exit(1)

    print("[OK] package.json found.")

    # Display versions
    print("\n[INFO] Checking versions...")
    run_command(["node", "--version"])
    run_command(["yarn", "--version"])

    # Install dependencies
    print("\n[INFO] Installing project dependencies...")
    run_command(["yarn", "install"])

    # Start Twenty application
    print("\n[INFO] Starting Twenty application...")
    print("[INFO] Press Ctrl+C to stop the application.")

    run_command(["yarn", "twenty", "dev"])


if __name__ == "__main__":
    main()
