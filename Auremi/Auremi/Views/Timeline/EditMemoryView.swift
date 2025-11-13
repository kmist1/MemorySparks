//
//  EditMemoryView.swift
//  Auremi
//
//  Created by Krunal Mistry on 11/3/25.
//


import SwiftUI

struct EditMemoryView: View {
    
    @Environment(\.dismiss) var dismiss
    private var viewModel: CaptureViewModel
    @State private var showingSaveAlert = false
    
    init(viewModel: CaptureViewModel) {
        self.viewModel = viewModel
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
