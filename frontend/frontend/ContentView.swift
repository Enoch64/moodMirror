//
//  ContentView.swift
//  frontend
//
//  Created by Eunsong on 2025-01-18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        LiveCameraPage().tabItem{
            Image(systemName: "house.fill")
            Text("Home")
        }
        
        CallPage().tabItem{
            Image(systemName: "camera.fill")
            Text("Call Page")
        }
        
    }
}

struct LiveCameraPage: View {
    var body: some View {
        VStack {
            Text("Live Camera Mode")
                .font(.title)
            Button(action: {
                print("First Page Button clicked!")
            }) {
                Text("Go to First Page Details")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
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
    }
}

#Preview {
    ContentView()
}
