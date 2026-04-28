sap.ui.define([
  "sap/fe/core/AppComponent"
], function (AppComponent) {
  "use strict";

  return AppComponent.extend("o2c.orders.Component", {
    metadata: {
      manifest: "json"
    },
    
    init: function () {
      AppComponent.prototype.init.apply(this, arguments);
      this.getRouter().initialize();
    }
  });
});