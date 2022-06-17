//
//  GifPresenterRepository.swift
//  GiphyAppInterview
//
//  Created by Evi St on 6/16/22.
//

import Foundation

protocol GifPresenterRepository {
    func getGifs(rating: GifPresenterViewModel.Rating, completion: @escaping (DataResponse<ImageData, ErrorResponse>) -> Void)
    func loadImageData(url: String, completion: @escaping(DataResponse<Data, ErrorResponse>) -> Void)

}

class GifPresenterRepositoryImpl: GifPresenterRepository {
    let networkManager = NetworkManager()
    
    static var shared: GifPresenterRepositoryImpl = .init()
    
    func getGifs(rating: GifPresenterViewModel.Rating, completion: @escaping (DataResponse<ImageData, ErrorResponse>) -> Void) {
        let url = "https://api.giphy.com/v1/gifs/trending?api_key=2ypvRHQFlwl2c4zO7lKsyBddQjzCAzi5&limit=10&rating=\(rating.rawValue)"
        self.networkManager.dataRequest(url: url, method: .get, completion: completion)
    }
    
    func loadImageData(url: String, completion: @escaping(DataResponse<Data, ErrorResponse>) -> Void) {
        self.networkManager.download(url: url, method: .get, completion: completion)
        }

}
