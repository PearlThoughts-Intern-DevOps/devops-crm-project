import shutil
import subprocess
import sys
import urllib.request


def check_command(command, name):
    if shutil.which(command):
        print(f"✓ {name} is installed.")
        return True

    print(f"✗ {name} is not installed.")
    return False


def check_project_dependencies():
    print("\n[4/6] Checking project dependencies...")

    result = subprocess.run(
        ["yarn", "install", "--immutable"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )

    if result.returncode == 0:
        print("✓ Project dependencies are already installed.")
        print("  Skipping installation.")
        return

    print("✗ Project dependencies are missing.")
    print("  Installing project dependencies...")

    subprocess.run(["yarn", "install"], check=True)

    print("✓ Project dependencies installed successfully.")


def is_twenty_running():
    try:
        urllib.request.urlopen(
            "http://localhost:2020",
            timeout=5
        )
        return True
    except Exception:
        return False


def start_twenty_server():
    print("\n[5/6] Checking Twenty CRM server...")

    if is_twenty_running():
        print("✓ Twenty CRM server is already running.")
        print("  Skipping server startup.")
        return

    print("✗ Twenty CRM server is not running.")
    print("  Starting Twenty CRM server...")

    subprocess.run(
        ["yarn", "twenty", "docker:start"],
        check=True
    )

    print("✓ Twenty CRM server started successfully.")


def start_development_server():
    print("\n[6/6] Starting Twenty CRM development server...")
    print("If authentication is required, follow the instructions shown below.\n")

    subprocess.run(
        ["yarn", "twenty", "dev"],
        check=True
    )


def stop_twenty_server():
    print("\nStopping Twenty CRM server...")

    subprocess.run(
        ["yarn", "twenty", "docker:stop"],
        check=False
    )

    print("✓ Twenty CRM server stopped.")


def main():
    try:
        print("=" * 60)
        print("Twenty CRM Local Setup Automation")
        print("=" * 60)

        print("\n[1/6] Checking Node.js...")
        node_ok = check_command("node", "Node.js")

        print("\n[2/6] Checking Yarn...")
        yarn_ok = check_command("yarn", "Yarn")

        print("\n[3/6] Checking Docker...")
        docker_ok = check_command("docker", "Docker")

        if not (node_ok and yarn_ok and docker_ok):
            print("\n✗ Required dependencies are missing.")
            print("Please install the missing dependencies and run the script again.")
            sys.exit(1)

        print("\n✓ All required system dependencies are installed.")

        check_project_dependencies()

        start_twenty_server()

        start_development_server()

    except KeyboardInterrupt:
        print("\n\nStopping development environment...")
        stop_twenty_server()
        print("✓ Setup stopped by user.")
        sys.exit(0)


if __name__ == "__main__":
    main()
