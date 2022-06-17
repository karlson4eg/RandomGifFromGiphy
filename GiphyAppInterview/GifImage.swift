//
//  GifImage.swift
//  GiphyAppInterview
//
//  Created by Evi St on 6/15/22.
//
import SwiftUI
import WebKit


extension UIImage {
    class func gifImage(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil)
        else {
            return nil
        }
        let count = CGImageSourceGetCount(source)
        let delays = (0..<count).map {
            // store in milisecs and truncate to compute GCD more easily
            Int(delayForImage(at: $0, source: source) * 1000)
        }
        let duration = delays.reduce(0, +)
        let gcd = delays.reduce(0, gcd)
        
        var frames = [UIImage]()
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let frame = UIImage(cgImage: cgImage)
                let frameCount = delays[i] / gcd
                
                for _ in 0..<frameCount {
                    frames.append(frame)
                }
            } else {
                return nil
            }
        }
        
        return UIImage.animatedImage(with: frames,
                                     duration: Double(duration) / 1000.0)
    }
}

extension UIImage {
    class func gifImage(name: String) -> UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "gif"),
              let data = try? Data(contentsOf: url)
        else {
            return nil
        }
        return gifImage(data: data)
    }
}


private func gcd(_ a: Int, _ b: Int) -> Int {
    let absB = abs(b)
    let r = abs(a) % absB
    if r != 0 {
        return gcd(absB, r)
    } else {
        return absB
    }
}

private func delayForImage(at index: Int, source: CGImageSource) -> Double {
    let defaultDelay = 1.0
    
    let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
    let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
    defer {
        gifPropertiesPointer.deallocate()
    }
    let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
    if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
        return defaultDelay
    }
    let gifProperties = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
    var delayWrapper = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                          Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
                                     to: AnyObject.self)
    if delayWrapper.doubleValue == 0 {
        delayWrapper = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                          Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()),
                                     to: AnyObject.self)
    }
    
    if let delay = delayWrapper as? Double,
       delay > 0 {
        return delay
    } else {
        return defaultDelay
    }
}

class UIGIFImage: UIView {
    private let imageView = UIImageView()
    private var data: Data?
    private var name: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(name: String) {
        self.init()
        self.name = name
        initView()
    }
    
    convenience init(data: Data) {
        self.init()
        self.data = data
        initView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        self.addSubview(imageView)
    }
    
    func updateGIF(data: Data) {
        imageView.image = UIImage.gifImage(data: data)
        self.layoutIfNeeded()
    }
    
    func updateGIF(name: String) {
        imageView.image = UIImage.gifImage(name: name)
    }
    
    private func initView() {
        imageView.contentMode = .scaleAspectFill
    }
}

struct GifImage: UIViewRepresentable {
    @Binding var data: Data?

    func makeUIView(context: Context) -> UIGIFImage {
        UIGIFImage()
    }
    
    func updateUIView(_ uiView: UIGIFImage, context: Context) {
        guard let data = self.data else {
            return
        }
        uiView.updateGIF(data: data)
    }
}

class GifImageViewModel: ObservableObject {
    
    @Published var data: Data?
    @Published var isLoading: Bool = false
    
    init(url: String) {
        self.loadImage(url: url)
    }
    
    func loadImage(url: String ) {
        self.isLoading = true
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                self.data = data
            }
        }
        task.resume()
    }
}



struct GifImageView: View {
    
    @ObservedObject private var viewModel: GifImageViewModel
    var username: String
    
    init(imageData: ImageData.Data) {
        self.viewModel = .init(url: imageData.images.downsized.url)
        self.username = imageData.username
    }
    
    var body: some View {
        VStack {
            if self.viewModel.isLoading {
                ProgressView()
                    .frame(width: 300, height: 300)
            } else {
                GifImage(data: self.$viewModel.data)
                                .frame(width: 300, height: 300)
            }
            Text(username)
        }
    }
}
