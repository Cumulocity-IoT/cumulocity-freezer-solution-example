# Instructions

## Build

In order to build the public-options and ui-assets you simply need to zip the content of the folders seperately. Ensure you include the cumulocity.json in each zip. You should end up with a ```ui-assets.zip``` and a ```public-options.zip```.

## Deploy

You can either use the ```c8ycli``` tool to deploy or you can manually deploy them via the adminstration application.

### via c8ycli

Simply switch to the locations of each zip and run ```c8ycli deploy ui-assets.zip``` and ```c8ycli deploy public-options.zip```. You will be prompted to enter URL and credentials for the upload.

### via Administration

Switch to "Own applications" and click "Add application" and select "Upload web application". Then drag and drop the zip or select it form the filesystem. You need to repeat the process for the other zip.

## Customize

The options.json in public-options is your main entry for adding branding parameters. You can find a list of branding parameters in the [documentation](https://cumulocity.com/guides/web/angular/#branding). The options.json here already includes the styles.css from the ui-assets where you can include even more CSS. The full guide how to utilize the branding (including adding own languages) can be found [here](https://cumulocity.com/guides/web/angular/#customization).