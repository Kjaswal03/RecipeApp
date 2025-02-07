//
//  EndpointManager.swift
//  RecipeApp
//
//  Created by Kashev Jaswal on 2/3/25.
//

import Foundation

struct RecipeResponse: Codable {
    let recipes: [Recipe]
}

struct Recipe: Codable, Identifiable, Equatable {
    let id = UUID()
    let cuisine: String
    let name: String
    let photoUrlLarge: String?
    let photoUrlSmall: String?
    let uuid: String 
    let sourceUrl: String?
    let youtubeUrl: String?

    enum CodingKeys: String, CodingKey {
        case cuisine, name
        case photoUrlLarge = "photo_url_large"
        case photoUrlSmall = "photo_url_small"
        case uuid, sourceUrl = "source_url"
        case youtubeUrl = "youtube_url"
    }
}

class RecipeManager {
    
    let apiEndpoint = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json"

    func fetchRecipes(from urlString: String) async throws -> [Recipe] {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        
        do {
            let response = try decoder.decode(RecipeResponse.self, from: data)
            
            // Check for empty data
            if response.recipes.isEmpty {
                throw RecipeError.emptyData // This is thrown correctly
            }
            
            // Return the recipes if not empty
            return response.recipes
        } catch let error as RecipeError {
            // Catch RecipeError.emptyData and rethrow it
            throw error
        } catch let error as DecodingError {
            // Catch JSON decoding errors and treat them as malformed data
            print("Decoding Error: \(error)")
            throw RecipeError.malformedData
        } catch {
            // Catch any other unexpected errors
            print("Unexpected Error: \(error)")
            throw RecipeError.malformedData
        }
    }

    enum RecipeError: Error, LocalizedError {
        case malformedData
        case emptyData

        var errorDescription: String? {
            switch self {
            case .malformedData:
                return "The recipe data is malformed and cannot be displayed."
            case .emptyData:
                return "No recipes are available at the moment."
            }
        }
    }
}
