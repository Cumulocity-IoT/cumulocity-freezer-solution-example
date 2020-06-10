#!/usr/bin/env python

from pymodbus.client.sync import ModbusTcpClient as ModbusClient
import paho.mqtt.client as mqtt

from uuid import getnode
import logging, time, configparser, os

# --- Logging configuration ---
FORMAT = ('%(asctime)-15s %(threadName)-15s %(levelname)-8s %(module)-15s:%(lineno)-8s %(message)s')
logging.basicConfig(format=FORMAT)
log = logging.getLogger()
log.setLevel(logging.INFO)

C8Y_CONFIGURATION_PATH = os.getcwd() + '/agent.ini'

logging.debug(C8Y_CONFIGURATION_PATH)

configuration = configparser.ConfigParser()
configuration.read(C8Y_CONFIGURATION_PATH)

logging.debug(configuration.sections())

# --- Cumulocity configuration ---
C8Y_BASEURL = configuration.get('cumulocity','baseurl')
C8Y_MQTT_PORT = int(configuration.get('cumulocity','mqtt.port'))
C8Y_PING_INTERVAL = int(configuration.get('cumulocity','mqtt.ping.interval'))
C8Y_BOOTSTRAP_TENANT = configuration.get('cumulocity','tenant')
C8Y_BOOTSTRAP_USER = configuration.get('cumulocity','username')
C8Y_BOOTSTRAP_PASSWORD = configuration.get('cumulocity','password')

# --- Modbus server configuration --- 
MODBUS_UNIT = 0x1
MODBUS_SERVER_IP = 'localhost'
MODBUS_SERVER_PORT = 5020
MODBUS_POLL_INTERVAL = 5

# --- Modbus data configuration ---
MODBUS_HOLDING_REGISTERS = [
    {
        'number': 1,                                # the modbus number
        'startBit': 0,                              # the first bit to read from the register
        'noBits': 16,                               # the number of bits to read from the register
        'signed': False,                            # if the bytes should be interpreted as signed
        'divisor': 100,                             # divide value by this number
        'multiplier': 1,                            # multiply the value by this number
        'offset': 0,                                # add this value to the number
        'measurementFragment': 'c8y_Temperature',   # measurement fragment in Cumulocity
        'measurementSeries': 'T'                    # measurement series in Cumulocity
    },
    {
        'number': 2,                                # the modbus number
        'startBit': 0,                              # the first bit to read from the register
        'noBits': 16,                               # the number of bits to read from the register
        'signed': False,                            # if the bytes should be interpreted as signed
        'divisor': 1,                               # divide value by this number
        'multiplier': 1,                            # multiply the value by this number
        'offset': 0,                                # add this value to the number
        'measurementFragment': 'c8y_EnergyUsage',   # measurement fragment in Cumulocity
        'measurementSeries': 'total'                # measurement series in Cumulocity
    },
    {
        'number': 3,                                # the modbus number
        'startBit': 0,                              # the first bit to read from the register
        'noBits': 16,                               # the number of bits to read from the register
        'signed': False,                            # if the bytes should be interpreted as signed
        'divisor': 100,                             # divide value by this number
        'multiplier': 1,                            # multiply the value by this number
        'offset': 0,                                # add this value to the number
        'measurementFragment': 'c8y_Humidity',      # measurement fragment in Cumulocity
        'measurementSeries': 'H'                    # measurement series in Cumulocity
    },
    {
        'number': 4,                                # the modbus number
        'startBit': 0,                              # the first bit to read from the register
        'noBits': 16,                               # the number of bits to read from the register
        'signed': False,                            # if the bytes should be interpreted as signed
        'divisor': 1,                               # divide value by this number
        'multiplier': 1,                            # multiply the value by this number
        'offset': 0,                                # add this value to the number
        'measurementFragment': 'c8y_SetTemperature',# measurement fragment in Cumulocity
        'measurementSeries': 'T'                    # measurement series in Cumulocity
    },
    {
        'number': 5,                                # the modbus number
        'startBit': 0,                              # the first bit to read from the register
        'noBits': 16,                               # the number of bits to read from the register
        'signed': False,                            # if the bytes should be interpreted as signed
        'divisor': 1,                               # divide value by this number
        'multiplier': 1,                            # multiply the value by this number
        'offset': 0,                                # add this value to the number
        'measurementFragment': 'c8y_FanSpeed',      # measurement fragment in Cumulocity
        'measurementSeries': 'S'                    # measurement series in Cumulocity
    },
    {
        'number': 6,                                # the modbus number
        'startBit': 0,                              # the first bit to read from the register
        'noBits': 16,                               # the number of bits to read from the register
        'signed': False,                            # if the bytes should be interpreted as signed
        'divisor': 1,                               # divide value by this number
        'multiplier': 1,                            # multiply the value by this number
        'offset': 0,                                # add this value to the number
        'measurementFragment': 'c8y_DoorStatus',    # measurement fragment in Cumulocity
        'measurementSeries': 'opened'               # measurement series in Cumulocity
    }
]

