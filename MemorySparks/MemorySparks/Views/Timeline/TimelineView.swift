//
//  TimelineView.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/3/25.
//


import SwiftUI

struct TimelineView: View {
    @StateObject private var viewModel = TimelineViewModel()
    @State private var showingDeleteAlert = false
    @State private var memoryToDelete: Memory?

    // Break complex view into smaller, type-checker-friendly pieces
    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }

    @ViewBuilder
    private var flashbackSection: some View {
        if let flashback = viewModel.flashback {
            FlashbackBannerView(flashback: flashback) {
                viewModel.selectMemory(flashback.memory)
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var memoriesGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            ForEach(viewModel.memories, id: \.id) { memory in
                MemoryCardView(memory: memory)
                    .onTapGesture {
                        viewModel.selectMemory(memory)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            memoryToDelete = memory
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .padding(.horizontal)
    }

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading memories...")
                } else if viewModel.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Flashback Banner
                            flashbackSection

                            // Memories Grid
                            memoriesGrid
                        }
                        .padding(.top, 8)
                    }
                    .refreshable {
                        viewModel.loadMemories()
                    }
                }
            }
            .navigationTitle("Memories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Streak Badge
                        StreakBadgeView()

                        // Total Count
                        if !viewModel.isEmpty {
                            Text("\(viewModel.totalMemories)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingDetail) {
                if let memory = viewModel.selectedMemory {
                    MemoryDetailView(memory: memory, onDelete: {
                        viewModel.deleteMemory(memory)
                        viewModel.showingDetail = false
                    })
                }
            }
            .alert("Delete Memory", isPresented: $showingDeleteAlert, presenting: memoryToDelete) { memory in
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deleteMemory(memory)
                }
            } message: { memory in
                Text("Are you sure you want to delete this memory? This action cannot be undone.")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), presenting: viewModel.errorMessage) { _ in
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: { message in
                Text(message)
            }
        }
    }
}
