# TwoDirectionalScrollView

Extended (working) example for TwoDirectionalSnapList.swift: 
https://gist.github.com/sameersyd/fce9599687963fca90677d959dce7a6e

Added: TabImageViewCell, Media and Message class

TODO: Add image array for vertical scrolling and add complete xcode project

  Usage example:

  // Create media

  let media1 = Media(id: 1, image: "<your image name here>")
  let media2 = Media(id: 2, image: "<your image name here>")

  // Create messages and add media

  let messages = [Message(id: 1, content: "some content", media: media1), Message(id: 2, content: "some more", media: media2)]

  HomeView(viewModel: HomeViewModel(messages: messages))

    
  Note: images need to be in the assets folder of the project and the names of the images copied into the image parameters above <your image name here>

  For example pictures check out: https://picsum.photos
    
