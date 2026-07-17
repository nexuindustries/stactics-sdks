# Stactics Angular SDK

Angular wrapper around `@stactics/js`.

```ts
import { ApplicationConfig } from '@angular/core';
import { provideStactics } from '@stactics/angular';

export const appConfig: ApplicationConfig = {
  providers: [
    provideStactics({
      apiKey: 'pk_...',
      environment: 'production',
    }),
  ],
};
```

```ts
import { StacticsEvents, StacticsService } from '@stactics/angular';

constructor(private readonly stactics: StacticsService) {}

signup() {
  this.stactics.trackEvent(StacticsEvents.signup({
    userId: 'user_123',
    email: 'founder@example.com',
    displayName: 'Sam Founder',
    metadata: { plan: 'free' },
  }));
}

login() {
  this.stactics.trackEvent(StacticsEvents.login({
    userId: 'user_123',
    email: 'founder@example.com',
    displayName: 'Sam Founder',
    deviceId: 'install_abc',
  }));
}

purchase() {
  this.stactics.trackEvent(StacticsEvents.purchase({
    userId: 'user_123',
    accountId: 'team_123',
    amountCents: 1299,
    currency: 'AUD',
    metadata: { transactionId: 'txn_123', productId: 'pro_monthly' },
  }));
}

screenViewed() {
  this.stactics.trackEvent(StacticsEvents.screenViewed({
    userId: 'user_123',
    metadata: { path: '/dashboard' },
  }));
}

checkoutError() {
  this.stactics.trackEvent(StacticsEvents.error({
    userId: 'user_123',
    metadata: { error: 'Payment provider timeout', context: 'checkout' },
  }));
}
```

Use a `pk_...` key in Angular/browser apps.

Submit form values directly through the service; the Angular application remains responsible for retrieving and rendering the form definition:

```ts
await this.stactics.submitForm('contact', {
  name: 'Ada Founder',
  email: 'ada@example.com',
  message: 'I would like to discuss a technical collaboration.',
  consent: true,
}, {
  source: 'web',
  externalUserId: 'visitor_123',
});
```

`StacticsEventTypes` exposes the default event names and `StacticsEvents` builds payloads for `signup`, `login`, `active`, `purchase`, `subscriptionStarted`, `subscriptionCancelled`, `trialStarted`, `trialConverted`, `crash`, `error`, `appOpened`, `screenViewed`, `featureUsed`, `notificationSent`, `notificationOpened`, and `healthCheck`.
