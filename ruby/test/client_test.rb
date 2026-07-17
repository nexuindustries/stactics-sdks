require "minitest/autorun"
require "json"
require "stactics"

class StacticsClientTest < Minitest::Test
  FakeResponse = Struct.new(:code, :body)

  def test_tracks_single_event
    transport = FakeTransport.new(FakeResponse.new("201", { accepted: true, accepted_count: 1 }.to_json))
    client = Stactics::Client.new(api_key: "sk_test", host: "https://api.example.test", transport: transport)

    result = client.track(
      "signup",
      user_id: "user_123",
      environment: "production",
      amount_cents: 1299,
      currency: "AUD",
      metadata: { plan: "free" }
    )

    assert result.accepted?
    assert_equal 1, result.accepted_count
    assert_equal "/v1/events", transport.requests.first.fetch(:path)
    assert_equal "Bearer sk_test", transport.requests.first.dig(:headers, "Authorization")
    assert_equal(
      {
        "event_type" => "signup",
        "user_id" => "user_123",
        "environment" => "production",
        "amount_cents" => 1299,
        "currency" => "AUD",
        "metadata" => { "plan" => "free" }
      },
      transport.requests.first.fetch(:payload)
    )
  end

  def test_sends_batches
    transport = FakeTransport.new(FakeResponse.new("201", { accepted: true, accepted_count: 2 }.to_json))
    client = Stactics::Client.new(api_key: "sk_test", transport: transport)

    result = client.batch([
                            { event_type: "app_opened", device_id: "install_abc" },
                            { event_type: "screen_viewed", metadata: { screen: "Home" } }
                          ])

    assert_equal 2, result.accepted_count
    assert_equal "/v1/events/batch", transport.requests.first.fetch(:path)
    assert_equal(
      {
        "events" => [
          { "event_type" => "app_opened", "device_id" => "install_abc" },
          { "event_type" => "screen_viewed", "metadata" => { "screen" => "Home" } }
        ]
      },
      transport.requests.first.fetch(:payload)
    )
  end

  def test_raises_api_errors
    transport = FakeTransport.new(FakeResponse.new("422", { error: "event type is not allowed" }.to_json))
    client = Stactics::Client.new(api_key: "sk_test", transport: transport)

    error = assert_raises(Stactics::APIError) { client.track("made_up") }
    assert_equal 422, error.status
    assert_equal({ "error" => "event type is not allowed" }, error.body)
  end

  def test_submits_form_without_changing_field_keys
    body = {
      accepted: true,
      submission_id: "submission_123",
      submitted_at: "2026-07-17T04:00:00Z",
      message: "Thanks"
    }
    transport = FakeTransport.new(FakeResponse.new("201", body.to_json))
    client = Stactics::Client.new(api_key: "sk_test", transport: transport)

    result = client.submit_form(
      "contact",
      { first_name: "Ada", consent: true, interests: [ "Technical collaboration" ] },
      source: "ruby",
      external_user_id: "visitor_123"
    )

    assert result.accepted?
    assert_equal "submission_123", result.submission_id
    assert_equal "Thanks", result.message
    assert_equal "/v1/forms/contact/submissions", transport.requests.first.fetch(:path)
    assert_equal(
      {
        "fieldData" => {
          "first_name" => "Ada",
          "consent" => true,
          "interests" => [ "Technical collaboration" ]
        },
        "source" => "ruby",
        "external_user_id" => "visitor_123"
      },
      transport.requests.first.fetch(:payload)
    )
  end

  class FakeTransport
    attr_reader :requests

    def initialize(response)
      @response = response
      @requests = []
    end

    def call(path:, payload:, headers:, timeout:)
      @requests << { path: path, payload: payload, headers: headers, timeout: timeout }
      @response
    end
  end
end
