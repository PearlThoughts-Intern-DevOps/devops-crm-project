import subprocess
import time
import urllib.request

def run(cmd):
    print(f"\n>>> {' '.join(cmd)}")
    subprocess.run(cmd, check=True)

def wait_for_app(url="http://localhost:2020"):
    print("Waiting for Twenty...")
    for _ in range(36):
        try:
            urllib.request.urlopen(url, timeout=3)
            print(f"Twenty is running: {url}")
            return
        except Exception:
            time.sleep(5)
    raise RuntimeError("Twenty did not become ready.")

run(["yarn", "install"])
run(["yarn", "twenty", "docker:start"])
wait_for_app()
run(["yarn", "twenty", "dev"])
