import tsconfigPaths from 'vite-tsconfig-paths';
import { defineConfig } from 'vitest/config';

const TWENTY_API_URL = process.env.TWENTY_API_URL;

const TWENTY_API_KEY = process.env.TWENTY_API_KEY;

if (!TWENTY_API_URL || !TWENTY_API_KEY) {
  throw new Error(
    'TWENTY_API_URL and TWENTY_API_KEY must be set before running integration tests.',
  );
}

// Make env vars available to globalSetup.
process.env.TWENTY_API_URL = TWENTY_API_URL;
process.env.TWENTY_API_KEY = TWENTY_API_KEY;

export default defineConfig({
  plugins: [
    tsconfigPaths({
      projects: ['tsconfig.spec.json'],
      ignoreConfigErrors: true,
    }),
  ],
  test: {
    testTimeout: 120_000,
    hookTimeout: 120_000,
    fileParallelism: false,
    include: ['src/**/*.integration-test.ts'],
    globalSetup: ['src/__tests__/global-setup.ts'],
    env: {
      TWENTY_API_URL,
      TWENTY_API_KEY,
    },
  },
});

