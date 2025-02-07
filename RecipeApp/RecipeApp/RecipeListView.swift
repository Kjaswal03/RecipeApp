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
                    // Display error message
                    VStack {
                        Text("Error")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                        Button("Retry") {
                            Task {
                                await viewModel.fetchRecipes()
                            }
                        }
                    }
                } else if viewModel.recipes.isEmpty {
                    // Display empty state
                    Text("No recipes available.")
                        .font(.headline)
                } else {
                    // Display recipe list
                    List(viewModel.recipes) { recipe in
                        VStack(alignment: .leading) {
                            Text(recipe.name)
                                .font(.headline)
                            Text(recipe.cuisine)
                                .font(.subheadline)
                            ImageLoader.CachedImage(url: recipe.photoUrlSmall ?? "")
                                .frame(height: 200)
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .toolbar {
                Button(action: {
                    Task {
                        await viewModel.fetchRecipes()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
}

