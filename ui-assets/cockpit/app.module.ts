// Generated imports from clic8y
import { NgModule } from '@angular/core';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { RouterModule as NgRouterModule } from '@angular/router';
import { UpgradeModule as NgUpgradeModule } from '@angular/upgrade/static';
import { CoreModule, RouterModule } from '@c8y/ngx-components';
import { UpgradeModule, HybridAppModule, UPGRADE_ROUTES } from '@c8y/ngx-components/upgrade';
import { AssetsNavigatorModule } from '@c8y/ngx-components/assets-navigator';
import { ReportsModule } from '@c8y/ngx-components/reports';
import { ContextDashboardModule } from '@c8y/ngx-components/context-dashboard';

// New imports
import { DevicesAtRiskWidgetModule } from './widgets/devices-at-risk/devices-at-risk-widget.module';
import { FanSpeedWidgetModule } from './widgets/fan-speed/fan-speed-widget.module';

@NgModule({
  imports: [
    BrowserAnimationsModule,
    RouterModule.forRoot(),
    NgRouterModule.forRoot([...UPGRADE_ROUTES], { enableTracing: false, useHash: true }),
    CoreModule.forRoot(),
    AssetsNavigatorModule,
    ReportsModule,
    NgUpgradeModule,
    ContextDashboardModule,
    // Include new modules in imports
    DevicesAtRiskWidgetModule,
    FanSpeedWidgetModule,
    // Upgrade module must be the last
    UpgradeModule
  ]
})
export class AppModule extends HybridAppModule {
  constructor(protected upgrade: NgUpgradeModule) {
    super();
  }
}
