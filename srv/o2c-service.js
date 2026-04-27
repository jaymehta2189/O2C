const cds = require('@sap/cds');

function makeId(prefix) {
  const ts = Date.now().toString(36).toUpperCase();
  const rnd = Math.random().toString(36).slice(2, 6).toUpperCase();
  return `${prefix}${ts}${rnd}`.slice(0, 20);
}

function todayISO() {
  return new Date().toISOString().slice(0, 10);
}

function nowISO() {
  return new Date().toISOString();
}

module.exports = (srv) => {
  const { SELECT, INSERT, UPDATE } = cds.ql;
  const {
    Orders,
    OrderItems,
    Customers,
    Products,
    Approvals
  } = cds.entities('o2c');

  async function recalcOrderTotal(tx, orderID) {
    if (!orderID) return 0;

    const items = await tx.run(
      SELECT.from(OrderItems).columns('ItemTotal').where({ OrderID: orderID })
    );

    const total = items.reduce((sum, row) => sum + Number(row.ItemTotal || 0), 0);

    await tx.run(
      UPDATE(Orders).set({ TotalAmount: total }).where({ OrderID: orderID })
    );

    return total;
  }

  async function enrichAndValidateItems(req, tx, orderID, items) {
    let total = 0;

    for (const item of items || []) {
      if (!item.ProductID) req.reject(400, 'Product is required for each item');
      if (!item.Quantity || Number(item.Quantity) <= 0) req.reject(400, 'Quantity must be greater than zero');

      item.ItemID ??= makeId('ITEM');
      item.OrderID ??= orderID;

      const product = await tx.run(
        SELECT.one.from(Products).where({ ProductID: item.ProductID })
      );

      if (!product) req.reject(400, `Product ${item.ProductID} does not exist`);
      if (product.Status !== 'Active') req.reject(400, `Product ${item.ProductID} is not active`);

      item.UnitPrice = Number(product.Price || 0);
      item.ItemTotal = Number(item.UnitPrice) * Number(item.Quantity);
      total += Number(item.ItemTotal);
    }

    return total;
  }

  srv.before(['CREATE', 'UPDATE'], 'Orders', async (req) => {
    const tx = cds.transaction(req);
    const data = req.data;

    if (req.event === 'CREATE') {
      data.OrderID ??= makeId('ORD');
      data.OrderDate ??= todayISO();
      data.TotalAmount ??= 0;
      data.CreditStatus ??= 'Draft';
      data.OrderStatus ??= 'Draft';
    }

    if (!data.CustomerID) req.reject(400, 'Customer is required');

    const customer = await tx.run(
      SELECT.one.from(Customers).where({ CustomerID: data.CustomerID })
    );

    if (!customer) req.reject(400, `Customer ${data.CustomerID} does not exist`);
    if (customer.Status !== 'Active') req.reject(400, `Customer ${data.CustomerID} is not active`);

    if (req.event === 'UPDATE') {
      const existing = await tx.run(
        SELECT.one.from(Orders).where({ OrderID: data.OrderID })
      );

      if (!existing) req.reject(404, `Order ${data.OrderID} not found`);

      const editable = ['Draft', 'Rejected'];
      if (!editable.includes(existing.OrderStatus)) {
        req.reject(400, `Only Draft or Rejected orders can be edited`);
      }
    }

    if (Array.isArray(data.Items) && data.Items.length) {
      data.TotalAmount = await enrichAndValidateItems(req, tx, data.OrderID, data.Items);
    }
  });

  srv.before(['CREATE', 'UPDATE'], 'OrderItems', async (req) => {
    const tx = cds.transaction(req);
    const data = req.data;

    if (req.event === 'CREATE') {
      data.ItemID ??= makeId('ITEM');
    }

    if (!data.OrderID) req.reject(400, 'OrderID is required for order items');
    if (!data.ProductID) req.reject(400, 'Product is required');
    if (!data.Quantity || Number(data.Quantity) <= 0) req.reject(400, 'Quantity must be greater than zero');

    const product = await tx.run(
      SELECT.one.from(Products).where({ ProductID: data.ProductID })
    );
    if (!product) req.reject(400, `Product ${data.ProductID} does not exist`);
    if (product.Status !== 'Active') req.reject(400, `Product ${data.ProductID} is not active`);

    data.UnitPrice = Number(product.Price || 0);
    data.ItemTotal = Number(data.UnitPrice) * Number(data.Quantity);
  });

  srv.before('DELETE', 'OrderItems', async (req) => {
    const tx = cds.transaction(req);
    const item = await tx.run(
      SELECT.one.from(OrderItems).columns('OrderID').where(req.where)
    );
    req._orderID = item?.OrderID;
  });

  srv.after(['CREATE', 'UPDATE'], 'OrderItems', async (data, req) => {
    const tx = cds.transaction(req);
    const orderID = data?.OrderID || req.data?.OrderID;
    await recalcOrderTotal(tx, orderID);
  });

  srv.after('DELETE', 'OrderItems', async (_, req) => {
    const tx = cds.transaction(req);
    if (req._orderID) await recalcOrderTotal(tx, req._orderID);
  });

  srv.on('submitOrder', async (req) => {
    const { orderID } = req.data;
    const tx = cds.transaction(req);

    const order = await tx.run(
      SELECT.one.from(Orders).where({ OrderID: orderID })
    );
    if (!order) req.reject(404, `Order ${orderID} not found`);

    const customer = await tx.run(
      SELECT.one.from(Customers).where({ CustomerID: order.CustomerID })
    );

    const items = await tx.run(
      SELECT.from(OrderItems).where({ OrderID: orderID })
    );

    if (!items.length) req.reject(400, 'Add at least one item before submit');

    const total = items.reduce((sum, row) => sum + Number(row.ItemTotal || 0), 0);
    const used = Number(customer.UsedCredit || 0);
    const limit = Number(customer.CreditLimit || 0);
    const available = limit - used;

    await tx.run(
      UPDATE(Orders).set({
        TotalAmount: total,
        SubmittedOn: nowISO()
      }).where({ OrderID: orderID })
    );

    if (total <= available) {
      await tx.run(
        UPDATE(Customers).set({
          UsedCredit: used + total
        }).where({ CustomerID: customer.CustomerID })
      );

      await tx.run(
        UPDATE(Orders).set({
          CreditStatus: 'Approved',
          OrderStatus: 'Confirmed',
          ApprovedOn: nowISO(),
          ApprovedBy: req.user?.id || 'SYSTEM',
          BlockedReason: null
        }).where({ OrderID: orderID })
      );

      await tx.run(
        INSERT.into(Approvals).entries({
          ApprovalID: makeId('APR'),
          OrderID: orderID,
          Decision: 'Approved',
          Remarks: 'Auto-approved within credit limit',
          ApprovedBy: req.user?.id || 'SYSTEM',
          ApprovedOn: nowISO()
        })
      );
    } else {
      const blockedAmount = total - available;

      await tx.run(
        UPDATE(Orders).set({
          CreditStatus: 'Blocked',
          OrderStatus: 'Blocked',
          BlockedReason: `Exceeded credit by ${blockedAmount.toFixed(2)}`
        }).where({ OrderID: orderID })
      );

      await tx.run(
        INSERT.into(Approvals).entries({
          ApprovalID: makeId('APR'),
          OrderID: orderID,
          Decision: 'Hold',
          Remarks: `Blocked by credit check. Exceeded by ${blockedAmount.toFixed(2)}`,
          ApprovedBy: req.user?.id || 'SYSTEM',
          ApprovedOn: nowISO()
        })
      );
    }

    return tx.run(
      SELECT.one.from(Orders).where({ OrderID: orderID })
    );
  });

  srv.on('approveOrder', async (req) => {
    const { orderID, decision, remarks } = req.data;
    const tx = cds.transaction(req);

    const order = await tx.run(
      SELECT.one.from(Orders).where({ OrderID: orderID })
    );
    if (!order) req.reject(404, `Order ${orderID} not found`);

    const customer = await tx.run(
      SELECT.one.from(Customers).where({ CustomerID: order.CustomerID })
    );

    const total = Number(order.TotalAmount || 0);

    if (decision === 'Approved') {
      await tx.run(
        UPDATE(Customers).set({
          UsedCredit: Number(customer.UsedCredit || 0) + total
        }).where({ CustomerID: customer.CustomerID })
      );

      await tx.run(
        UPDATE(Orders).set({
          CreditStatus: 'Approved',
          OrderStatus: 'Confirmed',
          ApprovedOn: nowISO(),
          ApprovedBy: req.user?.id || 'SYSTEM',
          BlockedReason: null
        }).where({ OrderID: orderID })
      );
    } else if (decision === 'Rejected') {
      await tx.run(
        UPDATE(Orders).set({
          CreditStatus: 'Rejected',
          OrderStatus: 'Rejected',
          BlockedReason: remarks || 'Rejected by credit manager'
        }).where({ OrderID: orderID })
      );
    } else {
      await tx.run(
        UPDATE(Orders).set({
          CreditStatus: 'Hold',
          OrderStatus: 'Blocked',
          BlockedReason: remarks || 'Held for review'
        }).where({ OrderID: orderID })
      );
    }

    await tx.run(
      INSERT.into(Approvals).entries({
        ApprovalID: makeId('APR'),
        OrderID: orderID,
        Decision: decision,
        Remarks: remarks,
        ApprovedBy: req.user?.id || 'SYSTEM',
        ApprovedOn: nowISO()
      })
    );

    return tx.run(
      SELECT.one.from(Orders).where({ OrderID: orderID })
    );
  });

  srv.on('cancelOrder', async (req) => {
    const { orderID, remarks } = req.data;
    const tx = cds.transaction(req);

    const order = await tx.run(
      SELECT.one.from(Orders).where({ OrderID: orderID })
    );
    if (!order) req.reject(404, `Order ${orderID} not found`);

    await tx.run(
      UPDATE(Orders).set({
        OrderStatus: 'Cancelled',
        CreditStatus: 'Rejected',
        BlockedReason: remarks || 'Cancelled by user'
      }).where({ OrderID: orderID })
    );

    await tx.run(
      INSERT.into(Approvals).entries({
        ApprovalID: makeId('APR'),
        OrderID: orderID,
        Decision: 'Rejected',
        Remarks: remarks || 'Cancelled',
        ApprovedBy: req.user?.id || 'SYSTEM',
        ApprovedOn: nowISO()
      })
    );

    return tx.run(
      SELECT.one.from(Orders).where({ OrderID: orderID })
    );
  });
};