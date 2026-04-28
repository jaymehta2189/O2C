sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/UIComponent"
], function (Controller, UIComponent) {
  "use strict";

  return Controller.extend("o2c.home.controller.Home", {

    onOrders: function() {
      // Navigate to Orders app
      if (sap.ushell && sap.ushell.Container) {
        sap.ushell.Container.getServiceAsync("CrossApplicationNavigation").then(function(nav) {
          nav.toExternal({
            target: {
              semanticObject: "Orders",
              action: "display"
            }
          });
        }).catch(function() {
          // Fallback to direct navigation
          window.location.href = "../orders/webapp/index.html";
        });
      } else {
        // Direct navigation for standalone mode
        window.location.href = "../orders/webapp/index.html";
      }
    }

  });
});