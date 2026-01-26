enum PartyType { customer, supplier, internal }

enum TransactionType {
  credit, // Incoming money (from customer) or Debt (from supplier - wait, definitions vary)
  // Let's be explicit:
  // For Supplier:
  // - We bought goods (We owe them) -> Debt Increase
  // - We paid them (We owe less) -> Payment

  // For Customer:
  // - They bought goods (They owe us) -> Debt Increase
  // - They paid us (They owe less) -> Payment

  // To keep it simple in database:
  // Amount can be positive or negative?
  // Or "give" vs "take".

  // Let's stick to strict accounting terms or simplified terms.
  // "Credit" (Give), "Debit" (Take).

  // Let's use descriptive names for the user, but for the code:
  // For Transaction entity:
  payment, // Money moved between parties
  debt, // Goods/Services value exchanged on credit
}
