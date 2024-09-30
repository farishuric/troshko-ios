//
//  SettingsView.swift
//  Troshko
//
//  Created by Faris Hurić on 15. 9. 2024..
//

import SwiftUI

struct MainMenuView: View {
    @State private var isICloudBackupEnabled = false
    @State private var selectedAppearance = "Follow System"
    @State private var selectedLanguage = "English"
    @State private var selectedCurrency = "USD"
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Settings")) {
                    // Appearance
                    Picker("Appearance", selection: $selectedAppearance) {
                        Text("Light").tag("Light")
                        Text("Dark").tag("Dark")
                        Text("Follow System").tag("Follow System")
                    }
                    .pickerStyle(.navigationLink)
                    
                    // Language
                    Picker("Language", selection: $selectedLanguage) {
                        Text("English").tag("English")
                        Text("Bosnian").tag("Bosnian") // Add more as needed
                    }
                    .pickerStyle(.navigationLink)
                    
                    // Currency
                    Picker("Currency", selection: $selectedCurrency) {
                        Text("USD").tag("USD")
                        Text("EUR").tag("EUR")
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section(header: Text("Privacy")) {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Text("Privacy Policy")
                    }
                }
                
                Section {
                    Toggle(isOn: $isICloudBackupEnabled) {
                        VStack(alignment: .leading) {
                            HStack {
                                Image("icloud-icon")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                Text("Save Data to iCloud")
                            }
                        }
                    }
                }
            }

        }
    }
}

#Preview {
    MainMenuView()
}
