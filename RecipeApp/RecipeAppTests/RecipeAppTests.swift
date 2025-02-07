//
//  RecipeAppTests.swift
//  RecipeAppTests
//
//  Created by Kashev Jaswal on 2/3/25.
//

import Testing
import XCTest
@testable import RecipeApp

// Tests using different endpoints

class RecipeManagerTests: XCTestCase {
    
    var recipeManager: RecipeManager!
    
    override func setUpWithError() throws {
        recipeManager = RecipeManager()
    }
    
    override func tearDownWithError() throws {
        recipeManager = nil
    }
    
    // Test functional data endpoint
    func testFunctionalDataEndpoint() async throws {
        let functionalEndpoint = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
        
        do {
            let recipes = try await recipeManager.fetchRecipes(from: functionalEndpoint)
            
            // Check if recipes are fetched and displayed correctly
            XCTAssertFalse(recipes.isEmpty, "Recipes should not be empty")
            
            for recipe in recipes {
                XCTAssertNotNil(recipe.name, "Recipe name should not be nil")
                XCTAssertNotNil(recipe.cuisine, "Cuisine type should not be nil")
                XCTAssertNotNil(recipe.uuid, "Recipe uuid should not be nil")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    
    // Test empty data endpoint
    func testEmptyDataEndpoint() async throws {
        let emptyEndpoint = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json"
        
        do {
            let recipes = try await recipeManager.fetchRecipes(from: emptyEndpoint)
            XCTFail("Expected empty data error, but got recipes: \(recipes)")
        } catch RecipeManager.RecipeError.emptyData {
            // This is expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // Test malformed data endpoint
    func testMalformedDataEndpoint() async throws {
        let malformedEndpoint = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json"
        
        do {
            let recipes = try await recipeManager.fetchRecipes(from: malformedEndpoint)
            XCTFail("Expected malformed data error, but got recipes: \(recipes)")
        } catch RecipeManager.RecipeError.malformedData {
            // This is expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
