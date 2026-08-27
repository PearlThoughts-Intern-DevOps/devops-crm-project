import shutil
import subprocess
import sys
import time
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parent
REQUIRED_NODE_VERSION = "24.5.0"
REQUIRED_YARN_VERSION = "4.13.0"


def print_step(message):
    print(f"\n{'=' * 60}")
    print(message)
    print(f"{'=' * 60}")


def run_command(command, check=True):
    print(f"\n$ {' '.join(command)}")

    try:
        result = subprocess.run(
            command,
            cwd=PROJECT_ROOT,
            check=check,
        )
        return result.returncode
    except FileNotFoundError:
        print(f"ERROR: Command not found: {command[0]}")
        return 127
    except subprocess.CalledProcessError as error:
        print(f"ERROR: Command failed with exit code {error.returncode}")
        if check:
            sys.exit(error.returncode)
        return error.returncode


def get_command_output(command):
    try:
        result = subprocess.run(
            command,
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.strip()
    except (FileNotFoundError, subprocess.CalledProcessError):
        return ""


def check_project():
    print_step("Checking project directory")

    package_json = PROJECT_ROOT / "package.json"
    yarnrc = PROJECT_ROOT / ".yarnrc.yml"

    if not package_json.exists():
        print("ERROR: package.json was not found.")
        print("Please run this script from the project repository.")
        sys.exit(1)

    if not yarnrc.exists():
        print("ERROR: .yarnrc.yml was not found.")
        sys.exit(1)

    print(f"Project directory: {PROJECT_ROOT}")
    print("Project structure check: OK")


def check_command(command_name):
    if shutil.which(command_name) is None:
        print(f"ERROR: {command_name} is not installed or not available in PATH.")
        return False

    print(f"{command_name}: available")
    return True


def check_prerequisites():
    print_step("Checking prerequisites")

    required_commands = ["python3", "node", "yarn", "docker"]

    for command in required_commands:
        if not check_command(command):
            sys.exit(1)

    node_version = get_command_output(["node", "--version"])
    yarn_version = get_command_output(["yarn", "--version"])
    docker_version = get_command_output(["docker", "--version"])

    print(f"Node.js: {node_version}")
    print(f"Yarn: {yarn_version}")
    print(f"Docker: {docker_version}")

    expected_node = f"v{REQUIRED_NODE_VERSION}"

    if node_version != expected_node:
        print(
            f"ERROR: This project requires Node.js {REQUIRED_NODE_VERSION}. "
            f"Detected {node_version}."
        )
        sys.exit(1)

    if yarn_version != REQUIRED_YARN_VERSION:
        print(
            f"ERROR: This project requires Yarn {REQUIRED_YARN_VERSION}. "
            f"Detected {yarn_version}."
        )
        sys.exit(1)

    print("Node.js version check: OK")
    print("Yarn version check: OK")


def check_docker():
    print_step("Checking Docker")

    result = run_command(["docker", "info"], check=False)

    if result != 0:
        print("ERROR: Docker is installed but the Docker daemon is not available.")
        print("Please start Docker Desktop and run the script again.")
        sys.exit(1)

    print("Docker daemon: available")


def install_dependencies():
    print_step("Installing project dependencies")

    run_command(["yarn", "install"])

    print("Dependencies installed successfully.")


def start_twenty_docker():
    print_step("Starting local Twenty server")

    run_command(["yarn", "twenty", "docker:start"])

    print("Twenty Docker environment started.")


def wait_for_twenty():
    print_step("Waiting for Twenty to become healthy")

    max_attempts = 12

    for attempt in range(1, max_attempts + 1):
        print(f"Health check {attempt}/{max_attempts}...")

        result = subprocess.run(
            ["yarn", "twenty", "docker:status"],
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
        )

        output = result.stdout + result.stderr

        if "running (healthy)" in output:
            print("Twenty server is healthy.")
            print(output.strip())
            return

        time.sleep(5)

    print("ERROR: Twenty did not become healthy within the expected time.")
    print("Run 'yarn twenty docker:status' to inspect the server.")
    sys.exit(1)


def start_development_server():
    print_step("Starting Twenty development server")

    print("The development server will continue running.")
    print("Press Ctrl+C when you want to stop it.")

    try:
        subprocess.run(
            ["yarn", "twenty", "dev"],
            cwd=PROJECT_ROOT,
            check=True,
        )
    except KeyboardInterrupt:
        print("\nDevelopment server stopped by user.")


def main():
    print_step("Twenty CRM Local Setup Automation")

    check_project()
    check_prerequisites()
    check_docker()
    install_dependencies()
    start_twenty_docker()
    wait_for_twenty()
    start_development_server()


if __name__ == "__main__":
    main()
