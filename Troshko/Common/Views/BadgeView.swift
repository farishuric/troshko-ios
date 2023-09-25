//
//  BadgeView.swift
//  Troshko
//
//  Created by Faris Hurić on 18. 9. 2023..
//

import SwiftUI

struct BadgeView: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundColor(.white)
            .padding(.horizontal, 8) // Adjust the padding as needed
            .padding(.vertical, 4)   // Adjust the padding as needed
            .background(Capsule().fill(Color.blue)) // Adjust the background color
    }
}

struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeView(text: "Test")
    }
}
