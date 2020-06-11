import { NgModule } from '@angular/core';
import { CoreModule, HOOK_COMPONENT } from "@c8y/ngx-components";
import { DevicesAtRiskWidgetComponent } from './devices-at-risk-widget.component';
import { MatSortModule, MatTableModule, MatPaginatorModule, MatButtonModule } from '@angular/material';
import { DevicesAtRiskWidgetConfigComponent } from './devices-at-risk-widget-config/devices-at-risk-widget-config.component';
import { DevicesAtRiskWidgetService } from './devices-at-risk-widget.service';
import { RouterModule } from '@angular/router';



@NgModule({
  declarations: [DevicesAtRiskWidgetComponent, DevicesAtRiskWidgetConfigComponent],

  imports: [
    MatTableModule,
    MatSortModule,
    MatPaginatorModule,
    MatButtonModule,
    CoreModule,
    RouterModule.forRoot([])
  ],
  
  exports: [DevicesAtRiskWidgetComponent, DevicesAtRiskWidgetConfigComponent, RouterModule],
  entryComponents: [DevicesAtRiskWidgetComponent, DevicesAtRiskWidgetConfigComponent],
  providers: [
    DevicesAtRiskWidgetService,
    {
      provide: HOOK_COMPONENT,
      multi: true,
      useValue: {
          id: 'devices-at-risk.widget',
          label: 'Devices At Risk',
          description: 'Devices at Risk Dashboard - Displays all the devices with risk levels in the dashboard',
          component: DevicesAtRiskWidgetComponent,
          configComponent: DevicesAtRiskWidgetConfigComponent,
          data: {
              ng1: {
                  options: {
                    noDeviceTarget: true,
                    noNewWidgets: false,
                    deviceTargetNotRequired: false,
                    groupsSelectable: true
                  }
              }
          }
      }
    }],
})
export class DevicesAtRiskWidgetModule { }
