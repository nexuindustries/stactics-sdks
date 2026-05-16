package app.stactics

import com.sun.net.httpserver.HttpServer
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class StacticsClientTest {
    @Test
    fun trackPostsSingleEvent() {
        val server = TestServer("""{"accepted":true,"accepted_count":1}""")
        server.start()
        try {
            val client = StacticsClient(apiKey = "st_live_test", host = server.url)

            val result = client.trackBlocking(
                eventType = "signup",
                userId = "user_123",
                environment = "production",
                metadata = mapOf("plan" to "free")
            )

            assertTrue(result.accepted)
            assertEquals(1, result.acceptedCount)
            assertEquals("/v1/events", server.path)
            assertEquals("Bearer st_live_test", server.headers["Authorization"]?.first())
            assertEquals("application/json", server.headers["Content-Type"]?.first())
            assertEquals("stactics-android/0.1.0", server.headers["User-agent"]?.first())
            assertTrue(server.body.contains(""""event_type":"signup""""))
            assertTrue(server.body.contains(""""user_id":"user_123""""))
        } finally {
            server.stop()
        }
    }

    @Test
    fun batchPostsEvents() {
        val server = TestServer("""{"accepted":true,"accepted_count":2}""")
        server.start()
        try {
            val client = StacticsClient(apiKey = "st_secret_test", host = server.url)
            val result = client.batchBlocking(
                listOf(
                    StacticsEvent(eventType = "app_opened", deviceId = "install_abc"),
                    StacticsEvent(eventType = "screen_viewed", metadata = mapOf("screen" to "Home"))
                )
            )

            assertEquals(2, result.acceptedCount)
            assertEquals("/v1/events/batch", server.path)
            assertTrue(server.body.contains(""""events""""))
            assertTrue(server.body.contains(""""device_id":"install_abc""""))
        } finally {
            server.stop()
        }
    }
}

private class TestServer(private val responseBody: String) {
    private val server = HttpServer.create(java.net.InetSocketAddress(0), 0)
    var path: String = ""
    var body: String = ""
    var headers: com.sun.net.httpserver.Headers = com.sun.net.httpserver.Headers()

    val url: String
        get() = "http://127.0.0.1:${server.address.port}"

    fun start() {
        server.createContext("/") { exchange ->
            path = exchange.requestURI.path
            headers = exchange.requestHeaders
            body = exchange.requestBody.bufferedReader().readText()
            exchange.sendResponseHeaders(201, responseBody.toByteArray().size.toLong())
            exchange.responseBody.use { it.write(responseBody.toByteArray()) }
        }
        server.start()
    }

    fun stop() {
        server.stop(0)
    }
}
