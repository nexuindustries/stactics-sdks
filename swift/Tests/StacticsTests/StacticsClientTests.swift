import XCTest
@testable import Stactics

final class StacticsClientTests: XCTestCase {
    func testTrackPostsSingleEvent() async throws {
        let transport = RecordingTransport(statusCode: 201, body: #"{"accepted":true,"accepted_count":1}"#)
        let client = StacticsClient(
            apiKey: "st_live_test",
            host: URL(string: "https://api.example.test")!,
            transport: transport
        )

        let result = try await client.track(
            "signup",
            userId: "user_123",
            environment: "production",
            metadata: ["plan": "free"]
        )

        XCTAssertTrue(result.accepted)
        XCTAssertEqual(result.acceptedCount, 1)
        XCTAssertEqual(transport.requests.first?.url?.absoluteString, "https://api.example.test/v1/events")
        XCTAssertEqual(transport.requests.first?.value(forHTTPHeaderField: "Authorization"), "Bearer st_live_test")
        XCTAssertEqual(transport.requests.first?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(transport.requests.first?.value(forHTTPHeaderField: "User-Agent"), "stactics-swift/0.1.0")

        let body = try XCTUnwrap(transport.bodies.first)
        let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
        XCTAssertEqual(json?["event_type"] as? String, "signup")
        XCTAssertEqual(json?["user_id"] as? String, "user_123")
        XCTAssertEqual(json?["environment"] as? String, "production")
        XCTAssertEqual((json?["metadata"] as? [String: Any])?["plan"] as? String, "free")
    }

    func testBatchPostsEvents() async throws {
        let transport = RecordingTransport(statusCode: 201, body: #"{"accepted":true,"accepted_count":2}"#)
        let client = StacticsClient(apiKey: "st_secret_test", transport: transport)

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
        let client = StacticsClient(apiKey: "st_live_test", transport: transport)

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
