## Manual Installation

If you prefer to install dependencies manually. Steps 1-3 and 5-6 are identical on all platforms; step 4 differs.

1. **Clone the repository:**

    ```bash
    git clone <your-repository-url>   # replace with your fork/clone URL
    cd agentic-playwright
    ```

2. **Install npm dependencies:**

    ```bash
    npm install
    ```

3. **Install Playwright test browsers:**

    ```bash
    npx playwright install --with-deps chromium
    ```

4. **Link CLI commands and install `playwright-cli` browsers:**

    **macOS / Linux:**

    ```bash
    bash scripts/link-cli.sh "$(pwd -P)"
    npm run playwright-cli:install-browsers
    ```

    Then ensure `~/.local/bin` is on your PATH (add to `~/.zshrc` or `~/.bashrc` to make permanent):

    ```bash
    export PATH="$HOME/.local/bin:$PATH"
    ```

    **Windows (PowerShell):**

    ```powershell
    npm run playwright-cli:install-browsers
    ```

5. **Set up environment variables:**

    **macOS / Linux:**

    ```bash
    cp env/.env.example env/.env.dev
    ```

    **Windows (PowerShell):**

    ```powershell
    Copy-Item env\.env.example env\.env.dev
    ```

    Edit `env/.env.dev` with your application's configuration.

6. **Run tests:**

    ```bash
    npm test
    ```

## Verify Your Installation

After any setup method, confirm all tools are available:

**macOS / Linux:**

```bash
playwright --version
playwright-cli --version
```

**Windows (PowerShell):**

```powershell
npx playwright --version
playwright-cli --version
```

Expected output (exact versions vary with your installed packages):

```
playwright --version      → Version 1.64.1
playwright-cli --version  → 0.1.23
```

---

## Getting Started: Adapting the Scaffold

This scaffold ships with example files that demonstrate every pattern. Here's how to replace them with your real application code, step by step.

### Step 1: Configure Your Environment

Edit `env/.env.dev` with your application's actual URLs and credentials:

```bash
APP_URL=https://your-real-app.com
API_URL=https://your-real-api.com
APP_EMAIL=your-test-user@example.com
APP_PASSWORD=your-test-password
```

### Step 2: Update Enums

Open `enums/app/app.ts` and replace the placeholder values with your app's actual messages, API endpoints, and storage state paths:

```typescript
export enum Messages {
    LOGIN_SUCCESS = 'Your actual success message',
    LOGIN_ERROR = 'Your actual error message',
    // Add more messages as needed
}

export enum ApiEndpoints {
    LOGIN = '/your/actual/login/endpoint',
    // Add more endpoints as needed
}
```

### Step 3: Create Your First Page Object

Replace `pages/app/app.page.ts` with a page object for your application's actual login page (or whichever page you're testing first). Use the existing file as a template:

1. Update the locators to match your app's actual elements
2. Update the action methods to match your app's actual behavior
3. Keep the same patterns: getter locators, JSDoc comments, `Promise<void>` return types

> **Tip:** If using Cursor with AI, ask it to "navigate to [your-url] and create a page object" -- the AI rules will guide it to use `playwright-cli` by default to explore the page and generate accurate locators.

### Step 4: Update Authentication Setup

Edit `helpers/app/createStorageState.ts` to match your app's actual login flow. The two functions to update:

- `createAppStorageState()` -- Browser-based login for storage state
- `setUserAccessToken()` -- API-based login for access tokens

### Step 5: Write Your First Real Test

Replace the example tests in `tests/app/functional/` with tests for your application. Follow the pattern in the example files:

```typescript
import { expect, test } from '../../../fixtures/pom/test-options';

test.describe('Your Feature', () => {
    test(
        'should do something specific',
        { tag: '@smoke' },
        async ({ appPage }) => {
            await test.step('GIVEN precondition', async () => {
                /* ... */
            });
            await test.step('WHEN action is taken', async () => {
                /* ... */
            });
            await test.step('THEN expected result', async () => {
                /* ... */
            });
        }
    );
});
```

### Step 6: Run and Verify

```bash
npm test
```

### What to Keep vs. What to Replace

| Keep As-Is                                                                | Replace With Your App                                   |
| ------------------------------------------------------------------------- | ------------------------------------------------------- |
| `fixtures/pom/test-options.ts`                                            | `pages/app/*.page.ts` (your page objects)               |
| `fixtures/pom/page-object-fixture.ts` (extend it)                         | `tests/app/**/*.spec.ts` (your tests)                   |
| `fixtures/api/plain-function.ts`                                          | `enums/app/app.ts` (your messages/endpoints)            |
| `fixtures/api/api-types.ts`                                               | `test-data/static/app/*.ts` (your test data)            |
| `fixtures/helper/helper-fixture.ts` (extend it)                           | `test-data/factories/app/*.factory.ts` (your factories) |
| `config/`, `helpers/util/`                                                | `helpers/app/createStorageState.ts` (your auth flow)    |
| `.claude/skills/` (the AI skills; `.agents/skills/` is generated from it) | `fixtures/api/schemas/app/` (your API schemas)          |
| `playwright.config.ts` (mostly)                                           | `pages/components/` (your UI components)                |

---

## Project Structure

## Configuration

### Playwright Configuration

The `playwright.config.ts` file contains all test runner settings:

| Setting            | Local                   | CI                |
| ------------------ | ----------------------- | ----------------- |
| Parallel execution | Enabled                 | Enabled           |
| Workers            | Auto                    | 1                 |
| Retries            | 0                       | 2                 |
| Reporter           | HTML (opens on failure) | Blob + HTML       |
| Traces             | On first retry          | On first retry    |
| Screenshots        | On failure              | On failure        |
| Videos             | Retain on failure       | Retain on failure |

