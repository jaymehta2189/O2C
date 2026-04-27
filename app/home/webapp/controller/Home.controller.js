sap.ui.define([
  "sap/ui/core/mvc/Controller"
], function (Controller) {
  "use strict";

  return Controller.extend("o2c.home.controller.Home", {

    async onOrders() {
      if (sap.ushell && sap.ushell.Container) {
        const nav = await sap.ushell.Container.getServiceAsync("CrossApplicationNavigation");
        nav.toExternal({
          target: {
            semanticObject: "Orders",
            action: "display"
          }
        });
      } else {
        window.location.href = "../orders/webapp/index.html";
      }
    }

  });
});