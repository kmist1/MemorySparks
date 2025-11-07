//
//  EditMemoryView.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/3/25.
//


import SwiftUI

struct EditMemoryView: View {
    let memory: Memory
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var viewModel: CaptureViewModel
    @State private var showingSaveAlert = false
    
    init(memory: Memory) {
        self.memory = memory
        viewModel = CaptureViewModel()
        viewModel.loadExistingMemory(memory)
    }
    
    var body: some View {
        NavigationView {
            CaptureView(viewModel: viewModel)
                .navigationTitle("Edit Memory")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            viewModel.saveMemory()
                            dismiss()
                        }
                        .disabled(!viewModel.canSave)
                    }
                }
        }
    }
}