### Browser Projects

| Project     | Description                                  | Dependencies            |
| ----------- | -------------------------------------------- | ----------------------- |
| `setup-api` | API token over HTTP (`auth-api.setup.ts`)    | None                    |
| `setup-ui`  | Browser storage state (`auth.setup.ts`)      | None                    |
| `api`       | API tests, request context only (no browser) | `setup-api`             |
| `chromium`  | Main tests on Chrome                         | `setup-api`, `setup-ui` |

### Timeouts

| Timeout            | Value      |
| ------------------ | ---------- |
| Test timeout       | 60 seconds |
| Action timeout     | 10 seconds |
| Navigation timeout | 30 seconds |
| Expect timeout     | 10 seconds |

## Environment Variables

### Setup

1. Copy the example file:

    ```bash
    cp env/.env.example env/.env.dev
    ```

2. Configure your variables in `env/.env.dev`:

    ```bash
    # Application URL (frontend)
    APP_URL=https://your-app-url.com

    # API URL (backend)
    API_URL=https://your-api-url.com

    # Test User Credentials
    APP_EMAIL=your-email@example.com
    APP_PASSWORD=your-secure-password

    # Additional service URLs
    UTILITY_URL=https://your-utility-service.com
    ```

### Switching Environments

```bash
# Default (dev)
npm test

# Staging environment
ENVIRONMENT=staging npm test

# Production environment (read-only tests)
ENVIRONMENT=prod npm test
```

### Creating New Environments

Create `env/.env.<environment>` files:

- `env/.env.dev` -- Development
- `env/.env.staging` -- Staging
- `env/.env.prod` -- Production

## Running Tests

### Basic Commands

```bash
# Run all tests (excludes @destructive)
npm test

# Run tests on specific browser (excludes @destructive)
npm run test:chromium

# Run in headed mode (see browser)
npm run test:headed

# Run in debug mode (Playwright Inspector)
npm run test:debug

# Run with UI mode (interactive)
npm run test:ui
```

### Running by Tag

