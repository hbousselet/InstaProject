//
//  HomeView.swift
//  InstaProject
//
//  Created by Hugues BOUSSELET on 09/05/2025.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var nasaViewModel: NasaImagesViewModel
    @State var usersViewModel: DummyUsers
    
    let columns = [GridItem(.flexible())]
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    ScrollView(.horizontal) {
                        LazyHGrid(rows: columns, spacing: 20) {
                            ForEach(usersViewModel.dummyUsers.users, id: \.self) { user in
                                Image(user.avatarImageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 63, height: 63)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    Divider()
                    ScrollView(.vertical) {
                        LazyVGrid(columns: columns, spacing: 20) {
                            let imagesData = nasaViewModel.images
                            ForEach(imagesData, id: \.url) { nasaImage in
                                if nasaImage.media_type == "image" {
                                    NasaCard(nasaImage: nasaImage,
                                             geometryProxy: proxy,
                                             viewModel: nasaViewModel)
                                    .aspectRatio(1, contentMode: .fill)
                                    .padding(.horizontal, 20)
                                    .onAppear {
                                        if isDateWithinFiveDays(dateString: nasaImage.date,
                                                                lastFetchedDate: nasaViewModel.lastFetchedDate) {
                                            let lastFetchedDate: Date? = nasaViewModel.lastFetchedDate
//                                            let newDate: Date = subtractDays(from: lastFetchedDate, days: 10)
//                                            Task {
//                                                await nasaViewModel.fetchData(startDate: ,
//                                                                              endDate: nasaViewModel.lastFetchedDate)
//                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: proxy.size.height)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Pour vous")
                    .font(.headline)
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Image(systemName: "heart")
                        .foregroundColor(.gray)
                        .badge(1)
                    Image(systemName: "paperplane")
                        .rotationEffect(Angle(degrees: 10))
                        .foregroundColor(.gray)
                }
            }
        }
        .task {
            if nasaViewModel.images.isEmpty {
                print("Call in view fetch")
                await nasaViewModel.fetchData(startDate: (Date.now - 10 * (3600 * 24)), endDate: Date.now)
            }
        }
        .navigationTitle("Pour vous")
    }
    
    private func isDateWithinFiveDays(dateString: String?, lastFetchedDate: Date?) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let dateString = dateString,
              let lastFetchedDate = lastFetchedDate,
               let date = dateFormatter.date(from: dateString) else {
            return false
        }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: lastFetchedDate)
        guard let dayDifference = components.day else {
            return false
        }
        return abs(dayDifference) <= 5
    }
    
    private func subtractDays(from date: Date, days: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: -days, to: date)
    }
}

struct NasaCard: View {
    var nasaImage: NasaImage
    let geometryProxy: GeometryProxy
    @State var viewModel: NasaImagesViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(nasaImage.title)
                .font(.subheadline)
                .lineLimit(0)
            Text(nasaImage.date)
                .font(.footnote)
                .italic()
            NasaImageView(nasaImage: nasaImage, geometry: geometryProxy)
            HStack(alignment: .center) {
                LikeView(isLiked: viewModel.images.first(where: {$0.title == nasaImage.title})?.isLiked ?? false)
                    .onTapGesture {
                        viewModel.updateLikedImage(for: nasaImage)
                    }
                CommentView()
            }
            .padding(.leading, 5)
            .padding(.top, 7)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .overlay {
            RoundedRectangle(cornerRadius: 25)
                .fill(.clear)
                .strokeBorder(.gray, lineWidth: 1)
                .shadow(radius: 20)
                .padding(.horizontal, 10)
        }
    }
}

struct NasaImageView: View {
    let nasaImage: NasaImage
    let geometry: GeometryProxy
    
    var body: some View {
        AsyncImage(
            url: nasaImage.url,
            transaction: Transaction(animation: .easeInOut)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: geometry.size.width - 40, height: geometry.size.width - 40)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width - 40, height: geometry.size.width - 40)
                    .clipped()
            case .failure(let error):
                if (error as? URLError)?.code == .cancelled {
                    NasaImageView(nasaImage: nasaImage, geometry: geometry)
                } else {
                    Image(systemName: "exclamationmark.triangle")
                        .frame(width: geometry.size.width - 40, height: geometry.size.width - 40)
                }
            default:
                Image(systemName: "photo")
                    .frame(width: geometry.size.width - 40, height: geometry.size.width - 40)

            }
        }
            .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}

struct LikeView: View {
    @State var isLiked: Bool
    
    var body: some View {
        Image(systemName: "heart.fill")
            .foregroundColor(isLiked ? .red : .gray)
    }
}

struct CommentView: View {
    var body: some View {
        Image(systemName: "message")
            .foregroundColor(.gray)
    }
}
