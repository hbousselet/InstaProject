//
//  DummyUsers.swift
//  InstaProject
//
//  Created by Hugues BOUSSELET on 11/05/2025.
//

import Foundation

@Observable class DummyUsers {
    var dummyUsers: UserModel {
        didSet {
            autosave()
        }
    }
    
    private func autosave() {
        save(to: autosaveURL)
        print("autosaved to \(autosaveURL)")
    }
    
    private let autosaveURL: URL = URL.documentsDirectory.appendingPathComponent("Autosaved.users")
    
    init() {
        if let data = try? Data(contentsOf: autosaveURL),
           let autosavedUserModel = try? UserModel(json: data) {
            self.dummyUsers = autosavedUserModel
        } else {
            self.dummyUsers = UserModel(users: [User(username: "Léon", avatarImageName: "leon"),
                                   User(username: "Arnaud", avatarImageName: "arnaud"),
                                   User(username: "Julie", avatarImageName: "julie"),
                                   User(username: "Magalie", avatarImageName: "magalie")])
        }
    }
    
    private func save(to url: URL) {
        do {
            let data = try dummyUsers.json()
            try data.write(to: url)
        } catch let error {
            print("EmojiArtDocument: error while saving \(error.localizedDescription)")
        }
    }
}