Run tests filtered by tag. See the [Tag Reference](#tag-reference) section for the full list of available tags and their meanings.

```bash
# Run by importance level
npm run test:smoke          # Critical path tests
npm run test:sanity         # Key functionality verification
npm run test:regression     # Full regression coverage

# Run by test type
npm run test:api            # API-only tests
npm run test:e2e            # End-to-end user flows

# Run destructive tests only (single worker, isolated)
npm run test:destructive
```

### CI Mode

Optimized for CI environments with single worker, blob reports:

```bash
npm run test:ci
```

### View Reports

```bash
npm run report
```

---

## Tag Reference

Tags control selective test execution. Each test has **exactly one** tag. Apply tags to individual tests via `{ tag: '@smoke' }` -- **never** on `test.describe()` blocks. **`@functional` is forbidden.**

### The Single-Tag Rule

A test gets exactly one tag from this set. **`@destructive` is the heaviest tag and always wins -- but only for shared/global state.** A test that mutates state other tests or users depend on (locale, permissions, roles, guest access, feature flags, global settings) is tagged **only** `@destructive`, regardless of what importance or type tag it would otherwise carry. A test that creates and cleans up **only its own isolated data** is NOT destructive -- tag it by importance (`@smoke`/`@regression`/`@api`/…).

| Tag            | Purpose                                                                                                                               | npm Command                |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------- | -------------------------- |
| `@smoke`       | Critical path -- run first and frequently                                                                                             | `npm run test:smoke`       |
| `@sanity`      | Key functionality verification                                                                                                        | `npm run test:sanity`      |
| `@regression`  | Full regression coverage of a single behaviour                                                                                        | `npm run test:regression`  |
| `@e2e`         | End-to-end multi-feature user journey                                                                                                 | `npm run test:e2e`         |
| `@api`         | API contract and schema validation                                                                                                    | `npm run test:api`         |
| `@destructive` | Mutates **shared/global** state -- locale, permissions, roles, guest access, feature flags, global settings (overrides any other tag) | `npm run test:destructive` |

### How Tag Filtering Works

- **`npm test`** runs the full suite **excluding** `@destructive` tests (via `--grep-invert`), because the full suite runs in parallel and destructive tests modify shared state.
- **Tag-specific commands** (e.g., `test:smoke`) use `--grep @smoke` to run only matching tests. Because each test has exactly one tag, a `@destructive` test only runs under `npm run test:destructive` -- not under `test:smoke`, `test:regression`, etc.
- **`npm run test:destructive`** runs only `@destructive` tests with `--workers=1` for sequential execution.

### The `@destructive` Tag

`@destructive` is reserved for **shared/global** state -- state that lives outside the test and that other tests, users, or sessions depend on: changing the locale, granting/removing permissions, roles, or guest access, toggling feature flags or global settings, or mutating shared seed data every test reads (e.g. "delete all users"). They follow strict rules:

1. **Excluded from `npm test`** -- The base command uses `--grep-invert @destructive` to prevent them from running in the parallel full-suite execution.
2. **Run via dedicated command** -- `npm run test:destructive` with a single worker.

**Not destructive:** a test that creates its **own** record, asserts, then deletes **only that record** in cleanup is _isolated_, not destructive. Tag it by importance and let it run in the parallel suite.

**Cleanup applies to any state-mutating test.** Every test that writes persistent state -- `@destructive` shared-state tests **and** isolated own-data tests -- MUST use `test.afterEach()` or `test.afterAll()` to revert what it wrote, so subsequent tests always run against a clean environment.

```typescript
test.describe('admin data management', () => {
    test.afterEach(async ({ apiRequest }) => {
        // REQUIRED: Revert state changes made by the test
        await apiRequest({
            method: 'POST',
            url: '/api/admin/reset',
            baseUrl: process.env.API_URL,
        });
    });

    test(
        'should delete all inactive users',
        { tag: '@destructive' },
        async ({ apiRequest }) => {
            // Test modifies shared state, afterEach reverts it
        }
    );
});
```

### Forbidden Tag Patterns

```typescript
// FORBIDDEN -- @functional is not a valid tag
test('should login', { tag: '@functional' }, async ({ appPage }) => { ... });

// FORBIDDEN -- combining tags is not allowed
test('should authenticate', { tag: ['@smoke', '@api'] }, async ({ apiRequest }) => { ... });

// FORBIDDEN -- @destructive must be the ONLY tag (it always wins)
test('should purge cache', { tag: ['@regression', '@destructive'] }, async ({ apiRequest }) => { ... });

// FORBIDDEN -- tags belong on the test, not on the describe
test.describe('Feature @smoke', () => { ... });
```

---

## Writing Tests

### Test File Structure

Always import from the merged fixtures in `test-options.ts`:

```typescript
import { expect, test } from '../../../fixtures/pom/test-options';

test.describe('Feature Tests', () => {
    test.beforeEach(async ({ appPage }) => {
        await appPage.openHomePage();
    });

    test('should perform action', { tag: '@smoke' }, async ({ appPage }) => {
        await test.step('GIVEN user is on the home page', async () => {
            await expect(appPage.appTitle).toBeVisible();
        });

        await test.step('WHEN user performs an action', async () => {
            // Perform action
        });

        await test.step('THEN expected result should occur', async () => {
            // Assert result
        });
    });
});
```

### Using Test Steps

Use `test.step()` for better readability and reporting with Given/When/Then structure:

```typescript
test('descriptive test name', async ({ appPage }) => {
    await test.step('GIVEN user is on the login page', async () => {
        await appPage.openHomePage();
    });

    await test.step('WHEN user enters valid credentials', async () => {
        await appPage.login(email, password);
    });

    await test.step('THEN user should see dashboard', async () => {
        await expect(appPage.username).toBeVisible();
    });
});
```

### Data-Driven Tests

Use loops outside of test blocks to generate individual tests:

```typescript
import { INVALID_LOGIN_ATTEMPTS } from '../../../test-data/static/app/invalidCredentials';

for (const { description, email, password } of INVALID_LOGIN_ATTEMPTS) {
    test(
        `should show error for ${description}`,
        { tag: '@regression' },
        async ({ appPage }) => {
            await appPage.openHomePage();
            await appPage.login(email, password);
            await expect(appPage.errorMessage).toBeVisible();
        }
    );
}
```

## Page Object Model

### Creating Page Objects

Page objects encapsulate locators and actions for a page or component:

```typescript
import { expect, Locator, Page } from '@playwright/test';
import { Messages } from '../../enums/app/app';

export class MyPage {
    constructor(private readonly page: Page) {}

    // ==================== Locators ====================

    get inputField(): Locator {
        return this.page.getByLabel('Email address');
    }

    get submitButton(): Locator {
        return this.page.getByRole('button', { name: 'Submit' });
    }

    // ==================== Feedback Locators ====================

    get successMessage(): Locator {
        return this.page.getByText(Messages.SUBMIT_SUCCESS);
    }

    get errorMessage(): Locator {
        return this.page.getByText(Messages.SUBMIT_FAILED);
    }

    // ==================== Actions ====================

    /**
     * Submits the form and waits for the response.
     * @param {string} value - The value to enter in the form.
     * @returns {Promise<void>}
     */
    async submitForm(value: string): Promise<void> {
        await this.inputField.fill(value);
        await this.submitButton.click();
        await this.page.waitForResponse((response) =>
            response.url().includes('/api/submit')
        );
    }
}
```

### Locator Priority

Use semantic locators in this order of preference:

1. `page.getByRole()` -- Accessibility-based (recommended)
2. `page.getByLabel()` -- Form labels
3. `page.getByPlaceholder()` -- Placeholder text
4. `page.getByText()` -- Text content
5. `page.getByTestId()` -- Test IDs (fallback)
6. `page.locator()` -- CSS/XPath (last resort)

### Registering Page Objects

Add new page objects to `fixtures/pom/page-object-fixture.ts`:

```typescript
import { test as base } from '@playwright/test';
import { AppPage } from '../../pages/app/app.page';
import { MyNewPage } from '../../pages/app/my-new.page';

export type FrameworkFixtures = {
    appPage: AppPage;
    myNewPage: MyNewPage;
};

export const test = base.extend<FrameworkFixtures>({
    appPage: async ({ page }, use) => {
        await use(new AppPage(page));
    },
    myNewPage: async ({ page }, use) => {
        await use(new MyNewPage(page));
    },
});
```

### Using the `resetStorageState` Fixture

The framework provides a `resetStorageState` fixture that clears cookies, permissions and the app origin's `localStorage` and `sessionStorage` (it navigates to `APP_URL` first, because web storage is per origin). Call it in `beforeEach` when a test must start signed out inside an authenticated project: login flows, or forms that pre-fill a signed-in user's data:

```typescript
test.beforeEach(async ({ resetStorageState, appPage }) => {
    await resetStorageState();
    await appPage.openHomePage();
});

test('should login successfully', async ({ appPage }) => {
    await appPage.login(email, password);
    await expect(appPage.username).toBeVisible();
});
```

### Component Pattern

Reusable UI components can be composed into Page Objects:

```typescript
import { NavigationComponent } from '../components/navigation.component';

export class DashboardPage {
    readonly nav: NavigationComponent;

    constructor(private readonly page: Page) {
        this.nav = new NavigationComponent(page);
    }
}

// Usage in tests
await dashboardPage.nav.clickHome();
await dashboardPage.nav.logout();
```

## API Testing

### Making API Requests

Use the `apiRequest` fixture for all API calls in tests:

```typescript
import { expect, test } from '../../../fixtures/pom/test-options';
import {
    UserResponse,
    UserResponseSchema,
} from '../../../fixtures/api/schemas/app/userSchema';

test('should return user data', { tag: '@api' }, async ({ apiRequest }) => {
    const { status, body } = await apiRequest<UserResponse>({
        method: 'GET',
        url: '/api/users/me',
        baseUrl: process.env.API_URL,
        headers: process.env.ACCESS_TOKEN,
    });

    expect(status).toBe(200);
    expect(UserResponseSchema.parse(body)).toBeTruthy();
});
```

Use the `apiRequest` fixture directly for all API work -- assertions, `beforeEach`/`afterEach`, one-off calls. Do not create separate helpers for every endpoint.

### API Request Options

| Option     | Type                                              | Description                                   |
| ---------- | ------------------------------------------------- | --------------------------------------------- |
| `method`   | `'GET' \| 'POST' \| 'PUT' \| 'DELETE' \| 'PATCH'` | HTTP method                                   |
| `url`      | `string`                                          | Endpoint path                                 |
| `baseUrl`  | `string` (optional)                               | Base URL to prepend                           |
| `body`     | `Record<string, unknown>` (optional)              | Request payload                               |
| `headers`  | `string` (optional)                               | Authentication token for Authorization header |
| `authType` | `'Bearer' \| 'Token' \| 'Basic'` (optional)       | Auth scheme (default: `'Bearer'`)             |

### Schema Validation with Zod

Define schemas in `fixtures/api/schemas/`. Zod 4 promotes string format validators to top-level APIs for better tree-shaking and clarity:

```typescript
import { z } from 'zod';

export const UserResponseSchema = z.strictObject({
    id: z.uuid(),
    email: z.email(),
    token: z.string(),
});

export type UserResponse = z.infer<typeof UserResponseSchema>;
```

Use schemas to validate responses:

```typescript
const { body } = await apiRequest<UserResponse>({ ... });

// This will throw if the response doesn't match the schema
const validatedUser = UserResponseSchema.parse(body);
```

### Helper Fixtures for Important Setup/Teardown

For critical, recurring setup/teardown reused across many test files, use helper fixtures in `fixtures/helper/helper-fixture.ts`:

```typescript
// In tests -- the fixture handles lifecycle automatically
test('should edit resource', async ({ createdResource, appPage }) => {
    // createdResource was created via API before this test
    await appPage.navigateToResource(createdResource.id);
    // createdResource is deleted via API after this test (even on failure)
});
```

See `fixtures/helper/helper-fixture.ts` for the full setup/teardown pattern. Use helpers only when the same multi-step setup/teardown is duplicated across 3+ test files.

## Data Strategy

This framework uses a **bifurcated data strategy** to ensure both determinism and test isolation:

### Static Data (`test-data/static/`)

Immutable TypeScript files (`.ts` with `as const` exports) for **curated boundary and invalid data**. This data never changes, ensuring reproducible tests for edge cases. JSON is forbidden -- it cannot represent `undefined`, has no comments, no type safety, and no narrow literal autocomplete.

The scaffold follows a **three-tier rule** (see the `data-strategy` skill):

1. **Universal type-mismatch arrays** (wrong type for any field of a given primitive type) live in `test-data/static/util/invalid-values.ts` as exported `as const` tuples (`INVALID_STRING_VALUES`, `INVALID_NUMBER_VALUES`, `INVALID_BOOLEAN_VALUES`, `INVALID_UUID_VALUES`, `INVALID_ENUM_VALUES`, `INVALID_ARRAY_VALUES`, `INVALID_OBJECT_VALUES`). Import; never redefine inline.
2. **Domain-specific curated invalid sets** (invalid email formats, weak passwords, forbidden enum values, locale strings, etc.) live under `test-data/static/{area}/*.ts` -- this is where new static files usually go.
3. **Field-specific boundary / range values** (e.g., out-of-range for a `1..5` number) may stay inline in the spec file when used in exactly one place.

```
test-data/static/
├── util/
│   └── invalid-values.ts       # Universal type-mismatch tuples (as const)
└── app/
    └── invalidCredentials.ts   # Domain-specific: INVALID_EMAILS, INVALID_PASSWORDS, INVALID_LOGIN_ATTEMPTS
```

**Usage:**

```typescript
import { INVALID_LOGIN_ATTEMPTS } from '../../../test-data/static/app/invalidCredentials';

for (const { description, email, password } of INVALID_LOGIN_ATTEMPTS) {
    test(
        `should reject ${description}`,
        { tag: '@regression' },
        async ({ appPage }) => {
            await appPage.login(email, password);
            await expect(appPage.errorMessage).toBeVisible();
        }
    );
}
```

### Dynamic Data (`test-data/factories/`)

TypeScript factory functions using **Faker + Zod** for generating unique, valid data per test run. This prevents data collision in parallel execution.

```
test-data/factories/
└── app/
    └── user.factory.ts  # generateUser(), generateLoginCredentials()
```

**Usage:**

```typescript
import {
    generateUser,
    generateLoginCredentials,
} from '../../../test-data/factories/app/user.factory';

test('should create user with unique data', async ({ apiRequest }) => {
    // Generate unique user data for this test run
    const user = generateUser();
    const credentials = generateLoginCredentials();

    // Use in API calls or UI interactions
    const { status } = await apiRequest({
        method: 'POST',
        url: '/api/users',
        baseUrl: process.env.API_URL,
        body: { email: credentials.email, password: credentials.password },
    });

    expect(status).toBe(201);
});
```

**Factory with Overrides:**

```typescript
// Generate user with specific properties
const adminUser = generateUser({ email: 'admin@company.com' });

// Generate credentials with specific password
const creds = generateLoginCredentials({ password: 'SpecificPassword123!' });
```

## Authentication Setup

### How It Works

1. Two setup projects run before the main tests: `setup-api` (`tests/app/auth-api.setup.ts`) logs in over HTTP and saves the access token to `.auth/app/apiAccessToken.json`; `setup-ui` (`tests/app/auth.setup.ts`) logs in through the browser and saves the storage state
2. The `api` project depends on `setup-api` only, so API tests never launch a browser and pass where the UI is unreachable (fresh environments, CI behind bot protection); the `chromium` project depends on both
3. UI tests use the saved storage state (already authenticated)
4. Every worker of the `api` project loads the token file into `process.env.ACCESS_TOKEN` before its first test

### Storage State

The storage state is saved to `.auth/app/appStorageState.json` and includes:

- Cookies
- localStorage data
- Session information

The access token lives in a separate file because Playwright runs each project in its own worker processes: a `process.env` write made in the setup worker is not visible to other workers, so the setup writes the validated login response to `.auth/app/apiAccessToken.json` and the `apiRequest` fixture file reads it once per worker.

### Using Authentication in Tests

Tests using the `chromium` project automatically load the storage state:

```typescript
// No login needed - user is already authenticated
test('should show dashboard', async ({ appPage }) => {
    await appPage.openHomePage();
    await expect(appPage.username).toBeVisible();
});
```

### Using API Token

For API tests requiring authentication:

```typescript
const { status, body } = await apiRequest<UserData>({
    method: 'GET',
    url: '/api/protected-resource',
    baseUrl: process.env.API_URL,
    headers: process.env.ACCESS_TOKEN, // minted by auth-api.setup.ts, loaded per worker
});
```

## Code Quality

### Linting

```bash
# Check for issues
npm run lint

# Auto-fix issues
npm run lint:fix
```

### Formatting

```bash
npm run format
```

### Pre-commit Hooks

Husky runs on every commit:

- ESLint with auto-fix (`--max-warnings 0`) and Prettier on the staged TypeScript (lint-staged), then the Constitution scan (`enforce_constitution.py --scan`) over the same files
- The rule-layer gates (`check:agents-md`, `check:skills-sync`, `check:skills-shape`, `skills:verify`, `check:skills-drift`, `check:skills-references`, `check:skills-headings`, `check:skills-crossrefs`) -- only when `AGENTS.md`, `CLAUDE.md`, `AI-WORKFLOWS.md`, a skill tree, the rule manifest, `skills-lock.json`, the Constitution hook or one of their gate scripts is staged
- Version drift lint (`check:version`) -- only when `package.json` or `package-lock.json` is staged

A commit that touches none of those paths pays for lint-staged and the scan alone. The gates read the working tree, so stage the whole change; a deleted or renamed gated file triggers its block as well.

### Constitution enforcement

`scripts/enforce_constitution.py --scan` checks the mechanically detectable subset of `AGENTS.md`. The pre-commit hook and PR reviewer use this shared scanner; `npm run check:skills-drift` checks its rule mapping. It checks files on disk and cannot verify judgment-based rules such as contract fidelity or whether live exploration happened. Scan failures must be investigated; this repository does not configure a write-time agent hook.

| Hook rule                                                 | Scope                                                                  | Constitution row          |
| --------------------------------------------------------- | ---------------------------------------------------------------------- | ------------------------- |
| `no-playwright-test-import`                               | spec and setup files                                                   | Imports                   |
| `no-hard-wait`                                            | every `.ts`                                                            | No Hard Waits             |
| `no-loose-schema`                                         | `fixtures/api/schemas/**`                                              | No Loose Schemas          |
| `no-xpath`                                                | `pages/**`, `tests/**`                                                 | No XPath                  |
| `no-json-static-data`                                     | `test-data/static/**`                                                  | No JSON Static Data       |
| `no-functional-tag`, `no-multiple-tags`, `no-unknown-tag` | spec and setup files                                                   | No Multiple Tags          |
| `no-missing-tag`                                          | spec files                                                             | No Multiple Tags          |
| `no-tags-on-describe`                                     | spec and setup files                                                   | No Tags on Describe       |
| `no-manual-instantiation`                                 | spec and setup files                                                   | No Manual Instantiation   |
| `no-runtime-code-in-static-data`                          | `test-data/static/**`                                                  | Data Strategy             |
| `no-hardcoded-url`, `no-hardcoded-goto-url`               | tests, pages, fixtures, helpers, enums, config, `playwright.config.ts` | Sources of Truth          |
| `no-inline-universal-invalids`                            | spec and setup files                                                   | Data Strategy             |
| `no-jsdoc-on-locators`                                    | `pages/**`                                                             | No JSDoc on Locators      |
| `no-hardcoded-test-content`                               | spec and setup files                                                   | No Hardcoded Test Content |
| `no-eslint-disable-scaffold`                              | every `.ts`                                                            | Linting                   |

Live exploration before UI work remains an agent instruction. The CLI wrappers record an exploration marker, but the marker alone does not prove that the relevant application was explored. The scanner is a backstop, not a replacement for the full Constitution or review checklist.

### Versioning

The version in `package.json` is the source of truth. Update it and the lockfile together, then verify them:

```bash
npm run version:stamp -- 3.0.0
npm run check:version
```

The version check runs in pre-commit.

## Coding Standards

### TypeScript

| Rule             | Description                                           |
| ---------------- | ----------------------------------------------------- |
| Type annotations | Always specify types for parameters and return values |
| Avoid `any`      | Use proper types or `unknown`                         |
| Strict mode      | Enabled in tsconfig.json                              |
| ESNext features  | Optional chaining, nullish coalescing                 |

### Naming Conventions

| Type             | Convention                 | Example                         |
| ---------------- | -------------------------- | ------------------------------- |
| Variables        | camelCase                  | `userName`                      |
| Functions        | camelCase                  | `getUserData()`                 |
| Classes          | PascalCase                 | `AppPage`                       |
| Interfaces/Types | PascalCase                 | `UserResponse`                  |
| Enums            | PascalCase                 | `Roles`                         |
| Enum values      | SCREAMING_SNAKE            | `ADMIN`                         |
| Files            | kebab-case or dot notation | `user-schema.ts`, `app.page.ts` |

### File Naming Conventions

| Type             | Directory                   | Pattern               | Example                   |
| ---------------- | --------------------------- | --------------------- | ------------------------- |
| Page objects     | `pages/app/`                | `[name].page.ts`      | `login.page.ts`           |
| Components       | `pages/components/`         | `[name].component.ts` | `navigation.component.ts` |
| Functional tests | `tests/app/functional/`     | `[name].spec.ts`      | `login.spec.ts`           |
| API tests        | `tests/app/api/`            | `[name].spec.ts`      | `login.spec.ts`           |
| E2E tests        | `tests/app/e2e/`            | `[name].spec.ts`      | `checkout.spec.ts`        |
| Setup files      | `tests/app/`                | `[name].setup.ts`     | `auth.setup.ts`           |
| Data factories   | `test-data/factories/app/`  | `[name].factory.ts`   | `user.factory.ts`         |
| Static data      | `test-data/static/app/`     | `[name].ts`           | `invalidCredentials.ts`   |
| Zod schemas      | `fixtures/api/schemas/app/` | `[name]Schema.ts`     | `userSchema.ts`           |

### Page Object Guidelines

1. **Locators as Getters** -- Use `get` accessors for all locators
2. **Semantic Locators** -- Prefer `getByRole`, `getByLabel` over CSS/XPath
3. **Three Locator Sections** -- Every page object should have: interactive element locators, feedback/validation message locators, and action methods
4. **Action Methods** -- Methods should represent complete user flows
5. **JSDoc on Actions Only** -- Add JSDoc with `@param` and `@returns` to action methods only. Never add JSDoc to locator getters.

### Test Guidelines

1. **Descriptive Names** -- Test names should describe expected behavior
2. **Test Tags** -- Use importance tags (`@smoke`, `@sanity`, `@regression`), type tags (`@e2e`, `@api`), and `@destructive` for tests that modify shared/global state (see [Tag Reference](#tag-reference))
3. **Tags on Tests Only** -- Apply tags to individual tests via `{ tag: '@...' }`, never on `test.describe()` blocks
4. **Test Steps** -- Use `test.step()` with Given/When/Then for readability
5. **Independence** -- Tests should be independent and not rely on other tests
6. **Web-first Assertions** -- Use `toBeVisible`, `toHaveText`, etc.
7. **No Hardcoded Timeouts** -- Rely on Playwright's auto-waiting

---

## Core Principles (The Constitution)

The Constitution has one home, [`AGENTS.md`](AGENTS.md): 14 MUST, 5 SHOULD and 17 WON'T rules, one line each, with the skill that owns the detail named in the Skills Index. Every harness loads that file (Claude Code through `CLAUDE.md`), every hook message cites a rule by its name there, and `npm run check:skills-drift` proves each rule is anchored in its owning skill. This README does not repeat the rules, so they cannot drift here.

What they amount to:

- **One import point, injected page objects.** `test` and `expect` come from `fixtures/pom/test-options.ts`; page objects are fixtures, never `new SomePage(page)` in a spec.
- **Sources of truth, not literals.** URLs and credentials from `process.env.*`, paths and messages from `enums/`, test content from factories and `test-data/static/`.
- **Strict contracts.** `z.strictObject()` schemas built from the API document; a runtime mismatch is `test.skip` plus `// FIXME`, never a loosened schema.
- **Explore before you generate.** The live app through `playwright-cli` before any page object or selector; the OpenAPI document before any API test.
- **One tag per test, web-first assertions, no hard waits, lint clean, affected tests green before "done".**

The mechanical subset is scanned at commit and review time; see [Constitution enforcement](#constitution-enforcement).

---

## AI-Assisted Development Workflow

This framework is optimized for AI-assisted test development. Follow this workflow for the best results:

### The Golden Rule: Verify -> Commit -> Proceed

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AI-ASSISTED DEVELOPMENT CYCLE                       │
│                                                                             │
│    ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐          │
│    │  PROMPT  │────▶│  REVIEW  │────▶│  VERIFY  │────▶│  COMMIT  │──┐       │
│    │          │     │   CODE   │     │  TESTS   │     │          │  │       │
│    └──────────┘     └──────────┘     └──────────┘     └──────────┘  │       │
│         ▲                                                           │       │
│         └───────────────────────────────────────────────────────────┘       │
│                              Next prompt                                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Step-by-Step Best Practices

| Step                         | Action                                                                                                                                  | Why It Matters                                                                  |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| **1. One Task Per Prompt**   | Focus each prompt on a single, well-defined task (one page object, one test file, one schema)                                           | Smaller changes are easier to review, test, and revert if needed                |
| **2. Review Generated Code** | Read through the AI-generated code before running it. Check for selector accuracy, proper patterns, and adherence to Constitution rules | Catch issues early before they propagate to dependent code                      |
| **3. Verify Tests Pass**     | Run the generated tests: `npm test` or specific test commands. Ensure they pass consistently                                            | A failing test committed now becomes technical debt later                       |
| **4. Commit Working Code**   | Once verified, commit immediately with a descriptive message                                                                            | Creates a safe checkpoint. Future prompts cannot break what's already committed |
| **5. Proceed to Next Task**  | Only after committing, move to the next prompt                                                                                          | Builds incrementally on verified, working code                                  |

### Why This Workflow?

- **Isolation of Changes**: Each commit represents a verified, working state
- **Easy Rollback**: If a prompt produces broken code, simply `git checkout` to the last working commit
- **Incremental Progress**: Complex features are built step-by-step with verification at each stage
- **AI Context Preservation**: Committed code becomes part of the codebase context for future prompts
- **Reduced Debugging**: Issues are caught immediately, not after multiple layers of changes

### Example Workflow Session

```bash
# Prompt 1: "Create a LoginPage page object for https://app.example.com/login"
# → Review the generated code
# → Run: npm run test:smoke (verify any smoke tests still pass)
# → Commit: git add . && git commit -m "Add LoginPage page object"

# Prompt 2: "Create login tests for valid and invalid credentials"
# → Review the generated tests
# → Run: npx playwright test tests/<area>/functional/<file>.spec.ts (verify tests pass)
# → Commit: git add . && git commit -m "Add login functional tests"

# Prompt 3: "Add password reset flow to LoginPage"
# → Review the additions
# → Run tests
# → Commit: git add . && git commit -m "Add password reset flow"
```

### Recovery from Bad Prompts

If a prompt produces unsatisfactory results, simply discard the changes and try again:

```bash
# Discard all uncommitted changes and continue
git checkout .
```

If you need to go back to a specific commit (e.g., after multiple bad prompts):

```bash
# View commit history to find the commit you want
git log --oneline

# Go back to a specific commit (replace <commit-hash> with actual hash)
git reset --hard <commit-hash>

# Example: go back to the commit before the last 3 commits
git reset --hard HEAD~3
```

This is why **committing after each verified change** is critical. Each commit is a safe checkpoint you can return to at any time.

---

## AI Rules Architecture

One orchestrator, one canonical skill tree, one generated copy, one enforcement layer. It works with **Claude Code**, **Codex**, **Cursor** and **GitHub Copilot**.

### How It Works

- **[`AGENTS.md`](AGENTS.md)** -- always loaded. The Constitution (36 one-line rules), the workflow (proceed, verify, commit) and the Skills Index (17 skills, one read-when line each). Codex, Cursor and Copilot read it natively; Claude Code imports it from `CLAUDE.md`, which adds the Claude-only notes (hooks, protected paths, status line). `npm run check:agents-md` caps it at 100 lines / 800 words and keeps the index equal to the skill directories.
- **`.claude/skills/<name>/SKILL.md`** -- the canonical skills, at most 100 lines each: a Critical block (the rules), a Procedure (the steps) and References (the long material in `references/`, read on demand). Edit skills here only.
- **`.agents/skills/`** -- a byte-for-byte copy generated by `npm run skills:sync`. Codex loads skills from this directory; Cursor and VS Code Copilot read both trees (the same skills, listed twice). `npm run check:skills-sync` fails when it differs from the canonical tree, in content or in file modes.
- **Enforcement** -- the shared scanner checks mechanical rules at pre-commit and PR review time.
- **[`AI-WORKFLOWS.md`](AI-WORKFLOWS.md)** -- the step map for the common tasks, each step citing its owning skill and step.

### Tool Comparison

| Feature              | Claude Code                          | Codex                                 | Cursor                    | GitHub Copilot                                               |
| -------------------- | ------------------------------------ | ------------------------------------- | ------------------------- | ------------------------------------------------------------ |
| Orchestrator         | `CLAUDE.md` imports `AGENTS.md`      | `AGENTS.md`                           | `AGENTS.md`               | `AGENTS.md`                                                  |
| Skills               | `.claude/skills/`                    | `.agents/skills/`                     | both trees                | both trees                                                   |
| Skill activation     | on demand, from the index            | on demand, from the index or `$skill` | on demand, from the index | on demand, from the index                                    |
| Write-time hook      | not configured                      | no                                    | no                        | no                                                           |
| Scan, pre-commit     | yes                                  | yes                                   | yes                       | yes                                                          |
| Review-time scan     | `pr-reviewer` skill                  | `pr-reviewer` skill                   | `pr-reviewer` skill       | `pr-reviewer` skill |
| Browser exploration  | `playwright-cli`                     | `playwright-cli` (see the note)       | `playwright-cli`          | `playwright-cli`                                             |

Codex notes: it has no write-time hook, so the scan in pre-commit is its enforcement. On macOS its workspace-write sandbox cannot launch Chromium; run the exploration step with `codex --sandbox danger-full-access` or explore outside Codex first. Without an OpenAI account, `codex exec --oss --local-provider ollama -m gpt-oss:20b` runs the same harness on a local model; start Ollama with `OLLAMA_CONTEXT_LENGTH=131072`.

### Skills Index

The index is the `## Skills Index` section of [`AGENTS.md`](AGENTS.md): one line per skill, name and read-when. It is not repeated here; `npm run check:agents-md` keeps it equal to the directories under `.claude/skills/`.

---

## Architecture Overview

The framework uses a layered fixture composition pattern that provides clean separation of concerns:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         test-options.ts                                 │
│                    (Single Import Point for Tests)                      │
│                                                                         │
│     import { test, expect } from 'fixtures/pom/test-options';           │
└──────────┬──────────────────────┬───────────────────────┬───────────────┘
           │                      │                       │
    mergeTests()           mergeTests()            mergeTests()
           │                      │                       │
┌──────────▼────────────┐  ┌──────▼──────────────┐  ┌────▼──────────────────┐
│ page-object-fixture   │  │ api-request-fixture │  │ helper-fixture.ts     │
│                       │  │                     │  │                       │
│ • appPage: AppPage    │  │ • apiRequest<T>()   │  │ • createdResource     │
│ • resetStorageState() │  │   - Type-safe       │  │ • (your setup/        │
│                       │  │   - Zod validation  │  │    teardown fixtures) │
└──────────┬────────────┘  └──────┬──────────────┘  └──────┬────────────────┘
           │                      │                        │
┌──────────▼───────────┐  ┌────────▼──────────────┐  ┌─────▼─────────────────┐
│    pages/            │  │ fixtures/api/schemas/ │  │ fixtures/api/         │
│                      │  │                       │  │ plain-function.ts     │
│ • AppPage            │  │ • UserResponseSchema  │  │ (internal impl used   │
│ • NavigationComponent│  │ • ErrorResponseSchema │  │  by fixture & helpers)│
│ • (Your Pages)       │  │ • (Your Schemas)      │  └───────────────────────┘
└──────────────────────┘  └───────────────────────┘
```

### Key Architectural Decisions

| Decision                 | Rationale                                                                           |
| ------------------------ | ----------------------------------------------------------------------------------- |
| **Single import point**  | Tests always import from `test-options.ts`, ensuring consistent fixture access      |
| **`apiRequest` fixture** | Primary tool for all API calls in tests -- injected via DI, type-safe with generics |
| **Helper fixtures**      | Important recurring setup/teardown with guaranteed lifecycle (setup/yield/teardown) |
| **Fixture composition**  | `mergeTests()` combines POM, API, and helper fixtures without coupling              |
| **Schema validation**    | Zod schemas provide runtime type safety for API responses                           |
| **Component pattern**    | Reusable UI components (like `NavigationComponent`) can be composed into pages      |

---

## Troubleshooting

### `APP_URL is undefined` or tests navigate to `undefined`

The environment file is missing or not loaded. Ensure `env/.env.dev` exists:

```bash
cp env/.env.example env/.env.dev
```

Then edit it with your application's actual URLs and credentials.

### `browserType.launch: Executable doesn't exist`

Playwright test browsers are not installed. Run:

```bash
npx playwright install
```

If the error is coming from `playwright-cli`, refresh its separate browser cache instead:

```bash
npm run playwright-cli:install-browsers
```

### `playwright-cli: command not found`

The scaffold links CLI tools into `~/.local/bin`. Add it to your shell PATH and re-run the linker:

```bash
export PATH="$HOME/.local/bin:$PATH"
bash scripts/link-cli.sh "$(pwd -P)"
```

### `bash\r: No such file or directory` when running scripts in the container

Shell scripts have Windows-style CRLF line endings. The `\r` is appended to `bash` in the shebang, making the kernel look for an interpreter called `bash\r`. This happens when Git's `core.autocrlf=true` (the Windows default) converts LF to CRLF on checkout, and the files are then bind-mounted into the Linux container.

The `.gitattributes` file prevents this for new clones, but existing working trees need a one-time re-normalization. On the **host** (Windows), run:

```bash
# Delete affected files and let Git re-checkout them with LF endings
rm scripts/*.sh .devcontainer/Dockerfile .devcontainer/post-create.sh
git checkout -- scripts/ .devcontainer/
```

Verify with `git ls-files --eol -- scripts/*.sh` -- all files should show `w/lf`.

### Auth setup fails and all tests are skipped

The setup projects run before the test projects: `setup-api` before `api` and `chromium`, `setup-ui` before `chromium`. If one fails (wrong credentials, app not reachable), every project that depends on it is skipped entirely. Check:

1. Your `APP_URL` and `API_URL` are reachable from your machine
2. Your `APP_EMAIL` and `APP_PASSWORD` are valid credentials
3. The login flow in `helpers/app/createStorageState.ts` matches your app's actual login form

### `Cannot find module '../fixtures/pom/test-options'`

Import paths are relative to the test file location. From `tests/app/functional/`:

```typescript
import { expect, test } from '../../../fixtures/pom/test-options';
```

Count the directory levels carefully. Spec files in `tests/app/api/` and `tests/app/e2e/` use the same relative path.

### ESLint errors after generating code

Run the auto-fixer:

```bash
npm run lint:fix
```

If errors persist, check that the generated code follows the [Core Principles](#core-principles-the-constitution) -- common violations are missing return types, use of `any`, or raw locators.
