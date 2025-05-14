//
//  NasaImagesViewModel.swift
//  InstaProject
//
//  Created by Hugues BOUSSELET on 09/05/2025.
//

import Foundation

@Observable class NasaImagesViewModel {
    
    private let autosaveURL: URL = URL.documentsDirectory.appendingPathComponent("Autosaved.Nasa")
    private(set) var lastFetchedDate: Date?
    
    private let apiService: ApiService = .init()
    var alert: Error? = nil
    var needToPresentAlert = false
    
    var images: [NasaImage] {
        imagesData.nasaImages
    }
    
    private var imagesData: NasaImagesModel = NasaImagesModel() {
        didSet {
            print("images data modified")
            if imagesData.nasaImages != oldValue.nasaImages {
                print("va autosave")
                autosave()
            }
            if imagesData.nasaImages.count != oldValue.nasaImages.count && oldValue.nasaImages.count > 0 {
                print("let's call fetch new: \(imagesData.nasaImages.count) old: \(oldValue.nasaImages.count)")
                Task {
                    await self.fetchData(startDate: (Date.now - 10 * (3600 * 24)), endDate: Date.now)
                }
            }
        }
    }
    
    init() {
        if let data = try? Data(contentsOf: autosaveURL),
           let autosavedUserModel = try? NasaImagesModel(json: data) {
            print("Init: \(autosavedUserModel)")
            imagesData = autosavedUserModel
            if !imagesData.nasaImages.isEmpty {
                imagesData.orderImagesByDate()
                lastFetchedDate = imagesData.getLastFetchedDate()
            }
        }
    }
    
    private func autosave() {
        save(to: autosaveURL)
        print("autosaved to \(autosaveURL)")
    }
    
    private func save(to url: URL) {
        do {
            let data = try imagesData.json()
            try data.write(to: url)
        } catch let error {
            print("EmojiArtDocument: error while saving \(error.localizedDescription)")
        }
    }
            
    @MainActor
    func fetchData(startDate: Date?, endDate: Date?) async {
        print("call fetchData")
        guard let startDate = startDate, let endDate = endDate else { return }
        
        Task {
            do {
                let result = try await apiService.fetchApodDatas(apiRoute: .planetary(turnDateInString(startDate),
                                                                                      turnDateInString(endDate)))
                let rawImages = try result.get()
                imagesData.store(rawImages)
                imagesData.orderImagesByDate()
                lastFetchedDate = imagesData.getLastFetchedDate()
            } catch {
                
                print("error rr: \(error)")
                alert = error
                needToPresentAlert = true
            }
        }
    }
    
    private func turnDateInString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    @MainActor
    func updateLikedImage(for image: NasaImage) {
        print("before: \(String(describing: imagesData.nasaImages.first?.isLiked))")
        imagesData.toggleLike(for: image)
        print("after: \(String(describing: imagesData.nasaImages.first?.isLiked))")
    }
    
    func isDateWithinFiveDays(dateString: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: dateString), let lastFetchedDate = self.lastFetchedDate else {
            return false
        }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: lastFetchedDate)
        guard let dayDifference = components.day else {
            return false
        }
        return abs(dayDifference) <= 5
    }
}
