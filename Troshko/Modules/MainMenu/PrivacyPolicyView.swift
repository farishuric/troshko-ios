//
//  PrivacyPolicyView.swift
//  Troshko
//
//  Created by Faris Hurić on 30. 9. 2024..
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        NavigationView {
            VStack {
                List(PrivacyPolicySection.allCases, id: \.self) { section in
                    Section(header: Text(section.title).font(.subheadline)) {
                        Text(section.textDescription)
                            .font(.footnote)
                            .padding(.vertical, 4)
                    }
                }
                .navigationTitle("PRIVACY_POLICY.TITLE".localized)
                .navigationBarTitleDisplayMode(.inline)
                .listStyle(GroupedListStyle())
                
                Text("PRIVACY_POLICY.LAST_UPDATED".localized)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    PrivacyPolicyView()
}
