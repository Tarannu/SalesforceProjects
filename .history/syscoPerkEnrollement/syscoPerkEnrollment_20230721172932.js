import { LightningElement, wire, api } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import SYSCO_PERKS_ENROLLMENT_ASSETS from "@salesforce/resourceUrl/SyscoPerksEnrollment";
import PERKS_ENROLLMENT_DATE_FIELD from "@salesforce/schema/Account.Perks_Enrollment_Date__c";

export default class SyscoPerksEnrollment extends LightningElement {
  @api
  recordId;

  syscoPerksLogo = SYSCO_PERKS_ENROLLMENT_ASSETS + "/images/syscoperkslogo.png";

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [PERKS_ENROLLMENT_DATE_FIELD]
  })
  account;


  get perksEnrollmentDate() {
    return getFieldValue(this.account.data, PERKS_ENROLLMENT_DATE_FIELD);
  }
}