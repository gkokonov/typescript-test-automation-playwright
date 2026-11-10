# Auth bootstrap

How the scaffold signs in once per run and hands the result to every worker. The live files are `tests/app/auth-api.setup.ts` (the `setup-api` project: the token, no browser), `tests/app/auth.setup.ts` (the `setup-ui` project: the browser storage state) and `helpers/app/createStorageState.ts`. In `playwright.config.ts` the `api` project depends on `setup-api` only, so API runs never launch a browser; `chromium` depends on both.

## The chain

1. `createAppStorageState()` opens a browser, signs in through the page object with `process.env.APP_EMAIL` / `APP_PASSWORD`, and writes cookies and web storage to the run-specific path derived from `StorageStatePaths.APP`.
2. `setUserAccessToken(apiRequest)` posts the credentials to `ApiEndpoints.LOGIN`, validates the response, atomically publishes it at the run-specific path derived from `StorageStatePaths.API_ACCESS_TOKEN`, and sets `process.env.ACCESS_TOKEN` for the setup worker.
3. `loadUserAccessToken()` reads that file into `process.env.ACCESS_TOKEN` once per consuming worker. Setup projects do not load a previous token.

A `process.env` write is visible only inside the process that made it, which is why the token crosses the worker boundary as a file and not as an env var.

Global teardown removes the current run's authentication directory after the workers finish, including when tests fail.

## Adapting it to another app

Replace the sign-in steps inside the two mint functions; keep the file paths in `StorageStatePaths`, the credentials in `process.env.*` and the schema assertion. A second role (the 403 row of the API coverage matrix) is a second credential pair declared in `env/.env.example` and a second token file, minted the same way; never read an env var no helper populates.

## `process.env.ACCESS_TOKEN` is `undefined` in a test

- The `setup-api` project did not run: the spec's project lost `setup-api` in its `dependencies`, or the run filtered it out.
- The token file is missing: check that setup succeeded for this run; auth files live under `.auth/app/<run-id>/`.
- The login response changed shape: `UserResponseSchema.parse` fails inside the setup, so the setup test is red before any API test runs.
