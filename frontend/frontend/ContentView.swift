//
//  ContentView.swift
//  frontend
//
//  Created by Eunsong on 2025-01-18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        #if os(iOS)
        iOSSpecificView()
        #elseif os(macOS)
        macOSSpecificView()
        #else
        Text("Unsupported platform")
        #endif
    }
}

#Preview {
    ContentView()
}

struct CallPage: View {
    var body: some View {
        VStack {
            Text("Call Mode")
                .font(.title)
            Button(action: {
                print("Call Mode Page Button clicked!")
            }) {
                Text("Go to Second Page Details")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()

        #if os(iOS)
        iOSSpecificView()
        #elseif os(macOS)
        macOSSpecificView()
        #else
        Text("Unsupported platform")
        #endif
    }
}

#Preview {
    ContentView()
}
