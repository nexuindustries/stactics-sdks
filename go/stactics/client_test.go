package stactics

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestTrackPostsSingleEvent(t *testing.T) {
	var requestBody map[string]any
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/v1/events" {
			t.Fatalf("path = %s", r.URL.Path)
		}
		if got := r.Header.Get("Authorization"); got != "Bearer pk_test" {
			t.Fatalf("authorization = %s", got)
		}
		if got := r.Header.Get("User-Agent"); got != "stactics-go/0.1.3" {
			t.Fatalf("user agent = %s", got)
		}
		if err := json.NewDecoder(r.Body).Decode(&requestBody); err != nil {
			t.Fatalf("decode request body: %v", err)
		}
		w.WriteHeader(http.StatusCreated)
		_, _ = w.Write([]byte(`{"accepted":true,"accepted_count":1}`))
	}))
	defer server.Close()

	client := NewClient("pk_test", WithHost(server.URL))
	result, err := client.Track(context.Background(), "signup", Event{
		UserID:      "user_123",
		Environment: "production",
		AmountCents: 1299,
		Currency:    "AUD",
		Metadata:    map[string]any{"plan": "free"},
	})

	if err != nil {
		t.Fatalf("Track returned error: %v", err)
	}
	if !result.Accepted || result.AcceptedCount != 1 {
		t.Fatalf("result = %#v", result)
	}
	if requestBody["event_type"] != "signup" || requestBody["user_id"] != "user_123" {
		t.Fatalf("request body = %#v", requestBody)
	}
	if requestBody["amount_cents"] != float64(1299) || requestBody["currency"] != "AUD" {
		t.Fatalf("request body = %#v", requestBody)
	}
}

func TestSubmitFormPreservesFieldKeys(t *testing.T) {
	var requestBody map[string]any
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/v1/forms/contact/submissions" {
			t.Fatalf("path = %s", r.URL.Path)
		}
		if err := json.NewDecoder(r.Body).Decode(&requestBody); err != nil {
			t.Fatalf("decode request body: %v", err)
		}
		w.WriteHeader(http.StatusCreated)
		_, _ = w.Write([]byte(`{"accepted":true,"submission_id":"submission_123","submitted_at":"2026-07-17T04:00:00Z","message":"Thanks"}`))
	}))
	defer server.Close()

	client := NewClient("pk_test", WithHost(server.URL))
	result, err := client.SubmitForm(
		context.Background(),
		"contact",
		map[string]any{"first_name": "Ada", "consent": true},
		"go",
		"visitor_123",
	)

	if err != nil {
		t.Fatalf("SubmitForm returned error: %v", err)
	}
	if !result.Accepted || result.SubmissionID != "submission_123" || result.Message == nil || *result.Message != "Thanks" {
		t.Fatalf("result = %#v", result)
	}
	values := requestBody["values"].(map[string]any)
	if values["first_name"] != "Ada" || values["consent"] != true {
		t.Fatalf("request body = %#v", requestBody)
	}
	if requestBody["source"] != "go" || requestBody["external_user_id"] != "visitor_123" {
		t.Fatalf("request body = %#v", requestBody)
	}
}

func TestBatchPostsEvents(t *testing.T) {
	var requestBody map[string][]map[string]any
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/v1/events/batch" {
			t.Fatalf("path = %s", r.URL.Path)
		}
		if err := json.NewDecoder(r.Body).Decode(&requestBody); err != nil {
			t.Fatalf("decode request body: %v", err)
		}
		w.WriteHeader(http.StatusCreated)
		_, _ = w.Write([]byte(`{"accepted":true,"accepted_count":2}`))
	}))
	defer server.Close()

	client := NewClient("sk_test", WithHost(server.URL))
	result, err := client.Batch(context.Background(), []Event{
		{EventType: "app_opened", DeviceID: "install_abc"},
		{EventType: "screen_viewed", Metadata: map[string]any{"screen": "Home"}},
	})

	if err != nil {
		t.Fatalf("Batch returned error: %v", err)
	}
	if result.AcceptedCount != 2 {
		t.Fatalf("result = %#v", result)
	}
	if requestBody["events"][0]["event_type"] != "app_opened" {
		t.Fatalf("request body = %#v", requestBody)
	}
}

func TestReturnsAPIErrorForNonSuccessResponses(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusUnprocessableEntity)
		_, _ = w.Write([]byte(`{"error":"event type is not allowed"}`))
	}))
	defer server.Close()

	client := NewClient("pk_test", WithHost(server.URL))
	_, err := client.Track(context.Background(), "made_up", Event{})
	apiErr, ok := err.(*APIError)
	if !ok {
		t.Fatalf("error = %#v", err)
	}
	if apiErr.StatusCode != http.StatusUnprocessableEntity {
		t.Fatalf("status code = %d", apiErr.StatusCode)
	}
}
