({
    doInit: function (component, event, helper) {
      switch (component.get("v.apiSource")) {
        case "Sysco Delivery":
          helper.getDataFromSD(component);
          break;
        case "MST":
          helper.getDataFromMST(component);
          break;
      }
    }
  });