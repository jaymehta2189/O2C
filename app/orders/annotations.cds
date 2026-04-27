using O2CService as service from '../../srv/o2c-service.cds';

annotate service.Orders with @(
  UI.HeaderInfo : {
    TypeName       : 'Sales Order',
    TypeNamePlural : 'Sales Orders',
    Title          : { Value: OrderID },
    Description    : { Value: Customer.CustomerName }
  },

  UI.SelectionFields : [
    OrderID,
    CustomerID,
    OrderDate,
    CreditStatus,
    OrderStatus
  ],

  UI.LineItem : [
    {
      $Type : 'UI.DataField',
      Label : 'Order ID',
      Value : OrderID
    },
    {
      $Type : 'UI.DataField',
      Label : 'Customer',
      Value : Customer.CustomerName
    },
    {
      $Type : 'UI.DataField',
      Label : 'Order Date',
      Value : OrderDate
    },
    {
      $Type : 'UI.DataField',
      Label : 'Total Amount',
      Value : TotalAmount
    },
    {
      $Type : 'UI.DataField',
      Label : 'Credit Status',
      Value : CreditStatus
    },
    {
      $Type : 'UI.DataField',
      Label : 'Order Status',
      Value : OrderStatus
    }
  ],

  UI.Facets : [
    {
      $Type  : 'UI.ReferenceFacet',
      ID     : 'OrderGeneralFacet',
      Label  : 'Order Information',
      Target : '@UI.FieldGroup#OrderGeneral'
    },
    {
      $Type  : 'UI.ReferenceFacet',
      ID     : 'OrderItemsFacet',
      Label  : 'Items',
      Target : 'Items/@UI.LineItem'
    },
    {
      $Type  : 'UI.ReferenceFacet',
      ID     : 'ApprovalsFacet',
      Label  : 'Approvals',
      Target : 'Approvals/@UI.LineItem'
    },
    {
      $Type  : 'UI.ReferenceFacet',
      ID     : 'InvoicesFacet',
      Label  : 'Invoices',
      Target : 'Invoices/@UI.LineItem'
    }
  ],

  UI.FieldGroup #OrderGeneral : {
    Data : [
      { $Type : 'UI.DataField', Label : 'Order ID',       Value : OrderID },
      { $Type : 'UI.DataField', Label : 'Customer ID',    Value : CustomerID },
      { $Type : 'UI.DataField', Label : 'Order Date',     Value : OrderDate },
      { $Type : 'UI.DataField', Label : 'Total Amount',   Value : TotalAmount },
      { $Type : 'UI.DataField', Label : 'Credit Status',   Value : CreditStatus },
      { $Type : 'UI.DataField', Label : 'Order Status',    Value : OrderStatus },
      { $Type : 'UI.DataField', Label : 'Blocked Reason',  Value : BlockedReason },
      { $Type : 'UI.DataField', Label : 'Notes',          Value : Notes },
      { $Type : 'UI.DataField', Label : 'Submitted On',    Value : SubmittedOn },
      { $Type : 'UI.DataField', Label : 'Approved On',     Value : ApprovedOn },
      { $Type : 'UI.DataField', Label : 'Approved By',     Value : ApprovedBy }
    ]
  }
);

annotate service.OrderItems with @(
  UI.LineItem : [
    { $Type : 'UI.DataField', Label : 'Item ID',     Value : ItemID },
    { $Type : 'UI.DataField', Label : 'Product',     Value : Product.ProductName },
    { $Type : 'UI.DataField', Label : 'Quantity',    Value : Quantity },
    { $Type : 'UI.DataField', Label : 'Unit Price',  Value : UnitPrice },
    { $Type : 'UI.DataField', Label : 'Item Total',  Value : ItemTotal }
  ]
);

annotate service.Approvals with @(
  UI.LineItem : [
    { $Type : 'UI.DataField', Label : 'Approval ID', Value : ApprovalID },
    { $Type : 'UI.DataField', Label : 'Decision',    Value : Decision },
    { $Type : 'UI.DataField', Label : 'Remarks',     Value : Remarks },
    { $Type : 'UI.DataField', Label : 'Approved By', Value : ApprovedBy },
    { $Type : 'UI.DataField', Label : 'Approved On', Value : ApprovedOn }
  ]
);

annotate service.Invoices with @(
  UI.LineItem : [
    { $Type : 'UI.DataField', Label : 'Invoice ID',     Value : InvoiceID },
    { $Type : 'UI.DataField', Label : 'Invoice Date',   Value : InvoiceDate },
    { $Type : 'UI.DataField', Label : 'Amount',         Value : Amount },
    { $Type : 'UI.DataField', Label : 'Due Date',       Value : DueDate },
    { $Type : 'UI.DataField', Label : 'Invoice Status',  Value : InvoiceStatus }
  ]
);

annotate service.Payments with @(
  UI.LineItem : [
    { $Type : 'UI.DataField', Label : 'Payment ID',     Value : PaymentID },
    { $Type : 'UI.DataField', Label : 'Amount Paid',    Value : AmountPaid },
    { $Type : 'UI.DataField', Label : 'Payment Date',   Value : PaymentDate },
    { $Type : 'UI.DataField', Label : 'Payment Mode',   Value : PaymentMode },
    { $Type : 'UI.DataField', Label : 'Payment Status', Value : PaymentStatus }
  ]
);