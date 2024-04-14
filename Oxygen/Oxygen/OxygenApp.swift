//
//  OxygenApp.swift
//  Oxygen
//
//  Created by Haolun Yang on 2/3/24.
//

import SwiftUI

@main
struct OxygenApp: App {
    @StateObject private var viewModel = NotesViewModel()
    @State private var isAddingNote = true
    
    @State private var immersionMode: ImmersionStyle = .progressive
    
    var body: some Scene {
        WindowGroup(id: "content") {
            ContentView()
                .frame(width: 660, height: 580)
                .fixedSize()
        }
        .defaultSize(width: 660, height: 580)
        .windowStyle(.plain)
        .windowResizability(.contentSize)
        
        WindowGroup(id: "note") {
            NoteView(isPresented: .constant(true))
                .environmentObject(viewModel)
        }
        .defaultSize(width: 300, height: 300)
        
        WindowGroup(id: "history") {
            HistoryView()
                .environmentObject(viewModel)
        }
        .defaultSize(width: 400, height: 400)
        
        ImmersiveSpace (id: "immersive") {
            ImmersiveView()
        }
        .immersionStyle(selection: $immersionMode, in: .progressive)
    }
}
