# 记账 App（极速个人记账）Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 从零实现一款跨平台“极速个人记账”App 的 MVP：3 秒记一笔（支出/收入）、明细列表、本月概览、类别/账户管理、JSON/CSV 导出备份。

**Architecture:** 采用本地优先架构：所有写入先落本地 SQLite；UI 以“记账页”为主战场，明细与概览基于查询/聚合展示。业务层（领域模型/用例）与数据层（SQLite）分离，便于测试与后续加同步。

**Tech Stack:** Flutter（Dart）、SQLite（`drift` 或 `sqflite` + 手写 DAO，推荐 `drift`）、状态管理（`flutter_riverpod`）、测试（`flutter_test` + `test`）、格式化与静态检查（`flutter analyze`、`dart format`）

---

## 假设与约束（开始实现前统一口径）
- **项目当前为空目录**（无现成代码/脚手架）。
- **MVP 单币种**：默认币种写死/仅设置项可改，不做多币种换算。
- **不做云同步**：仅本地 SQLite + 导出/导入（JSON/CSV）。
- **先做支出/收入**；转账 UI/模型保留接口但可在 v1.1 完成（如果你坚持 MVP 就做转账，把下方“里程碑 3”里相关任务提前）。

## 里程碑概览（建议顺序）
- **Milestone 0：工程与质量基线**（可跑、可测、可持续迭代）
- **Milestone 1：领域模型 + 本地数据库层（SQLite）**（可测试、可迁移）
- **Milestone 2：记账页（3 秒记一笔）**（核心闭环）
- **Milestone 3：明细页（列表 + 编辑/删除/复制）**
- **Milestone 4：概览页（本月总额 + Top 类别 + 趋势）**
- **Milestone 5：类别/账户管理**
- **Milestone 6：导出/导入（JSON/CSV 备份）**
- **Milestone 7：打磨与验收**（性能、可用性、回归测试）

> **关于提交**：如果你希望跟随计划频繁 commit，请先在仓库根目录执行：`git init`。每个 Task 末尾都提供了推荐的提交命令（在 git 可用时执行）。

---

### Task 0.1：创建 Flutter 工程骨架

**Files:**
- Create: `pubspec.yaml`（由 Flutter 脚手架生成）
- Create: `lib/main.dart`（由 Flutter 脚手架生成）
- Test: `test/widget_test.dart`（由 Flutter 脚手架生成）

**Step 1: 生成工程**

Run: `flutter create one_tap_expense_tracker`
Expected: 成功生成 Flutter 项目目录 `one_tap_expense_tracker/`

**Step 2: 运行默认测试**

Run: `cd one_tap_expense_tracker && flutter test`
Expected: PASS（默认 widget 测试通过）

**Step 3: 初始化 git（可选但强烈建议）**

Run: `git init`
Expected: 初始化成功

**Step 4: Commit（可选）**

```bash
git add .
git commit -m "chore: bootstrap flutter app"
```

---

### Task 0.2：引入基础依赖与质量工具

**Files:**
- Modify: `one_tap_expense_tracker/pubspec.yaml`

**Step 1: 添加依赖（推荐组合）**
- 状态管理：`flutter_riverpod`
- 数据库（推荐）：`drift`, `drift_flutter`, `sqlite3_flutter_libs`, `path_provider`, `path`
- UUID：`uuid`
- 导出：`csv`, `share_plus`（或先只写到文件）

**Step 2: 运行依赖安装**

Run: `cd one_tap_expense_tracker && flutter pub get`
Expected: 成功安装，无版本冲突

**Step 3: 静态检查**

Run: `flutter analyze`
Expected: 0 issues

**Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add core dependencies"
```

---

### Task 1.1：定义领域模型（纯 Dart，可单测）

**Files:**
- Create: `one_tap_expense_tracker/lib/domain/money.dart`
- Create: `one_tap_expense_tracker/lib/domain/transaction.dart`
- Create: `one_tap_expense_tracker/lib/domain/category.dart`
- Create: `one_tap_expense_tracker/lib/domain/account.dart`
- Test: `one_tap_expense_tracker/test/domain/money_test.dart`
- Test: `one_tap_expense_tracker/test/domain/transaction_test.dart`

**Step 1: 写失败测试（金额以分存储）**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:one_tap_expense_tracker/domain/money.dart';

void main() {
  test('Money stores amount in minor units (cents)', () {
    final m = Money.cents(1234);
    expect(m.cents, 1234);
  });
}
```

**Step 2: 运行测试确保失败**

Run: `flutter test test/domain/money_test.dart`
Expected: FAIL（找不到 `Money` 或构造器）

**Step 3: 最小实现使其通过**

```dart
class Money {
  final int cents;
  const Money._(this.cents);

  factory Money.cents(int cents) => Money._(cents);
}
```

**Step 4: 运行测试确保通过**

Run: `flutter test test/domain/money_test.dart`
Expected: PASS

**Step 5: 为 Transaction 写失败测试（必填字段校验）**

测试点：
- `amount.cents > 0`
- `type` 为 `expense/income` 时必须有 `categoryId` 与 `accountId`

Run: `flutter test test/domain/transaction_test.dart`
Expected: 先 FAIL

**Step 6: 最小实现并跑全测**

Run: `flutter test`
Expected: PASS

**Step 7: Commit**

```bash
git add lib/domain test/domain
git commit -m "feat(domain): add core models"
```

---

### Task 1.2：定义 SQLite schema 与 DAO（drift）

**Files:**
- Create: `one_tap_expense_tracker/lib/data/db/app_db.dart`
- Create: `one_tap_expense_tracker/lib/data/db/tables.dart`
- Create: `one_tap_expense_tracker/lib/data/repositories/transaction_repository.dart`
- Test: `one_tap_expense_tracker/test/data/transaction_repository_test.dart`

**Step 1: 写失败测试（插入并按时间倒序读取）**

测试用例（要点）：
- 插入 2 条 `Transaction`
- 查询最近列表应按 `occurredAt DESC`

Run: `flutter test test/data/transaction_repository_test.dart`
Expected: FAIL（DB/Repo 未实现）

**Step 2: 最小实现：**
- 表：`transactions`, `categories`, `accounts`, `app_settings`（settings 可先用 key/value）
- 字段按设计文档：`amount_cents`、`occurred_at`、`created_at`、`updated_at`，可选 `deleted_at`
- Repository 提供：
  - `createTransaction(...)`
  - `listRecentTransactions({limit, offset})`

**Step 3: 跑测试**

Run: `flutter test test/data/transaction_repository_test.dart`
Expected: PASS

**Step 4: Commit**

```bash
git add lib/data test/data
git commit -m "feat(data): add sqlite db and transaction repository"
```

---

### Task 1.3：预置类别/账户种子数据（首次启动）

**Files:**
- Create: `one_tap_expense_tracker/lib/data/seed/seed_data.dart`
- Modify: `one_tap_expense_tracker/lib/data/db/app_db.dart`（初始化钩子）
- Test: `one_tap_expense_tracker/test/data/seed_test.dart`

**Step 1: 写失败测试（首次启动会插入默认类别/账户）**

Run: `flutter test test/data/seed_test.dart`
Expected: FAIL

**Step 2: 最小实现**
- 默认支出类别：餐饮/交通/购物/娱乐/居家/医疗/教育/其他
- 默认收入类别：工资/奖金/其他
- 默认账户：现金/银行卡/微信/支付宝

**Step 3: 跑测试**

Run: `flutter test test/data/seed_test.dart`
Expected: PASS

**Step 4: Commit**

```bash
git add lib/data/seed test/data/seed_test.dart
git commit -m "feat(data): seed default categories and accounts"
```

---

### Task 2.1：搭建应用骨架与 3-tab 导航

