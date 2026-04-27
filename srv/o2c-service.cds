using { o2c as db } from '../db/schema';

service O2CService {

  // =========================
  // Master Data
  // =========================
  @readonly entity Customers  as projection on db.Customers;
  @readonly entity Products   as projection on db.Products;

  // =========================
  // Orders
  // =========================
  entity Orders     as projection on db.Orders;
  entity OrderItems as projection on db.OrderItems;

  // =========================
  // Approval
  // =========================
  entity Approvals  as projection on db.Approvals;

  // =========================
  // Finance
  // =========================
  entity Invoices   as projection on db.Invoices;
  entity Payments   as projection on db.Payments;

  // =========================
  // Actions
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