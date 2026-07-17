require "json"
require "net/http"
require "uri"

module Stactics
  class APIError < StandardError
    attr_reader :status, :body

    def initialize(status:, body:)
      @status = status
      @body = body
      super(body.fetch("error", "Stactics API request failed"))
    end
  end

  Result = Struct.new(:accepted?, :accepted_count, :body, keyword_init: true)
  FormSubmissionResult = Struct.new(:accepted?, :submission_id, :submitted_at, :message, :body, keyword_init: true)

  class Client
    def initialize(api_key:, host: DEFAULT_HOST, timeout: 5, transport: nil)
      raise ArgumentError, "api_key is required" if api_key.to_s.strip.empty?

      @api_key = api_key
      @host = host.to_s.delete_suffix("/")
      @timeout = timeout
      @transport = transport || method(:perform_request)
    end

    def track(event_type, attributes = {})
      payload = stringify_keys(attributes).merge("event_type" => event_type.to_s)
      request("/v1/events", payload)
    end

    def batch(events)
      payload = { "events" => events.map { |event| stringify_keys(event) } }
      request("/v1/events/batch", payload)
    end

    def submit_form(form_key, field_data, source: nil, external_user_id: nil)
      raise ArgumentError, "form_key is required" if form_key.to_s.strip.empty?
      raise ArgumentError, "field_data must be a hash" unless field_data.is_a?(Hash)

      payload = { "fieldData" => stringify_form_values(field_data) }
      payload["source"] = source unless source.nil?
      payload["external_user_id"] = external_user_id unless external_user_id.nil?
      result = request("/v1/forms/#{URI.encode_www_form_component(form_key.to_s)}/submissions", payload)

      FormSubmissionResult.new(
        accepted?: result.accepted?,
        submission_id: result.body["submission_id"],
        submitted_at: result.body["submitted_at"],
        message: result.body["message"],
        body: result.body
      )
    end

    private

    def request(path, payload)
      response = @transport.call(
        path: path,
        payload: payload,
        headers: headers,
        timeout: @timeout
      )
      body = parse_json(response.body)
      status = response.code.to_i
      raise APIError.new(status: status, body: body) unless status.between?(200, 299)

      Result.new(
        accepted?: body.fetch("accepted", false),
        accepted_count: body.fetch("accepted_count", 0),
        body: body
      )
    end

    def perform_request(path:, payload:, headers:, timeout:)
      uri = URI("#{@host}#{path}")
      request = Net::HTTP::Post.new(uri, headers)
      request.body = JSON.generate(payload)

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https", read_timeout: timeout, open_timeout: timeout) do |http|
        http.request(request)
      end
    end

    def headers
      {
        "Authorization" => "Bearer #{@api_key}",
        "Content-Type" => "application/json",
        "User-Agent" => "stactics-ruby/#{VERSION}"
      }
    end

    def parse_json(raw_body)
      JSON.parse(raw_body.to_s)
    rescue JSON::ParserError
      {}
    end

    def stringify_keys(value)
      case value
      when Hash
        value.each_with_object({}) do |(key, nested_value), memo|
          memo[camel_or_symbol_to_snake(key)] = stringify_keys(nested_value)
        end
      when Array
        value.map { |item| stringify_keys(item) }
      else
        value
      end
    end

    def stringify_form_values(value)
      case value
      when Hash
        value.each_with_object({}) do |(key, nested_value), memo|
          memo[key.to_s] = stringify_form_values(nested_value)
        end
      when Array
        value.map { |item| stringify_form_values(item) }
      else
        value
      end
    end

    def camel_or_symbol_to_snake(key)
      key.to_s
         .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
         .gsub(/([a-z\d])([A-Z])/, '\1_\2')
         .tr("-", "_")
         .downcase
    end
  end
end
