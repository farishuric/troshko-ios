import AuthenticationServices
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
    @State private var isConfirmingDeleteAccount = false

    init(vm: VM) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack {
            BaseScreen(showsAmbientBackground: true) {
                ScrollView {
                    VStack(spacing: Spacing.Semantic.sectionSpacing) {
                        profileHeader
                        accountCard
                        if DemoDataConfiguration.isEnabled {
                            demoDataCard
                        }
                        appearanceCard
                        languageCard
                        appInfoCard
                    }
                    .padding(Spacing.Semantic.screenMargin)
                }
            }
            .navigationTitle("SETTINGS.TITLE".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.semibold(.body))
                            .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                            .frame(
                                width: Spacing.Semantic.minimumTouchTarget,
                                height: Spacing.Semantic.minimumTouchTarget
                            )
                    }
                    .accessibilityLabel("WORDING_CLOSE".localized)
                }
            }
        }
        .onAppear { vm.trigger(.onAppear) }
        .alert("SETTINGS.ACCOUNT.DELETE_TITLE".localized, isPresented: $isConfirmingDeleteAccount) {
            Button("WORDING_CANCEL".localized, role: .cancel) {}
            Button("SETTINGS.ACCOUNT.DELETE_ACTION".localized, role: .destructive) {
                vm.trigger(.deleteAccount)
            }
        } message: {
            Text("SETTINGS.ACCOUNT.DELETE_MESSAGE".localized)
        }
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

    private var accountCard: some View {
        FloatingCard {
            VStack(alignment: .leading, spacing: Spacing.Semantic.itemSpacing) {
                Label {
                    Text("SETTINGS.ACCOUNT.TITLE".localized)
                        .font(.semibold(.body))
                        .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                } icon: {
                    Image(systemName: "person.badge.key.fill")
                        .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
                }

                switch vm.state.account {
                case .signedOut:
                    signedOutContent
                case .signedIn(let displayName, let email):
                    signedInContent(displayName: displayName, email: email)
                }

                if let message = vm.state.accountErrorMessage {
                    errorText(message)
                }

                if let message = vm.state.subscriptionErrorMessage {
                    errorText(message)
                }
            }
        }
        .softAppear(index: 1)
    }

    private var signedOutContent: some View {
        VStack(alignment: .leading, spacing: Spacing.Semantic.itemSpacing) {
            Text("SETTINGS.ACCOUNT.SIGNED_OUT_MESSAGE".localized)
                .font(.regular(.small))
                .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                handleSignIn(result)
            }
            .frame(height: Spacing.Semantic.buttonHeight)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.Semantic.cornerRadiusMedium))
            .disabled(vm.state.isAccountLoading)
            .opacity(vm.state.isAccountLoading ? 0.55 : 1)
        }
    }

    private func signedInContent(displayName: String, email: String?) -> some View {
        VStack(spacing: Spacing.Semantic.itemSpacing) {
            settingsRow(
                iconName: "person.crop.circle.fill",
                title: "SETTINGS.ACCOUNT.SIGNED_IN".localized,
                value: displayName
            )

            if let email {
                settingsRow(
                    iconName: "envelope.fill",
                    title: "SETTINGS.ACCOUNT.EMAIL".localized,
                    value: email
                )
            }

            Divider()

            settingsRow(
                iconName: vm.state.subscription.isPremiumActive ? "crown.fill" : "crown",
                title: "SETTINGS.SUBSCRIPTION.TITLE".localized,
                value: vm.state.subscription.statusText
            )

            if !vm.state.subscription.isPremiumActive {
                subscriptionOffer
            }

            Button("SETTINGS.SUBSCRIPTION.RESTORE".localized) {
                vm.trigger(.restorePurchases)
            }
            .font(.semibold(.body))
            .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
            .frame(maxWidth: .infinity, minHeight: Spacing.Semantic.minimumTouchTarget)
            .disabled(vm.state.isAccountLoading)

            Divider()

            Button("SETTINGS.ACCOUNT.SIGN_OUT".localized) {
                vm.trigger(.signOut)
            }
            .font(.semibold(.body))
            .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
            .frame(maxWidth: .infinity, minHeight: Spacing.Semantic.minimumTouchTarget)
            .disabled(vm.state.isAccountLoading)

            Button("SETTINGS.ACCOUNT.DELETE_ACTION".localized) {
                isConfirmingDeleteAccount = true
            }
            .font(.semibold(.body))
            .foregroundStyle(SemanticColor.Colors.textError.swiftUIColor)
            .frame(maxWidth: .infinity, minHeight: Spacing.Semantic.minimumTouchTarget)
            .disabled(vm.state.isAccountLoading)
        }
    }

    private var subscriptionOffer: some View {
        VStack(alignment: .leading, spacing: Spacing.Semantic.groupSpacing) {
            if let product = vm.state.subscription.product {
                Text(product.title)
                    .font(.semibold(.body))
                    .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                Text(product.description)
                    .font(.regular(.small))
                    .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                Text(product.price)
                    .font(.semibold(.large))
                    .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
            } else {
                Text("SETTINGS.SUBSCRIPTION.PRODUCT_UNAVAILABLE".localized)
                    .font(.regular(.small))
                    .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
            }

            PrimaryButton(isLoading: vm.state.isAccountLoading) {
                vm.trigger(.purchasePremium)
            } label: {
                Text("SETTINGS.SUBSCRIPTION.SUBSCRIBE".localized)
            }
            .disabled(vm.state.subscription.product == nil || vm.state.isAccountLoading)
        }
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
        .softAppear(index: 3)
    }

    private var demoDataCard: some View {
        FloatingCard {
            VStack(alignment: .leading, spacing: Spacing.Semantic.itemSpacing) {
                Label {
                    Text("SETTINGS.DEMO_DATA.TITLE".localized)
                        .font(.semibold(.body))
                        .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                } icon: {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
                }

                Text("SETTINGS.DEMO_DATA.MESSAGE".localized)
                    .font(.regular(.small))
                    .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                    .fixedSize(horizontal: false, vertical: true)

                PrimaryButton(isLoading: vm.state.isDemoDataLoading) {
                    vm.trigger(.seedDemoData)
                } label: {
                    Text("SETTINGS.DEMO_DATA.ACTION".localized)
                }
                .disabled(vm.state.isDemoDataLoading)

                if let message = vm.state.demoDataMessage {
                    Text(message)
                        .font(.regular(.small))
                        .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .softAppear(index: 2)
    }

    private var appInfoCard: some View {
        FloatingCard {
            VStack(spacing: Spacing.Semantic.itemSpacing) {
                settingsRow(
                    iconName: "info.circle.fill",
                    title: "SETTINGS.VERSION.TITLE".localized,
                    value: vm.state.appVersion
                )
            }
        }
        .softAppear(index: 5)
    }

    private var languageCard: some View {
        FloatingCard {
            VStack(alignment: .leading, spacing: Spacing.Semantic.itemSpacing) {
                Label {
                    Text("SETTINGS.LANGUAGE.TITLE".localized)
                        .font(.semibold(.body))
                        .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                } icon: {
                    Image(systemName: "globe")
                        .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
                }

                VStack(spacing: Spacing.Semantic.groupSpacing) {
                    ForEach(AppLanguage.allCases) { language in
                        Button {
                            vm.trigger(.languageSelected(language))
                        } label: {
                            languageRow(language)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(language.localizedTitle)
                        .accessibilityAddTraits(vm.state.language == language ? .isSelected : [])
                    }
                }
            }
        }
        .softAppear(index: 4)
    }

    private func languageRow(_ language: AppLanguage) -> some View {
        HStack(spacing: Spacing.Semantic.itemSpacing) {
            ZStack {
                Circle()
                    .fill(SemanticColor.Colors.primary.swiftUIColor.opacity(0.10))
                    .shadow(
                        color: SemanticColor.Colors.primary.swiftUIColor.opacity(0.22),
                        radius: Spacing.Semantic.shadowRadius,
                        x: Spacing.Semantic.shadowOffset.width,
                        y: Spacing.Semantic.shadowOffset.height
                    )

                Image(language.flagAssetName)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: Spacing.Semantic.itemSpacing,
                        height: Spacing.Semantic.itemSpacing
                    )
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(
                            SemanticColor.Colors.plainWhite.swiftUIColor.opacity(0.82),
                            lineWidth: Spacing.Semantic.borderWidth
                        )
                    )
            }
            .frame(
                width: Spacing.Semantic.minimumTouchTarget,
                height: Spacing.Semantic.minimumTouchTarget
            )
            .overlay(
                Circle().stroke(
                    SemanticColor.Colors.primary.swiftUIColor.opacity(vm.state.language == language ? 0.42 : 0.18),
                    lineWidth: Spacing.Semantic.borderWidth
                )
            )

            VStack(alignment: .leading, spacing: Spacing.Semantic.groupSpacing) {
                Text(language.localizedTitle)
                    .font(.regular(.body))
                    .foregroundStyle(SemanticColor.Colors.textPrimary.swiftUIColor)
                Text(language.nativeTitle)
                    .font(.regular(.small))
                    .foregroundStyle(SemanticColor.Colors.textSecondary.swiftUIColor)
            }

            Spacer(minLength: Spacing.Semantic.itemSpacing)

            if vm.state.language == language {
                Image(systemName: "checkmark.circle.fill")
                    .font(.semibold(.body))
                    .foregroundStyle(SemanticColor.Colors.primary.swiftUIColor)
            }
        }
        .frame(minHeight: Spacing.Semantic.minimumTouchTarget)
        .padding(Spacing.Semantic.componentMargin)
        .background(
            RoundedRectangle(cornerRadius: Spacing.Semantic.cornerRadiusMedium)
                .fill(
                    vm.state.language == language
                    ? SemanticColor.Colors.primary.swiftUIColor.opacity(0.12)
                    : SemanticColor.Colors.backgroundSecondary.swiftUIColor.opacity(0.55)
                )
        )
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

    private func errorText(_ message: String) -> some View {
        Text(message)
            .font(.regular(.small))
            .foregroundStyle(SemanticColor.Colors.textError.swiftUIColor)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func handleSignIn(_ result: Result<ASAuthorization, Error>) {
        guard case .success(let authorization) = result,
              let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            vm.trigger(.signInWithAppleFailed)
            return
        }

        let formatter = PersonNameComponentsFormatter()
        let displayName = credential.fullName.map { formatter.string(from: $0) }
            .flatMap { $0.isEmpty ? nil : $0 }

        vm.trigger(
            .signInWithAppleCompleted(
                SignInWithApplePayload(
                    userIdentifier: credential.user,
                    identityToken: credential.identityToken.flatMap { String(data: $0, encoding: .utf8) },
                    authorizationCode: credential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) },
                    email: credential.email,
                    displayName: displayName
                )
            )
        )
    }
}
