//
//  MemoryDetailView.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/3/25.
//


import SwiftUI

struct MemoryDetailView: View {
    @State var memory: Memory
    let onDelete: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var image: UIImage?
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    @State private var showingShareSheet = false
    @ObservedObject private var viewModel: CaptureViewModel

    init(memory: Memory, onDelete: @escaping () -> Void) {
        self.memory = memory
        self.onDelete = onDelete
        self.viewModel = CaptureViewModel(existingMemory: memory)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Date Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(DateFormatter.relativeDate(from: memory.date ?? Date()))
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(DateFormatter.shortDate(from: memory.date ?? Date()))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Photo
                    if let uiImage = image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 5)
                            .padding(.horizontal)
                    } else if memory.hasPhoto {
                        ZStack {
                            Color(.systemGray5)
                            ProgressView()
                        }
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                    }
                    
                    // Text Content
                    if let text = memory.text, !text.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Memory")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(text)
                                .font(.body)
                                .lineSpacing(4)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
            .navigationTitle("Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingEditView = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button {
                            showingShareSheet = true
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditView) {
                EditMemoryView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingShareSheet) {
                if let shareText = createShareText() {
                    ShareSheet(items: [shareText])
                }
            }
            .alert("Delete Memory", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            } message: {
                Text("Are you sure you want to delete this memory? This action cannot be undone.")
            }
        }
        .onAppear {
            if let existingMemory = viewModel.getExistingMemory() {
                self.memory = existingMemory
            }
            loadImage()
        }
        .onChange(of: viewModel.isMemoryUpdated) { _, _ in
            loadImage()
        }
    }
    
    private func loadImage() {

        guard let filename = memory.photoFilename else { return }

        DispatchQueue.global(qos: .userInitiated).async {
            if let loadedImage = PhotoStorageManager.shared.loadPhoto(filename: filename) {
                DispatchQueue.main.async {
                    self.image = loadedImage
                }
            }
        }
    }
    
    private func createShareText() -> String? {
        var text = "✨ Memory from \(DateFormatter.shortDate(from: memory.date ?? Date()))\n\n"
        
        if let memoryText = memory.text {
            text += memoryText
        }
        
        text += "\n\n— Captured with MemorySpark"
        
        return text
    }
}
