//
//  ContentView.swift
//  GiphyAppInterview
//
//  Created by Evi St on 6/15/22.
//

import SwiftUI

struct GifPresenterScreen: View {
    @ObservedObject private var viewModel: GifPresenterViewModel = .init()
    
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                Text("Download a random gif using a top right button")
                    .font(.body)
                    .padding()
                
                Text("GIF Rating")
                    .font(.body)
                Picker("GIF Rating", selection: self.$viewModel.rating) {
                    ForEach(self.viewModel.ratings,id: \.self){ item in
                        Text(item.rawValue)
                            .font(.callout)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                self.gifsView
                
            }
            .navigationTitle("Random gif presenter")
            .toolbar {
                Button() {
                        self.viewModel.loadGifs()
                    } label: {
                        Image(systemName: "goforward")
                    }
            }
        }
        
        
    }
    
    var gifsView: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                    ForEach(Array(self.viewModel.imagesData),id: \.id){ item in
                        VStack(spacing: 8) {
                            GifImageView(imageData: item)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
            }
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GifPresenterScreen()
    }
}
