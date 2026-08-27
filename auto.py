import shutil
import subprocess
import sys
import time
import urllib.request
from pathlib import Path


PROJECT_DIR = Path(__file__).resolve().parent
TWENTY_URL = "http://localhost:2020"


def run_command(command, description):
    print(f"\n[INFO] {description}")
    print(f"[CMD] {' '.join(command)}")

    try:
        result = subprocess.run(
            command,
            cwd=PROJECT_DIR,
            check=True,
        )
        return result
    except subprocess.CalledProcessError as exc:
        print(f"[ERROR] Command failed with exit code {exc.returncode}")
        sys.exit(exc.returncode)


def check_command(command, name):
    if shutil.which(command) is None:
        print(f"[ERROR] {name} is not installed or not in PATH.")
        sys.exit(1)

    print(f"[OK] {name} is available.")


def check_node_version():
    result = subprocess.run(
        ["node", "--version"],
        capture_output=True,
        text=True,
        check=True,
    )

    version = result.stdout.strip().lstrip("v")
    required = "24.5.0"

    if version != required:
        print(
            f"[ERROR] Node.js {required} is required, "
            f"but {version} is installed."
        )
        sys.exit(1)

    print(f"[OK] Node.js {version}")


def check_yarn_version():
    result = subprocess.run(
        ["yarn", "--version"],
        capture_output=True,
        text=True,
        check=True,
    )

    version = result.stdout.strip()

    if version != "4.13.0":
        print(
            f"[WARNING] Expected Yarn 4.13.0, "
            f"but Yarn {version} is installed."
        )
    else:
        print(f"[OK] Yarn {version}")


def check_docker():
    result = subprocess.run(
        ["docker", "--version"],
        capture_output=True,
        text=True,
        check=True,
    )

    print(f"[OK] {result.stdout.strip()}")


def check_twenty_status():
    result = subprocess.run(
        ["yarn", "twenty", "docker:status"],
        cwd=PROJECT_DIR,
        capture_output=True,
        text=True,
    )

    output = result.stdout + result.stderr

    if "running (healthy)" in output.lower():
        print("[OK] Twenty server is already running and healthy.")
        return True

    print("[INFO] Twenty server is not running.")
    return False


def wait_for_twenty(timeout=120):
    print("[INFO] Waiting for Twenty server...")

    start_time = time.time()

    while time.time() - start_time < timeout:
        try:
            with urllib.request.urlopen(TWENTY_URL, timeout=5):
                print(f"[OK] Twenty server is reachable at {TWENTY_URL}")
                return
        except Exception:
            time.sleep(3)

    print("[ERROR] Twenty server did not become reachable within the timeout.")
    sys.exit(1)


def main():
    print("=" * 60)
    print("Twenty CRM Local Setup Automation")
    print("=" * 60)

    if not (PROJECT_DIR / "package.json").exists():
        print("[ERROR] package.json not found.")
        print("[ERROR] Run this script from the project directory.")
        sys.exit(1)

    print(f"[OK] Project directory: {PROJECT_DIR}")

    print("\n[1/6] Checking prerequisites")
    check_command("node", "Node.js")
    check_command("yarn", "Yarn")
    check_command("docker", "Docker")

    check_node_version()
    check_yarn_version()
    check_docker()

    print("\n[2/6] Installing project dependencies")
    run_command(
        ["yarn", "install"],
        "Installing dependencies with Yarn",
    )

    print("\n[3/6] Checking Twenty Docker server")

    if not check_twenty_status():
        run_command(
            ["yarn", "twenty", "docker:start"],
            "Starting the local Twenty server",
        )

    print("\n[4/6] Verifying Twenty server")
    wait_for_twenty()

    print("\n[5/6] Starting Twenty development environment")
    print("[INFO] Running 'yarn twenty dev'.")
    print("[INFO] This command keeps running while the development environment is active.")

    try:
        subprocess.run(
            ["yarn", "twenty", "dev"],
            cwd=PROJECT_DIR,
            check=True,
        )
    except KeyboardInterrupt:
        print("\n[INFO] Development server stopped by user.")
    except subprocess.CalledProcessError as exc:
        print(f"[ERROR] Twenty development command failed: {exc.returncode}")
        sys.exit(exc.returncode)

    print("\n[6/6] Setup completed.")


if __name__ == "__main__":
    main()
