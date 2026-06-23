import Foundation

enum StyleguideStrings {
    enum Accessibility {
        static let back = StyleguideStrings.tr("Styleguide", "accessibility.back", fallback: "Back")
        static let button = StyleguideStrings.tr("Styleguide", "accessibility.button", fallback: "Button")
        static let card = StyleguideStrings.tr("Styleguide", "accessibility.card", fallback: "Card")
        static let close = StyleguideStrings.tr("Styleguide", "accessibility.close", fallback: "Close")
        static let loading = StyleguideStrings.tr("Styleguide", "accessibility.loading", fallback: "Loading")
        static let menu = StyleguideStrings.tr("Styleguide", "accessibility.menu", fallback: "Menu")
        static let search = StyleguideStrings.tr("Styleguide", "accessibility.search", fallback: "Search")
        static let textfield = StyleguideStrings.tr("Styleguide", "accessibility.textfield", fallback: "Text field")
    }

    enum Button {
        static let add = StyleguideStrings.tr("Styleguide", "button.add", fallback: "Add")
        static let back = StyleguideStrings.tr("Styleguide", "button.back", fallback: "Back")
        static let cancel = StyleguideStrings.tr("Styleguide", "button.cancel", fallback: "Cancel")
        static let close = StyleguideStrings.tr("Styleguide", "button.close", fallback: "Close")
        static let `continue` = StyleguideStrings.tr("Styleguide", "button.continue", fallback: "Continue")
        static let delete = StyleguideStrings.tr("Styleguide", "button.delete", fallback: "Delete")
        static let done = StyleguideStrings.tr("Styleguide", "button.done", fallback: "Done")
        static let edit = StyleguideStrings.tr("Styleguide", "button.edit", fallback: "Edit")
        static let loading = StyleguideStrings.tr("Styleguide", "button.loading", fallback: "Loading...")
        static let next = StyleguideStrings.tr("Styleguide", "button.next", fallback: "Next")
        static let previous = StyleguideStrings.tr("Styleguide", "button.previous", fallback: "Previous")
        static let remove = StyleguideStrings.tr("Styleguide", "button.remove", fallback: "Remove")
        static let reset = StyleguideStrings.tr("Styleguide", "button.reset", fallback: "Reset")
        static let retry = StyleguideStrings.tr("Styleguide", "button.retry", fallback: "Retry")
        static let save = StyleguideStrings.tr("Styleguide", "button.save", fallback: "Save")
        static let submit = StyleguideStrings.tr("Styleguide", "button.submit", fallback: "Submit")
    }

    enum Error {
        static let generic = StyleguideStrings.tr("Styleguide", "error.generic", fallback: "Something went wrong. Please try again.")
        static let network = StyleguideStrings.tr("Styleguide", "error.network", fallback: "Network error. Please try again.")
        static let required = StyleguideStrings.tr("Styleguide", "error.required", fallback: "This field is required")

        enum Invalid {
            static let email = StyleguideStrings.tr("Styleguide", "error.invalid.email", fallback: "Please enter a valid email address")
            static let phone = StyleguideStrings.tr("Styleguide", "error.invalid.phone", fallback: "Please enter a valid phone number")
        }

        enum Password {
            static let mismatch = StyleguideStrings.tr("Styleguide", "error.password.mismatch", fallback: "Passwords do not match")

            enum Too {
                static let short = StyleguideStrings.tr("Styleguide", "error.password.too.short", fallback: "Password must be at least 8 characters")
            }
        }
    }

    enum Success {
        static let deleted = StyleguideStrings.tr("Styleguide", "success.deleted", fallback: "Deleted successfully")
        static let saved = StyleguideStrings.tr("Styleguide", "success.saved", fallback: "Saved successfully")
        static let sent = StyleguideStrings.tr("Styleguide", "success.sent", fallback: "Sent successfully")
        static let updated = StyleguideStrings.tr("Styleguide", "success.updated", fallback: "Updated successfully")
    }

    enum Textfield {
        enum Placeholder {
            static let comment = StyleguideStrings.tr("Styleguide", "textfield.placeholder.comment", fallback: "Add a comment...")
            static let email = StyleguideStrings.tr("Styleguide", "textfield.placeholder.email", fallback: "Enter your email")
            static let message = StyleguideStrings.tr("Styleguide", "textfield.placeholder.message", fallback: "Type your message...")
            static let name = StyleguideStrings.tr("Styleguide", "textfield.placeholder.name", fallback: "Enter your name")
            static let password = StyleguideStrings.tr("Styleguide", "textfield.placeholder.password", fallback: "Enter your password")
            static let phone = StyleguideStrings.tr("Styleguide", "textfield.placeholder.phone", fallback: "Enter your phone number")
            static let search = StyleguideStrings.tr("Styleguide", "textfield.placeholder.search", fallback: "Search...")
        }
    }
}

private extension StyleguideStrings {
    static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
        let format = Bundle.module.localizedString(forKey: key, value: value, table: table)
        return String(format: format, locale: Locale.current, arguments: args)
    }
}
