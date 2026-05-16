import { EnvironmentProviders, makeEnvironmentProviders } from '@angular/core';
import { STACTICS_CONFIG, StacticsAngularConfig } from './stactics.config';
import { StacticsService } from './stactics.service';

export function provideStactics(config: StacticsAngularConfig): EnvironmentProviders {
  return makeEnvironmentProviders([
    { provide: STACTICS_CONFIG, useValue: config },
    StacticsService,
  ]);
}
