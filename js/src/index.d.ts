export interface StacticsClientOptions {
  apiKey: string;
  host?: string;
  fetch?: typeof fetch;
}

export interface StacticsResult {
  accepted: boolean;
  acceptedCount: number;
  body: Record<string, unknown>;
}

export interface StacticsEventAttributes {
  userId?: string;
  accountId?: string;
  email?: string;
  deviceId?: string;
  buildVersion?: string;
  platform?: string;
  environment?: string;
  amountCents?: number;
  currency?: string;
  metadata?: Record<string, unknown>;
  occurredAt?: string;
  [key: string]: unknown;
}

export interface StacticsBatchEvent extends StacticsEventAttributes {
  eventType: string;
}

export class StacticsApiError extends Error {
  status: number;
  body: Record<string, unknown>;
}

export class StacticsClient {
  constructor(options: StacticsClientOptions);
  track(eventType: string, attributes?: StacticsEventAttributes): Promise<StacticsResult>;
  batch(events: StacticsBatchEvent[]): Promise<StacticsResult>;
}
