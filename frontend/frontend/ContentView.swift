//
//  ContentView.swift
//  frontend
//
//  Created by Eunsong on 2025-01-18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        macOSSpecificView()
//        #if os(iOS)
//        iOSSpecificView()
//        #elseif os(macOS)
//        #else
//        Text("Unsupported platform")
//        #endif
    }
}

#Preview {
    ContentView()
}
