# Categories Feature Spec

## Intent

Categories is the lightweight manager for user-defined expense buckets. It lets
the user create categories, delete them, and drill into category-specific
expenses.

## Entry Points

- `ExpensesView` presents `CategoriesView` from the toolbar category button.
- `CategoriesView` presents `AddCategoryView` for creation.
- `CategoriesView` navigates to `CategoryExpensesView` for one category's
  expenses.

## Files

- `Domain/Model/ExpenseCategory.swift` in Expenses shared domain
- `Domain/Repository/CategoryRepository.swift`
- `Domain/UseCase/AddCategoryUseCase.swift`
- `Domain/UseCase/DeleteCategoryUseCase.swift`
- `Domain/UseCase/GetCategoriesUseCase.swift`
- `Domain/UseCase/GetCategoryExpensesUseCase.swift`
- `Data/Repository/SwiftDataCategoryRepository.swift`
- `DI/CategoriesDependencyContainer.swift`
- `UI/Categories/*`
- `UI/AddCategory/*`
- `UI/CategoryExpenses/*`

## Behaviour

- Categories load newest/created order from the shared SwiftData store.
- Add Category validates a non-empty name before saving.
- Deleting a category uses a destructive confirmation dialog.
- Tapping a category navigates to a read-only grouped expense list.

## Design

- `CategoriesView` uses the Phase 5 calm/floating language: ambient background,
  floating summary card, card-like rows via `floatingListRow()`, and soft
  entrance animation.
- Empty and error states use `FloatingCard`, token typography, and clear primary
  actions where appropriate.
- All user-facing copy is localized in `en` and `bs-BA`.

## Gotchas

- Category deletion currently preserves the established repository behavior:
  deleting a category also deletes associated expenses.
- Categories are used by Add Expense and on-device category suggestion, so names
  should remain user-authored and stable.
