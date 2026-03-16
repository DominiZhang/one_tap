enum AccountType { cash, bank, wechat, alipay, custom }

class Account {
  final String id;
  final String name;
  final AccountType type;
  final int sortOrder;
  final bool isArchived;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.sortOrder,
    this.isArchived = false,
  });
}

