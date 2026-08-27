import shutil
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parent
TWENTY_URL = "http://localhost:2020"

REQUIRED_NODE_VERSION = "24.5.0"
REQUIRED_YARN_VERSION = "4.0.2"


def print_step(message):
    print(f"\n==> {message}")


def command_exists(command):
    return shutil.which(command) is not None


def get_version(command):
    result = subprocess.run(
        command,
        capture_output=True,
        text=True,
        check=False,
    )

    return result.stdout.strip() or result.stderr.strip()


def version_tuple(version):
    parts = version.lstrip("v").split(".")
    return tuple(int(part) for part in parts[:3])


def run_command(command, description):
    print_step(description)

    try:
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as error:
        print(
            f"ERROR: {description} failed "
            f"with exit code {error.returncode}."
        )
        sys.exit(error.returncode)
    except FileNotFoundError:
        print(f"ERROR: Required command not found: {command[0]}")
        sys.exit(1)


def check_project_directory():
    print_step("Checking project directory")

    required_files = [
        "package.json",
        "yarn.lock",
        ".nvmrc",
    ]

    missing_files = [
        file
        for file in required_files
        if not (PROJECT_ROOT / file).exists()
    ]

    if missing_files:
        print("ERROR: setup.py must be run from the project root.")
        print(f"Expected project directory: {PROJECT_ROOT}")
        print(f"Missing files: {', '.join(missing_files)}")
        sys.exit(1)

    print(f"Project directory: {PROJECT_ROOT}")
    print("Project structure check: PASSED")


def check_tools():
    print_step("Checking required tools")

    tools = [
        "python3",
        "node",
        "yarn",
        "docker",
    ]

    for tool in tools:
        if not command_exists(tool):
            print(
                f"ERROR: {tool} is not installed "
                "or is not available in PATH."
            )
            sys.exit(1)

        version = get_version([tool, "--version"])
        print(f"{tool}: {version}")

    node_version = get_version(["node", "--version"])

    if version_tuple(node_version) < version_tuple(
        REQUIRED_NODE_VERSION
    ):
        print(
            f"ERROR: Node.js {REQUIRED_NODE_VERSION} "
            "or newer is required."
        )
        sys.exit(1)

    yarn_version = get_version(["yarn", "--version"])

    if version_tuple(yarn_version) < version_tuple(
        REQUIRED_YARN_VERSION
    ):
        print(
            f"ERROR: Yarn {REQUIRED_YARN_VERSION} "
            "or newer is required."
        )
        sys.exit(1)

    print(
        f"Node.js requirement >= {REQUIRED_NODE_VERSION}: PASSED"
    )
    print(
        f"Yarn requirement >= {REQUIRED_YARN_VERSION}: PASSED"
    )
    print("Required tools check: PASSED")


def install_dependencies():
    print_step("Checking project dependencies")

    install_state = (
        PROJECT_ROOT / ".yarn" / "install-state.gz"
    )

    if install_state.exists():
        print("Dependencies are already installed.")
        print("Skipping yarn install.")
        return

    run_command(
        ["yarn", "install"],
        "Installing project dependencies",
    )

    print("Dependency installation: PASSED")


def twenty_server_is_ready():
    try:
        with urllib.request.urlopen(
            TWENTY_URL,
            timeout=5,
        ) as response:
            return response.status == 200

    except (
        urllib.error.URLError,
        TimeoutError,
    ):
        return False


def start_twenty_server():
    if twenty_server_is_ready():
        print_step("Checking Twenty server")
        print(f"Twenty server is already running at {TWENTY_URL}")
        return None

    print_step("Starting Twenty Docker server")

    process = subprocess.Popen(
        ["yarn", "twenty", "docker:start"],
        cwd=PROJECT_ROOT,
    )

    print("Waiting for Twenty server to become ready...")

    for _ in range(60):
        if twenty_server_is_ready():
            print(
                f"Twenty server is ready at {TWENTY_URL}"
            )
            return process

        if process.poll() is not None:
            print(
                "ERROR: Twenty Docker server "
                "stopped unexpectedly."
            )
            sys.exit(1)

        time.sleep(2)

    process.terminate()

    print(
        "ERROR: Timed out waiting for "
        "Twenty server."
    )
    sys.exit(1)


def start_development_server():
    print_step("Starting Twenty development server")

    print(
        "The development server will continue running "
        "until you press Ctrl+C."
    )

    try:
        subprocess.run(
            ["yarn", "twenty", "dev"],
            cwd=PROJECT_ROOT,
            check=True,
        )

    except KeyboardInterrupt:
        print("\nDevelopment server stopped.")

    except subprocess.CalledProcessError as error:
        print(
            "ERROR: Development server exited "
            f"with code {error.returncode}."
        )
        sys.exit(error.returncode)


def main():
    print("=" * 50)
    print("   DevOps CRM Project - Local Setup")
    print("=" * 50)

    check_project_directory()
    check_tools()
    install_dependencies()

    docker_process = start_twenty_server()

    try:
        start_development_server()

    finally:
        if (
            docker_process
            and docker_process.poll() is None
        ):
            print_step(
                "Stopping Twenty Docker startup process"
            )
            docker_process.terminate()


if __name__ == "__main__":
    main()
