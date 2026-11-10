/**
 * Application-specific constants.
 * Add your application's repeated string values here.
 *
 * @example
 * ```ts
 * import { Messages, ApiEndpoints } from '../../enums/app/app';
 *
 * await expect(page.getByText(Messages.LOGIN_ERROR)).toBeVisible();
 * ```
 */

/** Common UI messages — every value verified against the live demo app */
export enum Messages {
    LOGIN_ERROR = 'Invalid email or password',
    EMAIL_REQUIRED = 'Email is required',
    PASSWORD_REQUIRED = 'Password is required',
    EMAIL_FORMAT_INVALID = 'Email format is invalid',
}

/** UI route paths */
export enum AppRoutes {
    LOGIN = '/auth/login',
}

/** API endpoint paths */
export enum ApiEndpoints {
    LOGIN = '/users/login',
    LOGOUT = '/users/logout',
    CURRENT_USER = '/users/me',
    REGISTER = '/users/register',
}

/**
 * Auth state files written by the setup projects
 * (`tests/app/auth-api.setup.ts` and `tests/app/auth.setup.ts`).
 */
export enum StorageStatePaths {
    APP = '.auth/app/appStorageState.json',
    API_ACCESS_TOKEN = '.auth/app/apiAccessToken.json',
}

/** Resolve an auth state file inside this Playwright invocation's directory. */
export function runStorageStatePath(statePath: StorageStatePaths): string {
    const runId = process.env.PLAYWRIGHT_AUTH_RUN_ID;
    if (
        !runId ||
        !/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(
            runId
        )
    ) {
        throw new Error('PLAYWRIGHT_AUTH_RUN_ID must be a valid UUID v4');
    }
    return statePath.replace('.auth/app/', `.auth/app/${runId}/`);
}
