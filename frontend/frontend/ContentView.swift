//
//  ContentView.swift
//  frontend
//
//  Created by Eunsong on 2025-01-18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
<<<<<<< HEAD
        #if os(iOS)
        iOSSpecificView()
//        #elseif os(macOS)
//        macOSSpecificView()
        #else
        Text("Unsupported platform")
        #endif
=======
        macOSSpecificView()
//        #if os(iOS)
//        iOSSpecificView()
//        #elseif os(macOS)
//        #else
//        Text("Unsupported platform")
//        #endif
>>>>>>> ml-model
    }
}

#Preview {
    ContentView()
}
