# Expenses Feature Spec

## Intent

Expenses is the daily spending log. It owns listing, grouping, adding, editing,
deleting, and displaying expense amounts. It is also the reference screen for the
Phase 5 calm/floating design language. Phase 8 adds an optional on-device AI
category suggestion inside Add/Edit Expense.

## Entry Points

- `UI/Expenses/ExpensesView.swift` is the Expenses tab root.
- `UI/AddExpense/AddExpenseView.swift` is presented as a sheet for add/edit.
- Categories and Monthly Overview read the same expense/category data through the
  shared SwiftData store.

## Files

- `Domain/Model/Expense.swift`
- `Domain/Model/ExpenseCategory.swift`
- `Domain/Repository/ExpenseRepository.swift`
- `Domain/UseCase/GetExpensesUseCase.swift`
- `Domain/UseCase/AddExpenseUseCase.swift`
- `Domain/UseCase/UpdateExpenseUseCase.swift`
- `Domain/UseCase/DeleteExpenseUseCase.swift`
- `Domain/UseCase/GetExpenseCategoriesUseCase.swift`
- `Data/Model/ExpenseEntity.swift`
- `Data/ExpenseStore.swift`
- `Data/Repository/SwiftDataExpenseRepository.swift`
- `DI/ExpensesDependencyContainer.swift`
- `UI/Expenses/ExpensesView.swift`
- `UI/Expenses/ExpenseRow.swift`
- `UI/Expenses/ExpensesViewModel.swift`
- `UI/Expenses/ExpensesViewState.swift`
- `UI/Expenses/ExpensesViewEvent.swift`
- `UI/Expenses/ExpensesViewModelEvent.swift`
- `UI/AddExpense/AddExpenseView.swift`
- `UI/AddExpense/AddExpenseViewModel.swift`
- `UI/AddExpense/AddExpenseViewState.swift`
- `UI/AddExpense/AddExpenseViewEvent.swift`
- `UI/AddExpense/AddExpenseViewModelEvent.swift`
- `../OnDeviceAI/Domain/UseCase/SuggestExpenseCategoryUseCase.swift`

## Behaviour

- Expenses group newest-first under Today, This month, or Month Year.
- Amounts use the shared `Money` value type: exact integer minor units plus
  explicit currency code.
- Add/edit validates title and amount before enabling save.
- Add/edit supports optional category selection.
- Add/edit can suggest a category via on-device AI. Suggestions are
  propose-then-confirm and can only apply an existing category.
- Swipe actions support edit and delete from the list.
- Empty state presents a clear add-expense call to action.

## Design

- Root list uses `BaseScreen(showsAmbientBackground: true)`.
- Loaded state has a floating summary card, floating list rows, and soft entrance
  cascade.
- Empty/error states use `FloatingCard` and Styleguide tokens.
- Root toolbar includes the Phase 6 profile/settings entry point.

## Gotchas

- Do not add a whole-screen tap gesture around `AddExpenseView` to dismiss the
  keyboard. A broad recognizer can interfere with the graphical `DatePicker`.
  Use explicit focus handling and the keyboard Done toolbar instead.
- Decimal-pad amount entry has no return key, so keep the keyboard Done toolbar.
- Do not use floating point for money parsing, storage, aggregation, or display
  logic. Convert only at parsing/formatting/chart-size boundaries.
