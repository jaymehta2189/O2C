sap.ui.define([
  "sap/ui/core/UIComponent",
  "sap/ui/model/json/JSONModel"
], function (UIComponent, JSONModel) {
  "use strict";

  return UIComponent.extend("o2c.home.Component", {
    metadata: {
      manifest: "json"
    },

    init: function () {
      UIComponent.prototype.init.apply(this, arguments);
      
      // Initialize view model
      var oViewModel = new JSONModel({
        isLoading: false,
        items: []
      });
      this.setModel(oViewModel, "view");
      
      // Initialize router
      var oRouter = this.getRouter();
      if (oRouter) {
        oRouter.initialize();
      }
    }
  });
});