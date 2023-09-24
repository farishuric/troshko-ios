//
//  EmptyStateView.swift
//  Troshko
//
//  Created by Faris Hurić on 24. 9. 2023..
//

import SwiftUI

struct EmptyStateView: View {
    var systemImage: String
    var text: String
    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            Spacer().frame(height: 16)
            Text(text)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

struct EmptyListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(systemImage: "Test", text: "doc.text")
    }
}
