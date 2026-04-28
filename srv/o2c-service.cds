using { o2c as db } from '../db/schema';

@path: 'o2-c'
service O2CService {

  // =========================
  // Master Data (read-only)
  // =========================

  @readonly
  entity Customers as projection on db.Customers;

  @readonly
  entity Products as projection on db.Products;

  // =========================
  // Orders (Main Transactional Entity)
  // =========================

  entity Orders as projection on db.Orders {
    *,
    Customer  : redirected to Customers,
    Items     : redirected to OrderItems,
    Approvals : redirected to Approvals,
    Invoices  : redirected to Invoices
  };

  entity OrderItems as projection on db.OrderItems {
    *,
    Order   : redirected to Orders,
    Product : redirected to Products
  };

  // =========================
  // Approvals
  // =========================

  entity Approvals as projection on db.Approvals {
    *,
    Order : redirected to Orders
  };

  // =========================
  // Finance
  // =========================

  entity Invoices as projection on db.Invoices {
    *,
    Order    : redirected to Orders,
    Payments : redirected to Payments
  };

  entity Payments as projection on db.Payments {
    *,
    Invoice : redirected to Invoices
  };

  // =========================
  // Actions
  // =========================

  action submitOrder(
    orderID : String(20)
  ) returns Orders;

  action approveOrder(
    orderID  : String(20),
    decision : String(20),
    remarks  : String(200)
  ) returns Orders;

  action cancelOrder(
    orderID : String(20),
    remarks : String(200)
  ) returns Orders;
}