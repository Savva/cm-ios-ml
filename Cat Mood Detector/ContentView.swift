import SwiftUI
import CoreML

struct ContentView: View {
    // Images to cycle through
    let images = ["image1", "image2", "image3"]
    // State to keep track of the current image index
    @State private var currentIndex = 0
    // State to keep the classification result
    @State private var classificationLabel: String = "Tap 'Change Image' to classify"
    
    var body: some View {
        VStack(spacing: 20) {
            // Display the current image
            Image(images[currentIndex])
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300, maxHeight: 300)
            
            // Display the image file name and classification
            VStack {
                Text(images[currentIndex])
                    .font(.headline)
                
                Text(classificationLabel) // Display the classification result
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // Button to change the image and classify it
            Button("Change Image") {
                // Cycle through the images
                currentIndex = (currentIndex + 1) % images.count
                // Classify the new image
                classifyImage(named: images[currentIndex])
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
    }
    
    func classifyImage(named imageName: String) {
        do {
            guard let uiImage = UIImage(named: imageName) else {
                throw NSError(domain: "ImageLoadingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to load image from name: \(imageName)"])
            }

            let resizedImage = try uiImage.resizeTo(size: CGSize(width: 224, height: 224))
            let mlMultiArray = try resizedImage.toMLMultiArray()

            let input = CatModelInput(input_1: mlMultiArray)
            let prediction = try CatModel().prediction(input: input)
            print(prediction)
            classificationLabel = "prediction.label"
        } catch {
            // Now error logging will tell you exactly where it fails
            print("Error during classification: \(error.localizedDescription)")
            classificationLabel = "Error during classification: \(error.localizedDescription)"
        }
    }
}

extension UIImage {
    // Adjust this method to throw errors
    func resizeTo(size: CGSize) throws -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: size))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            throw NSError(domain: "ImageResizingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to resize image."])
        }
        UIGraphicsEndImageContext()
        return resizedImage
    }

    // Adjust this method to throw errors
    func toMLMultiArray() throws -> MLMultiArray {
        guard let cgImage = self.cgImage else {
            throw NSError(domain: "MLMultiArrayConversionError", code: 1, userInfo: [NSLocalizedDescriptionKey: "UIImage has no CGImage."])
        }
        
        let width = 224
        let height = 224
        let colorChannels = 3
        let context = CGContext(data: nil,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: width * colorChannels,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let pixelBuffer = context?.data?.assumingMemoryBound(to: UInt32.self) else {
            throw NSError(domain: "MLMultiArrayConversionError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create pixel buffer."])
        }
        
        let mlArrayShape = [1, height, width, colorChannels] as [NSNumber]
        guard let mlArray = try? MLMultiArray(shape: mlArrayShape, dataType: .float32) else {
            throw NSError(domain: "MLMultiArrayConversionError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to create MLMultiArray."])
        }
        
        let totalCount = height * width * colorChannels
        for i in 0..<totalCount {
            mlArray[i] = NSNumber(value: Float(pixelBuffer[i]) / 255.0) // Normalizing pixel values
        }
        
        return mlArray
    }
}


//extension UIImage {
//    // Resize the image to the specified size
//    func resizeTo(size: CGSize) -> UIImage? {
//        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
//        self.draw(in: CGRect(origin: .zero, size: size))
//        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return resizedImage
//    }
//
//    // Convert the image to a CVPixelBuffer
//    func toBuffer() -> CVPixelBuffer? {
//        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
//        var pixelBuffer: CVPixelBuffer?
//        let width = Int(self.size.width)
//        let height = Int(self.size.height)
//
//        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
//        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
//        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
//
//        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
//        let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
//
//        context?.translateBy(x: 0, y: CGFloat(height))
//        context?.scaleBy(x: 1.0, y: -1.0)
//
//        UIGraphicsPushContext(context!)
//        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
//        UIGraphicsPopContext()
//        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
//
//        return pixelBuffer
//    }
//}
