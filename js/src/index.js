const DEFAULT_HOST = "https://api.stactics.io";

export const StacticsEventTypes = Object.freeze({
  signup: "signup",
  login: "login",
  active: "active",
  purchase: "purchase",
  subscriptionStarted: "subscription_started",
  subscriptionCancelled: "subscription_cancelled",
  trialStarted: "trial_started",
  trialConverted: "trial_converted",
  crash: "crash",
  error: "error",
  appOpened: "app_opened",
  screenViewed: "screen_viewed",
  featureUsed: "feature_used",
  notificationSent: "notification_sent",
  notificationOpened: "notification_opened",
  healthCheck: "health_check",
});

export const StacticsEvents = Object.freeze({
  signup: (attributes = {}) => buildEvent(StacticsEventTypes.signup, attributes),
  login: (attributes = {}) => buildEvent(StacticsEventTypes.login, attributes),
  active: (attributes = {}) => buildEvent(StacticsEventTypes.active, attributes),
  purchase: (attributes = {}) => buildEvent(StacticsEventTypes.purchase, attributes),
  subscriptionStarted: (attributes = {}) => buildEvent(StacticsEventTypes.subscriptionStarted, attributes),
  subscriptionCancelled: (attributes = {}) => buildEvent(StacticsEventTypes.subscriptionCancelled, attributes),
  trialStarted: (attributes = {}) => buildEvent(StacticsEventTypes.trialStarted, attributes),
  trialConverted: (attributes = {}) => buildEvent(StacticsEventTypes.trialConverted, attributes),
  crash: (attributes = {}) => buildEvent(StacticsEventTypes.crash, attributes),
  error: (attributes = {}) => buildEvent(StacticsEventTypes.error, attributes),
  appOpened: (attributes = {}) => buildEvent(StacticsEventTypes.appOpened, attributes),
  screenViewed: (attributes = {}) => buildEvent(StacticsEventTypes.screenViewed, attributes),
  featureUsed: (attributes = {}) => buildEvent(StacticsEventTypes.featureUsed, attributes),
  notificationSent: (attributes = {}) => buildEvent(StacticsEventTypes.notificationSent, attributes),
  notificationOpened: (attributes = {}) => buildEvent(StacticsEventTypes.notificationOpened, attributes),
  healthCheck: (attributes = {}) => buildEvent(StacticsEventTypes.healthCheck, attributes),
});

export class StacticsApiError extends Error {
  constructor(status, body) {
    super(body?.error || "Stactics API request failed");
    this.name = "StacticsApiError";
    this.status = status;
    this.body = body;
  }
}

export class StacticsClient {
  constructor(options) {
    if (!options || !options.apiKey) {
      throw new Error("apiKey is required");
    }

    this.apiKey = options.apiKey;
    this.host = (options.host || DEFAULT_HOST).replace(/\/$/, "");
    this.fetch = options.fetch || globalThis.fetch;

    if (!this.fetch) {
      throw new Error("fetch is required in this runtime");
    }
  }

  async track(eventType, attributes = {}) {
    return this.request("/v1/events", {
      ...snakeCaseKeys(attributes),
      event_type: eventType,
    });
  }

  async trackEvent(event) {
    const eventType = event.eventType || event.event_type;
    if (!eventType) {
      throw new Error("eventType is required");
    }

    const { eventType: _eventType, event_type: _event_type, ...attributes } = event;
    return this.track(eventType, attributes);
  }

  async batch(events) {
    return this.request("/v1/events/batch", {
      events: events.map((event) => snakeCaseKeys(event)),
    });
  }

  async request(path, payload) {
    const response = await this.fetch(`${this.host}${path}`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${this.apiKey}`,
        "Content-Type": "application/json",
        "User-Agent": "stactics-js/0.1.1",
      },
      body: JSON.stringify(payload),
    });
    const body = await response.json();

    if (!response.ok) {
      throw new StacticsApiError(response.status, body);
    }

    return {
      accepted: body.accepted === true,
      acceptedCount: body.accepted_count || 0,
      body,
    };
  }
}

function snakeCaseKeys(value) {
  if (Array.isArray(value)) {
    return value.map((item) => snakeCaseKeys(item));
  }

  if (value && typeof value === "object" && value.constructor === Object) {
    return Object.entries(value).reduce((memo, [key, nestedValue]) => {
      memo[toSnakeCase(key)] = snakeCaseKeys(nestedValue);
      return memo;
    }, {});
  }

  return value;
}

function buildEvent(eventType, attributes) {
  return {
    eventType,
    ...attributes,
  };
}

function toSnakeCase(key) {
  return key
    .replace(/([A-Z]+)([A-Z][a-z])/g, "$1_$2")
    .replace(/([a-z\d])([A-Z])/g, "$1_$2")
    .replace(/-/g, "_")
    .toLowerCase();
}
