import { Component, OnInit, OnDestroy, Input } from '@angular/core';
import { OperationService, IOperation } from '@c8y/client';



@Component({
  selector: 'fan-speed-widget',
  templateUrl: 'fan-speed-widget.html'
})
export class FanSpeedWidgetComponent implements OnInit, OnDestroy {

  setSpeed: any;
  @Input() config;

  constructor(
    private operationSerivce: OperationService) { 
  }

  async setFanSpeed(fanSpeed) {
    const speedFanOperation: IOperation = {
      c8y_Command: {
        text: 'fan=' + fanSpeed,
      },
      deviceId: this.config.device.id,
    };
    this.operationSerivce.create(speedFanOperation);
    this.setSpeed = '';
  }

  async ngOnInit() {
  }

  ngOnDestroy(): void {
  }
}
