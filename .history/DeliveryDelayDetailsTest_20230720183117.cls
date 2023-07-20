@isTest
public class DeliveryDelayCSTDetailsTest {
	@testSetup
	static void setup() {
		User u = [SELECT Id, UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];

		System.runAs(u) {
			Id groupId = [
				SELECT Id, Name, DeveloperName
				FROM Group
				WHERE DeveloperName = 'USBL_Customer_Success_Team_Queue' AND Type = 'Queue'
				LIMIT 1
			]
			.Id;

			Id TaskRecordTypeId = RecordTypeUtility.getId('Task', 'Log_a_Call_Record_Type');

			Territory2Model terrMod = new Territory2Model(Name = 'TestModel', DeveloperName = 'TestModel');
			insert terrMod;

			Territory2Type terrType = [
				SELECT Id, DeveloperName
				FROM Territory2Type
				WHERE DeveloperName = 'Customer_Success_Manager'
				LIMIT 1
			];

			Territory2 terr = new Territory2(
				Name = 'CSM HTL',
				DeveloperName = 'CSMHTL',
				Hierarchy_Type__c = 'Customer Success Team',
				Territory2TypeId = terrType.Id,
				Territory2ModelId = terrMod.Id,
				External_Id__c = 'CSMHTL'
			);
			insert terr;

			UserTerritory2Association association = new UserTerritory2Association(
				Territory2Id = terr.Id,
				UserId = u.Id,
				RoleInTerritory2 = 'Customer Success Coordinator'
			);

			insert association;

			Account acc = (Account) TestFactory.createSObject(
				new Account(
					Name = 'Test Account',
					RecordTypeId = RecordTypeUtility.getId('Account', 'Account'),
					Account_ID__c = '056-123456',
					Account_Type__C = 'TRS',
					Status__c = 'AC'
				),
				true
			);

			Task t = new Task(
				ActivityDate = System.Today(),
				Sales_Team__c = 'CSM HTL',
				Subject = 'Delivery Delay Alert - Test',
				Subject__c = 'Test Route',
				Plan__c = 'Test Plan',
				OwnerId = groupId,
				RecordTypeId = TaskRecordTypeId,
				Task_Notes__c = 'Test Notes'
			);
			insert t;
		}
	}

	@isTest
	static void shouldReturnTask() {
		User u = [SELECT Id, UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(u) {
			Test.startTest();
			Territory2 terr = [SELECT Id, Name FROM Territory2 WHERE Name = 'CSM HTL'];

			Task t = [
				SELECT
					Id,
					Subject,
					RecordType.DeveloperName,
					Owner.Name,
					OwnerId,
					ActivityDate,
					Sales_Team__c,
					Subject__c,
					Plan__c,
					Task_Notes__c
				FROM Task
				WHERE Sales_Team__c = 'CSM HTL'
				LIMIT 1
			];

			List<Task> ddaTasks = DeliveryDelayCSTDetails.getDeliveryDelayCSTDetails();

			System.assertEquals(1, ddaTasks.size());

			Test.stopTest();
		}
	}
}