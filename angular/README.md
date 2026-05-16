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
import { StacticsService } from '@stactics/angular';

constructor(private readonly stactics: StacticsService) {}

signup() {
  this.stactics.track('signup', {
    userId: 'user_123',
    metadata: { plan: 'free' },
  });
}
```

Use a `pk_...` key in Angular/browser apps.
