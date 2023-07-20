public with sharing class GetOpcoFromInvoice {
	public static String endpoint = ApigeeUtility.getEndpoint();
	public static String apiPath = '/services/enterprise-invoice-service-v2';

	private static Sysco_LOG.PlatformBulkLogger log = new Sysco_LOG.PlatformBulkLogger('GetOpcoFromInvoice');

	public class InvoiceDetailClass {
		@InvocableVariable
		public List<EnterpriseInvoiceDetail> items;
	}

	@InvocableMethod(label='Get Valid Opco')
	public static List<List<String>> returnOpco(List<InvoiceInput> inputs) {
		List<List<String>> results = new List<List<String>>();

		for (InvoiceInput input : inputs) {
			String invoiceNumber = input.invoiceNumber;
			List<String> opcoIds = new List<String>();

			List<OpCo__c> opcoList = [
				SELECT OpCo_ID__c
				FROM OpCo__c
				WHERE EntityName__c = 'US Broadline' AND Name != 'Test Broadline' AND Name != 'TEST -US Broadline'
			];

			for (OpCo__c o : opcoList) {
				String oId = o.OpCo_ID__c;

				Boolean isValid = isValidOpco(invoiceNumber, oId);
				if (isValid) {
					opcoIds.add(oId);
					break;
				}
			}

			results.add(opcoIds);
		}

		if (results.size() > 0) {
			return results;
		} else {
			return null;
		}
	}

	private static Boolean isValidOpco(String invoiceNumber, String opcoId) {
		String route = '/invoice/extended/details/opcos/';
		HttpRequest req = new HttpRequest();
		req.setEndPoint(endpoint + apiPath + route + opcoId + '/invoices/' + invoiceNumber + '?page_size=1000');

		req.setHeader('X-REQUEST-ID', new Sysco_UTIL.UUID().getValue());
		req.setMethod('GET');

		Http http = new Http();
		HTTPResponse res = http.send(req);
		Boolean retValue;
		InvoiceDetailClass results = new InvoiceDetailClass();

		log.withRequest(req, new Set<String>{ 'X-REQUEST-ID' }).withResponse(res).debug('GetOpcoFromInvoice');

		if (res.getStatusCode() == 200) {
			InvoiceDetailClass detail = (InvoiceDetailClass) JSON.deserialize(res.getBody(), InvoiceDetailClass.class);
			for (EnterpriseInvoiceDetail item : detail.items) {
				if (opcoId.contains(String.valueOf(item.opcoNumber)) && invoiceNumber == String.valueOf(item.invoiceNumber))
					retValue = true;
				else
					retValue = false;
			}
		} else {
			retValue = false;
		}
		log.dispose();
		return retValue;
	}

	public class InvoiceInput {
		@InvocableVariable(label='Invoice Number' required=true)
		public String invoiceNumber;
	}
}