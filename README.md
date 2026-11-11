# TypeScript Playwright Test Automation

A Playwright and TypeScript scaffold for UI, API, and end-to-end tests. It combines page objects, composed fixtures, strict Zod response schemas, Faker data factories, and repository skills for AI-assisted development.

The `app` area contains example tests and application-specific templates. Configure and adapt these to your application before expecting a successful test run. The example API spec demonstrates patterns; it is not a complete endpoint coverage suite.

## Prerequisites

- Node.js 22 or later and npm. See [package.json](package.json) for dependencies and scripts.
- An accessible application and API, with a dedicated test account.
- Bash for the setup and skill-maintenance scripts. On Windows, use Git Bash for maintenance commands and PowerShell for the manual setup below.

## Installation

From the cloned repository directory, install the locked dependencies and browser caches:

```sh
npm ci
npx playwright install --with-deps chromium
npm run playwright-cli:install-browsers
```

The test runner and exploration CLI use separate browser caches. Install both when developing UI tests.

Create a local environment file:

**PowerShell:**

```powershell
Copy-Item env/.env.example env/.env.dev
```

**macOS / Linux:**

```sh
cp env/.env.example env/.env.dev
```

Edit `env/.env.dev` with your actual configuration. Local environment files are ignored by Git; [env/.env.example](env/.env.example) is the shared template.

| Variable       | Purpose                        |
| -------------- | ------------------------------ |
| `APP_URL`      | Frontend application URL       |
| `API_URL`      | Backend API URL                |
| `APP_EMAIL`    | Test account email             |
| `APP_PASSWORD` | Test account password          |
| `UTILITY_URL`  | Additional utility service URL |

Verify the installed tools:

```sh
npx playwright --version
```

**PowerShell:**

```powershell
.\scripts\playwright-cli.cmd --version
```

**macOS / Linux:**

```sh
bash scripts/playwright-cli.sh --version
```

On macOS and Linux, you can also link the repository wrappers onto your PATH:

```sh
bash scripts/link-cli.sh "$(pwd -P)"
export PATH="$HOME/.local/bin:$PATH"
```

The optional `npm run setup` automates setup on macOS and Linux, including WSL. It does not support native Windows; use the manual instructions above there.

## Running Tests

Run these commands after adapting the examples and configuring the target environment:

| Command                    | Runs                                                      |
| -------------------------- | --------------------------------------------------------- |
| `npm test`                 | All projects, excluding `@destructive` tests              |
| `npm run test:chromium`    | Chromium UI tests, excluding `@destructive`               |
| `npm run test:api`         | API project and its API authentication dependency         |
| `npm run test:smoke`       | Chromium tests tagged `@smoke`                            |
| `npm run test:sanity`      | Chromium tests tagged `@sanity`                           |
| `npm run test:regression`  | Chromium tests tagged `@regression`                       |
| `npm run test:e2e`         | Chromium tests tagged `@e2e`                              |
| `npm run test:destructive` | Chromium tests tagged `@destructive`, with one worker     |
| `npm run test:headed`      | Chromium with a visible browser, excluding `@destructive` |
| `npm run test:debug`       | Chromium in Playwright Inspector                          |
| `npm run test:ui`          | Chromium in Playwright UI mode                            |
| `npm run test:ci`          | Chromium with one worker, excluding `@destructive`        |
| `npm run report`           | Existing HTML report                                      |

The debug and UI commands have no destructive-test exclusion. Select the tests you intend to run.

Run an individual spec or inspect discovery without executing tests:

```sh
npx playwright test tests/app/functional/login.spec.ts --project=chromium
npx playwright test --list
```

### Environments

[playwright.config.ts](playwright.config.ts) loads `env/.env.dev` by default. Set `ENVIRONMENT` to load another `env/.env.<environment>` file.

**PowerShell:**

```powershell
$env:ENVIRONMENT = 'staging'
npm test
Remove-Item Env:ENVIRONMENT
```

**macOS / Linux:**

```sh
ENVIRONMENT=staging npm test
```

Changing the environment does not restrict tests to read-only operations.

### Projects and Authentication

| Project     | Purpose                        | Dependencies            |
| ----------- | ------------------------------ | ----------------------- |
| `setup-api` | Authenticate over HTTP         | None                    |
| `setup-ui`  | Sign in and save browser state | None                    |
| `api`       | API specs without a browser    | `setup-api`             |
| `chromium`  | UI and end-to-end specs        | `setup-api`, `setup-ui` |

