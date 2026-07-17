use serde_json::json;
use stactics::{Client, Error, Event};
use wiremock::matchers::{body_json, header, method, path};
use wiremock::{Mock, MockServer, ResponseTemplate};

#[tokio::test]
async fn track_posts_single_event() {
    let server = MockServer::start().await;
    Mock::given(method("POST"))
        .and(path("/v1/events"))
        .and(header("authorization", "Bearer pk_test"))
        .and(header("user-agent", "stactics-rust/0.1.3"))
        .and(body_json(json!({
            "event_type": "signup",
            "user_id": "user_123",
            "environment": "production",
            "amount_cents": 1299,
            "currency": "AUD",
            "metadata": { "plan": "free" }
        })))
        .respond_with(ResponseTemplate::new(201).set_body_json(json!({
            "accepted": true,
            "accepted_count": 1
        })))
        .mount(&server)
        .await;

    let client = Client::new("pk_test").with_host(server.uri());
    let result = client
        .track(
            Event::new("signup")
                .user_id("user_123")
                .environment("production")
                .amount_cents(1299)
                .currency("AUD")
                .metadata(json!({ "plan": "free" })),
        )
        .await
        .unwrap();

    assert!(result.accepted);
    assert_eq!(result.accepted_count, 1);
}

#[tokio::test]
async fn submit_form_preserves_field_keys() {
    let server = MockServer::start().await;
    Mock::given(method("POST"))
        .and(path("/v1/forms/contact/submissions"))
        .and(body_json(json!({
            "values": {
                "first_name": "Ada",
                "consent": true
            },
            "source": "rust",
            "external_user_id": "visitor_123"
        })))
        .respond_with(ResponseTemplate::new(201).set_body_json(json!({
            "accepted": true,
            "submission_id": "submission_123",
            "submitted_at": "2026-07-17T04:00:00Z",
            "message": "Thanks"
        })))
        .mount(&server)
        .await;

    let client = Client::new("pk_test").with_host(server.uri());
    let result = client
        .submit_form(
            "contact",
            json!({ "first_name": "Ada", "consent": true }),
            Some("rust"),
            Some("visitor_123"),
        )
        .await
        .unwrap();

    assert!(result.accepted);
    assert_eq!(result.submission_id, "submission_123");
    assert_eq!(result.message.as_deref(), Some("Thanks"));
}

#[tokio::test]
async fn batch_posts_events() {
    let server = MockServer::start().await;
    Mock::given(method("POST"))
        .and(path("/v1/events/batch"))
        .and(body_json(json!({
            "events": [
                { "event_type": "app_opened", "device_id": "install_abc" },
                { "event_type": "screen_viewed", "metadata": { "screen": "Home" } }
            ]
        })))
        .respond_with(ResponseTemplate::new(201).set_body_json(json!({
            "accepted": true,
            "accepted_count": 2
        })))
        .mount(&server)
        .await;

    let client = Client::new("sk_test").with_host(server.uri());
    let result = client
        .batch(vec![
            Event::new("app_opened").device_id("install_abc"),
            Event::new("screen_viewed").metadata(json!({ "screen": "Home" })),
        ])
        .await
        .unwrap();

    assert_eq!(result.accepted_count, 2);
}

#[tokio::test]
async fn returns_api_error_for_non_success_responses() {
    let server = MockServer::start().await;
    Mock::given(method("POST"))
        .and(path("/v1/events"))
        .respond_with(ResponseTemplate::new(422).set_body_json(json!({
            "error": "event type is not allowed"
        })))
        .mount(&server)
        .await;

    let client = Client::new("pk_test").with_host(server.uri());
    let error = client.track(Event::new("made_up")).await.unwrap_err();

    match error {
        Error::Api { status, body } => {
            assert_eq!(status, 422);
            assert_eq!(body["error"], "event type is not allowed");
        }
        other => panic!("unexpected error: {other:?}"),
    }
}
