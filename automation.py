import shutil
import subprocess
import sys


def run_command(command):
    print(f"\n>>> Running: {' '.join(command)}")

    result = subprocess.run(command)

    if result.returncode != 0:
        print(f"\n❌ Command failed: {' '.join(command)}")
        sys.exit(result.returncode)

    print(f"✓ Completed: {' '.join(command)}")


def check_command(command, name):
    if shutil.which(command) is None:
        print(f"❌ {name} is not installed or not available in PATH.")
        sys.exit(1)

    print(f"✓ {name} is available")


def main():
    print("=" * 50)
    print("Twenty CRM Local Setup Automation")
    print("=" * 50)

    print("\nChecking prerequisites...")

    check_command("node", "Node.js")
    check_command("yarn", "Yarn")
    check_command("docker", "Docker")

    print("\nInstalling project dependencies...")
    run_command(["yarn", "install"])

    print("\nStarting local Twenty server...")
    run_command(["yarn", "twenty", "docker:start"])

    print("\nStarting Twenty development environment...")
    run_command(["yarn", "twenty", "dev"])

    print("\n" + "=" * 50)
    print("✓ Setup and startup completed successfully!")
    print("✓ Twenty CRM: http://localhost:2020")
    print("=" * 50)


if __name__ == "__main__":
    main()
