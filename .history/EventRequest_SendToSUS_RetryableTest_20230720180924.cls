@isTest
public with sharing class EventRequest_SendToSUS_RetryableTest {
	@TestSetup
	static void setup() {
		User forceTeam = [SELECT Id FROM User WHERE Name = 'Force.com Team' LIMIT 1];
		Id eventRecordTypeId = RecordTypeUtility.getId('Event_Request__c', 'New_Event_Request');

		System.runAs(forceTeam) {
			OpCo__c opco = (OpCo__c) TestDataFactory.createSObject(
				'Opco__c',
				new Map<String, Object>{
					'OpCo_ID__c' => '056',
					'Name ' => 'Boston',
					'Address_1__c' => TestDataFactory.DEFAULT_VALUE,
					'City__c' => TestDataFactory.DEFAULT_VALUE,
					'State_Province__c' => 'MA',
					'Zip__c' => '02367',
					'Director_of_Sales_Strategy_Operations__c' => UserInfo.getUserId(),
					'VP_of_Sales__c' => UserInfo.getUserId()
				}
			);

			Event_Request__c siteOverride = (Event_Request__c) TestDataFactory.createSObject(
				'Event_Request__c',
				new Map<String, Object>{
					'OpCo__c' => opco.Id,
					'Cut_Off_Override_Type__c' => 'Site',
					'Cutoff_Time__c' => '11:00am',
					'Start_Date__c' => Date.newinstance(2022, 3, 8),
					'End_Date__c' => Date.newinstance(2022, 3, 15),
					'SUS_Error_Message__c' => '',
					'Type__c' => 'Cut Off Times',
					'Status__c' => 'New',
					'Approval_Status__c' => 'Needs Approval',
					'RecordTypeId' => RecordTypeUtility.getId('Event_Request__c', 'New_Event_Request'),
					'Approver1__c' => opco.VP_of_Sales__c
				}
			);
			Event_Request__c customerOverride = (Event_Request__c) TestDataFactory.createSObject(
				'Event_Request__c',
				new Map<String, Object>{
					'OpCo__c' => opco.Id,
					'Cut_Off_Override_Type__c' => 'Customer',
					'Cutoff_Time__c' => '11:00am',
					'Start_Date__c' => Date.newinstance(2022, 3, 8),
					'End_Date__c' => Date.newinstance(2022, 3, 18),
					'SUS_Error_Message__c' => '',
					'Type__c' => 'Cut Off Times',
					'Status__c' => 'New',
					'Account_Type__c' => 'CMU;LCC;OTH',
					'Approval_Status__c' => 'Needs Approval',
					'RecordTypeId' => RecordTypeUtility.getId('Event_Request__c', 'New_Event_Request'),
					'Approver1__c' => opco.VP_of_Sales__c
				}
			);
			Event_Request__c cutOffMaintenance = (Event_Request__c) TestDataFactory.createSObject(
				'Event_Request__c',
				new Map<String, Object>{
					'OpCo__c' => opco.Id,
					'Cutoff_Time__c' => '11:00am',
					'Start_Date__c' => Date.newinstance(2022, 3, 8),
					'End_Date__c' => Date.newinstance(2022, 3, 18),
					'SUS_Error_Message__c' => '',
					'Type__c' => 'Cut Off Times',
					'Status__c' => 'New',
					'Cut_Off_Override_Type__c' => '',
					'Approval_Status__c' => 'Needs Approval',
					'RecordTypeId' => RecordTypeUtility.getId('Event_Request__c', 'New_Event_Request'),
					'Approver1__c' => opco.VP_of_Sales__c
				}
			);
		}

	}

	@isTest
	public static void sendTositeCutoffOverrides() {
		List<Id> eventId = new List<Id>();

		Event_Request__c e = [
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
			WHERE Cut_Off_Override_Type__c = 'Site'
			LIMIT 1
		];

		eventId.add(e.Id);

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, getSuccessMultiCalloutMock());
		EventRequest_SendToSUS_Retryable.execute(eventId);

		Test.stopTest();
	}
	@isTest
	static void sendTocustomerCutoffOverrides() {
		EventRequest_SendToSUS_Retryable.Customer_Overrides co = new EventRequest_SendToSUS_Retryable.Customer_Overrides();
		List<Id> eventId = new List<Id>();
		Event_Request__c e = [
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
			WHERE Cut_Off_Override_Type__c = 'Customer'
			LIMIT 1
		];

		eventId.add(e.Id);

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, getSuccessMultiCalloutMock());
		co.action = 'U';
		co.siteId = e.OpCo__r.OpCo_ID__c;
		co.accountTypes = e.Account_Type__c.split(';');
		co.endDate = '2022/03/18';
		co.startDate = '2022/03/08';
		co.userId = 'force';
		co.cutoffOverridesExternal = '11:00';
		co.cutoffOverridesInternal = '00:00';
		JobResult result = new EventRequest_SendToSUS_Retryable(null, co, e).startJob();
		Test.stopTest();
		System.assertEquals('Successful send to SUS', result.message);
	}
	@isTest
	static void sendTocutOffMaintenance() {
		List<Id> eventId = new List<Id>();
		Event_Request__c e = [
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
			WHERE Cut_Off_Override_Type__c = ''
			LIMIT 1
		];

		eventId.add(e.Id);

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, getSuccessMultiCalloutMock());
		EventRequest_SendToSUS_Retryable.execute(eventId);
		Test.stopTest();
	}

	private static final String SUS_SUCCESS = '{"id": 12,"siteId": "056","cutoff": "11:00","startDate": "2022-03-08","endDate": "2022-03-15","createTimestamp": "2022-03-03T22:12:00.955","modifiedTimestamp": "2022-03-03T22:12:00.955","modifiedBy": "test123"}';
	private static final String CUSTOMER_SUS_SUCCESS = '{"0"}';
	private static final String CUTOFF_MAINTENANCE_SUCCESS = '{"id": 12,"siteId": "056","routingGroupCode": "11","cutOff": "11:00","createTimestamp": "2021-12-01T14:36:12.738","modifiedTimestamp": "2021-12-01T14:36:12.738","modifiedBy": "chua5512","siteIdAndCutoff": "056-11:00"}';
	private static MultiRequestMock getSuccessMultiCalloutMock() {
		Map<String, HttpCalloutMock> callouts = new Map<String, HttpCalloutMock>();

		HttpCalloutMock susResponse = new SingleRequestMock(200, 'Complete', SUS_SUCCESS, null);
		HttpCalloutMock customerResponse = new SingleRequestMock(200, 'Complete', CUSTOMER_SUS_SUCCESS, null);
		HttpCalloutMock cutoffMaintenanceResponse = new SingleRequestMock(
			200,
			'Complete',
			CUTOFF_MAINTENANCE_SUCCESS,
			null
		);

		callouts.put(ApigeeUtility.getEndpoint() + '/holiday-calendar/holiday-calendar' + '/site-cutoff/save', susResponse);
		callouts.put(
			ApigeeUtility.getEndpoint() +
			'/holiday-calendar/holiday-calendar' +
			'/customer/update-cutoff-overrides',
			customerResponse
		);
		callouts.put(
			ApigeeUtility.getEndpoint() +
			'/holiday-calendar/holiday-calendar' +
			'/routing-group/save',
			cutoffMaintenanceResponse
		);

		return new MultiRequestMock(callouts);
	}
}