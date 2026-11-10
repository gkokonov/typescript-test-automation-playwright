import { rm } from 'node:fs/promises';
import { dirname } from 'node:path';
import { runStorageStatePath, StorageStatePaths } from '../../enums/app/app';

/** Remove only this invocation's authentication files after Playwright finishes. */
export default async function cleanupAuthState(): Promise<void> {
    const runDirectory = dirname(runStorageStatePath(StorageStatePaths.APP));
    await rm(runDirectory, { recursive: true, force: true });
}
