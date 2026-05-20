//
//  BackupView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 20.05.26.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct BackupView: View {
    @State var viewModel: BackupViewModel
    @State private var showFileImporter = false
    @State private var showImportConfirmation = false

    var body: some View {
        List {
            Section {
                Button {
                    Task { await viewModel.export() }
                } label: {
                    Label("Export data", systemImage: "square.and.arrow.up")
                }
                .disabled(viewModel.isExporting)

                Button {
                    showImportConfirmation = true
                } label: {
                    Label("Import data", systemImage: "square.and.arrow.down")
                }
                .disabled(viewModel.isImporting)
            } footer: {
                Text(
                    "Export saves all workouts and exercises to a JSON file. Import restores them from a previously exported file."
                )
            }
        }
        .navigationTitle("Backup")
        .shareSheet(
            url: $viewModel.exportURL,
            onDismiss: {
                viewModel.clearExportURL()
            }
        )
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.json]
        ) { result in
            switch result {
            case .success(let url):
                Task { await viewModel.importBackup(from: url) }
            case .failure(let error):
                print("Import error: \(error)")
            }
        }
        .confirmationDialog(
            "Import data",
            isPresented: $showImportConfirmation
        ) {
            Button("Import", role: .destructive) {
                showFileImporter = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                "Existing data will not be deleted. Duplicate entries may appear if you import the same file twice."
            )
        }
        .alert("Import successful", isPresented: $viewModel.importSuccess) {
            Button("OK") {}
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.clearError() } }
            )
        ) {
            Button("OK") {}
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
    }
}

extension View {
    func shareSheet(url: Binding<URL?>, onDismiss: @escaping () -> Void) -> some View {
        sheet(item: Binding(
            get: { url.wrappedValue.map { IdentifiableURL(url: $0) } },
            set: { if $0 == nil { url.wrappedValue = nil } }
        )) { identifiable in
            ShareSheet(url: identifiable.url, onDismiss: onDismiss)
        }
    }
}

private struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

private struct ShareSheet: UIViewControllerRepresentable {
    let url: URL
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        controller.completionWithItemsHandler = { _, _, _, _ in
            onDismiss()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
//
//#Preview {
//    BackupView(
//        viewModel: BackupViewModel(
//            backupService: BackupService(),
//            workoutRepository: MockWorkoutRepository(),
//            exerciseRepository: MockExerciseRepository()
//        )
//    )
//}
