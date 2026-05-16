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

export class StacticsApiError extends Error {
  status: number;
  body: Record<string, unknown>;
}

export class StacticsClient {
  constructor(options: StacticsClientOptions);
  track(eventType: string, attributes?: Record<string, unknown>): Promise<StacticsResult>;
  batch(events: Array<Record<string, unknown>>): Promise<StacticsResult>;
}
