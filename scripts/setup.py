import subprocess
import shutil
import sys
import os


def run(command):
    print("\n>>", " ".join(command))
    result = subprocess.run(command)

    if result.returncode != 0:
        print("ERROR: Command failed.")
        sys.exit(1)


print("====================================")
print(" CRM Local Setup Automation")
print("====================================")

print("\nChecking required tools...")

for tool in ["node", "docker", "corepack"]:
    if shutil.which(tool):
        print("[OK]", tool, "is installed")
    else:
        print("[ERROR]", tool, "is not installed")
        sys.exit(1)

print("\nChecking project directory...")

if not os.path.exists("package.json"):
    print("[ERROR] Run this script from the project root.")
    sys.exit(1)

print("[OK] Project directory verified")

print("\nDependency versions:")
run(["node", "--version"])
run(["corepack", "yarn", "--version"])
run(["docker", "--version"])

print("\nInstalling dependencies...")
run(["corepack", "yarn", "install"])

print("\nStarting Twenty server...")
run(["corepack", "yarn", "twenty", "docker:start"])

print("\nStarting development server...")
print("Application URL: http://localhost:2020")

run(["corepack", "yarn", "twenty", "dev"])
