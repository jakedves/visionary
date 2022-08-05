//
//  CameraView.swift
//  Visionary
//
//  Created by Jake Davies on 30/07/2022.
//

import SwiftUI
import AVFoundation

/**
 A SwiftUI view for rendering the camera to the screen. The Image is rerendered whenever a frame is written
 to thr VisionaryViewModel, which is how I got video in SwiftUI. Haven't looked into other approaches.
 
 I made this app for macOS, but with a few changes it can be made to run on iPhone I believe:
 EITHER:
    Try to replace NSImage with CGImage, do this in VisionaryViewModel as well (I'm not sure if this works, I've heard cgImage isn't full image data but worth a shot)
 
 OR:
    1. Create a file targetting iOS and another targetting macOS
    2. Create a struct that handles conversion from CIImage -> NSImage
        Place this in the macOS file
    3. Create a struct with the same name that handles conversion from CIImage -> UIImage
        Place this in the iOS file
    4. Use this struct in VisionaryViewModel.captureOutput, to convert from the ciimage to a device compatible image
    5. Create a typealias ImageType == NSImage (in the macOS file) and ImageType == UIImage (in the iOS file)
    6. Set VisionaryViewModel.frame to type ImageType? (instead of NSImage?)
    7. Make an NativeImageView struct: View, one in the macOS file and one in the iOS file
    8. They should have the same constructor, NativeImageView.init(imageData: ImageType)
    9. var body: some View { Image(ciImage: imageData) }.resizeable() for iOS, and the same with Image(nsImage) for macOS
    10. Use that NativeImageView instead of Image below.
 */
struct CameraView: View {
    @StateObject var cameraFeed = VisionaryViewModel()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if cameraFeed.videoIsShowing && cameraFeed.frame != nil {
                    Image(nsImage: cameraFeed.frame!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geo.size.width)
                        .background(Color.red)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
                let val = cameraFeed.state == .open ? "open" : cameraFeed.state == .closed ? "closed" : "none"

                VStack {
                    Spacer()
                    // Center the button and state display horizontally
                    HStack {
                        Spacer()
                        VStack {
                            Text("Hand is: \(val)")
                                .padding()
                                .background(cameraFeed.state == .open ? Color.green.opacity(0.5) :
                                                cameraFeed.state == .closed ? Color.red.opacity(0.5) : Color.blue.opacity(0.5))
                                .cornerRadius(15.0)
                            Button(cameraFeed.videoIsShowing ? "Hide Video" : "Show Video") {
                                cameraFeed.videoIsShowing.toggle()
                            }
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
