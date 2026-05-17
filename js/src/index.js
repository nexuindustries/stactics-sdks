const DEFAULT_HOST = "https://api.stactics.io";

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

function toSnakeCase(key) {
  return key
    .replace(/([A-Z]+)([A-Z][a-z])/g, "$1_$2")
    .replace(/([a-z\d])([A-Z])/g, "$1_$2")
    .replace(/-/g, "_")
    .toLowerCase();
}
