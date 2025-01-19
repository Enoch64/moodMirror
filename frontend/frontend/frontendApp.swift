//
//  frontendApp.swift
//  frontend
//
//  Created by Eunsong on 2025-01-18.
//

import SwiftUI

@main
struct frontendApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 115/255, green: 125/255, blue: 254/255),
                            Color(red: 255/255, green: 202/255, blue: 201/255)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .edgesIgnoringSafeArea(.all)
                .navigationTitle("Mood Mirror")
        }
    }
}
