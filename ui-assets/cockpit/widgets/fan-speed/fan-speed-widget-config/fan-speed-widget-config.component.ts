import { Component, OnInit, Input } from '@angular/core';

@Component({
  selector: 'fan-speed-widget-config',
  templateUrl: './fan-speed-widget-config.component.html',
  styleUrls: ['./fan-speed-widget-config.component.css']
})
export class FanSpeedWidgetConfigComponent implements OnInit {

  constructor() { }
  @Input() config: any = {}; 

  ngOnInit() {
  }

}
