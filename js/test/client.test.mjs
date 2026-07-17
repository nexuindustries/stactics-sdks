import assert from "assert";
import {
  StacticsApiError,
  StacticsClient,
  StacticsEvents,
  StacticsEventTypes,
} from "../src/index.js";

async function testTracksSingleEvent() {
  const calls = [];
  const fetchImpl = async (url, options) => {
    calls.push({ url, options });
    return response(201, { accepted: true, accepted_count: 1 });
  };
  const client = new StacticsClient({
    apiKey: "pk_test",
    host: "https://api.example.test",
    fetch: fetchImpl,
  });

  const result = await client.track("signup", {
    userId: "user_123",
    environment: "production",
    amountCents: 1299,
    currency: "AUD",
    metadata: { plan: "free" },
  });

  assert.equal(result.accepted, true);
  assert.equal(result.acceptedCount, 1);
  assert.equal(calls[0].url, "https://api.example.test/v1/events");
  assert.equal(calls[0].options.headers.Authorization, "Bearer pk_test");
  assert.deepEqual(JSON.parse(calls[0].options.body), {
    event_type: "signup",
    user_id: "user_123",
    environment: "production",
    amount_cents: 1299,
    currency: "AUD",
    metadata: { plan: "free" },
  });
}

async function testSendsBatch() {
  const calls = [];
  const fetchImpl = async (url, options) => {
    calls.push({ url, options });
    return response(201, { accepted: true, accepted_count: 2 });
  };
  const client = new StacticsClient({ apiKey: "sk_test", fetch: fetchImpl });

  const result = await client.batch([
    { eventType: "app_opened", deviceId: "install_abc" },
    { eventType: "screen_viewed", metadata: { screen: "Home" } },
  ]);

  assert.equal(result.acceptedCount, 2);
  assert.equal(calls[0].url, "https://api.stactics.io/v1/events/batch");
  assert.deepEqual(JSON.parse(calls[0].options.body), {
    events: [
      { event_type: "app_opened", device_id: "install_abc" },
      { event_type: "screen_viewed", metadata: { screen: "Home" } },
    ],
  });
}

async function testTracksBuiltEventPayload() {
  const calls = [];
  const fetchImpl = async (url, options) => {
    calls.push({ url, options });
    return response(201, { accepted: true, accepted_count: 1 });
  };
  const client = new StacticsClient({
    apiKey: "pk_test",
    host: "https://api.example.test",
    fetch: fetchImpl,
  });

  const event = StacticsEvents.purchase({
    userId: "user_123",
    accountId: "team_123",
    amountCents: 1299,
    currency: "aud",
    metadata: { transactionId: "txn_123", productId: "pro_monthly" },
  });

  assert.equal(event.eventType, StacticsEventTypes.purchase);

  const result = await client.trackEvent(event);

  assert.equal(result.accepted, true);
  assert.deepEqual(JSON.parse(calls[0].options.body), {
    event_type: "purchase",
    user_id: "user_123",
    account_id: "team_123",
    amount_cents: 1299,
    currency: "aud",
    metadata: { transaction_id: "txn_123", product_id: "pro_monthly" },
  });
}

function testBuildsDefaultEventPayloads() {
  assert.deepEqual(StacticsEvents.login({
    userId: "user_123",
    email: "founder@example.com",
    displayName: "Sam Founder",
  }), {
    eventType: "login",
    userId: "user_123",
    email: "founder@example.com",
    displayName: "Sam Founder",
  });

  assert.deepEqual(StacticsEvents.screenViewed({
    userId: "user_123",
    metadata: { path: "/dashboard" },
  }), {
    eventType: "screen_viewed",
    userId: "user_123",
    metadata: { path: "/dashboard" },
  });

  assert.deepEqual(StacticsEvents.healthCheck({
    metadata: { source: "uptime_monitor", check: "ingest" },
  }), {
    eventType: "health_check",
    metadata: { source: "uptime_monitor", check: "ingest" },
  });
}

async function testRaisesApiErrors() {
  const client = new StacticsClient({
    apiKey: "pk_test",
    fetch: async () => response(422, { error: "event type is not allowed" }),
  });

  await assert.rejects(
    () => client.track("made_up"),
    (error) => {
      assert(error instanceof StacticsApiError);
      assert.equal(error.status, 422);
      assert.deepEqual(error.body, { error: "event type is not allowed" });
      return true;
    }
  );
}

async function testSubmitsFormWithoutChangingFieldKeys() {
  const calls = [];
  const fetchImpl = async (url, options) => {
    calls.push({ url, options });
    return response(201, {
      accepted: true,
      submission_id: "submission_123",
      submitted_at: "2026-07-17T04:00:00Z",
      message: "Thanks",
    });
  };
  const client = new StacticsClient({
    apiKey: "pk_test",
    host: "https://api.example.test",
    fetch: fetchImpl,
  });

  const result = await client.submitForm("contact", {
    first_name: "Ada",
    consent: true,
    interests: ["Technical collaboration"],
  }, {
    source: "web",
    externalUserId: "visitor_123",
  });

  assert.equal(calls[0].url, "https://api.example.test/v1/forms/contact/submissions");
  assert.deepEqual(JSON.parse(calls[0].options.body), {
    values: {
      first_name: "Ada",
      consent: true,
      interests: ["Technical collaboration"],
    },
    source: "web",
    external_user_id: "visitor_123",
  });
  assert.deepEqual(result, {
    accepted: true,
    submissionId: "submission_123",
    submittedAt: "2026-07-17T04:00:00Z",
    message: "Thanks",
    body: {
      accepted: true,
      submission_id: "submission_123",
      submitted_at: "2026-07-17T04:00:00Z",
      message: "Thanks",
    },
  });
}

function response(status, body) {
  return {
    ok: status >= 200 && status < 300,
    status,
    async json() {
      return body;
    },
  };
}

await testTracksSingleEvent();
await testSendsBatch();
await testTracksBuiltEventPayload();
testBuildsDefaultEventPayloads();
await testRaisesApiErrors();
await testSubmitsFormWithoutChangingFieldKeys();
