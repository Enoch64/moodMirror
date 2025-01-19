//
//  ContentView.swift
//  frontend
//
//  Created by Eunsong on 2025-01-18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        #if os(macOS)
        macOSSpecificView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 114/255, green: 38/255, blue: 255/255),
                        Color(red: 1/255, green: 0/255, blue: 48/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .edgesIgnoringSafeArea(.all)
        #elseif os(iOS)
        iOSSpecificView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 114/255, green: 38/255, blue: 255/255),
                        Color(red: 1/255, green: 0/255, blue: 48/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .edgesIgnoringSafeArea(.all)
        #else
        Text("Unsupported platform")
        #endif
    }
}

#Preview {
    ContentView()
}
