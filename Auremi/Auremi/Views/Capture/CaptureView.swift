//
//  CaptureView.swift
//  Auremi
//
//  Created by Krunal Mistry on 11/1/25.
//

import SwiftUI
import PhotosUI

struct CaptureView: View {
    private var viewModel = CaptureViewModel()
    @State private var showingPhotoOptions = false

    init(viewModel: CaptureViewModel = CaptureViewModel(), showingPhotoOptions: Bool = false) {
        self.viewModel = viewModel
        self.showingPhotoOptions = showingPhotoOptions
    }
    var body: some View {
        NavigationView {
            CaptureViewContent(viewModel: viewModel)
                .navigationTitle(viewModel.isEditingExisting ? "Edit" : "Today's Memory")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Reusable Content View
struct CaptureViewContent: View {
    @ObservedObject var viewModel: CaptureViewModel
    @State private var showingPhotoOptions = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Photo Section
                    photoSection

                    // Text Input Section
                    textInputSection

                    // Save Button
                    saveButton

                    Spacer(minLength: 40)
                }
                .padding()
            }

            // Confetti Overlay
            if viewModel.showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }

            // Loading Overlay
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .sheet(isPresented: $viewModel.showingImagePicker) {
            ImagePicker(image: $viewModel.selectedImage)
        }
        .fullScreenCover(isPresented: $viewModel.showingCamera) {
            CameraView(image: $viewModel.selectedImage)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), presenting: viewModel.errorMessage) { _ in
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: { message in
            Text(message)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(DateFormatter.todayString)
                .font(.title2)
                .fontWeight(.semibold)

            Text("What made you smile today?")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var photoSection: some View {
        VStack(spacing: 16) {
            if let image = viewModel.selectedImage {
                // Photo Preview
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 5)

                    // Delete Button
                    Button(action: {
                        viewModel.deletePhoto()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 32, height: 32)
                            )
                    }
                    .padding(12)
                }
            } else {
                // Add Photo Button
                Button(action: {
                    showingPhotoOptions = true
                }) {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)

                        Text("Add Photo")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text("Optional")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .confirmationDialog("Add Photo", isPresented: $showingPhotoOptions) {
                    Button("Take Photo") {
                        viewModel.showingCamera = true
                    }
                    Button("Choose from Library") {
                        viewModel.showingImagePicker = true
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
        }
    }

    private var textInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Your Memory")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.entryText.count)/\(AppConstants.maxTextLength)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            TextEditor(text: $viewModel.entryText)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .onChange(of: viewModel.entryText) { _,newValue in
                    // Limit text length
                    if newValue.count > AppConstants.maxTextLength {
                        viewModel.entryText = String(newValue.prefix(AppConstants.maxTextLength))
                    }
                }
        }
    }

    private var saveButton: some View {
        Button(action: {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            viewModel.saveMemory()
        }) {
            HStack {
                Image(systemName: viewModel.isEditingExisting ? "checkmark.circle.fill" : "sparkles")
                Text(viewModel.isEditingExisting ? "Update Memory" : "Save Memory")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.canSave ? AppConstants.Colors.primary : Color.secondary)
            .foregroundColor(Color.orange.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!viewModel.canSave)
    }
}
