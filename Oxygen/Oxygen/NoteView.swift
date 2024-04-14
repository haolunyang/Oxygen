//
//  NoteView.swift
//  Oxygen
//
//  Created by Haolun Yang on 2/3/24.
//

import SwiftUI

struct NoteView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    @Environment(\.dismissWindow) private var dismissWindow
    
    @AppStorage("prompt") var prompt = ""
    
    @State private var brainSymbol = "brain"
    @State private var note = ""
    
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            TextEditor(text: $note)
                .font(.title3)
                .toolbar {
                    ToolbarItem(placement: .bottomOrnament) {
                        Button {
                            prompt += "- " + note + "\n"
                            
                            brainSymbol = "checkmark.circle.fill"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                brainSymbol = "brain"
                            }
                        } label: {
                            HStack {
                                Image(systemName: brainSymbol)
                                    .contentTransition(.symbolEffect(.replace))
                            }
                            .frame(width: 30, height: 30)
                            .help("Add the thought as a bullet point")
                        }
                        .buttonBorderShape(.circle)
                    }
                }
                .onDisappear {
                    if !note.isEmpty {
                        viewModel.addNote(content: note)
                    }
                    isPresented = false
                }
        }
        .clipShape(.rect(cornerRadius: 30, style: .continuous))
        .padding(20)
    }
}