**Files:**
- Modify: `one_tap_expense_tracker/lib/main.dart`
- Create: `one_tap_expense_tracker/lib/app/app.dart`
- Create: `one_tap_expense_tracker/lib/app/routes.dart`（可选）
- Create: `one_tap_expense_tracker/lib/ui/nav/root_scaffold.dart`
- Test: `one_tap_expense_tracker/test/ui/navigation_smoke_test.dart`

**Step 1: 写失败测试（存在 3 个 Tab：记账/明细/概览）**

Run: `flutter test test/ui/navigation_smoke_test.dart`
Expected: FAIL

**Step 2: 最小实现 RootScaffold**
- BottomNavigationBar 3 项
- 三个页面占位：`AddTransactionPage`, `TransactionsPage`, `OverviewPage`

**Step 3: 跑测试**

Run: `flutter test test/ui/navigation_smoke_test.dart`
Expected: PASS

**Step 4: Commit**

```bash
git add lib/app lib/ui/nav test/ui
git commit -m "feat(ui): add root navigation scaffold"
```

---

### Task 2.2：实现记账页（金额输入 + 类别快捷 + 一键保存）

**Files:**
- Create: `one_tap_expense_tracker/lib/ui/add/add_transaction_page.dart`
- Create: `one_tap_expense_tracker/lib/ui/add/widgets/amount_input.dart`
- Create: `one_tap_expense_tracker/lib/ui/add/widgets/category_quick_grid.dart`
- Create: `one_tap_expense_tracker/lib/ui/add/widgets/secondary_fields_sheet.dart`
- Create: `one_tap_expense_tracker/lib/state/add_transaction_controller.dart`
- Test: `one_tap_expense_tracker/test/ui/add_transaction_flow_test.dart`

**Step 1: 写失败测试（输入金额、选择类别、点击保存后写入 DB）**

Run: `flutter test test/ui/add_transaction_flow_test.dart`
Expected: FAIL

**Step 2: 最小实现**
- AmountInput：仅支持整数/两位小数（内部转分）
- CategoryQuickGrid：展示“最近 + 常用”（MVP 可先全部类别，后续再优化排序）
- Controller：维护 amount/category/account/note/occurredAt；保存时调用 repository
- 保存成功后：清空金额并保留最近类别（提升连记效率）

**Step 3: 跑测试**

Run: `flutter test test/ui/add_transaction_flow_test.dart`
Expected: PASS

**Step 4: 手动验收（本里程碑关键）**
- Run: `flutter run`
- 验收点：
  - 不填金额不可保存
  - 金额 + 类别 两步能完成保存
  - 保存后列表可看到新记录（下一任务完成后）

**Step 5: Commit**

```bash
git add lib/ui/add lib/state test/ui/add_transaction_flow_test.dart
git commit -m "feat(ui): implement fast add transaction flow"
```

---

### Task 3.1：实现明细页（倒序列表 + 分组）

**Files:**
- Create: `one_tap_expense_tracker/lib/ui/transactions/transactions_page.dart`
- Create: `one_tap_expense_tracker/lib/ui/transactions/widgets/transaction_list_item.dart`
- Create: `one_tap_expense_tracker/lib/state/transactions_controller.dart`
- Test: `one_tap_expense_tracker/test/ui/transactions_list_test.dart`

**Step 1: 写失败测试（按 occurredAt 倒序显示）**

Run: `flutter test test/ui/transactions_list_test.dart`
Expected: FAIL

**Step 2: 最小实现**
- 从 repository 读取最近 N 条
- ListView 展示金额与类别名称（图标/颜色可后置）
- 分组（今天/昨天/本周/更早）可先简化为日期 header（MVP 简版）

**Step 3: 跑测试**

Run: `flutter test test/ui/transactions_list_test.dart`
Expected: PASS

**Step 4: Commit**

```bash
git add lib/ui/transactions lib/state test/ui/transactions_list_test.dart
git commit -m "feat(ui): add transactions list page"
```

---

### Task 3.2：明细编辑/删除/复制

