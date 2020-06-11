import { Injectable } from '@angular/core';
import { InventoryService, IdentityService } from '@c8y/client';


@Injectable()

export class DevicesAtRiskWidgetService {

  constructor(public inventory: InventoryService, public identity: IdentityService) {}

  // Variables
  response: any;
  deviceResponse: any;
  dataSource: any;
  devicesAll: any;
  devicesAtRisk: Device[] = [];
  latestFirmwareVersion = 0;

  async getDeviceList(config) {
    // Clear array
    this.devicesAtRisk = [];

    // Verify that the config contains a group and not a device
    if (config.device.hasOwnProperty('c8y_IsDevice')) {
      alert('Please select a group for this widget to fuction correctly'); 
    } else {
      const filter: object = {
        pageSize: 100
      };
      const groupContent = await this.inventory.childAssetsList(config.device.id, filter);
      this.devicesAll = groupContent.data;
      this.devicesAll.map(async (device) => {
        const deviceData = await this.fetchData(device);
        if ( deviceData != null) {
          this.devicesAtRisk.push(deviceData);
        }
      });
    }
    return this.devicesAtRisk;
  }

  async fetchData(childDevice) {
    let majorAlerts = false;
    let criticalAlerts = false;

    // Extract alarm status and verify
    const activeAlerts = childDevice.c8y_ActiveAlarmsStatus;
    if (activeAlerts !== undefined) {
      if (activeAlerts.hasOwnProperty('major')) {
        if (activeAlerts.major > 0) { 
          majorAlerts = true; 
        }
      }
      if (activeAlerts.hasOwnProperty('critical')) {
        if (activeAlerts.critical > 0) { 
          criticalAlerts = true; 
        }
      }
    }
    // Check if there are any Alerts
    if (majorAlerts || criticalAlerts) {
      // Add Alert information
      let alertDesc = '';
      if (criticalAlerts) { 
        alertDesc += 'Critial Alarms: ' + childDevice.c8y_ActiveAlarmsStatus.critical; 
      }
      if (majorAlerts) {
        if (alertDesc.length > 0) {
          alertDesc += ' '
        }
        alertDesc += 'Major Alarms: ' + childDevice.c8y_ActiveAlarmsStatus.major; 
      }

      const device: Device = {
        id: childDevice.id,
        name: childDevice.name,
        alarms: alertDesc,
        availability: (childDevice.c8y_Availability && childDevice.c8y_Availability.status ? childDevice.c8y_Availability.status : '')
      };
      return device;
    }
    // Devices without major or critical alarms are not shown
    return null;
  }
}

// Table row construct
export interface Device {
  id: string;
  name: string;
  alarms: string;
  availability: string;
}
