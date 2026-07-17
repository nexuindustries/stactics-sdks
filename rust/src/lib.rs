use reqwest::header::{HeaderMap, HeaderValue, AUTHORIZATION, CONTENT_TYPE, USER_AGENT};
use serde::de::DeserializeOwned;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};

const DEFAULT_HOST: &str = "https://api.stactics.io";
const USER_AGENT_VALUE: &str = "stactics-rust/0.1.4";

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug, thiserror::Error)]
pub enum Error {
    #[error("stactics API request failed with status {status}: {body}")]
    Api { status: u16, body: Value },
    #[error(transparent)]
    Http(#[from] reqwest::Error),
    #[error(transparent)]
    Header(#[from] reqwest::header::InvalidHeaderValue),
    #[error(transparent)]
    Json(#[from] serde_json::Error),
}

#[derive(Clone)]
pub struct Client {
    api_key: String,
    host: String,
    http: reqwest::Client,
}

impl Client {
    pub fn new(api_key: impl Into<String>) -> Self {
        Self {
            api_key: api_key.into(),
            host: DEFAULT_HOST.to_string(),
            http: reqwest::Client::new(),
        }
    }

    pub fn with_host(mut self, host: impl Into<String>) -> Self {
        self.host = host.into().trim_end_matches('/').to_string();
        self
    }

    pub fn with_http_client(mut self, http: reqwest::Client) -> Self {
        self.http = http;
        self
    }

    pub async fn track(&self, event: Event) -> Result<Response> {
        self.request("/v1/events", &event).await
    }

    pub async fn batch(&self, events: Vec<Event>) -> Result<Response> {
        self.request("/v1/events/batch", &json!({ "events": events }))
            .await
    }

    pub async fn submit_form(
        &self,
        form_key: &str,
        field_data: Value,
        source: Option<&str>,
        external_user_id: Option<&str>,
    ) -> Result<FormSubmissionResponse> {
        let mut payload = json!({ "fieldData": field_data });
        if let Some(source) = source {
            payload["source"] = json!(source);
        }
        if let Some(external_user_id) = external_user_id {
            payload["external_user_id"] = json!(external_user_id);
        }
        self.request(&format!("/v1/forms/{form_key}/submissions"), &payload)
            .await
    }

    async fn request<T: Serialize + ?Sized, R: DeserializeOwned>(
        &self,
        path: &str,
        payload: &T,
    ) -> Result<R> {
        let response = self
            .http
            .post(format!("{}{}", self.host, path))
            .headers(self.headers()?)
            .json(payload)
            .send()
            .await?;
        let status = response.status();
        let body = response.json::<Value>().await.unwrap_or_else(|_| json!({}));

        if !status.is_success() {
            return Err(Error::Api {
                status: status.as_u16(),
                body,
            });
        }

        Ok(serde_json::from_value(body)?)
    }

    fn headers(&self) -> Result<HeaderMap> {
        let mut headers = HeaderMap::new();
        headers.insert(
            AUTHORIZATION,
            HeaderValue::from_str(&format!("Bearer {}", self.api_key))?,
        );
        headers.insert(CONTENT_TYPE, HeaderValue::from_static("application/json"));
        headers.insert(USER_AGENT, HeaderValue::from_static(USER_AGENT_VALUE));
        Ok(headers)
    }
}

#[derive(Clone, Debug, Default, Serialize)]
pub struct Event {
    pub event_type: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub user_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub account_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub email: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub device_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub build_version: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub platform: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub environment: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub amount_cents: Option<i64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub currency: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub metadata: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub occurred_at: Option<String>,
}

impl Event {
    pub fn new(event_type: impl Into<String>) -> Self {
        Self {
            event_type: event_type.into(),
            ..Default::default()
        }
    }

    pub fn user_id(mut self, value: impl Into<String>) -> Self {
        self.user_id = Some(value.into());
        self
    }

    pub fn account_id(mut self, value: impl Into<String>) -> Self {
        self.account_id = Some(value.into());
        self
    }

    pub fn email(mut self, value: impl Into<String>) -> Self {
        self.email = Some(value.into());
        self
    }

    pub fn device_id(mut self, value: impl Into<String>) -> Self {
        self.device_id = Some(value.into());
        self
    }

    pub fn build_version(mut self, value: impl Into<String>) -> Self {
        self.build_version = Some(value.into());
        self
    }

    pub fn platform(mut self, value: impl Into<String>) -> Self {
        self.platform = Some(value.into());
        self
    }

    pub fn environment(mut self, value: impl Into<String>) -> Self {
        self.environment = Some(value.into());
        self
    }

    pub fn amount_cents(mut self, value: i64) -> Self {
        self.amount_cents = Some(value);
        self
    }

    pub fn currency(mut self, value: impl Into<String>) -> Self {
        self.currency = Some(value.into());
        self
    }

    pub fn metadata(mut self, value: Value) -> Self {
        self.metadata = Some(value);
        self
    }

    pub fn occurred_at(mut self, value: impl Into<String>) -> Self {
        self.occurred_at = Some(value.into());
        self
    }
}

#[derive(Clone, Debug, Default, Deserialize, PartialEq, Eq)]
pub struct Response {
    pub accepted: bool,
    pub accepted_count: u64,
}

#[derive(Clone, Debug, Deserialize, PartialEq, Eq)]
pub struct FormSubmissionResponse {
    pub accepted: bool,
    pub submission_id: String,
    pub submitted_at: String,
    pub message: Option<String>,
}
