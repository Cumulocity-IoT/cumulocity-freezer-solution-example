package c8y.example;

import java.util.Date;
import java.util.List;

import com.cumulocity.microservice.autoconfigure.MicroserviceApplication;
import com.cumulocity.microservice.subscription.service.MicroserviceSubscriptionsService;
import com.cumulocity.model.ID;
import com.cumulocity.rest.representation.identity.ExternalIDRepresentation;
import com.cumulocity.rest.representation.inventory.ManagedObjectRepresentation;
import com.cumulocity.rest.representation.measurement.MeasurementRepresentation;
import com.cumulocity.sdk.client.Param;
import com.cumulocity.sdk.client.QueryParam;
import com.cumulocity.sdk.client.identity.IdentityApi;
import com.cumulocity.sdk.client.measurement.MeasurementApi;
import com.cumulocity.sdk.client.measurement.MeasurementCollection;
import com.cumulocity.sdk.client.measurement.MeasurementFilter;
import com.jayway.jsonpath.JsonPath;

import org.joda.time.DateTime;
import org.joda.time.DateTimeZone;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.web.client.RestTemplate;

@MicroserviceApplication
public class App {
	private static final org.slf4j.Logger LOG = LoggerFactory.getLogger(App.class);
	private static final String ENERGY_API = "https://hourlypricing.comed.com/api?type=5minutefeed";

	// Configuration CHANGE HERE
	private static final String DEVICE_EXTERNAL_ID_TYPE ="c8y_Serial";
	private static final String DEVICE_EXTERNAL_ID_VALUE="154505277107645";
	private static final String ENERGY_MEASUREMENT_FRAGEMENT = "c8y_EnergyUsage";
	private static final String ENERGY_MEASUREMENT_SERIES = "total";
	// -------------

	private final IdentityApi identityApi;
	private final MeasurementApi measurementApi;

	private final MicroserviceSubscriptionsService subscriptionService;

	@Autowired
	public App(IdentityApi identityApi, MicroserviceSubscriptionsService subscriptionService, MeasurementApi measurementApi) {
		this.identityApi = identityApi;
		this.subscriptionService = subscriptionService;
		this.measurementApi = measurementApi;
	}

