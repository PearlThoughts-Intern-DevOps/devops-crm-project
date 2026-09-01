import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';
import { execFileSync } from 'child_process';

const APP_PATH = process.cwd();
const CONFIG_DIR = path.join(os.homedir(), '.twenty');

function validateEnv(): { apiUrl: string; apiKey: string } {
  const apiUrl = process.env.TWENTY_API_URL;
  const apiKey = process.env.TWENTY_API_KEY;

  if (!apiUrl || !apiKey) {
    throw new Error(
      'TWENTY_API_URL and TWENTY_API_KEY must be set.\n' +
        'Make sure the integration test environment provides both variables.',
    );
  }

  return { apiUrl, apiKey };
}

async function checkServer(apiUrl: string) {
  let response: Response;

  try {
    response = await fetch(`${apiUrl}/healthz`);
  } catch {
    throw new Error(
      `Twenty server is not reachable at ${apiUrl}. ` +
        'Make sure the server is running before executing integration tests.',
    );
  }

  if (!response.ok) {
    throw new Error(`Server at ${apiUrl} returned ${response.status}`);
  }
}

function writeTestConfig(apiUrl: string, apiKey: string) {
  const payload = JSON.stringify(
    {
      version: 1,
      remotes: {
        local: {
          apiUrl,
          apiKey,
        },
      },
      defaultRemote: 'local',
    },
    null,
    2,
  );

  fs.mkdirSync(CONFIG_DIR, { recursive: true });
  fs.writeFileSync(
    path.join(CONFIG_DIR, 'config.test.json'),
    payload,
  );
}

function runTwenty(command: string, args: string[]) {
  execFileSync('yarn', ['twenty', command, ...args], {
    cwd: APP_PATH,
    stdio: 'inherit',
    env: {
      ...process.env,
      TWENTY_CLI_CONFIG_PATH: path.join(
        CONFIG_DIR,
        'config.test.json',
      ),
    },
  });
}

export async function setup() {
  const { apiUrl, apiKey } = validateEnv();

  await checkServer(apiUrl);
  writeTestConfig(apiUrl, apiKey);

  runTwenty('dev', ['--once']);
}

export async function teardown() {
  try {
    runTwenty('app:uninstall', ['-y']);
  } catch (error) {
    console.warn(
      `App uninstall failed: ${
        error instanceof Error ? error.message : String(error)
      }`,
    );
  }
}