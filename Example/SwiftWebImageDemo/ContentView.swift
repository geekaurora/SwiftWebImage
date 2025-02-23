import SwiftUI
import SwiftWebImage

struct Feed: Identifiable {
  let id: UUID = UUID()
  let imageUrl: String
  
  static let list: [Feed] = [
    .init(imageUrl: "https://raw.githubusercontent.com/geekaurora/resources/main/images/01bff78eae0870a01ed491ef86405bdf.jpg"),
    .init(imageUrl: "https://raw.githubusercontent.com/geekaurora/resources/main/images/14729eb660b3a409368f820a053ac319.jpg"),
    .init(imageUrl: "https://raw.githubusercontent.com/geekaurora/resources/main/images/16c9316d8f5dbccf394f20361c96a541.jpg"),
    .init(imageUrl: "https://raw.githubusercontent.com/geekaurora/resources/main/images/297ee57338cb757d5bf359f5f0dd666f.jpg"),
    .init(imageUrl: "https://raw.githubusercontent.com/geekaurora/resources/main/images/3a7635518ee11c02c113c6cb88f1613e.jpg")
  ]
}

struct ContentView : View {
  var body: some View {
    List {
      ForEach(Feed.list) { feed in
        SwiftImage(feed.imageUrl) { imageView in
          imageView
            .resizable()
            .aspectRatio(1, contentMode: .fit)
        }
      }
    }
  }
}

