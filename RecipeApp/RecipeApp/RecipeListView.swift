//
//  RecipeListView.swift
//  RecipeApp
//
//  Created by Kashev Jaswal on 2/5/25.
//

import SwiftUI

class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var errorMessage: String? = nil

    private let recipeService = RecipeManager()

    func fetchRecipes() async {
        // Reset error message before fetching new data
        DispatchQueue.main.async {
            self.errorMessage = nil
        }

        do {
            let fetchedRecipes = try await recipeService.fetchRecipes(from: RecipeManager().apiEndpoint)
            DispatchQueue.main.async {
                self.recipes = fetchedRecipes
                self.errorMessage = nil // Clear any previous error
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.recipes = [] // Clear the recipes list
            }
        }
    }
}

struct RecipeListView: View {
    @StateObject private var viewModel = RecipeViewModel()

    var body: some View {
        NavigationView {
            Group {
                if let errorMessage = viewModel.errorMessage {
                    errorView(errorMessage: errorMessage)
                } else if viewModel.recipes.isEmpty {
                    emptyStateView()
                } else {
                    recipeListView()
                }
            }
            .navigationTitle("Recipes")
            .toolbarBackground(Color.blue, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                Button(action: {
                    Task {
                        await viewModel.fetchRecipes()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.black)
                }
            }
        }
    }

    // Error View
    private func errorView(errorMessage: String) -> some View {
        VStack(spacing: 16) {
            Text("Error")
                .font(.headline)
                .foregroundColor(.red)
            Text(errorMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button("Retry") {
                Task {
                    await viewModel.fetchRecipes()
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
    }

    // Empty State View
    private func emptyStateView() -> some View {
        VStack {
            Text("No recipes available.")
                .font(.headline)
                .foregroundColor(.primary)
            Text("Please check back later.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
    }

    // Recipe List View
    private func recipeListView() -> some View {
        List(viewModel.recipes) { recipe in
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(recipe.cuisine)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                ImageLoader.CachedImage(url: recipe.photoUrlSmall ?? "")
                    .frame(height: 200)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding(.vertical, 8)
            .listRowBackground((viewModel.recipes.firstIndex(of: recipe) ?? 0) % 2 == 0 ? Color.white : Color(.systemGray6))
        }
        .listStyle(.plain)
    }
}
