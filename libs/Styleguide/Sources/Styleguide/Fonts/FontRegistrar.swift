import CoreText
import Foundation

public enum FontRegistrar {
    public static func registerFonts() {
        let fontURLs = Bundle.module.urls(forResourcesWithExtension: "ttf", subdirectory: "Fonts")
            ?? Bundle.module.urls(forResourcesWithExtension: "ttf", subdirectory: nil)
            ?? []

        for url in fontURLs {
            _ = CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
