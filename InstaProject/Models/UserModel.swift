//
//  UserModel.swift
//  InstaProject
//
//  Created by Hugues BOUSSELET on 11/05/2025.
//

import Foundation

struct UserModel: Codable, Equatable {
    var users: [User]
    
    func json() throws -> Data {
        let encoded = try JSONEncoder().encode(self)
        print("UserData = \(String(data: encoded, encoding: .utf8) ?? "nil")")
        return encoded
    }
    
    init(json: Data) throws {
        self.users = try JSONDecoder().decode([User].self, from: json)
    }
    
    init(users: [User]) {
        self.users = users
    }
}

struct User: Codable, Equatable, Hashable {
    let username: String
    let avatarImageName: String
}
