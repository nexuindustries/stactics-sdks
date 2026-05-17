import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol StacticsTransport {
    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

public struct StacticsURLSessionTransport: StacticsTransport {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw StacticsAPIError(statusCode: 0, body: "Stactics API request failed")
        }
        return (data, httpResponse)
    }
}

public struct StacticsAPIError: Error, Equatable {
    public let statusCode: Int
    public let body: String
}

public struct StacticsResult: Decodable, Equatable {
    public let accepted: Bool
    public let acceptedCount: Int

    enum CodingKeys: String, CodingKey {
        case accepted
        case acceptedCount = "accepted_count"
    }
}

public struct StacticsEvent: Encodable, Equatable {
    public var eventType: String
    public var userId: String?
    public var accountId: String?
    public var email: String?
    public var deviceId: String?
    public var buildVersion: String?
    public var platform: String?
    public var environment: String?
    public var amountCents: Int?
    public var currency: String?
    public var metadata: [String: String]?
    public var occurredAt: Date?

    public init(
        eventType: String,
        userId: String? = nil,
        accountId: String? = nil,
        email: String? = nil,
        deviceId: String? = nil,
        buildVersion: String? = nil,
        platform: String? = nil,
        environment: String? = nil,
        amountCents: Int? = nil,
        currency: String? = nil,
        metadata: [String: String]? = nil,
        occurredAt: Date? = nil
    ) {
        self.eventType = eventType
        self.userId = userId
        self.accountId = accountId
        self.email = email
        self.deviceId = deviceId
        self.buildVersion = buildVersion
        self.platform = platform
        self.environment = environment
        self.amountCents = amountCents
        self.currency = currency
        self.metadata = metadata
        self.occurredAt = occurredAt
    }

    enum CodingKeys: String, CodingKey {
        case eventType = "event_type"
        case userId = "user_id"
        case accountId = "account_id"
        case email
        case deviceId = "device_id"
        case buildVersion = "build_version"
        case platform
        case environment
        case amountCents = "amount_cents"
        case currency
        case metadata
        case occurredAt = "occurred_at"
    }
}

public final class StacticsClient {
    public static let defaultHost = URL(string: "https://api.stactics.io")!

    private let apiKey: String
    private let host: URL
    private let transport: StacticsTransport
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        apiKey: String,
        host: URL = StacticsClient.defaultHost,
        transport: StacticsTransport = StacticsURLSessionTransport()
    ) {
        precondition(!apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "apiKey is required")
        self.apiKey = apiKey
        self.host = host
        self.transport = transport

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
        self.decoder = JSONDecoder()
    }

    public func track(
        _ eventType: String,
        userId: String? = nil,
        accountId: String? = nil,
        email: String? = nil,
        deviceId: String? = nil,
        buildVersion: String? = nil,
        platform: String? = "ios",
        environment: String? = nil,
        amountCents: Int? = nil,
        currency: String? = nil,
        metadata: [String: String]? = nil,
        occurredAt: Date? = nil
    ) async throws -> StacticsResult {
        let event = StacticsEvent(
            eventType: eventType,
            userId: userId,
            accountId: accountId,
            email: email,
            deviceId: deviceId,
            buildVersion: buildVersion,
            platform: platform,
            environment: environment,
            amountCents: amountCents,
            currency: currency,
            metadata: metadata,
            occurredAt: occurredAt
        )
        return try await request(path: "/v1/events", payload: event)
    }

    public func batch(_ events: [StacticsEvent]) async throws -> StacticsResult {
        try await request(path: "/v1/events/batch", payload: BatchPayload(events: events))
    }

    private func request<T: Encodable>(path: String, payload: T) async throws -> StacticsResult {
        let base = host.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        var request = URLRequest(url: URL(string: "\(base)\(path)")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("stactics-swift/0.1.1", forHTTPHeaderField: "User-Agent")
        request.httpBody = try encoder.encode(payload)

        let (data, response) = try await transport.send(request)
        guard (200..<300).contains(response.statusCode) else {
            throw StacticsAPIError(statusCode: response.statusCode, body: errorMessage(from: data))
        }

        return try decoder.decode(StacticsResult.self, from: data)
    }

    private func errorMessage(from data: Data) -> String {
        guard
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let error = object["error"] as? String
        else {
            return String(data: data, encoding: .utf8) ?? "Stactics API request failed"
        }

        return error
    }
}

private struct BatchPayload: Encodable {
    let events: [StacticsEvent]
}
