import os
import shutil
import subprocess
import sys


def run_command(command, check=True):
    print(f"\n[INFO] Running: {' '.join(command)}")
    return subprocess.run(command, check=check)


def command_exists(command):
    return shutil.which(command) is not None


def main():
    print("\n==========================================")
    print("   Twenty CRM Local Setup Automation")
    print("==========================================\n")

    # 1. Verify required tools
    print("[INFO] Checking required tools...")

    required_tools = ["node", "yarn", "docker"]

    for tool in required_tools:
        if not command_exists(tool):
            print(f"[ERROR] Required tool not found: {tool}")
            sys.exit(1)

        print(f"[SUCCESS] {tool} is installed")

    # 2. Display tool versions
    print("\n[INFO] Installed tool versions:\n")

    run_command(["node", "--version"])
    run_command(["yarn.cmd", "--version"])
    run_command(["docker", "--version"])

    # 3. Verify project files
    print("\n[INFO] Checking project files...")

    required_files = ["package.json", "SETUP.md"]

    for file in required_files:
        if not os.path.isfile(file):
            print(f"[ERROR] Required file not found: {file}")
            sys.exit(1)

        print(f"[SUCCESS] Found {file}")

    # 4. Install dependencies
    print("\n[INFO] Installing project dependencies...")

    run_command(["yarn.cmd", "install"])

    print("\n[SUCCESS] Dependencies installed successfully.")

    # 5. Check Docker
    print("\n[INFO] Checking Docker...")

    docker_check = subprocess.run(
        ["docker", "info"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    if docker_check.returncode != 0:
        print("[ERROR] Docker is not running.")
        print("[ERROR] Please start Docker Desktop and run the script again.")
        sys.exit(1)

    print("[SUCCESS] Docker is running.")

    # 6. Check Twenty server status
    print("\n[INFO] Checking Twenty server status...")

    status = subprocess.run(
        ["yarn.cmd", "twenty", "docker:status"],
        capture_output=True,
        text=True,
    )

    if "running" in status.stdout.lower():
        print("[SUCCESS] Twenty server is already running.")
    else:
        print("[INFO] Twenty server is not running.")
        print("[INFO] Starting Twenty Docker server...")

        run_command(["yarn.cmd", "twenty", "docker:start"])

        print("[SUCCESS] Twenty Docker server started.")

    # 7. Verify server
    print("\n[INFO] Verifying Twenty server...")

    run_command(["yarn.cmd", "twenty", "docker:status"])

    # 8. Final instructions
    print("\n==========================================")
    print("   Twenty CRM setup completed")
    print("==========================================")

    print("\nApplication URL:")
    print("http://localhost:2020")

    print("\nDefault development credentials:")
    print("Username: tim@apple.dev")
    print("Password: tim@apple.dev")

    print("\n[SUCCESS] Local Twenty server is running.")

    print("\n[INFO] To start the application development mode, run:")
    print("       yarn twenty dev")

    print("\n[SUCCESS] Setup automation completed successfully.")


if __name__ == "__main__":
    main()
