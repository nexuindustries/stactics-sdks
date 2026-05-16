import { InjectionToken } from '@angular/core';

export interface StacticsAngularConfig {
  apiKey: string;
  host?: string;
  environment?: string;
  platform?: string;
}

export const STACTICS_CONFIG = new InjectionToken<StacticsAngularConfig>('STACTICS_CONFIG');
