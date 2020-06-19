# Analytics rules

## Importing the EPL app

1. Go to "Apama EPL apps" via the app switcher
2. Click the "Import EPL" button and upload the doorOpenDuration.mon file
3. Once uploaded set the rule to "Active"

## Importing the Analytics Builder models

1. Go to "Apama Analytics Builder" via the app switcher
2. Click the "Import model" button and upload the JSON files from the analyticsBuilder folder in this directory (you need to import the models one-by-one).
3. Once uploaded you need to edit each model and in the input and output blocks change the device to your own device.
4. Afterwards save the model, set the mode to "Production" and set it to "Active"