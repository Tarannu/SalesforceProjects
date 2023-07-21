@isTest
public class SendEmailWithCCTest {
	@isTest
	static void testThatEmailWasSent() {
		String mainEmail = 'force.comteam@sysco.com';
		List<String> ccAddresses = new List<String>();
		ccAddresses.add('test@sysco.com');
		String subject = 'This is a test Subject';
		String htmlBody = '<h1>This is a test email</h1>';

		SendEmailWithCC.EmailDetails emailDetailsList = new SendEmailWithCC.EmailDetails();

		emailDetailsList.mainEmail = mainEmail;
		emailDetailsList.ccEmails = ccAddresses;
		emailDetailsList.subject = subject;
		emailDetailsList.body = htmlBody;

		Test.startTest();
		System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should be sent');

		SendEmailWithCC.sendEmail(new List<SendEmailWithCC.EmailDetails>{ emailDetailsList });

		System.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');
		Test.stopTest();
	}
}
