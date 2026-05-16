require "minitest/autorun"
require "json"
require "stactics"

class StacticsClientTest < Minitest::Test
  FakeResponse = Struct.new(:code, :body)

  def test_tracks_single_event
    transport = FakeTransport.new(FakeResponse.new("201", { accepted: true, accepted_count: 1 }.to_json))
    client = Stactics::Client.new(api_key: "sk_test", host: "https://api.example.test", transport: transport)

    result = client.track("signup", user_id: "user_123", environment: "production", metadata: { plan: "free" })

    assert result.accepted?
    assert_equal 1, result.accepted_count
    assert_equal "/v1/events", transport.requests.first.fetch(:path)
    assert_equal "Bearer sk_test", transport.requests.first.dig(:headers, "Authorization")
    assert_equal(
      {
        "event_type" => "signup",
        "user_id" => "user_123",
        "environment" => "production",
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
