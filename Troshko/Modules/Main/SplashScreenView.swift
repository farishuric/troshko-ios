//
//  SplashScreenView.swift
//  Troshko
//
//  Created by Assistant
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.5
    
    var body: some View {
        if isActive {
            MainView()
        } else {
            VStack {
                Image("troshko_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.scale = 1.0
                            self.opacity = 1.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                self.isActive = true
                            }
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("main"))
            .ignoresSafeArea()
        }
    }
}

#Preview {
    SplashScreenView()
}