**Files:**
- Modify: `one_tap_expense_tracker/lib/data/repositories/transaction_repository.dart`
- Modify: `one_tap_expense_tracker/lib/ui/transactions/transactions_page.dart`
- Test: `one_tap_expense_tracker/test/ui/transactions_edit_delete_copy_test.dart`

**Step 1: 写失败测试**
- 删除后不再显示
- 复制后生成新 `id` 且金额/类别/账户/备注相同，时间为 now（或保持原 occurredAt，二选一，建议 now）

Run: `flutter test test/ui/transactions_edit_delete_copy_test.dart`
Expected: FAIL

**Step 2: 最小实现**
- Repo 增加：`deleteTransaction(id)`（软删或硬删，推荐软删）
- UI：滑动操作（先用按钮/菜单实现，手势可后置到 v1.1，避免阻塞）
- Copy：读取原记录并创建新记录

**Step 3: 跑测试**

Run: `flutter test test/ui/transactions_edit_delete_copy_test.dart`
Expected: PASS

**Step 4: Commit**

```bash
git add lib/data lib/ui/transactions test/ui/transactions_edit_delete_copy_test.dart
git commit -m "feat: add transaction delete and copy"
```

---

### Task 4.1：概览页（本月总额 + Top 类别）

**Files:**
- Modify: `one_tap_expense_tracker/lib/data/repositories/transaction_repository.dart`（聚合查询）
- Create: `one_tap_expense_tracker/lib/ui/overview/overview_page.dart`
- Create: `one_tap_expense_tracker/lib/state/overview_controller.dart`
- Test: `one_tap_expense_tracker/test/data/overview_aggregation_test.dart`

**Step 1: 写失败测试（给定账目应计算本月总额与类别 Top）**

Run: `flutter test test/data/overview_aggregation_test.dart`
Expected: FAIL

**Step 2: 最小实现聚合查询**
- `sumExpenseByMonth(monthStart, monthEnd)`
- `topCategoriesByMonth(limit)`

**Step 3: 跑测试**

Run: `flutter test test/data/overview_aggregation_test.dart`
Expected: PASS

**Step 4: UI 最小实现**
- 显示本月总额与 Top5 列表

**Step 5: Commit**

```bash
git add lib/ui/overview lib/state lib/data test/data/overview_aggregation_test.dart
git commit -m "feat(ui): add overview page with monthly aggregates"
```

---

### Task 4.2：概览趋势（7/30 天）

**Files:**
- Modify: `one_tap_expense_tracker/lib/data/repositories/transaction_repository.dart`
- Modify: `one_tap_expense_tracker/lib/ui/overview/overview_page.dart`
- Test: `one_tap_expense_tracker/test/data/trend_aggregation_test.dart`

**Step 1: 写失败测试（按天聚合）**

Run: `flutter test test/data/trend_aggregation_test.dart`
Expected: FAIL

**Step 2: 最小实现**
- 查询过去 N 天每日支出（缺失天补 0）
- UI 用简单列表/迷你柱状（不引入大图表库也可以）

**Step 3: 跑测试并 Commit**

Run: `flutter test`
Expected: PASS

```bash
git add lib/ui/overview lib/data test/data/trend_aggregation_test.dart
git commit -m "feat: add simple spending trend"
```

---

### Task 5.1：类别管理（增删改排序/归档）

**Files:**
- Create: `one_tap_expense_tracker/lib/ui/settings/categories/categories_page.dart`
- Create: `one_tap_expense_tracker/lib/state/categories_controller.dart`
- Modify: `one_tap_expense_tracker/lib/data/repositories/category_repository.dart`（新增）
- Test: `one_tap_expense_tracker/test/ui/categories_crud_test.dart`

**Step 1: 写失败测试（新增类别后可用于记账）**

Run: `flutter test test/ui/categories_crud_test.dart`
Expected: FAIL

**Step 2: 最小实现 CRUD**
- 新增/重命名/归档
- 排序：MVP 可先用 `sortOrder` + 上下移动按钮（拖拽后置）

