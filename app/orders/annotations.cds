using O2CService as service from '../../srv/o2c-service.cds';

// ====================================================
// Orders Entity - UI Annotations
// ====================================================

annotate service.Orders with @(
  UI.HeaderInfo: {
    TypeName: 'Sales Order',
    TypeNamePlural: 'Sales Orders',
    Title: { Value: OrderID },
    Description: { Value: Customer.CustomerName }
  },

  UI.SelectionFields: [
    OrderID,
    CustomerID,
    OrderDate
  ],

  UI.LineItem: [
    { $Type: 'UI.DataField', Label: 'Order ID', Value: OrderID },
    { $Type: 'UI.DataField', Label: 'Customer', Value: Customer.CustomerName },
    { $Type: 'UI.DataField', Label: 'Order Date', Value: OrderDate },
    { $Type: 'UI.DataField', Label: 'Total Amount', Value: TotalAmount },
    { $Type: 'UI.DataField', Label: 'Credit Status', Value: CreditStatus },
    { $Type: 'UI.DataField', Label: 'Order Status', Value: OrderStatus }
  ],

  UI.Facets: [
    { $Type: 'UI.ReferenceFacet', ID: 'OrderInfo', Label: 'Order Information', Target: '@UI.FieldGroup#OrderGeneral' },
    { $Type: 'UI.ReferenceFacet', ID: 'Items', Label: 'Items', Target: 'Items/@UI.LineItem' },
    { $Type: 'UI.ReferenceFacet', ID: 'Approvals', Label: 'Approvals', Target: 'Approvals/@UI.LineItem' },
    { $Type: 'UI.ReferenceFacet', ID: 'Invoices', Label: 'Invoices', Target: 'Invoices/@UI.LineItem' }
  ],

  UI.FieldGroup#OrderGeneral: {
    Data: [
      { $Type: 'UI.DataField', Label: 'Order ID', Value: OrderID },
      { $Type: 'UI.DataField', Label: 'Customer', Value: Customer.CustomerName },
      { $Type: 'UI.DataField', Label: 'Order Date', Value: OrderDate },
      { $Type: 'UI.DataField', Label: 'Total Amount', Value: TotalAmount },
      { $Type: 'UI.DataField', Label: 'Credit Status', Value: CreditStatus },
      { $Type: 'UI.DataField', Label: 'Order Status', Value: OrderStatus },
      { $Type: 'UI.DataField', Label: 'Notes', Value: Notes }
    ]
  }
);

annotate service.Orders with {
  CustomerID @(
    Common.ValueListWithFixedValues: true,
    Common.ValueList: {
      CollectionPath: 'Customers',
      Parameters: [
        { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: CustomerID, ValueListProperty: 'CustomerID' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'CustomerName' }
      ]
    }
  );
  
  CreditStatus @(Common.ValueListWithFixedValues: true);
  OrderStatus @(Common.ValueListWithFixedValues: true);
  TotalAmount @(Measures.ISOCurrency: 'USD');
};

// ====================================================
// OrderItems Entity
// ====================================================

annotate service.OrderItems with @(
  UI.LineItem: [
    { $Type: 'UI.DataField', Label: 'Item ID', Value: ItemID },
    { $Type: 'UI.DataField', Label: 'Product', Value: Product.ProductName },
    { $Type: 'UI.DataField', Label: 'Quantity', Value: Quantity },
    { $Type: 'UI.DataField', Label: 'Unit Price', Value: UnitPrice },
    { $Type: 'UI.DataField', Label: 'Total', Value: ItemTotal }
  ],

  UI.FieldGroup#ItemDetail: {
    Data: [
      { $Type: 'UI.DataField', Label: 'Item ID', Value: ItemID },
      { $Type: 'UI.DataField', Label: 'Product', Value: Product.ProductName },
      { $Type: 'UI.DataField', Label: 'Quantity', Value: Quantity },
      { $Type: 'UI.DataField', Label: 'Unit Price', Value: UnitPrice },
      { $Type: 'UI.DataField', Label: 'Total', Value: ItemTotal }
    ]
  }
);

annotate service.OrderItems with {
  ProductID @(
    Common.ValueListWithFixedValues: true,
    Common.ValueList: {
      CollectionPath: 'Products',
      Parameters: [
        { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: ProductID, ValueListProperty: 'ProductID' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'ProductName' }
      ]
    }
  );
};

// ====================================================
// Approvals Entity
// ====================================================

annotate service.Approvals with @(
  UI.LineItem: [
    { $Type: 'UI.DataField', Label: 'Approval ID', Value: ApprovalID },
    { $Type: 'UI.DataField', Label: 'Decision', Value: Decision },
    { $Type: 'UI.DataField', Label: 'Remarks', Value: Remarks },
    { $Type: 'UI.DataField', Label: 'Approved By', Value: ApprovedBy },
    { $Type: 'UI.DataField', Label: 'Approved On', Value: ApprovedOn }
  ]
);

// ====================================================
// Invoices Entity
// ====================================================

annotate service.Invoices with @(
  UI.LineItem: [
    { $Type: 'UI.DataField', Label: 'Invoice ID', Value: InvoiceID },
    { $Type: 'UI.DataField', Label: 'Invoice Date', Value: InvoiceDate },
    { $Type: 'UI.DataField', Label: 'Amount', Value: Amount },
    { $Type: 'UI.DataField', Label: 'Tax', Value: TaxAmount },
    { $Type: 'UI.DataField', Label: 'Due Date', Value: DueDate },
    { $Type: 'UI.DataField', Label: 'Status', Value: InvoiceStatus }
  ]
);

// ====================================================
// Payments Entity
// ====================================================

annotate service.Payments with @(
  UI.LineItem: [
    { $Type: 'UI.DataField', Label: 'Payment ID', Value: PaymentID },
    { $Type: 'UI.DataField', Label: 'Amount', Value: AmountPaid },
    { $Type: 'UI.DataField', Label: 'Payment Date', Value: PaymentDate },
    { $Type: 'UI.DataField', Label: 'Mode', Value: PaymentMode },
    { $Type: 'UI.DataField', Label: 'Status', Value: PaymentStatus }
  ]
);
