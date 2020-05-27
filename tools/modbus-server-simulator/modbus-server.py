#!/usr/bin/env python

from pymodbus.server.asynchronous import StartTcpServer
from pymodbus.device import ModbusDeviceIdentification
from pymodbus.datastore import ModbusSequentialDataBlock
from pymodbus.datastore import ModbusSlaveContext, ModbusServerContext
from pymodbus.transaction import ModbusRtuFramer, ModbusAsciiFramer

from twisted.internet.task import LoopingCall

import logging, math

FORMAT = ('%(asctime)-15s %(threadName)-15s '
          '%(levelname)-8s %(module)-15s:%(lineno)-8s %(message)s')
logging.basicConfig(format=FORMAT)
log = logging.getLogger()
log.setLevel(logging.DEBUG)


'''
Start simulation functions
'''
def sinus(a, args):
    v = math.sin(a) + args[0]
    v = v * 100
    return int(v)

def increment(a, args):
    return (a + 1) % 65536

def initial(a, args):
    if a == 1:
        return args[0]
    else:
        return None

'''
End simulation functions
'''


SIMULATIONS = [
    {
        "address": 0x01,
        "func": sinus,
        "args": [4]
    },
    {
        "address": 0x02,
        "func": increment,
        "args": []
    },
    {
        "address": 0x03,
        "func": sinus,
        "args": [95]
    },
    {
        "address": 0x04 ,
        "func": initial,
        "args": [4]
    }    
]


LOOP_CALLS = 0

'''
Simulator function being called in an interval and updating the server
'''
def simulator_function(a):
    global LOOP_CALLS
    log.info("updating the context")
    LOOP_CALLS += 1
    context = a[0]
    slave_id = 0x00
    # holding register
    register = 3
    for sim in SIMULATIONS:
        address = sim["address"]
        values = [sim["func"](LOOP_CALLS, sim["args"])]
        if values[0]:
            log.info("update address: %s ; value: %s", str(address), str(values))
            context[slave_id].setValues(register, address, values)


def run_modbus_server():

    # initialize modbus server store with 0 on the first 100 addresses
    store = ModbusSlaveContext(
        di=ModbusSequentialDataBlock(0, [0]*100),
        co=ModbusSequentialDataBlock(0, [0]*100),
        hr=ModbusSequentialDataBlock(0, [0]*100),
        ir=ModbusSequentialDataBlock(0, [0]*100))
    context = ModbusServerContext(slaves=store, single=True)
    
    # simulator loop configuration
    interval = 5
    loop = LoopingCall(f=simulator_function, a=(context,))
    loop.start(interval, now=False)

    # start server on localhost
    StartTcpServer(context, address=("localhost", 5020))


if __name__ == "__main__":
    run_modbus_server()