
import shutil
import subprocess
import sys
import time
import urllib.request
from pathlib import Path


PROJECT_DIR = Path(__file__).resolve().parent
TWENTY_URL = "http://localhost:2020"


def check_command(command, name):
    """Check whether a required command is available."""
    if shutil.which(command) is None:
        print(f"ERROR: {name} is not installed or not available in PATH.")
        sys.exit(1)

    print(f"[OK] {name} found.")


def run_command(command, description):
    """Run a command and stop if it fails."""
    print(f"\n==> {description}")

    print(f"$ {' '.join(command)}")

    try:
        subprocess.run(command, cwd=PROJECT_DIR, check=True)
    except FileNotFoundError:
        print(f"\nERROR: Command not found: {command[0]}")
        sys.exit(1)
    except subprocess.CalledProcessError as error:
        print(f"\nERROR: {description} failed.")
        print(f"Exit code: {error.returncode}")
        sys.exit(error.returncode)


def twenty_is_running():
    """Check whether the local Twenty server is reachable."""
    try:
        with urllib.request.urlopen(TWENTY_URL, timeout=3):
            return True
    except Exception:
        return False


def wait_for_twenty(timeout=120):
    """Wait until the local Twenty server becomes available."""
    print("\n==> Waiting for Twenty to become available...")

    start_time = time.time()

    while time.time() - start_time < timeout:
        if twenty_is_running():
            print(f"[OK] Twenty is running at {TWENTY_URL}")
            return

        time.sleep(3)

    print("ERROR: Twenty did not become available within the timeout.")
    sys.exit(1)


def main():
    print("=" * 50)
    print("      Twenty CRM Local Setup Automation")
    print("=" * 50)

    print("\n==> Checking prerequisites...")
    check_command("node", "Node.js")
    check_command("yarn", "Yarn")
    check_command("docker", "Docker")

    run_command(
        ["yarn", "install"],
        "Installing project dependencies",
    )

    if twenty_is_running():
        print(f"\n[OK] Twenty is already running at {TWENTY_URL}")
    else:
        run_command(
            ["yarn", "twenty", "docker:start"],
            "Starting Twenty Docker environment",
        )

        wait_for_twenty()

    print("\n==> Starting Twenty development environment...")

    run_command(
        ["yarn", "twenty", "dev"],
        "Starting Twenty development server",
    )


if __name__ == "__main__":
    main()
```
