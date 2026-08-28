import shutil
import subprocess
import sys
import time
import urllib.request


PROJECT_ROOT = __import__("pathlib").Path(__file__).resolve().parent.parent
SERVER_URL = "http://localhost:2020"


def run_command(command, description, check=True):
    print(f"\n[INFO] {description}")
    print(f"[CMD] {' '.join(command)}")

    executable = shutil.which(command[0])

    if executable is None:
        print(f"[ERROR] Could not find command: {command[0]}")
        sys.exit(1)

    command[0] = executable

    result = subprocess.run(
        command,
        cwd=PROJECT_ROOT,
        check=False,
    )

    if check and result.returncode != 0:
        print(f"[ERROR] Command failed with exit code {result.returncode}")
        sys.exit(result.returncode)

    return result.returncode


def check_tool(name, version_command):
    if shutil.which(name) is None:
        print(f"[ERROR] {name} is not installed or not available in PATH.")
        sys.exit(1)

    run_command(version_command, f"Checking {name} version")


def wait_for_server(timeout=120):
    print("\n[INFO] Waiting for Twenty server...")

    start = time.time()

    while time.time() - start < timeout:
        try:
            with urllib.request.urlopen(SERVER_URL, timeout=5):
                print(f"[OK] Twenty server is available at {SERVER_URL}")
                return True
        except Exception:
            time.sleep(3)

    print("[ERROR] Twenty server did not become available within the timeout.")
    return False


def main():
    print("=" * 60)
    print("Twenty CRM - Local Setup Automation")
    print("=" * 60)

    print(f"[INFO] Project root: {PROJECT_ROOT}")

    if not (PROJECT_ROOT / "package.json").exists():
        print("[ERROR] package.json not found.")
        sys.exit(1)

    if not (PROJECT_ROOT / "src").exists():
        print("[ERROR] src directory not found.")
        sys.exit(1)

    check_tool("node", ["node", "--version"])
    check_tool("yarn", ["yarn", "--version"])
    check_tool("docker", ["docker", "--version"])

    run_command(
        ["docker", "info"],
        "Checking Docker engine",
    )

    run_command(
        ["yarn", "install"],
        "Installing project dependencies",
    )

    run_command(
        ["yarn", "twenty", "docker:start"],
        "Starting local Twenty Docker server",
    )

    if not wait_for_server():
        sys.exit(1)

    run_command(
        ["yarn", "twenty", "docker:status"],
        "Checking Twenty Docker server status",
    )

    run_command(
        ["yarn", "twenty", "dev:build", "."],
        "Building the Twenty application",
    )

    print("\n[INFO] Attempting to synchronize the application...")

    result = run_command(
        ["yarn", "twenty", "apply", "."],
        "Synchronizing the local Twenty application",
        check=False,
    )

    if result != 0:
        print("\n[WARNING] Application synchronization failed.")
        print(
            "[WARNING] The local Twenty server is running, "
            "but the SDK synchronization returned an error."
        )
        print(
            "[WARNING] Check the command output above for the exact reason."
        )
        sys.exit(result)

    print("\n" + "=" * 60)
    print("SUCCESS: Twenty CRM local setup completed.")
    print(f"Open: {SERVER_URL}")
    print("=" * 60)


if __name__ == "__main__":
    main()

