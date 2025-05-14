//
//  DailyImagesModel.swift
//  InstaProject
//
//  Created by Hugues BOUSSELET on 09/05/2025.
//

import Foundation

struct NasaImagesModel: Codable, Equatable {
    private(set) var nasaImages = [NasaImage]()
    
    func json() throws -> Data {
        let encoded = try JSONEncoder().encode(self)
        print("UserData = \(String(data: encoded, encoding: .utf8) ?? "nil")")
        return encoded
    }
    
    mutating func store(_ images: [NasaImage]) {
        self.nasaImages = images
    }
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(NasaImagesModel.self, from: json)
        self.nasaImages.sort { $0.date > $1.date }
    }
    
    init() {
        
    }
    
    mutating func toggleLike(for image: NasaImage) {
        guard let index = nasaImages.firstIndex(of: image) else { return }
        nasaImages[index].isLiked.toggle()
    }
    
    mutating func orderImagesByDate() {
        self.nasaImages.sort { $0.date > $1.date }
    }
    
    func getLastFetchedDate() -> Date? {
        guard let lastFetchDateString = self.nasaImages.last?.date else {
            return Date.now
        }
        let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: lastFetchDateString)
    }
}

struct NasaImage: Codable, Equatable {
    let date: String
    let explanation: String
    let media_type: String
    let service_version: String
    let title: String
    let url: URL
    
    var isLiked: Bool = false
    
    enum CodingKeys: CodingKey {
        case date
        case explanation
        case media_type
        case service_version
        case title
        case url
    }
}
