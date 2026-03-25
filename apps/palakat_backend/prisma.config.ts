import * as fs from 'node:fs';
import * as path from 'node:path';
import { parse } from 'dotenv';
import { defineConfig } from 'prisma/config';

type EnvMap = Record<string, string>;

const normalizeEnvName = (value?: string) =>
  (value || 'local').trim().toLowerCase();

const resolveEnvFilePath = () => {
  if (process.env.DOTENV_CONFIG_PATH) {
    return process.env.DOTENV_CONFIG_PATH;
  }

  return path.resolve(process.cwd(), '.env');
};

const parseSelectedEnvFile = (
  filePath: string,
  selectedEnv: string,
): EnvMap => {
  if (!fs.existsSync(filePath)) {
    return {};
  }

  const source = fs.readFileSync(filePath, 'utf8');
  const lines = source.split(/\r?\n/);
  const hasSections = lines.some((line) => /^\s*\[[^\]]+\]\s*$/.test(line));

  if (!hasSections) {
    return parse(source);
  }

  const commonLines: string[] = [];
  const selectedLines: string[] = [];
  let currentSection: string | null = null;
  let sawSection = false;

  for (const line of lines) {
    const sectionMatch = line.match(/^\s*\[([^\]]+)\]\s*$/);
    if (sectionMatch) {
      sawSection = true;
      currentSection = normalizeEnvName(sectionMatch[1]);
      continue;
    }

    if (!sawSection) {
      commonLines.push(line);
      continue;
    }

    if (currentSection === selectedEnv) {
      selectedLines.push(line);
    }
  }

  return parse([...commonLines, ...selectedLines].join('\n'));
};

const selectedEnv = normalizeEnvName(process.env.PALAKAT_ENV);
const fileEnv = parseSelectedEnvFile(resolveEnvFilePath(), selectedEnv);

const readEnvValue = (key: string) => {
  const processValue = process.env[key];
  if (processValue && !processValue.includes('${')) {
    return processValue;
  }

  const fileValue = fileEnv[key];
  if (fileValue && !fileValue.includes('${')) {
    return fileValue;
  }

  return undefined;
};

const databaseUrl = (() => {
  const raw = readEnvValue('DATABASE_URL');
  if (raw) {
    return raw;
  }

  const host = readEnvValue('POSTGRES_HOST') || 'localhost';
  const port = readEnvValue('POSTGRES_PORT') || '5432';
  const user = readEnvValue('POSTGRES_USER') || 'root';
  const password = readEnvValue('POSTGRES_PASSWORD') || 'password';
  const db = readEnvValue('POSTGRES_DB') || 'database';

  return `postgresql://${user}:${password}@${host}:${port}/${db}`;
})();

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
    seed: './node_modules/.bin/tsx prisma/seed.ts',
  },
  datasource: {
    url: databaseUrl,
  },
});
