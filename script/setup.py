#!/usr/bin/env python3
"""
Twenty CRM - Local Setup Automation
PearlThoughts DevOps Internship - Task 03

Usage: python3 setup.py [check|db|env|install|start|stop|status|all]
"""

import os, sys, shutil, subprocess, time, urllib.request
from pathlib import Path

NVM = 'export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"'

# ── Auto-detect project root ──────────────────────────────────────────────────
def find_root():
    path = Path(__file__).resolve().parent
    while path != path.parent:
        if (path / "package.json").exists():
            return path
        path = path.parent
    return None

ROOT = find_root()
if not ROOT:
    print("[ERR]  package.json not found."); sys.exit(1)
os.chdir(ROOT)

# ── Load .env ─────────────────────────────────────────────────────────────────
def load_env():
    env_file = ROOT / ".env"
    if not env_file.exists():
        return
    for line in env_file.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        os.environ.setdefault(k.strip(), v.strip())

load_env()

# App URL — read from .env PORT, fallback to Twenty default
PORT    = os.environ.get("PORT", "3000")
APP_URL = os.environ.get("SERVER_URL", f"http://localhost:{PORT}")

# ── Helpers ───────────────────────────────────────────────────────────────────
def ok(m):   print(f"[OK]   {m}")
def warn(m): print(f"[WARN] {m}")
def err(m):  print(f"[ERR]  {m}")
def skip(m): print(f"[SKIP] {m}")
def step(t): print(f"\n=== {t} ===")

def run(cmd):
    r = subprocess.run(f'bash -c \'{NVM}; {cmd}\'', shell=True, cwd=ROOT)
    if r.returncode != 0:
        err(f"Failed: {cmd}"); sys.exit(r.returncode)

def out(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True,
                          text=True, cwd=ROOT).stdout.strip()

def is_up(url):
    try: urllib.request.urlopen(url, timeout=3); return True
    except: return False

def wait_for(url, timeout=120):
    deadline = time.time() + timeout
    while time.time() < deadline:
        if is_up(url): ok(f"Up: {url}"); return
        time.sleep(5)
    warn(f"Timed out waiting for: {url}")

def node_version():
    nvmrc = ROOT / ".nvmrc"
    return nvmrc.read_text().strip() if nvmrc.exists() else None

# ── Step 1: Check ─────────────────────────────────────────────────────────────
def cmd_check():
    step("Check Prerequisites")
    for tool in ["git", "node", "yarn", "docker"]:
        v = out(f'bash -c \'{NVM}; {tool} --version 2>/dev/null\'')
        if v: ok(f"{tool}: {v.splitlines()[0]}")
        else: err(f"{tool} not found"); sys.exit(1)

    # Docker must be running for twenty docker:start to work
    if out("docker info 2>/dev/null | grep 'Server Version'"):
        ok("Docker daemon: running")
    else:
        err("Docker daemon not running. Start it with: sudo systemctl start docker")
        sys.exit(1)

    ok(f"Project root: {ROOT}")
    ok("All checks passed.")

# ── Step 2: Install ───────────────────────────────────────────────────────────
def cmd_install():
    step("Install Dependencies")
    ver = node_version()
    run(f"nvm install {ver} && nvm use {ver} && yarn" if ver else "nvm install && nvm use && yarn")
    ok("Dependencies installed.")

# ── Step 3: .env ──────────────────────────────────────────────────────────────
def cmd_env():
    step("Copy .env Files")
    examples = list(ROOT.rglob(".env.example"))
    if examples:
        for src in examples:
            dst = src.parent / ".env"
            if dst.exists(): skip(f"{dst.relative_to(ROOT)} exists.")
            else: shutil.copy(src, dst); ok(f"Copied → {dst.relative_to(ROOT)}")
    elif (ROOT / ".env").exists():
        skip(".env already exists at project root.")
    else:
        warn("No .env found. Create one at project root.")

# ── Step 4: Start (Docker) ────────────────────────────────────────────────────
def cmd_start():
    step("Start Twenty CRM via Docker")
    ok("Running: yarn twenty docker:start ...")
    run("yarn twenty docker:start")
    wait_for(APP_URL)
    ok(f"Twenty CRM is running → {APP_URL}")
    ok("Login → tim@apple.dev / tim@apple.dev")

# ── Step 5: Stop (Docker) ─────────────────────────────────────────────────────
def cmd_stop():
    step("Stop Twenty CRM Docker Container")
    run("yarn twenty docker:stop")
    ok("Stopped.")

# ── Status ────────────────────────────────────────────────────────────────────
def cmd_status():
    step("Status")
    # Docker container status
    container = out("yarn twenty docker:status 2>/dev/null | tail -5")
    print(container) if container else warn("Could not get docker status.")

    ok(f"App: up → {APP_URL}") if is_up(APP_URL) else warn(f"App: not responding at {APP_URL}")

# ── All ───────────────────────────────────────────────────────────────────────
def cmd_all():
    cmd_check(); cmd_env(); cmd_install(); cmd_start()

# ── Dispatch ──────────────────────────────────────────────────────────────────
CMDS = {"check": cmd_check, "env": cmd_env, "install": cmd_install,
        "start": cmd_start, "stop": cmd_stop, "status": cmd_status, "all": cmd_all}

if len(sys.argv) < 2 or sys.argv[1] not in CMDS:
    print(__doc__); sys.exit(0)

try: CMDS[sys.argv[1]]()
except KeyboardInterrupt: warn("Aborted.")
