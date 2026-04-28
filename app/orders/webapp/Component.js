sap.ui.define([
  "sap/fe/core/AppComponent"
], function (AppComponent) {
  "use strict";

  return AppComponent.extend("o2c.orders.Component", {
    metadata: {
      manifest: "json"
    }
    // No init() override — sap.fe.core.AppComponent manages
    // its own router and lifecycle internally
  });
});