	public static void main(String[] args) {
		SpringApplication.run(App.class, args);
	}
	// run every 5 minutes
	//@Scheduled(cron = "0 */5 * * * *")
	// run at midnight
	@Scheduled(cron = "0 0 0 * * *") 
	public void startThread() {
		// the cron job will run for each tenant subscribed to the microservice
		subscriptionService.runForEachTenant(new Runnable() {
			@Override
			public void run() {
				LOG.info("Start scheduled job");
				double dailyEnergyUsage;
				double dataNow;
				double data24hAgo;
				
				try { 
					// Get the device object
					ManagedObjectRepresentation deviceObject = resolveManagedObject(DEVICE_EXTERNAL_ID_TYPE, DEVICE_EXTERNAL_ID_VALUE);
					// Get current time
					Date currentDate = new Date();
					// Get time from previous slot (-24h)
					Date dateFrom24hAgo = new Date(currentDate.getTime() - (1000*60*60*24));

					// Setup query filter for getting latest measurement
					MeasurementCollection measurementCollection = measurementApi.getMeasurementsByFilter(
							new MeasurementFilter().byDate(dateFrom24hAgo, currentDate)
									.byValueFragmentTypeAndSeries(ENERGY_MEASUREMENT_FRAGEMENT, ENERGY_MEASUREMENT_SERIES)
									.bySource(deviceObject.getId()));
					
					// Get 1 value in revert order = get latest value
					List<MeasurementRepresentation> measurementList = measurementCollection
							.get(1, new QueryParam(new Param() {
								@Override
								public String getName() {
									return "revert";
								}
							}, "true")).getMeasurements();
					if (measurementList.isEmpty()) {
						LOG.info("Nmeasurements within last day. Skip calculation");
						return;
					}
					MeasurementRepresentation lastEnergyMeasurement = measurementList.get(0);
					LOG.info("[latest data]: " + lastEnergyMeasurement.toJSON());
					
					JSONParser measurementJsonParse = new JSONParser();
					JSONObject jsonObj = (JSONObject) measurementJsonParse.parse(lastEnergyMeasurement.toJSON());
					JSONObject totalObj = JsonPath.parse(jsonObj).read("$." + ENERGY_MEASUREMENT_FRAGEMENT + "." + ENERGY_MEASUREMENT_SERIES);
					dataNow = (double)totalObj.get("value");
					LOG.info("[SDK] latest Data:  " + dataNow);
						
					// Setup query filter for getting last value from previous period
					measurementCollection = measurementApi.getMeasurementsByFilter(
							new MeasurementFilter().byType(ENERGY_MEASUREMENT_FRAGEMENT)
									.byDate(new Date(0), dateFrom24hAgo)
									.byValueFragmentTypeAndSeries(ENERGY_MEASUREMENT_FRAGEMENT, ENERGY_MEASUREMENT_SERIES)
									.bySource(deviceObject.getId()));

					// Get 1 value in revert order = get latest value
					measurementList = measurementCollection
							.get(1, new QueryParam(new Param() {
								@Override
								public String getName() {
									return "revert";
								}
							}, "true")).getMeasurements();
					
					if (measurementList.isEmpty()) {
						LOG.info("Could not find any measurements");
						return;
					}
					MeasurementRepresentation lastEnergyMeasurement24hAgo = measurementList.get(0);
					
					jsonObj = (JSONObject) measurementJsonParse.parse(lastEnergyMeasurement24hAgo.toJSON());
					totalObj = JsonPath.parse(jsonObj).read("$." + ENERGY_MEASUREMENT_FRAGEMENT + "." + ENERGY_MEASUREMENT_SERIES);
					data24hAgo = (double)totalObj.get("value");
					LOG.info("[SDK] data 24h ago:  " + data24hAgo);
					
					// calculate the energy consumption
					if(dataNow>data24hAgo)
						dailyEnergyUsage = dataNow - data24hAgo;
					else
						dailyEnergyUsage = 0;
					
					LOG.info("[dailyEnergyUsage]:  " + dailyEnergyUsage);
					LOG.info("Call External API: ");

					// Fetch the energy price
					JSONParser jsParse = new JSONParser();
					JSONArray dtArray = (JSONArray) jsParse.parse(externalEnergyRate(ENERGY_API));
					
					// Build the average energy cost over the last day
					double averageEnergyPrice;
					double sum = 0.0;
					double temp = 0.0;
					for (int i = 0; i < dtArray.size(); i++) {
						JSONObject rtObj = (JSONObject) dtArray.get(i);
						temp = Double.parseDouble(rtObj.get("price").toString());
						sum = sum + temp;
					}
					LOG.info("Sum: " + sum + "  Count: " + dtArray.size());
					averageEnergyPrice = sum / dtArray.size();
					LOG.info("Rate: " + averageEnergyPrice);
					
					// Calculate energy cost
					double eCost = dailyEnergyUsage * averageEnergyPrice;
					LOG.info("Energy Cost: " + eCost);

					LOG.info("Send energy cost data to the Cumulocity IoT");
					
					// Build the measurement object
					MeasurementRepresentation energyCostMeasurement = new MeasurementRepresentation();
					energyCostMeasurement.setSource(deviceObject);
					energyCostMeasurement.setType("c8y_EnergyUsage");
					energyCostMeasurement.setDateTime(DateTime.now(DateTimeZone.UTC));

					JSONObject costObj = new JSONObject();
					costObj.put("c8y_UsageCost", getMeasure(eCost, "USD"));
					energyCostMeasurement.setProperty("c8y_EnergyUsage",costObj );
					
					LOG.info("[json] " + energyCostMeasurement.toJSON());
					
					// Send to Cumulocity
					measurementApi.create(energyCostMeasurement);

				} catch (Exception e) {
					LOG.error("Something bad happened", e);
				}
			}
		});
	}

	private ManagedObjectRepresentation resolveManagedObject(String deviceType,String deviceID) {
		ExternalIDRepresentation externalIDRepresentation = identityApi.getExternalId(new ID(deviceType, deviceID));
		return externalIDRepresentation.getManagedObject();
	}

	private String externalEnergyRate(String extUrl) {
		RestTemplate restTemplate = new RestTemplate();
		return restTemplate.getForEntity(extUrl, String.class).getBody();
	}

	private static JSONObject getMeasure(Object value, String unit) {
		JSONObject jo = new JSONObject();
		jo.put("value", value);
		jo.put("unit", unit);
		return jo;
	}


}