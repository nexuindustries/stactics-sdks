import XCTest
@testable import Stactics

final class StacticsClientTests: XCTestCase {
    func testTrackPostsSingleEvent() async throws {
        let transport = RecordingTransport(statusCode: 201, body: #"{"accepted":true,"accepted_count":1}"#)
        let client = StacticsClient(
            apiKey: "pk_test",
            host: URL(string: "https://api.example.test")!,
            transport: transport
        )

        let result = try await client.track(
            "signup",
            userId: "user_123",
            email: "founder@example.com",
            displayName: "Ada Founder",
            environment: "production",
            amountCents: 1299,
            currency: "AUD",
            metadata: ["plan": "free"]
        )

        XCTAssertTrue(result.accepted)
        XCTAssertEqual(result.acceptedCount, 1)
        XCTAssertEqual(transport.requests.first?.url?.absoluteString, "https://api.example.test/v1/events")
        XCTAssertEqual(transport.requests.first?.value(forHTTPHeaderField: "Authorization"), "Bearer pk_test")
        XCTAssertEqual(transport.requests.first?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(transport.requests.first?.value(forHTTPHeaderField: "User-Agent"), "stactics-swift/0.1.4")

        let body = try XCTUnwrap(transport.bodies.first)
        let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
        XCTAssertEqual(json?["event_type"] as? String, "signup")
        XCTAssertEqual(json?["user_id"] as? String, "user_123")
        XCTAssertEqual(json?["email"] as? String, "founder@example.com")
        XCTAssertEqual(json?["display_name"] as? String, "Ada Founder")
        XCTAssertEqual(json?["environment"] as? String, "production")
        XCTAssertEqual(json?["amount_cents"] as? Int, 1299)
        XCTAssertEqual(json?["currency"] as? String, "AUD")
        XCTAssertEqual((json?["metadata"] as? [String: Any])?["plan"] as? String, "free")
    }

    func testBatchPostsEvents() async throws {
        let transport = RecordingTransport(statusCode: 201, body: #"{"accepted":true,"accepted_count":2}"#)
        let client = StacticsClient(apiKey: "sk_test", transport: transport)

        let result = try await client.batch([
            StacticsEvent(eventType: "app_opened", deviceId: "install_abc"),
            StacticsEvent(eventType: "screen_viewed", metadata: ["screen": "Home"])
        ])

        XCTAssertEqual(result.acceptedCount, 2)
        XCTAssertEqual(transport.requests.first?.url?.absoluteString, "https://api.stactics.io/v1/events/batch")

        let body = try XCTUnwrap(transport.bodies.first)
        let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
        let events = json?["events"] as? [[String: Any]]
        XCTAssertEqual(events?.count, 2)
        XCTAssertEqual(events?.first?["event_type"] as? String, "app_opened")
        XCTAssertEqual(events?.first?["device_id"] as? String, "install_abc")
    }

    func testThrowsApiErrorForNonSuccessResponses() async {
        let transport = RecordingTransport(statusCode: 422, body: #"{"error":"event type is not allowed"}"#)
        let client = StacticsClient(apiKey: "pk_test", transport: transport)

        do {
            _ = try await client.track("made_up")
            XCTFail("Expected StacticsAPIError")
        } catch let error as StacticsAPIError {
            XCTAssertEqual(error.statusCode, 422)
            XCTAssertEqual(error.body, "event type is not allowed")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testSubmitFormPreservesFieldKeys() async throws {
        let transport = RecordingTransport(
            statusCode: 201,
            body: #"{"accepted":true,"submission_id":"submission_123","submitted_at":"2026-07-17T04:00:00Z","message":"Thanks"}"#
        )
        let client = StacticsClient(
            apiKey: "pk_test",
            host: URL(string: "https://api.example.test")!,
            transport: transport
        )

        let result = try await client.submitForm(
            "contact",
            fieldData: [
                "first_name": "Ada",
                "consent": true,
                "interests": ["Technical collaboration"]
            ],
            source: "ios",
            externalUserId: "visitor_123"
        )

        XCTAssertTrue(result.accepted)
        XCTAssertEqual(result.submissionId, "submission_123")
        XCTAssertEqual(result.message, "Thanks")
        XCTAssertEqual(transport.requests.first?.url?.absoluteString, "https://api.example.test/v1/forms/contact/submissions")

        let body = try XCTUnwrap(transport.bodies.first)
        let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
        let fieldData = json?["fieldData"] as? [String: Any]
        XCTAssertEqual(fieldData?["first_name"] as? String, "Ada")
        XCTAssertEqual(fieldData?["consent"] as? Bool, true)
        XCTAssertEqual(json?["source"] as? String, "ios")
        XCTAssertEqual(json?["external_user_id"] as? String, "visitor_123")
    }
}

private final class RecordingTransport: StacticsTransport {
    let statusCode: Int
    let body: String
    private(set) var requests: [URLRequest] = []
    private(set) var bodies: [Data] = []

    init(statusCode: Int, body: String) {
        self.statusCode = statusCode
        self.body = body
    }

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        requests.append(request)
        bodies.append(request.httpBody ?? Data())
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        return (Data(body.utf8), response)
    }
}
