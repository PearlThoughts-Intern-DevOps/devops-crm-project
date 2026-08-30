import shutil
import subprocess
import sys


def get_command(command):
    """
    Find the correct executable for Windows/Linux/macOS.
    """
    if sys.platform == "win32":
        path = shutil.which(command)

        if path:
            return path

        path = shutil.which(command + ".cmd")

        if path:
            return path

        path = shutil.which(command + ".exe")

        if path:
            return path

    else:
        path = shutil.which(command)

        if path:
            return path

    return None


def run(command):
    """
    Run a command and stop the script if it fails.
    """
    executable = get_command(command[0])

    if not executable:
        print(f"\nERROR: '{command[0]}' was not found.")
        sys.exit(1)

    command[0] = executable

    print(f"\n> {' '.join(command)}")

    result = subprocess.run(command)

    if result.returncode != 0:
        print(f"\nERROR: Command failed.")
        print(f"Command: {' '.join(command)}")
        sys.exit(1)


print("=" * 50)
print(" Twenty CRM - Local Setup")
print("=" * 50)


# --------------------------------------------------
# 1. Check project directory
# --------------------------------------------------

if not shutil.which("python"):
    print("ERROR: Python is not available.")
    sys.exit(1)

if not __import__("os").path.exists("package.json"):
    print("\nERROR: package.json was not found.")
    print("Please run this script from the project root.")
    sys.exit(1)

print("\nProject directory detected.")


# --------------------------------------------------
# 2. Check Node.js
# --------------------------------------------------

if not get_command("node"):
    print("\nERROR: Node.js is not installed.")
    sys.exit(1)

print("Node.js found.")


# --------------------------------------------------
# 3. Check Yarn
# --------------------------------------------------

if not get_command("yarn"):
    print("\nERROR: Yarn is not installed or not available in PATH.")
    print("Make sure Yarn 4 is enabled through Corepack.")
    sys.exit(1)

print("Yarn found.")


# --------------------------------------------------
# 4. Check Docker
# --------------------------------------------------

if not get_command("docker"):
    print("\nERROR: Docker is not installed or not available in PATH.")
    sys.exit(1)

print("Docker found.")


# --------------------------------------------------
# 5. Install dependencies
# --------------------------------------------------

print("\nInstalling project dependencies...")

run(["yarn", "install"])


# --------------------------------------------------
# 6. Start Twenty CRM
# --------------------------------------------------

print("\nStarting Twenty CRM using Docker...")

run(["yarn", "twenty", "docker:start"])


# --------------------------------------------------
# 7. Start Twenty App
# --------------------------------------------------

print("\nStarting Twenty App in development mode...")

run(["yarn", "twenty", "dev"])