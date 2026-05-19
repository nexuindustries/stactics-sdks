import { Inject, Injectable } from '@angular/core';
import { StacticsBatchEvent, StacticsClient, StacticsEventAttributes, StacticsResult } from '@stactics.io/js';
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

  track(eventType: string, attributes: StacticsEventAttributes = {}): Promise<StacticsResult> {
    return this.client.track(eventType, this.withDefaults(attributes));
  }

  trackEvent(event: StacticsBatchEvent): Promise<StacticsResult> {
    return this.client.trackEvent(this.withDefaults(event));
  }

  batch(events: StacticsBatchEvent[]): Promise<StacticsResult> {
    return this.client.batch(events.map((event) => this.withDefaults(event)));
  }

  private withDefaults<T extends StacticsEventAttributes>(attributes: T): T {
    return {
      platform: this.config.platform || 'web',
      environment: this.config.environment,
      ...attributes,
    } as T;
  }
}
