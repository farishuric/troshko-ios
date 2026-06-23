import SwiftUI
import MVVM
import Styleguide

struct SettingsView<VM: ViewModel>: View
    where VM.State == SettingsViewState,
          VM.Event == SettingsViewEvent,
          VM.VMEvent == SettingsViewModelEvent
{
    @StateObject private var vm: VM
    @Environment(\.dismiss) private var dismiss

    init(vm: VM) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack {
            BaseScreen(showsAmbientBackground: true) {
                ScrollView {
                    VStack(spacing: Spacing.Semantic.sectionSpacing) {
                        profileHeader
                        appearanceCard
                        appInfoCard
                    }
                    .padding(Spacing.Semantic.screenMargin)
                }
            }
            .navigationTitle("SETTINGS.TITLE".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("WORDING_DONE".localized) { dismiss() }
                }
            }
        }
        .onAppear { vm.trigger(.onAppear) }
    }

    private var profileHeader: some View {
        FloatingCard {
            HStack(spacing: Spacing.Semantic.itemSpacing) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.bold(.headline))
                    .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)

                VStack(alignment: .leading, spacing: Spacing.Semantic.groupSpacing) {
                    Text("SETTINGS.PROFILE.TITLE".localized)
                        .font(.semibold(.large))
                        .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                    Text("SETTINGS.PROFILE.SUBTITLE".localized)
                        .font(.regular(.small))
                        .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                }
            }
        }
        .softAppear()
    }

    private var appearanceCard: some View {
        FloatingCard {
            VStack(alignment: .leading, spacing: Spacing.Semantic.itemSpacing) {
                Label {
                    Text("SETTINGS.APPEARANCE.TITLE".localized)
                        .font(.semibold(.body))
                        .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                } icon: {
                    Image(systemName: "paintpalette.fill")
                        .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
                }

                Picker(
                    "SETTINGS.APPEARANCE.TITLE".localized,
                    selection: Binding(
                        get: { vm.state.appearance },
                        set: { vm.trigger(.appearanceSelected($0)) }
                    )
                ) {
                    ForEach(AppAppearance.allCases) { appearance in
                        Label(appearance.localizedTitle, systemImage: appearance.systemImageName)
                            .tag(appearance)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .softAppear(index: 1)
    }

    private var appInfoCard: some View {
        FloatingCard {
            VStack(spacing: Spacing.Semantic.itemSpacing) {
                settingsRow(
                    iconName: "globe",
                    title: "SETTINGS.LANGUAGE.TITLE".localized,
                    value: vm.state.languageName
                )

                Divider()

                settingsRow(
                    iconName: "info.circle.fill",
                    title: "SETTINGS.VERSION.TITLE".localized,
                    value: vm.state.appVersion
                )
            }
        }
        .softAppear(index: 2)
    }

    private func settingsRow(iconName: String, title: String, value: String) -> some View {
        HStack(spacing: Spacing.Semantic.itemSpacing) {
            Image(systemName: iconName)
                .font(.semibold(.body))
                .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
                .frame(
                    width: Spacing.Semantic.minimumTouchTarget,
                    height: Spacing.Semantic.minimumTouchTarget
                )
                .background(
                    Circle().fill(SemanticColor.Colors.primary.swiftUIColor.opacity(0.12))
                )

            Text(title)
                .font(.regular(.body))
                .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)

            Spacer(minLength: Spacing.Semantic.itemSpacing)

            Text(value)
                .font(.regular(.small))
                .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                .multilineTextAlignment(.trailing)
        }
    }
}
