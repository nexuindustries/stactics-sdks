package app.stactics

import java.io.IOException
import java.net.HttpURLConnection
import java.net.URI
import java.util.concurrent.CompletableFuture
import java.util.concurrent.Executor
import java.util.concurrent.Executors

class StacticsClient @JvmOverloads constructor(
    private val apiKey: String,
    host: String = DEFAULT_HOST,
    private val executor: Executor = DEFAULT_EXECUTOR
) {
    private val host = host.trimEnd('/')

    fun track(event: StacticsEvent): CompletableFuture<StacticsResult> {
        return send("/v1/events", event)
    }

    @JvmOverloads
    fun track(
        eventType: String,
        userId: String? = null,
        environment: String? = null,
        amountCents: Long? = null,
        currency: String? = null,
        metadata: Map<String, Any?>? = null
    ): CompletableFuture<StacticsResult> {
        return track(
            StacticsEvent(
                eventType = eventType,
                userId = userId,
                environment = environment,
                amountCents = amountCents,
                currency = currency,
                metadata = metadata
            )
        )
    }

    fun trackBlocking(
        eventType: String,
        userId: String? = null,
        environment: String? = null,
        amountCents: Long? = null,
        currency: String? = null,
        metadata: Map<String, Any?>? = null
    ): StacticsResult = track(eventType, userId, environment, amountCents, currency, metadata).get()

    fun batch(events: List<StacticsEvent>): CompletableFuture<StacticsResult> {
        return send("/v1/events/batch", mapOf("events" to events.map { it.toMap() }))
    }

    fun batchBlocking(events: List<StacticsEvent>): StacticsResult = batch(events).get()

    private fun send(path: String, payload: Any?): CompletableFuture<StacticsResult> {
        return CompletableFuture.supplyAsync({
            val connection = URI.create("$host$path").toURL().openConnection() as HttpURLConnection
            connection.requestMethod = "POST"
            connection.setRequestProperty("Authorization", "Bearer $apiKey")
            connection.setRequestProperty("Content-Type", "application/json")
            connection.setRequestProperty("User-Agent", "stactics-android/0.1.1")
            connection.doOutput = true
            connection.outputStream.use { it.write(Json.encode(payload).toByteArray()) }

            val status = connection.responseCode
            val responseBody = readResponse(connection)
            if (status !in 200..299) {
                throw StacticsApiException(status, responseBody)
            }
            StacticsResult.fromJson(responseBody)
        }, executor)
    }

    private fun readResponse(connection: HttpURLConnection): String {
        val stream = if (connection.responseCode in 200..299) connection.inputStream else connection.errorStream
        return stream?.bufferedReader()?.readText().orEmpty()
    }

    companion object {
        const val DEFAULT_HOST = "https://api.stactics.io"
        private val DEFAULT_EXECUTOR = Executors.newCachedThreadPool()
    }
}

data class StacticsEvent(
    val eventType: String,
    val userId: String? = null,
    val accountId: String? = null,
    val email: String? = null,
    val deviceId: String? = null,
    val buildVersion: String? = null,
    val platform: String? = "android",
    val environment: String? = null,
    val amountCents: Long? = null,
    val currency: String? = null,
    val metadata: Map<String, Any?>? = null,
    val occurredAt: String? = null
) {
    fun toMap(): Map<String, Any?> = linkedMapOf(
        "event_type" to eventType,
        "user_id" to userId,
        "account_id" to accountId,
        "email" to email,
        "device_id" to deviceId,
        "build_version" to buildVersion,
        "platform" to platform,
        "environment" to environment,
        "amount_cents" to amountCents,
        "currency" to currency,
        "metadata" to metadata,
        "occurred_at" to occurredAt
    ).filterValues { it != null }

    companion object {
        @JvmStatic
        fun builder(eventType: String): Builder = Builder(eventType)
    }

    class Builder(private val eventType: String) {
        private var userId: String? = null
        private var environment: String? = null
        private var amountCents: Long? = null
        private var currency: String? = null
        private var metadata: Map<String, Any?>? = null

        fun userId(value: String?) = apply { userId = value }
        fun environment(value: String?) = apply { environment = value }
        fun amountCents(value: Long?) = apply { amountCents = value }
        fun currency(value: String?) = apply { currency = value }
        fun metadata(value: Map<String, Any?>?) = apply { metadata = value }
        fun build(): StacticsEvent = StacticsEvent(
            eventType = eventType,
            userId = userId,
            environment = environment,
            amountCents = amountCents,
            currency = currency,
            metadata = metadata
        )
    }
}

data class StacticsResult(val accepted: Boolean, val acceptedCount: Int) {
    companion object {
        fun fromJson(body: String): StacticsResult {
            val accepted = Regex("\"accepted\"\\s*:\\s*true").containsMatchIn(body)
            val count = Regex("\"accepted_count\"\\s*:\\s*(\\d+)").find(body)?.groupValues?.get(1)?.toInt() ?: 0
            return StacticsResult(accepted = accepted, acceptedCount = count)
        }
    }
}

class StacticsApiException(val statusCode: Int, body: String) : IOException(body)

private object Json {
    fun encode(value: Any?): String = when (value) {
        null -> "null"
        is String -> "\"${escape(value)}\""
        is Number, is Boolean -> value.toString()
        is StacticsEvent -> encode(value.toMap())
        is Map<*, *> -> value.entries.joinToString(prefix = "{", postfix = "}") { (key, nested) ->
            "${encode(key.toString())}:${encode(nested)}"
        }
        is Iterable<*> -> value.joinToString(prefix = "[", postfix = "]") { encode(it) }
        else -> encode(value.toString())
    }

    private fun escape(value: String): String = value
        .replace("\\", "\\\\")
        .replace("\"", "\\\"")
        .replace("\n", "\\n")
}