CONNECTED_FLAG = False

def on_connect(client, userdata, flags, rc):
    logging.info('Agent connected with result code: '+str(rc))
    if rc == 0:
        global CONNECTED_FLAG
        CONNECTED_FLAG = True

def on_message(client, userdata, msg):
    logging.info('Received message: ' + msg.topic + " " + str(msg.payload))
    messageParts = msg.payload.decode('utf-8').split(',')

    # Check if it is a shell operation
    if messageParts[0] == '511':
        # Set operation to executing
        client.publish('s/us', '501,c8y_Command')

        # Extract value (the 'by force' way)
        try:
            command = messageParts[2].split('=')
            value = int(command[1])
            command = command[0]
            if command == 'setpoint':
                # Write value to Modbus server temperature setpoint register
                modbus_client = ModbusClient(MODBUS_SERVER_IP, port=MODBUS_SERVER_PORT)
                modbus_client.connect()
                modbus_client.write_register(4, value, unit=MODBUS_UNIT)
                modbus_client.close()
            elif command == 'fan':
                # Write value to Modbus server fan speed register
                modbus_client = ModbusClient(MODBUS_SERVER_IP, port=MODBUS_SERVER_PORT)
                modbus_client.connect()
                modbus_client.write_register(5, value, unit=MODBUS_UNIT)
                modbus_client.close()
            # Set operation to successful
            client.publish('s/us', '503,c8y_Command')
        except Exception as error:
            log.error(error)
            # Set operation to failed
            client.publish('s/us', '502,c8y_Command, That did not work')        

def run_modbus_client():
    serial = str(getnode())
    logging.info('Serial: ' + serial)

    # Setup MQTT connection to Cumulocity
    mqtt_client = mqtt.Client(serial)
    mqtt_client.on_connect = on_connect
    mqtt_client.on_message = on_message

    mqtt_client.username_pw_set(C8Y_BOOTSTRAP_TENANT + '/' + C8Y_BOOTSTRAP_USER, C8Y_BOOTSTRAP_PASSWORD)
    mqtt_client.connect(C8Y_BASEURL, C8Y_MQTT_PORT, C8Y_PING_INTERVAL)

    mqtt_client.loop_start()
    # Wait until successful connected
    while not CONNECTED_FLAG:
        time.sleep(1)
    
    # Subscribe to error channel
    #mqtt_client.subscribe('s/e')
    # Subscribe to static downlink messages
    mqtt_client.subscribe('s/ds')

    # Create device object
    mqtt_client.publish('s/us', '100,My New Modbus Device,c8y_PythonModbusAgent')
    # Set supported operations
    mqtt_client.publish('s/us', '114,c8y_Restart,c8y_SoftwareList,c8y_Firmware,c8y_Command')

    # Setup Modbus connection
    modbus_client = ModbusClient(MODBUS_SERVER_IP, port=MODBUS_SERVER_PORT)
    modbus_client.connect()

    try:
        while True:
            # Wait for polling interval
            time.sleep(MODBUS_POLL_INTERVAL)
            for register in MODBUS_HOLDING_REGISTERS:
                # Request the register from the Modbus server
                rr = modbus_client.read_holding_registers(register['number'], 1, unit=MODBUS_UNIT)
                logging.info(rr.registers)
                rawValue = rr.registers[0]
                # Transform the value
                calculatedValue = rawValue * register['multiplier'] / register['divisor']
                offsetValue = calculatedValue + register['offset']
                # Send data to Cumulocity IoT
                mqtt_client.publish('s/us', '200,' + register['measurementFragment'] + ',' + register['measurementSeries'] + ',' + str(offsetValue))
    except Exception as error:
        log.error(error)
        modbus_client.close()
        mqtt_client.disconnect()

if __name__ == "__main__":
    run_modbus_client()