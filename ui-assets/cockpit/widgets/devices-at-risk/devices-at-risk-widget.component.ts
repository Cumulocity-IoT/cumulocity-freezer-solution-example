import { Component, OnInit, Input, ViewChild, OnDestroy } from '@angular/core';
import { MatSort, MatTableDataSource } from '@angular/material';
import { DevicesAtRiskWidgetService, Device } from './devices-at-risk-widget.service'
import { InventoryService } from '@c8y/client';
import { Subject } from 'rxjs';

@Component({
  selector: 'lib-devices-at-risk-widget',
  templateUrl: 'devices-at-risk-widget.html',
  styleUrls: ['material-grid.component.css']
})
export class DevicesAtRiskWidgetComponent implements OnInit, OnDestroy {

  displayedColumns: string[] = ['id', 'name', 'alarms', 'availability'];
  dataSource = new MatTableDataSource<Device>([]);
  realtimeState = true;
  unsubscribeRealTime$ = new Subject<void>();
  @Input() config;
  @ViewChild(MatSort, {static: false}) sort: MatSort;

   externalId = {};

  constructor(
    private deviceListService: DevicesAtRiskWidgetService, 
    private inventory: InventoryService) { 
  }

  toggle() {
    this.realtimeState = !this.realtimeState;
    if (this.realtimeState) {
      this.handleReatime();
    } else {
      this.unsubscribeRealTime$.next();
    }
  }

  async handleReatime() {
    const inventory = await this.inventory.detail(this.config.device.id);
    const response = inventory.data;

    // Check that the response is a group and not a device
    if (response.hasOwnProperty('c8y_IsDevice')) {
      alert('Please select a group for this widget to fuction correctly'); 
    } else {
      const devicesAll = response.childAssets.references;
      devicesAll.map(async (device) => {
        this.inventory.detail$(device.managedObject.id, {
          hot: true,
          realtime: true
        })
        .subscribe((data) => {
          this.manageRealtime(data);
        });
      });
    }
  }

  async manageRealtime(realtimeUpdate) {
    if (this.realtimeState) {
      for(const updatedObject of realtimeUpdate) {
        const tableData = this.dataSource.data.filter(singleDevice => singleDevice.id !== updatedObject.id);
        const deviceData = await this.deviceListService.fetchData(updatedObject);
        if (deviceData != null) {
          tableData.push(deviceData);
        }
        this.dataSource.data = [...tableData];
      }
    };    
  }

  async ngOnInit() {
    this.dataSource.data = await this.deviceListService.getDeviceList(this.config);
    this.dataSource.sort = this.sort;
    this.handleReatime();
  }

  ngOnDestroy(): void {
    this.unsubscribeRealTime$.next();
    this.unsubscribeRealTime$.complete();
  }

  async refresh() {
    this.dataSource.data = await this.deviceListService.getDeviceList(this.config);
    this.dataSource.sort = this.sort;
  }
}
