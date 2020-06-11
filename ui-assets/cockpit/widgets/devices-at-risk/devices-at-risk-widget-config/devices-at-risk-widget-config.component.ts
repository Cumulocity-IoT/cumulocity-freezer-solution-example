import { Component, OnInit, Input } from '@angular/core';

@Component({
  selector: 'lib-devices-at-risk-widget-config',
  templateUrl: './devices-at-risk-widget-config.component.html',
  styleUrls: ['./devices-at-risk-widget-config.component.css']
})
export class DevicesAtRiskWidgetConfigComponent implements OnInit {

  constructor() { }
  @Input() config: any = {}; 

  ngOnInit() {
  }

}
