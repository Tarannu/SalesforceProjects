public with sharing class DeliveryDelayCSTDetails {
	@AuraEnabled(cacheable=true)
	public static List<Task> getDeliveryDelayCSTDetails() {
		List<Task> ddaTasks = new List<Task>();

		UserTerritory2Association uta = [
			SELECT Territory2.Name
			FROM UserTerritory2Association
			WHERE
				UserId = :UserInfo.getUserId()
				AND Territory2.Hierarchy_Type__c = 'Customer Success Team'
				AND Territory2.Territory2Type.DeveloperName = 'Customer_Success_Manager'
			LIMIT 1
		];

		Id groupId = [
			SELECT Id, Name, DeveloperName
			FROM Group
			WHERE DeveloperName = 'USBL_Customer_Success_Team_Queue' AND Type = 'Queue'
			LIMIT 1
		]
		.Id;
		Id taskRTId = RecordTypeUtility.getId('Task', 'Log_a_Call_Record_Type');

		if (uta != null) {
			ddaTasks = [
				SELECT Id, ActivityDate, Sales_Team__c, Subject, WhatID, What.Name, Plan__c, Task_Notes__c, Description
				FROM Task
				WHERE
					CreatedDate = TODAY
					AND Sales_Team__c = :uta.Territory2.Name
					AND RecordTypeId = :taskRTId
					AND Subject LIKE 'Delivery Delay Alert%'
					AND OwnerId = :groupId
				ORDER BY CreatedDate DESC
			];
		}
		return ddaTasks;
	}
}