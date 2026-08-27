# DevOps CRM Project — Local Setup Automation (Task 3)

This branch adds automation for setting up and running this Twenty CRM app
locally, without needing to run each setup command by hand.

## Where things are

| File | What it is |
|---|---|
| [`setup_crm.py`](./setup_crm.py) | The Python automation script. Run this to install dependencies, start the local Twenty server, and launch the dev server — all in one command. |
| [`devops_crm_project.pdf`](./devops_crm_project.pdf) | Full documentation: manual setup steps, how the automation script works, issues faced during setup and their solutions, and the git/PR workflow used. |

## Quick start

```bash
python setup_crm.py
```

Run this from the project root (the same folder as `package.json`). It
will check your tools, verify the project directory, install dependencies,
start the local Twenty server in Docker, check port 2020, and start the
dev server.

Once running, open [http://localhost:2020](http://localhost:2020) and log
in with the default development credentials: `tim@apple.dev` / `tim@apple.dev`.

## More detail

For the full breakdown of what each step does, why Python was used instead
of a shell script, and the specific issues encountered while building this
automation, see [`devops_crm_project.pdf`](./devops_crm_project.pdf).

## Project structure (this branch)

```
devops-crm-project/
├── .github/                    # CI/workflow configs
├── public/                     # Static assets
├── src/                        # App source code
├── .gitignore
├── .nvmrc                      # Pinned Node.js version (24.5.0)
├── .oxlintrc.json               # Linter config
├── .yarnrc.yml                 # Yarn 4 config
├── AGENTS.md
├── CHANGELOG.md
├── CLAUDE.md
├── README.md                   # This file
├── SETUP.md                    # Original manual setup steps
├── devops_crm_project.pdf      # Full task documentation (setup, automation, issues faced)
├── package.json                # Project manifest — Yarn 4, Twenty SDK dependencies
├── setup_crm.py                # Python automation script (this task's deliverable)
├── tsconfig.json
├── tsconfig.spec.json
├── vitest.config.ts
├── vitest.unit.config.ts
└── yarn.lock

# Generated locally, excluded from version control via .gitignore:
├── node_modules/                # Installed by `yarn install`
├── .yarn/                       # Yarn 4 cache/state
└── .twenty/                     # Local Twenty server state (created by `yarn twenty docker:start`)
```

> Generated from a directory listing on this branch after running
> `setup_crm.py`. The `node_modules/`, `.yarn/`, and `.twenty/` folders are
> created automatically by the setup process and should stay out of git —
> verify they're listed in `.gitignore` before committing.
