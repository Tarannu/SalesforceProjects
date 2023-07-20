public with sharing class EventRequest_SendToSUS_Retryable extends Retryable {
	private static Sysco_LOG.PlatformBulkLogger log = new Sysco_LOG.PlatformBulkLogger(
		'EventRequest_SendToSUS_Retryable'
	);

	private static String baseURL = ApigeeUtility.getEndpoint() + '/holiday-calendar/holiday-calendar';

	public class Wrapper {
		public Map<String, String> eventAttributes;
	}

	public class Customer_Overrides {
		public String action;
		public String endDate;
		public String siteId;
		public String startDate;
		public String userId;
		public List<String> accountTypes;
		public String cutoffOverridesExternal;
		public String cutoffOverridesInternal;
	}
	private static List<Event_Request__c> getEventRequest(List<Id> eventId) {
		List<Event_Request__c> eventList = new List<Event_Request__c>();

		eventList = [
			SELECT
				Id,
				OwnerId,
				OpCo__r.OpCo_ID__c,
				Cut_Off_Override_Type__c,
				Cutoff_Time__c,
				Account_Type__c,
				Start_Date__c,
				End_Date__c,
				SUS_Error_Message__c,
				Approval_Status__c
			FROM Event_Request__c
			WHERE Id IN :eventId
		];
		return eventList;
	}

	private static Map<Id, User> getUser(List<Event_Request__c> eventList) {
		Set<Id> ownerIds = new Set<Id>();
		for (Event_Request__c e : eventList) {
			ownerIds.add(e.OwnerId);
		}
		Map<Id, User> users = new Map<Id, User>([SELECT Id, Sysco_User_ID__c FROM User WHERE Id IN :ownerIds LIMIT 1]);
		return users;
	}

	public String overrideType;
	private Event_Request__c eve;
	public Wrapper wrapper;
	public Customer_Overrides cutoff_Overrides;
	public EventRequest_SendToSUS_Retryable(
		EventRequest_SendToSUS_Retryable.Wrapper w,
		EventRequest_SendToSUS_Retryable.Customer_Overrides c,
		Event_Request__c e
	) {
		this.wrapper = w;
		this.cutoff_Overrides = c;
		this.eve = e;
		this.overrideType = e.Cut_Off_Override_Type__c;
		retryScheduleInMinutes = new List<Integer>{ 5, 10, 15, 20, 25, 60 };
	}

	@invocableMethod(label='Send to SUS for Cutoff Time Management')
	public static void execute(List<Id> eventId) {
		List<Retryable> safeRetryables = new List<Retryable>();
		Wrapper wrapper = new Wrapper();
		Customer_Overrides co = new Customer_Overrides();
		List<Event_Request__c> eventList = getEventRequest(eventId);
		Map<Id, User> users = getUser(eventList);

		for (Event_Request__c e : eventList) {
			User u = users.get(e.OwnerId);
			Datetime startDateTime = e.Start_Date__c;
			Datetime endDateTime = e.End_Date__c;
			String formattedStartDate = startDateTime.format('yyyy-MM-dd', 'UTC');
			String formattedEndDate = endDateTime.format('yyyy-MM-dd', 'UTC');

			String cutOffTime = e.Cutoff_Time__c != null
				? (e.Cutoff_Time__c.contains('a') ? e.Cutoff_Time__c.split('a')[0] : e.Cutoff_Time__c.split('p')[0])
				: '0';

			if (e.Cut_Off_Override_Type__c == 'Site') {
				wrapper.eventAttributes = new Map<String, String>{
					'cutoff' => cutOffTime,
					'endDate' => formattedEndDate,
					'siteId' => e.OpCo__r.OpCo_ID__c,
					'startDate' => formattedStartDate,
					'userId' => u.Sysco_User_ID__c
				};
			} else if (e.Cut_Off_Override_Type__c == 'Customer') {
				co.action = 'U';
				co.endDate = formattedEndDate;
				co.siteId = e.OpCo__r.OpCo_ID__c;
				co.userId = u.Sysco_User_ID__c;
				co.startDate = formattedStartDate;
				co.cutoffOverridesExternal = cutOffTime;
				co.cutoffOverridesInternal = '00:00';
				co.accountTypes = e.Account_Type__c.split(';');
			} else {
				wrapper.eventAttributes = new Map<String, String>{
					'siteId' => e.OpCo__r.OpCo_ID__c,
					'cutOff' => cutOffTime,
					'userId' => u.Sysco_User_ID__c
				};
			}
			safeRetryables.add(new EventRequest_SendToSUS_Retryable(wrapper, co, e));
		}

		if (!safeRetryables.isEmpty()) {
			Utils.safeRetry(safeRetryables);
		}
	}

	public override JobResult startJob() {
		Retryable.Status retryStatus = Retryable.Status.SUCCEEDED;
		HttpRequest req = new HttpRequest();
		String endpoint = baseURL;

		req.setHeader('Content-Type', 'application/json');
		req.setHeader('X-REQUEST-ID', new Sysco_UTIL.UUID().getValue());
		if (this.overrideType == 'Site') {
			endpoint += '/site-cutoff/save';
			req.setEndpoint(endpoint);
			req.setMethod('POST');
			req.setBody(JSON.serialize(this.wrapper.eventAttributes));
		} else if (this.overrideType == 'Customer') {
			endpoint += '/customer/update-cutoff-overrides';
			req.setEndpoint(endpoint);
			req.setMethod('PUT');
			req.setBody(JSON.serialize(this.cutoff_Overrides));
		} else {
			endpoint += '/routing-group/save';
			req.setEndpoint(endpoint);
			req.setMethod('POST');
			req.setBody(JSON.serialize(this.wrapper.eventAttributes));
		}

		Http http = new Http();
		HTTPResponse res = new HttpResponse();
		String message = '';

		try {
			res = http.send(req);
			log.withRequest(req).withResponse(res).debug('Send to SUS' + this.eve.Id);
			message = getResponseErrorMessage(res);
		} catch (Exception err) {
			retryStatus = Retryable.Status.FAILED_RETRY;
			message = err.getMessage();
			log
				.withException(err)
				.withRequest(req)
				.withResponse(res)
				.withFields(new Map<String, Object>{ 'Application' => 'CutOffTimeManagement', 'Source' => 'triggeredSend' })
				.error('Sending request to SUS for cutoff time management');
		}

		log.dispose();

		return new JobResult(retryStatus, message);
	}
	private String getResponseErrorMessage(HttpResponse res) {
		Retryable.Status retryStatus = Retryable.Status.SUCCEEDED;
		String message = 'Successful send to SUS';

		List<Id> idList = new List<Id>();
		idList.add(this.eve.Id);
		List<Event_Request__c> eventList = getEventRequest(idList);
		List<Event_Request__c> updateEventList = new List<Event_Request__c>();

		retryStatus = Utils.httpRetryScenario(res);

		if (retryStatus != Retryable.Status.SUCCEEDED) {
			message = res.getStatusCode() + ' Error Response ' + res.getBody();
			String statusbody = res.getStatusCode() == 401
				? 'Invalid access token'
				: res.getStatusCode() == 400
						? '400 BAD REQUEST'
						: res.getStatusCode() == 500 ? 'Internal Server Error' : 'Uhandled Error';
			for (Event_Request__c e : eventList) {
				e.Approval_Status__c = 'Failed To Transmit';
				e.SUS_Error_Message__c = statusbody;
				updateEventList.add(e);
			}
			update updateEventList;
		}

		return message;
	}

	public override String getTraceIds() {
		return this.eve.Id;
	}
}