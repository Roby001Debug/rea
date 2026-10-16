export function calculateTotal(quantity, unitPrice) {
  const subtotal = quantity * unitPrice;
  return subtotal + 7;
}
export function describeTotal(quantity) {
  return { total: calculateTotal(quantity, 2), mode: 'synthetic' };
}
