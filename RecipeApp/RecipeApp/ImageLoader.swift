//
//  ImageLoader.swift
//  RecipeApp
//
//  Created by Kashev Jaswal on 2/5/25.
//

import SwiftUI
import Foundation

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private let url: String
    private var cache: NSCache<NSString, UIImage>?
    
    init(url: String, cache: NSCache<NSString, UIImage>? = nil) {
        self.url = url
        self.cache = cache
    }
    
    func loadImage() async {
        if let cachedImage = cache?.object(forKey: url as NSString){
            image = cachedImage
            return
        }
        guard let imageURL = URL(string: url) else {return}
        do {
            let(data, _) = try await URLSession.shared.data(from: imageURL)
            if let downloadedImage = UIImage(data: data) {
                cache?.setObject(downloadedImage, forKey: url as NSString)
                image = downloadedImage
            }
        } catch {
            print("Error loading image: \(error)")
        }
        
    }
    
    
    struct CachedImage: View {
        @StateObject private var imageLoader: ImageLoader

        init(url: String, cache: NSCache<NSString, UIImage>? = nil) {
            _imageLoader = StateObject(wrappedValue: ImageLoader(url: url, cache: cache))
        }

        var body: some View {
            Group {
                if let image = imageLoader.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    ProgressView()
                }
            }
            .onAppear {
                Task {
                    await imageLoader.loadImage()
                }
            }
        }
    }
}

