//
//
//  AppTextField.swift
//  Styleguide
//
//  Created by Fare
//

import SwiftUI

public struct AppTextField: View {

    // MARK: - Types

    public enum FieldType {
        case text
        case email
        case password
    }

    public enum ValidationState {
        case none
        case error
    }

    // MARK: - Properties

    private let title: LocalizedStringKey
    private let placeholder: LocalizedStringKey
    @Binding private var text: String
    private let type: FieldType
    private let validation: ValidationState
    private let errorMessage: String?
    private let focus: FocusState<Bool>.Binding?
    private let submitLabel: SubmitLabel
    private let onSubmit: () -> Void

    @FocusState private var isFocused: Bool
    @State private var isSecureVisible: Bool = false

    private let cornerRadius: CGFloat
    private let padding: CGFloat
    private let backgroundColor: Color

    // MARK: - Init

    public init(
        title: LocalizedStringKey,
        placeholder: LocalizedStringKey,
        text: Binding<String>,
        type: FieldType = .text,
        validation: ValidationState = .none,
        errorMessage: String? = nil,
        focus: FocusState<Bool>.Binding? = nil,
        submitLabel: SubmitLabel = .return,
        onSubmit: @escaping () -> Void = {},
        cornerRadius: CGFloat = Spacing.Semantic.cornerRadiusLarge,
        padding: CGFloat = Spacing.Semantic.componentPadding,
        backgroundColor: Color = SemanticColor.Colors.textFieldBG.swiftUIColor
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.type = type
        self.validation = validation
        self.errorMessage = errorMessage
        self.focus = focus
        self.submitLabel = submitLabel
        self.onSubmit = onSubmit
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.backgroundColor = backgroundColor
    }

    // MARK: - Styling

    private var hasError: Bool {
        validation == .error
    }

    private var borderColor: Color {
        if hasError {
            return SemanticColor.Colors.borderError.swiftUIColor
        } else if hasFocus {
            return SemanticColor.Colors.borderFocus.swiftUIColor
        } else {
            return SemanticColor.Colors.borderPrimary.swiftUIColor
        }
    }

    private var borderWidth: CGFloat {
        (hasError || hasFocus) ? 1.5 : 1
    }

    private var glowColor: Color {
        if hasError {
            return SemanticColor.Colors.borderError.swiftUIColor.opacity(0.3)
        } else if hasFocus {
            return SemanticColor.Colors.borderFocus.swiftUIColor.opacity(0.3)
        } else {
            return .clear
        }
    }

    private var glowRadius: CGFloat {
        (hasError || hasFocus) ? 4 : 0
    }

    private var hasFocus: Bool {
        focus?.wrappedValue ?? isFocused
    }

    private var isSecure: Bool {
        type == .password && !isSecureVisible
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                if let focus {
                    inputField.focused(focus)
                } else {
                    inputField.focused($isFocused)
                }

                if type == .password {
                    Button {
                        isSecureVisible.toggle()
                    } label: {
                        Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                            .foregroundStyle(SemanticColor.Colors.borderPrimary.swiftUIColor)
                    }
                }
            }
            .padding(padding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: glowColor, radius: glowRadius)

            if let errorMessage, hasError {
                Text(errorMessage)
                    .font(.regular(.small))
                    .foregroundStyle(SemanticColor.Colors.textError.swiftUIColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: hasFocus)
        .animation(.easeInOut(duration: 0.2), value: hasError)
    }

    private var inputField: some View {
        Group {
            if isSecure {
                SecureField(
                    "",
                    text: $text,
                    prompt: Text(placeholder)
                        .foregroundStyle(SemanticColor.Colors.textFieldPlaceholder.swiftUIColor)
                )
            } else {
                TextField(
                    "",
                    text: $text,
                    prompt: Text(placeholder)
                        .foregroundStyle(SemanticColor.Colors.textFieldPlaceholder.swiftUIColor)
                )
            }
        }
        .foregroundStyle(SemanticColor.Colors.textFieldText.swiftUIColor)
        .tint(SemanticColor.Colors.primary.swiftUIColor)
        .textInputAutocapitalization(type == .email ? .never : .words)
        .keyboardType(type == .email ? .emailAddress : .default)
        .autocorrectionDisabled(type == .email)
        .submitLabel(submitLabel)
        .onSubmit(onSubmit)
    }
}
