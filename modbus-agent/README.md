# Modbus Agent

This short python script connect towards a local Modbus TCP server and transforms the data in order to send it to Cumulocity IoT via MQTT. It also supports updating a Modbus register via the Cumulocity IoT Shell feature in the Devicemanagement.

## Requirements

- Python 3
- Install requirements from file
- Set your tenant and credentials in the agent.ini

## Run the agent

Simply run the python script via

```
python modbus-client.py
```

Note: You need to run the command from the folder your agent.ini is located.



