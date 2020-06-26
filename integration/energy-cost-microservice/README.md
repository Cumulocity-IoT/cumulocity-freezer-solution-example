# Energy cost microservice

## Prerequisites

Follow the instructions of the [official documentation](https://cumulocity.com/guides/microservice-sdk/java/#overview) for setting up Java, Maven and Docker

## Building and deploying the microservice

Run ```mvn clean install``` in the current directory. Afterwards you will find a ```energy-cost-*.zip``` in the target folder which you can upload to your Cumulocity tenant.

## Adapting the microservice to your device

The microservice does the calculation for a fixed device and a fixed measurement. You will need to change at least the device parameters to make it work for your device (lines 37-40). 
