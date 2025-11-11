//
//  ErrorBanner.swift
//  BobTheBuilder
//
//  Reusable error banner component with retry action
//

import SwiftUI

struct ErrorBanner: View {
    let error: Error
    let retryAction: (() async -> Void)?

    @State private var isRetrying = false

    init(error: Error, retryAction: (() async -> Void)? = nil) {
        self.error = error
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(.red)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Error")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            if let retryAction = retryAction {
                HStack {
                    Spacer()
                    Button {
                        Task {
                            await retry()
                        }
                    } label: {
                        if isRetrying {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .scaleEffect(0.8)
                                Text("Retrying...")
                            }
                        } else {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Retry")
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isRetrying)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color.red.opacity(0.1),
                    Color.red.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }

    private var errorMessage: String {
        if let apiError = error as? APIError {
            switch apiError {
            case .unauthorized:
                return "You don't have permission to perform this action"
            case .networkError:
                return "Network connection error. Check your internet connection"
            case .serverError(let message):
                return message
            case .decodingError:
                return "Failed to process server response"
            default:
                return apiError.errorDescription ?? "An error occurred"
            }
        }
        return error.localizedDescription
    }

    private func retry() async {
        guard let retryAction = retryAction else { return }
        isRetrying = true
        await retryAction()
        isRetrying = false
    }
}

// MARK: - Preview


