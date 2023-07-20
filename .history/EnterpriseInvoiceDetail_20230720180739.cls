public with sharing class EnterpriseInvoiceDetail {
	// API fields
	@AuraEnabled
	@InvocableVariable
	public String acctTypeCode;

	@AuraEnabled
	@InvocableVariable
	public String billToCustomerNumber;

	@AuraEnabled
	@InvocableVariable
	public String brndNumber;

	@AuraEnabled
	@InvocableVariable
	public Integer caseAvlforCrdt;

	@AuraEnabled
	@InvocableVariable
	public String catchWeightIndicator;

	@AuraEnabled
	@InvocableVariable
	public String crdtDbtLineitemRsnCode;

	@AuraEnabled
	@InvocableVariable
	public String cuisineCode;

	@AuraEnabled
	@InvocableVariable
	public Decimal currentItemExtPrice;

	@AuraEnabled
	@InvocableVariable
	public Decimal currentItemMiscTaxAmt;

	@AuraEnabled
	@InvocableVariable
	public Decimal currentItemTaxAmt;

	@AuraEnabled
	@InvocableVariable
	public Decimal currentPrice;

	@AuraEnabled
	@InvocableVariable
	public Integer currentQty;

	@AuraEnabled
	@InvocableVariable
	public Integer currentSplitQty;

	@AuraEnabled
	@InvocableVariable
	public Integer currentSpltCnt;

	@AuraEnabled
	@InvocableVariable
	public Decimal currentTotalCatchWeight;

	@AuraEnabled
	@InvocableVariable
	public Long customerShipToNumber;

	@AuraEnabled
	@InvocableVariable
	public String dfltCalcOnFreqFlg;

	@AuraEnabled
	@InvocableVariable
	public String dlvrMethCode;

	@AuraEnabled
	@InvocableVariable
	public String entyId;

	@AuraEnabled
	@InvocableVariable
	public String freeGoodFlg;

	@AuraEnabled
	@InvocableVariable
	public Decimal grsPrice;

	@AuraEnabled
	@InvocableVariable
	public String invoiceNumber;

	@AuraEnabled
	@InvocableVariable
	public String invoiceRefNumber;

	@AuraEnabled
	@InvocableVariable
	public Decimal itemAmount;

	@AuraEnabled
	@InvocableVariable
	public String itemDescription;

	@AuraEnabled
	@InvocableVariable
	public String itemNumber;

	@AuraEnabled
	@InvocableVariable
	public String itemStringCode;

	@AuraEnabled
	@InvocableVariable
	public String itemTypeCode;

	@AuraEnabled
	@InvocableVariable
	public Integer lclCatgyCode;

	@AuraEnabled
	@InvocableVariable
	public Integer lclIntrmCode;

	@AuraEnabled
	@InvocableVariable
	public Integer lclMajCode;

	@AuraEnabled
	@InvocableVariable
	public Integer lclMnrCode;

	@AuraEnabled
	@InvocableVariable
	public String lineCode;

	@AuraEnabled
	@InvocableVariable
	public Integer lineNumber;

	@AuraEnabled
	@InvocableVariable
	public String miscChrgTypeCode;

	@AuraEnabled
	@InvocableVariable
	public Decimal netPrice;

	@AuraEnabled
	@InvocableVariable
	public Integer opcoNumber;

	@AuraEnabled
	@InvocableVariable
	public String orderGuidSeqNumber;

	@AuraEnabled
	@InvocableVariable
	public String orderReasonCode;

	@AuraEnabled
	@InvocableVariable
	public String orderSeqNumber;

	@AuraEnabled
	@InvocableVariable
	public String orderTypeCode;

	@AuraEnabled
	@InvocableVariable
	public Decimal originalMiscTaxAmt;

	@AuraEnabled
	@InvocableVariable
	public Integer originalOrderQty;

	@AuraEnabled
	@InvocableVariable
	public Decimal originalPrice;

	@AuraEnabled
	@InvocableVariable
	public Integer originalShipQty;

	@AuraEnabled
	@InvocableVariable
	public Decimal originalTaxAmt;

	@AuraEnabled
	@InvocableVariable
	public Decimal originalTotCatchWeight;

	@AuraEnabled
	@InvocableVariable
	public String proprItemFlg;

	@AuraEnabled
	@InvocableVariable
	public Integer qtyAvlforCrdt;

	@AuraEnabled
	@InvocableVariable
	public String rmotOrderEntMethCode;

	@AuraEnabled
	@InvocableVariable
	public String saleObligTransId;

	@AuraEnabled
	@InvocableVariable
	public String saleTaxIndCode;

	@AuraEnabled
	@InvocableVariable
	public String shipAddrId;

	@AuraEnabled
	@InvocableVariable
	public String splitCode;

	@AuraEnabled
	@InvocableVariable
	public Integer spltAvlForCrdt;

	@AuraEnabled
	@InvocableVariable
	public Integer supcIntrmCode;

	@AuraEnabled
	@InvocableVariable
	public Integer subItemNumber;

	@AuraEnabled
	@InvocableVariable
	public Integer supcCatgyCode;

	@AuraEnabled
	@InvocableVariable
	public Integer supcMajCode;

	@AuraEnabled
	@InvocableVariable
	public Integer supcMnrCode;

	@AuraEnabled
	@InvocableVariable
	public String transCode;

	@AuraEnabled
	@InvocableVariable
	public String transDate;

	@AuraEnabled
	@InvocableVariable
	public Integer transRefLineNumber;

	@AuraEnabled
	@InvocableVariable
	public String weightUOM;

	// custom fields
	@AuraEnabled
	@InvocableVariable
	public List<String> fieldsToEnable;

	@AuraEnabled
	@InvocableVariable
	public Boolean inActiveProduct;

	@AuraEnabled
	@InvocableVariable
	public String reasonCode;

	@AuraEnabled
	@InvocableVariable
	public String originalUOM;

	@AuraEnabled
	@InvocableVariable
	public String product2Id;

	@AuraEnabled
	@InvocableVariable
	public String productPack;

	@AuraEnabled
	@InvocableVariable
	public String productCategory;

	@AuraEnabled
	@InvocableVariable
	public Decimal wgtAvlForCrdt;

	@AuraEnabled
	@InvocableVariable
	public String returnUOM;

	@AuraEnabled
	@InvocableVariable
	public Decimal returnQty;

	@AuraEnabled
	@InvocableVariable
	public String mispickItem;

	@AuraEnabled
	@InvocableVariable
	public Decimal adjustedPrice;

	@AuraEnabled
	@InvocableVariable
	public Decimal adjustedNetWeight;

	//  do not remove
	// these fields are used by the lwc datatable
	@AuraEnabled
	@InvocableVariable
	public String adjustBtnLabel;

	@AuraEnabled
	@InvocableVariable
	public String adjustBtnVariant;

	@AuraEnabled
	@InvocableVariable
	public String selectBtnLabel;

	@AuraEnabled
	@InvocableVariable
	public String selectBtnVariant;


	@AuraEnabled
	@InvocableVariable
	public String itemComments;

	@AuraEnabled
	public String categoryId;
}