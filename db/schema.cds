namespace o2c;

using { managed } from '@sap/cds/common';

type CustomerStatus   : String enum { Active; Inactive; }
type ProductStatus    : String enum { Active; Inactive; }
type OrderStatus      : String enum { Draft; Saved; Submitted; Confirmed; Blocked; Rejected; Cancelled; }
type CreditStatus     : String enum { Draft; Pending; Approved; Blocked; Rejected; Hold; }
type ApprovalDecision : String enum { Approved; Rejected; Hold; }
type InvoiceStatus    : String enum { Open; PartiallyPaid; Paid; Cancelled; }
type PaymentStatus    : String enum { Pending; Completed; Failed; Reversed; }
type PaymentMode      : String enum { UPI; NEFT; IMPS; Card; Cash; Cheque; BankTransfer; }

entity Customers : managed {
  key CustomerID  : String(10);
      CustomerName: String(100);
      Email       : String(100);
      Phone       : String(15);
      Address     : String(200);
      CreditLimit : Decimal(15,2);
      UsedCredit  : Decimal(15,2);
      Status      : CustomerStatus;
}

entity Products : managed {
  key ProductID   : String(10);
      ProductName : String(100);
      Category    : String(50);
      Price       : Decimal(15,2);
      Stock       : Integer;
      Status      : ProductStatus;
}

entity Orders : managed {
  key OrderID       : String(20);
      Customer      : Association to one Customers;
      CustomerID    : String(10);
      OrderDate     : Date;
      TotalAmount   : Decimal(15,2);
      CreditStatus  : CreditStatus;
      OrderStatus   : OrderStatus;
      BlockedReason : String(200);
      Notes         : String(500);
      SubmittedOn   : DateTime;
      ApprovedOn    : DateTime;
      ApprovedBy    : String(100);

      Items         : Composition of many OrderItems
                        on Items.Order = $self;

      Approvals     : Composition of many Approvals
                        on Approvals.Order = $self;

      Invoices      : Composition of many Invoices
                        on Invoices.Order = $self;
}

entity OrderItems : managed {
  key ItemID    : String(20);
      Order     : Association to one Orders;
      OrderID   : String(20);
      Product   : Association to one Products;
      ProductID : String(10);
      Quantity  : Integer;
      UnitPrice : Decimal(15,2);
      ItemTotal : Decimal(15,2);
}

entity Approvals : managed {
  key ApprovalID  : String(20);
      Order       : Association to one Orders;
      OrderID     : String(20);
      Decision    : ApprovalDecision;
      Remarks     : String(200);
      ApprovedBy  : String(100);
      ApprovedOn  : DateTime;
}

entity Invoices : managed {
  key InvoiceID    : String(20);
      Order        : Association to one Orders;
      OrderID      : String(20);
      InvoiceDate  : Date;
      Amount       : Decimal(15,2);
      TaxAmount    : Decimal(15,2);
      DueDate      : Date;
      InvoiceStatus: InvoiceStatus;
      Payments     : Composition of many Payments
                       on Payments.Invoice = $self;
}

entity Payments : managed {
  key PaymentID    : String(20);
      Invoice      : Association to one Invoices;
      InvoiceID    : String(20);
      AmountPaid   : Decimal(15,2);
      PaymentDate  : Date;
      PaymentMode  : PaymentMode;
      PaymentStatus: PaymentStatus;
      ReferenceNo  : String(100);
}