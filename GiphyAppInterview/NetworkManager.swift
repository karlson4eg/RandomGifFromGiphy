//
//  NetworkManager.swift
//  GiphyAppInterview
//
//  Created by Evi St on 6/15/22.
//

import Foundation
import Alamofire

enum DataResponse<T: Decodable, Error: Decodable> {
    case success(data: T)
    case error(error: Error)
}

enum Response<Error: Decodable> {
    case success
    case error(error: Error)
}

class NetworkManager {
    
    static var shared: NetworkManager = .init()
    
    private var authToken: String?
    
    var isLogedIn: Bool {
        return authToken != nil
    }
    
    var defaultHeaders: [String: String] {
        return [:]
    }
    
    func dataRequest<T>(url: String, method: HTTPMethod, parameters: [String: String]? = nil, completion: @escaping (DataResponse<T, ErrorResponse>) -> Void ) where T: Decodable {
        print("URL: \(url)")
        AF.request(url, method: method, parameters: parameters, encoder: .json, headers: HTTPHeaders(defaultHeaders))
            .customValidate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data: data))
                
                case .failure(let error):
                    if let customError = error.underlyingError as? ErrorResponse {
                        print("Error in request while decoding: \(customError.localizedDescription)")
                        completion(.error(error: customError))
                    } else {
                        print("Error in request while decoding: \(error.localizedDescription)")
                        completion(.error(error: .generalResponseError))
                    }
                }
            }
    }
    
    func download(url: String, method: HTTPMethod, completion: @escaping (DataResponse<Data, ErrorResponse>) -> Void) {
        AF.download(url)
            .responseData { response in
                guard let data = response.value else {
                    return
                }
                completion(.success(data: data))
            }
    }
    
    func request(url: String, method: HTTPMethod, parameters: [String: String]? = nil, completion: @escaping (Response<ErrorResponse>) -> Void) {
        print("URL: \(url)")
        AF.request(url, method: method, parameters: parameters, encoder: .json, headers: HTTPHeaders(defaultHeaders))
            .customValidate()
            .response { response in
                switch response.result {
                case .success(_):
                    completion(.success)
                case .failure(let error):
                    if let customError = error.underlyingError as? ErrorResponse {
                        completion(.error(error: customError))
                    } else {
                        completion(.error(error: .generalResponseError))
                    }
                }
            }
    }
}

extension DataRequest {
    func customValidate() -> Self {
          return self.validate { _, response, data -> Request.ValidationResult in
              print("Status Code: \(response.statusCode)")
              let str = String(data: data!, encoding: .windowsCP1252)
              print("Data: \(str)")
              if let s = str?.data(using: String.Encoding.utf8), let attributedString = try? NSAttributedString(data: s, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                  let finalString = attributedString.string
                  print(finalString)
              }
              print()
              guard (400...599) ~= response.statusCode else {
                  return .success(Void())
              }
              guard let data = data else {
                  return .failure(ErrorResponse.generalResponseError)
              }
              
              
              
              guard let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) else {
                  return .failure(ErrorResponse.generalResponseError)
              }

              if response.statusCode == 401 {
                  return .failure(ErrorResponse.unauthorizedAccessError)
              }

              return .failure(errorResponse)
          }
      }
}

open class ErrorResponse:Codable, Error {
    public let exception: String
    public let reason: [String: [String]]?
    
    
    enum CodingKeys: String, CodingKey {
        case exception = "message"
        case reason = "errors"
    }
    
    public var firstReasonMessage: String {
        guard let message = self.reason?.first?.value.first else {
            return self.exception
        }
        return message
    }
    
    public init(exception: String, message: [String: [String]]?) {
        self.exception = exception
        self.reason = message
    }
    
    static var generalResponseError: ErrorResponse {
        return .init(exception: "Unknown error", message: [:])
    }
    
    static var unauthorizedAccessError: ErrorResponse {
        return .init(exception: "Unauthorized", message: [:])
    }
}