**Step 3: 跑测试与 Commit**

Run: `flutter test`
Expected: PASS

```bash
git add lib/ui/settings lib/state lib/data test/ui/categories_crud_test.dart
git commit -m "feat: add category management"
```

---

### Task 5.2：账户管理（增删改排序/归档）

**Files:**
- Create: `one_tap_expense_tracker/lib/ui/settings/accounts/accounts_page.dart`
- Create: `one_tap_expense_tracker/lib/state/accounts_controller.dart`
- Modify: `one_tap_expense_tracker/lib/data/repositories/account_repository.dart`（新增）
- Test: `one_tap_expense_tracker/test/ui/accounts_crud_test.dart`

**Step 1: 写失败测试**

Run: `flutter test test/ui/accounts_crud_test.dart`
Expected: FAIL

**Step 2: 最小实现**
- CRUD 与排序同类别管理

**Step 3: 跑测试与 Commit**

Run: `flutter test`
Expected: PASS

```bash
git add lib/ui/settings lib/state lib/data test/ui/accounts_crud_test.dart
git commit -m "feat: add account management"
```

---

### Task 6.1：JSON 导出/导入（含 schemaVersion）

**Files:**
- Create: `one_tap_expense_tracker/lib/data/backup/backup_service.dart`
- Create: `one_tap_expense_tracker/lib/ui/settings/backup/backup_page.dart`
- Test: `one_tap_expense_tracker/test/data/backup_roundtrip_test.dart`

**Step 1: 写失败测试（导出→导入 round-trip 一致性）**

Run: `flutter test test/data/backup_roundtrip_test.dart`
Expected: FAIL

**Step 2: 最小实现**
- 导出：categories/accounts/transactions/settings（按 JSON）
- 导入：清空并重建（MVP 先采用“覆盖导入”，合并策略后置）
- 包含：`schemaVersion`, `exportedAt`

**Step 3: 跑测试与 Commit**

Run: `flutter test`
Expected: PASS

```bash
git add lib/data/backup lib/ui/settings/backup test/data/backup_roundtrip_test.dart
git commit -m "feat: add json backup export/import"
```

---

### Task 6.2：CSV 导出（交易明细）

**Files:**
- Modify: `one_tap_expense_tracker/lib/data/backup/backup_service.dart`
- Test: `one_tap_expense_tracker/test/data/csv_export_test.dart`

**Step 1: 写失败测试（CSV 包含关键列）**
- columns：date, type, amount, category, account, note

Run: `flutter test test/data/csv_export_test.dart`
Expected: FAIL

**Step 2: 最小实现并通过测试**

Run: `flutter test`
Expected: PASS

**Step 3: Commit**

```bash
git add lib/data/backup test/data/csv_export_test.dart
git commit -m "feat: add csv export"
```

---

### Task 7.1：回归测试与验收清单（release 前）

**Files:**
- Create: `one_tap_expense_tracker/docs/acceptance/mvp-checklist.md`

**Step 1: 编写验收清单（手工）**
必验点：
- 3 秒记一笔：金额 + 类别 → 保存成功
- 明细列表：新增后立刻可见；删除/复制正确
- 概览：本月总额与 Top 类别与明细一致
- 备份：JSON 导出文件可导入恢复数据；CSV 可在表格中正常打开

**Step 2: 跑全量自动化**

Run: `flutter analyze && dart format . --set-exit-if-changed && flutter test`
Expected: 全部 PASS

**Step 3: Commit**

```bash
git add docs/acceptance/mvp-checklist.md
git commit -m "docs: add MVP acceptance checklist"
```

---

## 最终交付物（MVP）
- 可运行的 Flutter App（Android/iOS）
- 本地 SQLite 持久化
- 记账/明细/概览 3 Tab
- 类别/账户管理
- JSON/CSV 导出（备份）
- 自动化测试覆盖核心领域与聚合逻辑

