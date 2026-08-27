import shutil
import subprocess
import sys


def run(command):
    print(f"\n> {' '.join(command)}")
    result = subprocess.run(command)

    if result.returncode != 0:
        print(f"\nERROR: Command failed: {' '.join(command)}")
        sys.exit(1)


print("=== Twenty CRM Local Setup ===")

# 1. Check Node.js
if not shutil.which("node"):
    print("ERROR: Node.js is not installed.")
    sys.exit(1)

print("Node.js found.")


# 2. Check Yarn
if not shutil.which("yarn"):
    print("ERROR: Yarn is not installed.")
    print("Install/enable Yarn 4 using Corepack.")
    sys.exit(1)

print("Yarn found.")


# 3. Check Docker
if not shutil.which("docker"):
    print("ERROR: Docker is not installed.")
    sys.exit(1)

print("Docker found.")


# 4. Install dependencies
print("\nInstalling project dependencies...")
run(["yarn", "install"])


# 5. Start Twenty CRM
print("\nStarting Twenty CRM...")
run(["yarn", "twenty", "docker:start"])


# 6. Start the application
print("\nStarting Twenty App...")
run(["yarn", "twenty", "dev"])