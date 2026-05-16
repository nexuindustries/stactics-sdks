import { Inject, Injectable } from '@angular/core';
import { StacticsClient, StacticsResult } from '@stactics/js';
import { STACTICS_CONFIG, StacticsAngularConfig } from './stactics.config';

@Injectable()
export class StacticsService {
  private readonly client: StacticsClient;

  constructor(@Inject(STACTICS_CONFIG) private readonly config: StacticsAngularConfig) {
    this.client = new StacticsClient({
      apiKey: config.apiKey,
      host: config.host,
    });
  }

  track(eventType: string, attributes: Record<string, unknown> = {}): Promise<StacticsResult> {
    return this.client.track(eventType, this.withDefaults(attributes));
  }

  batch(events: Array<Record<string, unknown>>): Promise<StacticsResult> {
    return this.client.batch(events.map((event) => this.withDefaults(event)));
  }

  private withDefaults(attributes: Record<string, unknown>): Record<string, unknown> {
    return {
      platform: this.config.platform || 'web',
      environment: this.config.environment,
      ...attributes,
    };
  }
}
