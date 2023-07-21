({
	getDataFromSD: function (component) {
		function formatDateTime(value, timeZone) {
			if (!value) return;
			let dt = new Date(value * 1000);
			return dt.toLocaleTimeString("en-US", {
				timeZone: timeZone
			});
		}
		function formatDelayTime(actualTime, expectedTime) {
			const delayObj = {};
			delayObj.delayStatus = "Not Done";
			if (!actualTime) return delayObj;
			let at = new Date(actualTime * 1000);
			let et = new Date(expectedTime * 1000);

			let del = at - et;
			let statusString = "On Time";

			if (at.getTime() !== et.getTime()) {
				if (at.getTime() < et.getTime()) {
					statusString = "Early";
					del = et - at;
				} else {
					statusString = "Delayed";
				}
			}

			delayObj.delayStatus = statusString;
			let dFormatted = new Date(del);
			let timeStr = dFormatted.toISOString().substr(11, 8);
			delayObj.time = timeStr.substr(0, 2) + " h " + timeStr.substr(3, 2) + " m " + timeStr.substr(6, 2) + " s";

			return delayObj;
		}
		let action = component.get("c.getDataFromSD");
		const greenStatuses = ["EN_ROUTE_EARLY", "EN_ROUTE_ON_TIME", "SCHEDULED", "SCHEDULED", "EN_ROUTE_UPDATED_WINDOW"];
		const blueStatuses = ["ONSITE", "COMPLETE"];
		const redStatuses = ["EN_ROUTE_DELAYED"];
		const statuses = new Map([
			["SCHEDULED", "Scheduled"],
			["EN_ROUTE_ON_TIME", "En Route"],
			["EN_ROUTE_DELAYED", "Delayed"],
			["EN_ROUTE_EARLY", "Early"],
			["EN_ROUTE_UPDATED_WINDOW", "En Route"],
			["ONSITE", "Arrived"],
			["COMPLETE", "Completed"]
		]);
		action.setParams({
			acctId: component.get("v.recordId")
		});
		action.setCallback(this, function (res) {
			if (res.getState() === "SUCCESS") {
				let results = res.getReturnValue();
				let tempData = [];
				if (results && results.length > 0) {
					for (let r of results) {
						let obj = {};
						obj.routeNumber = r.routeNumber;
						obj.stopNumber = r.stopNumber;
						obj.quantity = r.deliveryCaseCount;
						obj.estimatedArrivalTimeFrom = formatDateTime(
							r.timeWindow && r.timeWindow.fromTime ? r.timeWindow.fromTime : r.initialWindow.fromTime,
							r.timeZone
						);
						obj.estimatedArrivalTimeTo = formatDateTime(
							r.timeWindow && r.timeWindow.toTime ? r.timeWindow.toTime : r.initialWindow.toTime,
							r.timeZone
						);
						obj.actualArrivalTime = formatDateTime(r.actualArrivalTime, r.timeZone);
						obj.delay = formatDelayTime(r.actualArrivalTime, r.expectedArrivalTime).time;
						obj.delayStatus = formatDelayTime(r.actualArrivalTime, r.expectedArrivalTime).delayStatus;
						let status = r.deliveryStatus.toUpperCase();
						obj.status = statuses.get(status);
						if (greenStatuses.includes(status)) {
							component.set("v.truckStatusCode", "green");
						} else if (blueStatuses.includes(status)) {
							component.set("v.truckStatusCode", "blue");
						} else if (redStatuses.includes(status)) {
							component.set("v.truckStatusCode", "red");
						}
						tempData.push(obj);
					}
					this.getInvoices(component, tempData);
				}
			}
			component.set("v.isLoading", false);
		});
		$A.enqueueAction(action);
	},
	getInvoices: function (component, tempData) {
		let action = component.get("c.getInvoices");
		action.setParams({
			acctId: component.get("v.recordId")
		});
		action.setCallback(this, function (res) {
			if (res.getState() === "SUCCESS") {
				let results = res.getReturnValue();
				for (let d of tempData) {
					let invoices = results.filter((r) => r.rteNbr.toString() === d.routeNumber.toString());
					if (invoices && invoices.length > 0) {
						d.invoices = invoices.reduce(
							(arr, curr) => [
								...arr,
								{
									invoiceNumber: curr.invoiceNumber,
									quantity: curr.currentCaseCount
								}
							],
							[]
						);
						d.quantity = invoices.reduce((arr, curr) => {
							return arr + curr.currentCaseCount;
						}, 0);
						d.stopNumber = invoices[0].stopNbr;
					}
				}
			}
			component.set("v.data", tempData);
			component.set("v.isLoading", false);
		});
		$A.enqueueAction(action);
	},
	getDataFromMST: function (component) {
		function getTime(value, timeZone) {
			if (!value) return;
			let time = new Date(value + "Z").toLocaleTimeString("en-US", {
				timeZone: timeZone
			});
			let minutes = time.substring(time.indexOf(":") + 1, time.lastIndexOf(":"));
			let hours = parseInt(time.substring(0, value.indexOf(":")));
			let ampm = time.substring(time.indexOf(" ") + 1);
			return (rtnVal = hours + ":" + minutes + " " + ampm);
		}
		let action = component.get("c.getDataFromMST");
		action.setParams({
			acctId: component.get("v.recordId")
		});
		action.setCallback(this, function (res) {
			if (res.getState() === "SUCCESS") {
				let results;
				let tempData = [];
				let organization;
				try {
					results =
						res.getReturnValue().CustomerOrders.organization.territoryList.territories[0].customerList.customers[0]
							.orderList.orders;
					organization = res.getReturnValue().CustomerOrders.organization;
				} catch (e) {
					console.log(e);
				}
				if (results && results.length > 0) {
					for (let o of results) {
						let obj = {};
						obj.routeNumber = o.routeNumber;
						obj.stopNumber = o.stopNumber;
						obj.orderNumber = o.orderNumber;
						obj.quantity = o.itemQty;
						if (o.delivery.projectedArrivalFrom) {
							obj.estimatedArrivalTimeFrom = getTime(o.delivery.projectedArrivalFrom, organization.timezone);
							obj.estimatedArrivalTimeTo = getTime(o.delivery.projectedArrivalTo, organization.timezone);
						} else {
							obj.estimatedArrivalTimeFrom = getTime(o.delivery.plannedArrvTime, organization.timezone);
							obj.estimatedArrivalTimeTo = getTime(o.delivery.plannedDeptTime, organization.timezone);
						}
						obj.actualArrivalTime = getTime(o.delivery.actualArrvTime, organization.timezone);
						if (o.orderStatus === "D") {
							component.set("v.truckStatusCode", "blue");
							obj.status = "COMPLETED";
						} else {
							component.set("v.truckStatusCode", "green");
							obj.status = "IN TRANSIT";
						}
						if (o.invoiceItemList) {
							let invoices = [];
							let invoice = {};
							for (let i of order.invoiceItemList) {
								invoice.invoiceNumber = i.invoiceNumber;
								invoice.quantity = i.caseCount;
								invoices.push(invoice);
							}
							tempData.invoices = invoices;
						}
						tempData.push(obj);
					}
					component.set("v.data", tempData);
				}
			}
			component.set("v.isLoading", false);
		});
		$A.enqueueAction(action);
	}
});