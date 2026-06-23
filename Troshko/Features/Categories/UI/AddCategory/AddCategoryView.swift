import SwiftUI
import MVVM
import Styleguide

struct AddCategoryView<VM: ViewModel>: View
    where VM.State == AddCategoryViewState,
          VM.Event == AddCategoryViewEvent,
          VM.VMEvent == AddCategoryViewModelEvent
{
    @StateObject private var vm: VM
    private let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""

    init(vm: VM, onSaved: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: vm)
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            BaseScreen(isLoading: isSaving, dismissesKeyboardOnTap: true) {
                content
            }
            .navigationTitle("CATEGORIES.ADD.CATEGORY".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("WORDING_CANCEL".localized) { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if case .form(let canSave) = vm.state {
                    PrimaryButton(action: { vm.trigger(.saveTapped) }) {
                        Text("WORDING_ADD".localized)
                    }
                    .disabled(!canSave)
                    .padding(.horizontal, Spacing.Semantic.screenMargin)
                    .padding(.vertical, Spacing.Semantic.componentMargin)
                    .background(.ultraThinMaterial)
                }
            }
        }
        .onReceive(vm.eventPublisher) { event in
            switch event {
            case .saved:
                onSaved()
                dismiss()
            }
        }
    }

    private var isSaving: Bool {
        if case .saving = vm.state { return true }
        return false
    }

    @ViewBuilder
    private var content: some View {
        if case .error(let message) = vm.state {
            errorView(message)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.Semantic.sectionSpacing) {
                    AppTextField(
                        title: LocalizedStringKey("CATEGORIES.NAME"),
                        placeholder: LocalizedStringKey("CATEGORIES.PLACEHOLDER"),
                        text: $name,
                        submitLabel: .done,
                        onSubmit: { vm.trigger(.saveTapped) }
                    )
                    .onValueChange(of: name) { vm.trigger(.nameChanged($0)) }

                    Text("CATEGORIES.DESCRIPTION".localized)
                        .font(.regular(.small))
                        .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                }
                .padding(.horizontal, Spacing.Semantic.screenMargin)
                .padding(.top, Spacing.Semantic.sectionSpacing)
            }
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: Spacing.Semantic.itemSpacing) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(SemanticColor.Colors.error.swiftUIColor)
            Text(message)
                .font(.regular(.body))
                .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                .multilineTextAlignment(.center)
            Button("WORDING_RETRY".localized) { vm.trigger(.saveTapped) }
                .font(.semibold(.body))
                .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
        }
        .padding(Spacing.Semantic.screenMargin)
    }
}
