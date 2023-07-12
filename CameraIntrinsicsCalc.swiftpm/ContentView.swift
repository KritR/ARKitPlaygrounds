import SwiftUI

struct ContentView: View {
    @State private var takePhoto = false
    @State private var newConfig = true
    
    var body: some View {
        VStack {
            ARViewContainer(takePhoto: $takePhoto, unset: $newConfig)
            Button(action: {
                self.takePhoto = true
            }) {
                Text("Take Photo")
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}
