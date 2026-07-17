package stactics

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"
)

const defaultHost = "https://api.stactics.io"
const userAgent = "stactics-go/0.1.4"

type Client struct {
	apiKey     string
	host       string
	httpClient *http.Client
}

type Option func(*Client)

func NewClient(apiKey string, options ...Option) *Client {
	client := &Client{
		apiKey:     apiKey,
		host:       defaultHost,
		httpClient: &http.Client{Timeout: 5 * time.Second},
	}
	for _, option := range options {
		option(client)
	}
	client.host = strings.TrimRight(client.host, "/")
	return client
}

func WithHost(host string) Option {
	return func(client *Client) {
		client.host = host
	}
}

func WithHTTPClient(httpClient *http.Client) Option {
	return func(client *Client) {
		client.httpClient = httpClient
	}
}

type Event struct {
	EventType    string         `json:"event_type,omitempty"`
	UserID       string         `json:"user_id,omitempty"`
	AccountID    string         `json:"account_id,omitempty"`
	Email        string         `json:"email,omitempty"`
	DeviceID     string         `json:"device_id,omitempty"`
	BuildVersion string         `json:"build_version,omitempty"`
	Platform     string         `json:"platform,omitempty"`
	Environment  string         `json:"environment,omitempty"`
	AmountCents  int64          `json:"amount_cents,omitempty"`
	Currency     string         `json:"currency,omitempty"`
	Metadata     map[string]any `json:"metadata,omitempty"`
	OccurredAt   *time.Time     `json:"occurred_at,omitempty"`
}

type Result struct {
	Accepted      bool `json:"accepted"`
	AcceptedCount int  `json:"accepted_count"`
}

type FormSubmissionResult struct {
	Accepted     bool    `json:"accepted"`
	SubmissionID string  `json:"submission_id"`
	SubmittedAt  string  `json:"submitted_at"`
	Message      *string `json:"message"`
}

type APIError struct {
	StatusCode int
	Body       string
}

func (err *APIError) Error() string {
	return fmt.Sprintf("stactics API request failed with status %d: %s", err.StatusCode, err.Body)
}

func (client *Client) Track(ctx context.Context, eventType string, event Event) (*Result, error) {
	event.EventType = eventType
	result := &Result{}
	if err := client.request(ctx, "/v1/events", event, result); err != nil {
		return nil, err
	}
	return result, nil
}

func (client *Client) Batch(ctx context.Context, events []Event) (*Result, error) {
	result := &Result{}
	if err := client.request(ctx, "/v1/events/batch", map[string][]Event{"events": events}, result); err != nil {
		return nil, err
	}
	return result, nil
}

func (client *Client) SubmitForm(
	ctx context.Context,
	formKey string,
	fieldData map[string]any,
	source string,
	externalUserID string,
) (*FormSubmissionResult, error) {
	payload := map[string]any{"fieldData": fieldData}
	if source != "" {
		payload["source"] = source
	}
	if externalUserID != "" {
		payload["external_user_id"] = externalUserID
	}
	result := &FormSubmissionResult{}
	path := "/v1/forms/" + url.PathEscape(formKey) + "/submissions"
	if err := client.request(ctx, path, payload, result); err != nil {
		return nil, err
	}
	return result, nil
}

func (client *Client) request(ctx context.Context, path string, payload any, result any) error {
	body, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	request, err := http.NewRequestWithContext(ctx, http.MethodPost, client.host+path, bytes.NewReader(body))
	if err != nil {
		return err
	}
	request.Header.Set("Authorization", "Bearer "+client.apiKey)
	request.Header.Set("Content-Type", "application/json")
	request.Header.Set("User-Agent", userAgent)

	response, err := client.httpClient.Do(request)
	if err != nil {
		return err
	}
	defer response.Body.Close()

	rawBody, err := io.ReadAll(response.Body)
	if err != nil {
		return err
	}
	if response.StatusCode < 200 || response.StatusCode >= 300 {
		return &APIError{StatusCode: response.StatusCode, Body: string(rawBody)}
	}

	if err := json.Unmarshal(rawBody, result); err != nil {
		return err
	}
	return nil
}
