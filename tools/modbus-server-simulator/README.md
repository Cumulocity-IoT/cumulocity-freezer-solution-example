# Modbus Server Simulator

This short python script sets up a Modbus TCP server and simulates several holding registers.

## Requirements

- Python 3
- Install requirements from file

## Run the server

Simply run the python script via

```
python modbus-server.py
```

## Extending the simulator

In order to simulate additional regsiters the SIMULATIONS list can be extended. The simulation thread runs every 5 seconds and updates all simulated registers by calling the defined simulation functions.


