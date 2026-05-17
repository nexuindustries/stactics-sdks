package app.stactics;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.Map;
import org.junit.jupiter.api.Test;

class StacticsJavaInteropTest {
    @Test
    void buildsJavaFriendlyEvents() {
        StacticsEvent event = StacticsEvent.builder("signup")
                .userId("user_123")
                .environment("production")
                .amountCents(1299L)
                .currency("AUD")
                .metadata(Map.of("plan", "free"))
                .build();

        assertEquals("signup", event.getEventType());
        assertEquals("user_123", event.getUserId());
        assertEquals("production", event.getEnvironment());
        assertEquals(1299L, event.getAmountCents());
        assertEquals("AUD", event.getCurrency());
    }
}
