//
//  BrowseTabView.swift
//  InstaProject
//
//  Created by Hugues BOUSSELET on 09/05/2025.
//

import SwiftUI

struct BrowseTabView: View {
    @State var selection: InstaTab = .home
    @State var browseTabPath: [InstaTab] = []
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selection) {
                Tab("Home", systemImage: "house", value: .home) {
                    HomeView(nasaViewModel: NasaImagesViewModel(), usersViewModel: DummyUsers())
                }
                Tab("Search", systemImage: "magnifyingglass", value: .search) {
                    SearchView()
                }
                Tab("Story", systemImage: "plus.app", value: .story) {
                    StoryView()
                }
                Tab("Reals", systemImage: "play.square", value: .reals) {
                    RealsView()
                }
                Tab("Profile", systemImage: "person.crop.circle", value: .profile) {
                    ProfileView()
                }
            }
        }
    }
    
    
    enum InstaTab {
        case home, search, story, reals, profile
    }
}
