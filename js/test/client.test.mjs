import assert from "assert";
import { StacticsClient, StacticsApiError } from "../src/index.js";

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
await testRaisesApiErrors();
