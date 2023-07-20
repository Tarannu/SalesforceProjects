import { LightningElement, track, wire } from "lwc";
import getDeliveryDelayCSTDetails from "@salesforce/apex/DeliveryDelayCSTDetails.getDeliveryDelayCSTDetails";
import { NavigationMixin } from "lightning/navigation";

export default class DeliveryDelayDetails extends NavigationMixin(LightningElement) {
	@track columns = [
		{
			label: "Date/Time",
			fieldName: "ActivityDate",
			type: "date-local",
			sortable: true
		},
		{
			label: "Related To",
			fieldName: "WhatName",
			type: "text",
			sortable: true
		},
		{
			label: "Subject",
			fieldName: "taskUrl",
			type: "url",
			typeAttributes: {
				label: { fieldName: "Subject", type: "text" },
				target: "_blank"
			},
			sortable: true
		},
		{
			label: "Plan",
			fieldName: "Plan__c",
			type: "text",
			sortable: true
		},
		{
			label: "Task Notes",
			fieldName: "Task_Notes__c",
			type: "text",
			sortable: true
		},
		{
			label: "Results",
			fieldName: "Description",
			type: "text",
			sortable: true
		}
	];
	@track error;
	@track dataRow;
	@track data;
	@wire(getDeliveryDelayCSTDetails)
	wiredTask({ error, data }) {
		if (data) {
			let baseUrl = "https://" + location.host + "/";
			const result = data.map((d) => {
				const WhatName = d.What.Name;
				const taskUrl = baseUrl + d.Id;
				return { ...d, WhatName, taskUrl };
			});
			this.dataRow = result;
		} else if (error) {
			this.error = error;
		}
	}
	handleNavigation() {
		this[NavigationMixin.Navigate]({
			type: "standard__objectPage",
			attributes: {
				actionName: "list",
				objectApiName: "Task"
			},
			state: {
				filterName: "Delivery_Delay_Alerts"
			}
		});
	}
}