Authentication helpers live in [helpers/app/createStorageState.ts](helpers/app/createStorageState.ts). API tokens are saved to a run-specific file and loaded in each test worker. Browser state is also scoped to the run; global teardown removes that run's authentication directory. If a setup project fails, its dependent tests cannot run.

`test:ci` selects Chromium and one worker. Set `CI=1` in the execution environment to also enable the configuration's two retries, focused-test rejection, and Blob plus HTML reports. This repository does not include a hosted CI workflow.

### Runtime Settings

| Setting            | Value                                |
| ------------------ | ------------------------------------ |
| Parallel execution | Enabled; one worker when `CI` is set |
| Retries            | 0 locally; 2 when `CI` is set        |
| Test timeout       | 60 seconds                           |
| Action timeout     | 10 seconds                           |
| Navigation timeout | 30 seconds                           |
| Assertion timeout  | 10 seconds                           |
| Traces             | On first retry                       |
| Screenshots        | On failure                           |
| Videos             | Retain on failure                    |

With zero local retries, `on-first-retry` does not collect a trace on an ordinary local failure.

## Repository Structure

```text
.agents/skills/             Project skills and supporting references
.husky/                    Pre-commit checks
config/                    Application and utility configuration
enums/                     Endpoint paths, routes, messages, roles, auth paths
env/                       Environment template and ignored local settings
fixtures/
  api/                     API request fixture, types, and implementation
    schemas/               Strict Zod response schemas
  helper/                  Reusable setup and teardown fixtures
  pom/                     Page object fixtures and merged test entry point
helpers/
  app/                     Authentication setup and cleanup
  util/                    Shared utilities
pages/
  app/                     Application page objects
  components/              Reusable UI components
test-data/
  factories/app/           Generated happy-path data
  static/app/              Curated application inputs
  static/util/             Shared invalid and boundary inputs
tests/app/
  api/                     API specs
  functional/              UI feature specs
  e2e/                     End-to-end specs
  auth-api.setup.ts        API authentication setup
  auth.setup.ts            Browser authentication setup
scripts/                   Setup, CLI wrappers, and repository checks
playwright.config.ts       Projects, environment loading, and runtime settings
```

## Adapting the Scaffold

1. Configure the application URLs and test credentials in your local environment file.
2. Read the API's OpenAPI contract and explore the live UI using the repository `playwright-cli` wrapper before writing UI tests, selectors, or page objects. Start with the [scaffold exploration guide](.agents/skills/playwright-cli/references/scaffold-usage.md).
3. Replace application-specific paths and messages in [enums/app/app.ts](enums/app/app.ts), then adapt the authentication helpers and setup projects to the real login flow.
4. Adapt page objects under `pages/app/` and register them in [fixtures/pom/page-object-fixture.ts](fixtures/pom/page-object-fixture.ts). Tests receive them through fixtures.
5. Build strict response schemas under `fixtures/api/schemas/`, happy-path factories under `test-data/factories/`, and curated inputs under `test-data/static/`.
6. Replace the example specs with application coverage, including cleanup for persistent changes and coverage for every documented API status code.
7. Run lint and the affected tests before considering the change complete.

The framework composes page object, API request, and helper fixtures with `mergeTests()` in [fixtures/pom/test-options.ts](fixtures/pom/test-options.ts). All specs import `test` and `expect` from that entry point. The `apiRequest` fixture makes HTTP calls; specs explicitly validate response bodies with their Zod schema.

## Test and Data Conventions

[AGENTS.md](AGENTS.md) is the authoritative Constitution and skill index. Key conventions include:

- Inject page objects through fixtures; use semantic locators in priority order: role, label, placeholder, text, then test ID. XPath and hard waits are forbidden.
- Use web-first assertions and expose success, error, and validation feedback in form and CRUD page objects.
- Keep URLs and credentials in environment variables; keep endpoint paths, routes, messages, and storage-state paths in enums.
- Use Faker factories for happy-path content and TypeScript `as const` sets for curated static inputs. Shared invalid values live in `test-data/static/util/invalid-values.ts`.
- Use `z.strictObject()` for response schemas, with exactly `expect(SchemaName.parse(body)).toBeTruthy();` for response validation. Do not use `any`.
- For tests making two or more API calls, use one `test.step()` per call.
- Revert persistent changes in `afterEach` or `afterAll`, including changes to data owned by the test.
- Build API coverage from the documented contract. A runtime contract mismatch requires `test.skip` with a `// FIXME:` explanation; keep the schema strict.

