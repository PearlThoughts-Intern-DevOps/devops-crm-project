
import shutil
import subprocess
import sys
import time
import urllib.request
from pathlib import Path


# ---------------------------------------------------------
# Configuration
# ---------------------------------------------------------

PROJECT_DIR = Path(__file__).resolve().parent
SERVER_URL = "http://localhost:2020"


# ---------------------------------------------------------
# Printing helpers
# ---------------------------------------------------------

def print_header(message):
    print("\n" + "=" * 60)
    print(message)
    print("=" * 60)


def success(message):
    print(f"[SUCCESS] {message}")


def info(message):
    print(f"[INFO] {message}")


def warning(message):
    print(f"[WARNING] {message}")


def error(message):
    print(f"[ERROR] {message}")


# ---------------------------------------------------------
# Command helpers
# ---------------------------------------------------------

def command_exists(command):
    """Check whether a command is available in PATH."""
    return shutil.which(command) is not None


def run_command(command, description):
    """Run a command and stop if it fails."""
    info(description)
    print(f"$ {' '.join(command)}")

    try:
        result = subprocess.run(
            command,
            cwd=PROJECT_DIR,
            check=True
        )
        success(description)
        return result

    except subprocess.CalledProcessError as exc:
        error(f"{description} failed with exit code {exc.returncode}.")
        sys.exit(1)


def get_command_output(command):
    """Return command output or None if the command fails."""
    try:
        result = subprocess.run(
            command,
            cwd=PROJECT_DIR,
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip()

    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


# ---------------------------------------------------------
# Dependency checks
# ---------------------------------------------------------

def check_python():
    print_header("Checking Python")

    version = f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"

    if sys.version_info < (3, 8):
        error(f"Python {version} is too old. Python 3.8+ is required.")
        sys.exit(1)

    success(f"Python {version} is installed.")


def check_command(command, name):
    print_header(f"Checking {name}")

    if not command_exists(command):
        error(f"{name} is not installed or not available in PATH.")
        sys.exit(1)

    version = get_command_output([command, "--version"])

    if version:
        success(f"{name} is installed: {version}")
    else:
        success(f"{name} is installed.")


def check_project_files():
    print_header("Checking Project Files")

    required_files = [
        ".nvmrc",
        "package.json",
        "yarn.lock",
    ]

    for filename in required_files:
        file_path = PROJECT_DIR / filename

        if not file_path.exists():
            error(f"Required file not found: {filename}")
            sys.exit(1)

        success(f"Found {filename}")

    success("Project structure looks correct.")


def check_node_version():
    print_header("Checking Node.js Version")

    required_version = (24, 5, 0)
    output = get_command_output(["node", "--version"])

    if not output:
        error("Unable to determine Node.js version.")
        sys.exit(1)

    version_string = output.lstrip("v")

    try:
        major, minor, patch = map(int, version_string.split(".")[:3])
        current_version = (major, minor, patch)
    except ValueError:
        warning(f"Could not parse Node.js version: {output}")
        return

    if current_version < required_version:
        error(
            f"Node.js {output} is too old. "
            f"Node.js {required_version[0]}.{required_version[1]}.{required_version[2]}+ is required."
        )
        sys.exit(1)

    success(f"Node.js {output} is compatible.")


def check_yarn_version():
    print_header("Checking Yarn Version")

    required_version = "4.13.0"
    output = get_command_output(["yarn", "--version"])

    if not output:
        error("Unable to determine Yarn version.")
        sys.exit(1)

    if output != required_version:
        warning(
            f"Project specifies Yarn {required_version}, "
            f"but Yarn {output} is currently active."
        )
    else:
        success(f"Yarn {output} is correctly installed.")


def check_docker():
    print_header("Checking Docker")

    if not command_exists("docker"):
        error("Docker CLI is not installed or not available in PATH.")
        sys.exit(1)

    version = get_command_output(["docker", "--version"])

    if version:
        success(f"Docker is installed: {version}")

    info("Checking Docker engine...")

    try:
        subprocess.run(
            ["docker", "info"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=True
        )
        success("Docker engine is running.")

    except subprocess.CalledProcessError:
        error(
            "Docker CLI is installed, but the Docker engine is not running.\n"
            "Start Docker Desktop or Colima and run the script again."
        )
        sys.exit(1)


# ---------------------------------------------------------
# Server checks
# ---------------------------------------------------------

def wait_for_server(timeout=120):
    print_header("Waiting for Twenty Server")

    info(f"Checking {SERVER_URL}")

    start_time = time.time()

    while time.time() - start_time < timeout:
        try:
            with urllib.request.urlopen(
                SERVER_URL,
                timeout=3
            ):
                success(f"Twenty server is available at {SERVER_URL}")
                return True

        except Exception:
            print(".", end="", flush=True)
            time.sleep(2)

    print()
    error(
        f"Twenty server did not become available within {timeout} seconds."
    )
    return False


# ---------------------------------------------------------
# Main setup process
# ---------------------------------------------------------

def main():
    print_header("Twenty CRM Local Setup Automation")

    info(f"Project directory: {PROJECT_DIR}")

    # Dependency checks
    check_python()
    check_command("node", "Node.js")
    check_node_version()

    check_command("yarn", "Yarn")
    check_yarn_version()

    check_docker()
    check_project_files()

    # Install dependencies
    print_header("Installing Project Dependencies")

    run_command(
        ["yarn", "install"],
        "Installing project dependencies"
    )

    # Start Twenty server
    print_header("Starting Twenty Server")

    run_command(
        ["yarn", "twenty", "docker:start"],
        "Starting local Twenty server"
    )

    # Verify server
    if not wait_for_server():
        sys.exit(1)

    # Start development server
    print_header("Starting Twenty Development Server")

    info("Starting 'yarn twenty dev'.")
    info("Keep this terminal open while developing.")

    try:
        subprocess.run(
            ["yarn", "twenty", "dev"],
            cwd=PROJECT_DIR,
            check=True
        )

    except KeyboardInterrupt:
        print()
        info("Development server stopped by user.")

    except subprocess.CalledProcessError as exc:
        error(
            f"Development server stopped with exit code {exc.returncode}."
        )
        sys.exit(exc.returncode)


if __name__ == "__main__":
    main()
