//
//  ImageData.swift
//  GiphyAppInterview
//
//  Created by Evi St on 6/15/22.
//

import Foundation



struct ImageData: Decodable {
    struct Data: Decodable {
        var id: String {
            return UUID().uuidString
        }
        let username: String
        let images: ImageData.Image
    }
    let data: [ImageData.Data]
    
    struct Image: Decodable {
        let downsized: ImageData.Downsized
    }
    
    struct Downsized: Decodable {
        let url: String
    }

    
}

