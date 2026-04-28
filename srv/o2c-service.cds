using { o2c as db } from '../db/schema';

@path: 'o2-c'
service O2CService {

  // =========================
  // Master Data
  // =========================
  @readonly @odata.publish.targets
  entity Customers  as projection on db.Customers;
  
  @readonly @odata.publish.targets
  entity Products   as projection on db.Products;

  // =========================
  // Orders (Main Entity)
  // =========================
  @odata.publish.targets
  @UI.FieldGroup#Facet : {
    Data: [
      { Value: OrderID },
      { Value: CustomerID },
      { Value: OrderDate },
      { Value: TotalAmount }
    ]
  }
  entity Orders as projection on db.Orders {
    *,
    Customer: redirected to Customers,
    Items: redirected to OrderItems,
    Approvals: redirected to Approvals,
    Invoices: redirected to Invoices
  };

  @odata.publish.targets
  entity OrderItems as projection on db.OrderItems {
    *,
    Order: redirected to Orders,
    Product: redirected to Products
  };

  // =========================
  // Approval
  // =========================
  @odata.publish.targets
  entity Approvals as projection on db.Approvals {
    *,
    Order: redirected to Orders
  };

  // =========================
  // Finance
  // =========================
  @odata.publish.targets
  entity Invoices as projection on db.Invoices {
    *,
    Order: redirected to Orders,
    Payments: redirected to Payments
  };

  @odata.publish.targets
  entity Payments as projection on db.Payments {
    *,
    Invoice: redirected to Invoices
  };

  // =========================
  // Actions & Functions
  // =========================

  action submitOrder(
    orderID : String(20)
  ) returns Orders;

  action approveOrder(
    orderID : String(20),
    decision : String(20),
    remarks  : String(200)
  ) returns Orders;

  action cancelOrder(
    orderID : String(20),
    remarks  : String(200)
  ) returns Orders;
}