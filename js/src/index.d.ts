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

export type StacticsEventType =
  | 'signup'
  | 'login'
  | 'active'
  | 'purchase'
  | 'subscription_started'
  | 'subscription_cancelled'
  | 'trial_started'
  | 'trial_converted'
  | 'crash'
  | 'error'
  | 'app_opened'
  | 'screen_viewed'
  | 'feature_used'
  | 'notification_sent'
  | 'notification_opened'
  | 'health_check';

export interface StacticsEventAttributes {
  userId?: string;
  externalUserId?: string;
  accountId?: string;
  externalAccountId?: string;
  email?: string;
  username?: string;
  displayName?: string;
  deviceId?: string;
  buildVersion?: string;
  platform?: string;
  environment?: string;
  environmentId?: string;
  projectEnvironmentId?: string;
  amountCents?: number;
  currency?: string;
  metadata?: Record<string, unknown>;
  occurredAt?: string;
  [key: string]: unknown;
}

export interface StacticsBatchEvent extends StacticsEventAttributes {
  eventType: StacticsEventType | string;
}

export interface StacticsEventBuilders {
  signup(attributes?: StacticsEventAttributes): StacticsBatchEvent;
  login(attributes?: StacticsEventAttributes): StacticsBatchEvent;
  active(attributes?: StacticsEventAttributes): StacticsBatchEvent;
  purchase(attributes?: StacticsEventAttributes): StacticsBatchEvent;
  subscriptionStarted(attributes?: StacticsEventAttributes): StacticsBatchEvent;
  subscriptionCancelled(attributes?: StacticsEventAttributes): StacticsBatchEvent;
  trialStarted(attributes?: StacticsEventAttributes): StacticsBatchEvent;
  trialConverted(attributes?: StacticsEventAttributes): StacticsBatchEvent;
  crash(attributes?: StacticsEventAttributes): StacticsBatchEvent;
  error(attributes?: StacticsEventAttributes): StacticsBatchEvent;
  appOpened(attributes?: StacticsEventAttributes): StacticsBatchEvent;
  screenViewed(attributes?: StacticsEventAttributes): StacticsBatchEvent;
  featureUsed(attributes?: StacticsEventAttributes): StacticsBatchEvent;
  notificationSent(attributes?: StacticsEventAttributes): StacticsBatchEvent;
  notificationOpened(attributes?: StacticsEventAttributes): StacticsBatchEvent;
  healthCheck(attributes?: StacticsEventAttributes): StacticsBatchEvent;
}

export const StacticsEventTypes: Readonly<{
  signup: 'signup';
  login: 'login';
  active: 'active';
  purchase: 'purchase';
  subscriptionStarted: 'subscription_started';
  subscriptionCancelled: 'subscription_cancelled';
  trialStarted: 'trial_started';
  trialConverted: 'trial_converted';
  crash: 'crash';
  error: 'error';
  appOpened: 'app_opened';
  screenViewed: 'screen_viewed';
  featureUsed: 'feature_used';
  notificationSent: 'notification_sent';
  notificationOpened: 'notification_opened';
  healthCheck: 'health_check';
}>;

export const StacticsEvents: StacticsEventBuilders;

export class StacticsApiError extends Error {
  status: number;
  body: Record<string, unknown>;
}

export class StacticsClient {
  constructor(options: StacticsClientOptions);
  track(eventType: StacticsEventType | string, attributes?: StacticsEventAttributes): Promise<StacticsResult>;
  trackEvent(event: StacticsBatchEvent): Promise<StacticsResult>;
  batch(events: StacticsBatchEvent[]): Promise<StacticsResult>;
}
