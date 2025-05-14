//
//  ApiService.swift
//  InstaProject
//
//  Created by Hugues BOUSSELET on 09/05/2025.
//

import Foundation

class ApiService {
    let session: URLSession = .shared
    
    func fetchApodDatas(apiRoute: ApiRoute) async throws -> Result<[NasaImage], Error> {
        guard let url = URL(string: apiRoute.urlString) else {
            print("invalid URL")
            return .failure(CocoaError(.executableLink))
        }
        var request = URLRequest(url: url)
        request.httpMethod = apiRoute.method.rawValue.uppercased()
        
        do {
            let (data, _) = try await session.data(for: request)
            guard let decodedData: [NasaImage] = try? JSONDecoder().decode([NasaImage].self, from: data) else {
                return .failure("Error" as! Error)
            }
            return .success(decodedData)
        } catch {
            return .failure(error)
        }
    }
    
}


enum ApiRoute {
    case planetary(String, String)
    
    var urlString: String {
        switch self {
        case .planetary(let start_date, let end_date):
            "https://api.nasa.gov/planetary/apod?api_key=\(apiKey)&start_date=\(start_date)&end_date=\(end_date)"
        }
    }
    var method: Methods {
        switch self {
        case .planetary:
            return .get
        }
    }
    
    var apiKey: String { "bKW4CTBmXQW3StbVQ1BXX9HlUr6c7maxNm5yELMd" }
    
    enum Methods: String {
      case get
      case post
      case put
      case delete
    }
}
