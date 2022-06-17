//
//  GifPresenterViewModel.swift
//  GiphyAppInterview
//
//  Created by Evi St on 6/16/22.
//

import Foundation


class GifPresenterViewModel: ObservableObject {
    private var repository: GifPresenterRepository = GifPresenterRepositoryImpl.shared 
    @Published var ratings: [Rating] = [.general, .parentalGuidance, .parentsStronglyCautioned, .restricted]

    @Published var rating: Rating = .general {
        didSet {
            self.loadGifs()
        }
    }
    @Published var imagesData: [ImageData.Data] = []
    
    init() {
        self.loadGifs()
    }
    
    func loadGifs() {
        self.imagesData.removeAll()
        self.repository.getGifs(rating: self.rating) { response in
            switch response {
            case .error(error: let error):
                print("ERROR when loading gifs: \(error.localizedDescription)")
            case .success(data: let data):
                self.imagesData = data.data
            }
        }
    }
}

extension GifPresenterViewModel {
    enum Rating: String {
        case general = "g"
        case parentalGuidance = "pg"
        case parentsStronglyCautioned = "pg-13"
        case restricted = "r"
    }
    
    
}
