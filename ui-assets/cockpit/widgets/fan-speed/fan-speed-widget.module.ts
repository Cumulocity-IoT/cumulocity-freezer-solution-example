import { NgModule } from '@angular/core';
import { CoreModule, HOOK_COMPONENT } from "@c8y/ngx-components";
import { FanSpeedWidgetComponent } from './fan-speed-widget.component';
import { FanSpeedWidgetConfigComponent } from './fan-speed-widget-config/fan-speed-widget-config.component';
import { RouterModule } from '@angular/router';

@NgModule({
  declarations: [FanSpeedWidgetComponent, FanSpeedWidgetConfigComponent],

  imports: [
    CoreModule,
    RouterModule.forRoot([])
  ],
  
  exports: [FanSpeedWidgetComponent, FanSpeedWidgetConfigComponent, RouterModule],
  entryComponents: [FanSpeedWidgetComponent, FanSpeedWidgetConfigComponent],
  providers: [
    {
      provide: HOOK_COMPONENT,
      multi: true,
      useValue: {
          id: 'fan-speed.widget',
          label: 'Fan speed control',
          description: 'Remote control the speed of the fan',
          component: FanSpeedWidgetComponent,
          configComponent: FanSpeedWidgetConfigComponent,
          data: {
              ng1: {
                  options: {
                    noDeviceTarget: false,
                    noNewWidgets: false,
                    deviceTargetNotRequired: false,
                    groupsSelectable: false
                  }
              }
          }
      }
    }],
})
export class FanSpeedWidgetModule { }
