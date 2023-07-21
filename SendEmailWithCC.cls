public without sharing class SendEmailWithCC {
	private static Sysco_LOG.PlatformBulkLogger log = new Sysco_LOG.PlatformBulkLogger('SendEmailWithCC');
	public class EmailDetails {
		@InvocableVariable(label='Main Email' required=true)
		public String mainEmail;

		@InvocableVariable(label='Body (This includes HTML format)' required=true)
		public String body;

		@InvocableVariable
		public String subject;

		@InvocableVariable
		public List<String> ccEmails;
	}

	@InvocableMethod(Label='Send HTML Email with cc')
	public static void sendEmail(List<EmailDetails> emailDetailList) {
		List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

		for (EmailDetails e : emailDetailList) {
			List<String> mainEmail = new List<String>();
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setHtmlBody(e.body);
			mainEmail.add(e.mainEmail);
			mail.setToAddresses(mainEmail);
			mail.setCcAddresses(e.ccEmails);
			mail.setSubject(e.subject);

			mails.add(mail);
		}

		List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(mails);
	}
}
