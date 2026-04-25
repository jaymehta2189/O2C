namespace o2c;

using { cuid, managed } from '@sap/cds/common';

entity Customers : cuid, managed {
  key CustomerID   : String(10);
      CustomerName : String(100);
      Email        : String(100);
      Phone        : String(15);
      Address      : String(200);
      CreditLimit  : Decimal(15,2);
      UsedCredit   : Decimal(15,2);
      Status       : String(10);   // Active / Inactive
}

entity Products : cuid, managed {
  key ProductID   : String(10);
      ProductName : String(100);
      Category    : String(50);
      Price       : Decimal(15,2);
      Stock       : Integer;
      Status      : String(10);    // Active / Inactive
}

entity Orders : cuid, managed {
  key OrderID        : String(10);
      Customer       : Association to one Customers;
      CustomerID     : String(10);
      OrderDate      : Date;
      TotalAmount    : Decimal(15,2);
      CreditStatus   : String(20);   // Draft / Pending / Approved / Rejected / Blocked
      OrderStatus    : String(20);   // Draft / Submitted / Confirmed / Delivered / Cancelled
      DeliveryStatus : String(20);   // Pending / Shipped / Delivered
      Notes          : String(255);

      Items          : Composition of many OrderItems
                         on Items.Order = $self;

      Approvals      : Composition of many Approvals
                         on Approvals.Order = $self;

      Invoices       : Composition of many Invoices
                         on Invoices.Order = $self;
}

entity OrderItems : cuid, managed {
  key ItemID      : String(10);
      Order       : Association to one Orders;
      OrderID     : String(10);

      Product     : Association to one Products;
      ProductID   : String(10);

      Quantity    : Integer;
      UnitPrice   : Decimal(15,2);
      ItemTotal   : Decimal(15,2);
}

entity Approvals : cuid, managed {
  key ApprovalID  : String(10);
      Order       : Association to one Orders;
      OrderID     : String(10);

      Decision    : String(10);     // Approved / Rejected / Hold
      Remarks     : String(200);
      ApprovedBy  : String(100);
      ApprovedOn  : DateTime;
}

entity Invoices : cuid, managed {
  key InvoiceID     : String(10);
      Order         : Association to one Orders;
      OrderID       : String(10);

      InvoiceDate   : Date;
      Amount        : Decimal(15,2);
      TaxAmount     : Decimal(15,2);
      DueDate       : Date;
      InvoiceStatus : String(20);   // Open / Partially Paid / Paid / Cancelled

      Payments      : Composition of many Payments
                        on Payments.Invoice = $self;
}

entity Payments : cuid, managed {
  key PaymentID     : String(10);
      Invoice       : Association to one Invoices;
      InvoiceID     : String(10);

      AmountPaid    : Decimal(15,2);
      PaymentDate   : Date;
      PaymentMode   : String(20);   // UPI / NEFT / Card / Cash / Cheque
      PaymentStatus : String(20);   // Pending / Completed / Failed / Reversed
      ReferenceNo   : String(100);
}