import SwiftUI

struct ContentView: View {
    // Images to cycle through
    let images = ["image1", "image2", "image3"]
    // State to keep track of the current image index
    @State private var currentIndex = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Display the current image
            Image(images[currentIndex])
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300, maxHeight: 300)
            
            // Display the image file name
            Text(images[currentIndex])
                .font(.headline)
            
            // Button to change the image
            Button("Change Image") {
                // Cycle through the images
                currentIndex = (currentIndex + 1) % images.count
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
    }
}
