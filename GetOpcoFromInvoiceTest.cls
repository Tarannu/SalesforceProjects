public with sharing class GetOpcoFromInvoiceTest {
	@testSetup
	static void setup() {
		OpCo__c opco1 = (OpCo__c) TestFactory.createSObject(new OpCo__c(OpCo_ID__c = '056', Name = 'Test USBL'), true);

		Product2 prod1 = (Product2) TestFactory.createSObject(
			new Product2(Name = 'BUTTER SOLID UNSLT USDA AA', SUPC__c = '2208064', Pack__c = '1', OpCo_ID__c = opco1.Id),
			true
		);

		Product2 prod2 = (Product2) TestFactory.createSObject(
			new Product2(Name = 'BUTTER SOLID UNSLTD 83% EUROPN', SUPC__c = '3030117', Pack__c = '1', OpCo__c = opco1.Id),
			true
		);
	}
}