### Tags

Every test has exactly one tag, applied to the individual test. Do not tag `test.describe()` or use `@functional`.

| Tag            | Purpose                                            |
| -------------- | -------------------------------------------------- |
| `@smoke`       | Critical paths                                     |
| `@sanity`      | Key functionality                                  |
| `@regression`  | Detailed coverage of a behaviour                   |
| `@e2e`         | End-to-end user journeys                           |
| `@api`         | API contract coverage                              |
| `@destructive` | Changes to shared state, such as roles or settings |

Use `@destructive` alone for shared-state changes and run those tests with the dedicated single-worker command. Creating and deleting only a test's own isolated data does not require this tag; cleanup still applies.

## AI-Assisted Development

Start non-trivial work with [ai-native-workflow](.agents/skills/ai-native-workflow/SKILL.md). It routes to the relevant skill, gathers evidence, and defines a confidence-scored proposal and human review gate before implementation. Codex, Cursor, and GitHub Copilot share the project skill tree under `.agents/skills/`; the index in [AGENTS.md](AGENTS.md) explains when to load each skill.

For UI exploration, use the repository wrapper so the CLI uses its isolated browser cache and records successful exploration:

**PowerShell:**

```powershell
.\scripts\playwright-cli.cmd open $env:APP_URL
.\scripts\playwright-cli.cmd snapshot
.\scripts\playwright-cli.cmd close
```

**macOS / Linux:**

```sh
bash scripts/playwright-cli.sh open "$APP_URL"
bash scripts/playwright-cli.sh snapshot
bash scripts/playwright-cli.sh close
```

These commands require `APP_URL` in the current shell; the wrapper does not load `env/.env.dev`. Use your configured application URL when opening the exploration session.

If the CLI cannot run, stop UI authoring and report the blocker. Save exploration authentication only under `.playwright-cli/` or `.auth/`. Keep snapshots, probe specs, and other exploration artifacts out of commits. The exploration marker is bookkeeping; it does not prove the relevant page was inspected. No write-time hook is configured.

## Quality Checks

```sh
npm run lint
npx prettier --check README.md
npx playwright test tests/app/functional/login.spec.ts --project=chromium
```

Replace the example spec path with the files affected by your change. For generated artifacts, follow the [common-tasks verification checklist](.agents/skills/common-tasks/SKILL.md).

When changing agent instructions or skills, also run:

```sh
npm run check:skills
```

The maintenance scripts require Bash. From PowerShell, if `bash` resolves to an unavailable WSL installation, invoke individual scripts through Git Bash, for example:

```powershell
& 'C:\Program Files\Git\bin\bash.exe' scripts/check-agents-md.sh
```

The Husky pre-commit hook runs lint-staged and scans staged TypeScript and static JSON inputs for mechanical Constitution violations. Skill and version checks run when their related files are staged. These checks supplement code review and live test execution.

Keep commits focused, use Conventional Commit subjects, and obtain approval before committing. Do not commit real environment files, authentication state, or `test.only`.

## Troubleshooting

| Symptom                       | Check or action                                                                                                               |
| ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Missing application URL       | Create `env/.env.dev`, configure it, and check `ENVIRONMENT`.                                                                 |
| Browser executable missing    | Run `npx playwright install --with-deps chromium` for tests or `npm run playwright-cli:install-browsers` for exploration.     |
| CLI command not found         | Invoke `scripts/playwright-cli.cmd` on Windows or `bash scripts/playwright-cli.sh` on macOS/Linux.                            |
| Authentication setup fails    | Check application reachability, account credentials, endpoint enums, and the login flow in the authentication helper.         |
| Fixture import fails          | From `tests/app/api/`, `functional/`, or `e2e/`, the entry point is `../../../fixtures/pom/test-options`.                     |
| Lint fails                    | Review the reported rule and fix the cause; `npm run lint:fix` can apply automatic fixes.                                     |
| Shell script reports `bash\r` | Check `git ls-files --eol -- scripts/*.sh`; shell files should have LF working-tree endings, as required by `.gitattributes`. |

## License

[MIT](LICENSE).
