import { Injectable } from '@nestjs/common';
import { App, cert, getApps, initializeApp } from 'firebase-admin/app';
import { Auth, getAuth } from 'firebase-admin/auth';
import { getStorage, Storage } from 'firebase-admin/storage';

@Injectable()
export class FirebaseAdminService {
  private readonly app?: App;
  private readonly configured: boolean;
  private readonly testMode: boolean;

  constructor() {
    this.testMode = process.env.NODE_ENV === 'test';
    const existing = getApps()?.[0];
    if (existing) {
      this.app = existing;
      this.configured = true;
      return;
    }

    const projectId = process.env.FIREBASE_PROJECT_ID;
    const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
    const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');

    if (!projectId || !clientEmail || !privateKey) {
      if (this.testMode) {
        this.configured = false;
        return;
      }
      throw new Error(
        'Firebase Admin is not configured. Missing FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, or FIREBASE_PRIVATE_KEY.',
      );
    }

    this.app = initializeApp({
      credential: cert({
        projectId,
        clientEmail,
        privateKey,
      }),
      storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
    });

    this.configured = true;
  }

  auth(): Auth {
    if (!this.configured) {
      return {
        verifyIdToken: async () => {
          throw new Error('Firebase Admin auth is not configured');
        },
        setCustomUserClaims: async () => {
          return;
        },
      } as any;
    }
    return getAuth(this.app!);
  }

  storage(): Storage {
    if (!this.configured) {
      return {} as any;
    }
    return getStorage(this.app!);
  }

  bucket(bucketName?: string): any {
    const name =
      bucketName ??
      process.env.FIREBASE_STORAGE_BUCKET ??
      (this.testMode ? 'test-bucket' : undefined);

    if (!name) {
      throw new Error('FIREBASE_STORAGE_BUCKET is not configured.');
    }

    if (!this.configured) {
      return {
        name,
        file: (path: string) => ({
          save: async () => {
            return;
          },
          getSignedUrl: async () => {
            return [`https://example.test/${encodeURIComponent(path)}`];
          },
        }),
      };
    }

    return this.storage().bucket(name);
  }
}
