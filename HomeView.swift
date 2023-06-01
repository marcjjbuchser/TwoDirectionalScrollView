/* 
  Extended working example from: https://gist.github.com/sameersyd/fce9599687963fca90677d959dce7a6e (SwiftUI - Two Directional SnapList)
  Added: TabImageViewCell, Media and Message class
  TODO: Add image array for vertical scrolling

  Usage example:
  // Create media
  let media1 = Media(id: 1, image: "<your image name here>")
  let media2 = Media(id: 2, image: "<your image name here>")
  // Create messages and add media
  let messages = [Message(id: 1, content: "some content", media: media1), Message(id: 2, content: "some more", media: media2)]
  HomeView(viewModel: HomeViewModel(messages: messages))
    
  Note: images need to be in the assets folder of the project and the names of the images copied into the image parameters above <your image name here>
*/


import SwiftUI
import Combine

struct HomeView: View {

    @StateObject var viewModel: HomeViewModel

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ScrollViewReader { reader in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(0..<($viewModel.messages.count), id: \.self) { i in
                                TabImageViewCell(media: $viewModel.messages[i].media)
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .id(i)
                            }
                        }
                        .background(GeometryReader {
                            Color.clear.preference(key: ScrollOffsetKey.self,
                                value: -$0.frame(in: .named("scroll")).origin.y)
                        })
                        .onPreferenceChange(ScrollOffsetKey.self) { viewModel.scrollDetector.send($0) }
                    }
                    .coordinateSpace(name: "scroll")
                    .onReceive(viewModel.scrollPublisher) {
                        var index = $0/geo.size.height
                        // Check if next item is near
                        let value = index < 1 ? index : index.truncatingRemainder(dividingBy: CGFloat(Int(index)))
                        if value > 0.5 { index += 1 }
                        else { index = CGFloat(Int(index)) }
                        // Scroll to index
                        withAnimation { reader.scrollTo(Int(index), anchor: .center) }
                    }
                }
            }.edgesIgnoringSafeArea(.all)
        }.edgesIgnoringSafeArea(.all)
    }
}


// To Get Scroll Offset
fileprivate struct ScrollOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}


// -----------------------------------------

class HomeViewModel: ObservableObject {

    var messages: [Message]
    let scrollDetector: CurrentValueSubject<CGFloat, Never>
    let scrollPublisher: AnyPublisher<CGFloat, Never>

    init(messages: [Message]) {
        self.messages = messages
        // detect when scroll ends
        let detector = CurrentValueSubject<CGFloat, Never>(0)
        self.scrollPublisher = detector
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .dropFirst().eraseToAnyPublisher()
        self.scrollDetector = detector
    }
}


struct TabImageViewCell: View {

    @Binding var media: Media
    @State private var selection = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                TabView(selection: $selection) {
                // TODO: Replace with array for vertical scrolling
                    ForEach(0..<(media.image.count), id: \.self) { i in
                        Image(media.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    }
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }.edgesIgnoringSafeArea(.all).clipped()
        }.edgesIgnoringSafeArea(.all)
    }
}

class Message {
    let id: Int
    let content: String
    var media: Media

    init(id: Int, content: String, media: Media) {
        self.id = id
        self.content = content
        self.media = media
    }
}

class Media {
    let id: Int
    let image: String

    init(id: Int, image: String) {
        self.id = id
        self.image = image
    }
}
