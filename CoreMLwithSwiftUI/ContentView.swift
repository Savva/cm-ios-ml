//
//  ContentView.swift
//  CoreMLwithSwiftUI
//
//  Created by Moritz Philip Recke for Create with Swift on 24 May 2021.
//

import SwiftUI
import CoreML

struct ContentView: View {

    let config = MLModelConfiguration()
//    let model = MobileNetV2()
    let model = CatModel()
    @State private var classificationLabel: String = ""
    
    let photos = ["image1", "image2", "image3"]
    @State private var currentIndex: Int = 0
    
    var body: some View {
        VStack {
            Image(photos[currentIndex])
                .resizable()
                .frame(width: 200, height: 200)
            HStack {
                Button("Back") {
                    if self.currentIndex >= self.photos.count {
                        self.currentIndex = self.currentIndex - 1
                    } else {
                        self.currentIndex = 0
                    }
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .clipShape(Capsule())

                Button("Next") {
                    if self.currentIndex < self.photos.count - 1 {
                        self.currentIndex = self.currentIndex + 1
                    } else {
                        self.currentIndex = 0
                    }
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
            // The button we will use to classify the image using our model
            Button("Classify") {
                // Add more code here
                classifyImage()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())

            // The Text View that we will use to display the results of the classification
            Text(classificationLabel)
                .padding()
                .font(.body)
            Spacer()
        }
    }
    
    private func classifyImage() {
        let currentImageName = photos[currentIndex]
        
        guard let image = UIImage(named: currentImageName),
              let resizedImage = image.resizeImageTo(size:CGSize(width: 224, height: 224)),
              let buffer = resizedImage.convertToBuffer() else {
              return
        }
        
        let output = try? model.prediction(input_1: buffer)
        
        if let output = output {
            let predictionOutput = output.Identity
            print(predictionOutput)
            // Convert MLMultiArray to [Double] for easier processing
            if let (predictedClass, highestScore) = predictionOutput.max(by: { $0.value < $1.value }) {
                print("Predicted class: \(predictedClass) with score: \(highestScore)")
                self.classificationLabel = predictedClass
            } else {
                print("Failed to find a prediction.")
                self.classificationLabel = "Failed to find a prediction."
            }

            
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 12")
    }
}
