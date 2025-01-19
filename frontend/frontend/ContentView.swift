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
//        #elseif os(iOS)
//        iOSSpecificView()
        #else
        Text("Unsupported platform")
        #endif
    }
}

#Preview {
    ContentView()
}
