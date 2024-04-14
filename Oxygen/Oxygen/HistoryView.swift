//
//  ContentView.swift
//  Oxygen
//
//  Created by Haolun Yang on 2/3/24.
//

import SwiftUI

struct Note: Identifiable, Codable {
    let id: UUID
    var content: String
    var timestamp: Date
}

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    
    init() {
        loadNotes()
    }
    
    func addNote(content: String) {
        let newNote = Note(id: UUID(), content: content, timestamp: Date())
        notes.insert(newNote, at: 0)
        saveNotes()
    }
    
    func deleteNote(at index: Int) {
        notes.remove(at: index)
        saveNotes()
    }
    
    private func saveNotes() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(notes) {
            UserDefaults.standard.set(encodedData, forKey: "notes")
        }
    }
    
    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: "notes") {
            let decoder = JSONDecoder()
            if let decodedNotes = try? decoder.decode([Note].self, from: data) {
                notes = decodedNotes
            }
        }
    }
}

struct HistoryView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    @Environment(\.openWindow) private var openWindow
    @State private var isAddingNote = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.notes) { note in
                    NoteRow(note: note)
                }
                .onDelete(perform: deleteNote)
            }
            .navigationTitle("History")
            .overlay {
                if viewModel.notes.isEmpty {
                    ContentUnavailableView("No History", systemImage: "clock.arrow.circlepath", description: Text("Your closed notes will be archived here."))
                        .symbolVariant(.slash)
                    .offset(y: -30)
                }
            }
        }
    }
    
    private func deleteNote(at offsets: IndexSet) {
        offsets.forEach { index in
            viewModel.deleteNote(at: index)
        }
    }
}

struct NoteRow: View {
    var note: Note
    @State private var copySymbol = "doc.on.doc"

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(note.content)
                    .font(.subheadline)
                Text(note.timestamp, style: .date)
                    .font(.caption)
            }
            Spacer()
            Button {
                copySymbol = "checkmark.circle.fill"
                UIPasteboard.general.string = note.content
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    copySymbol = "doc.on.doc"
                }
            } label: {
                Image(systemName: copySymbol)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonBorderShape(.circle)
            .buttonStyle(.bordered)
        }
    }
}
