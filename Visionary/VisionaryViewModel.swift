//
//  VisionaryViewModel.swift
//  Visionary
//
//  Created by Jake Davies on 05/08/2022.
//

import AVFoundation
import SwiftUI

/**
 This view model class holds and instance of HandHandler, to which it sends frames for Vision processing, and CameraFeed, for
 which it uses to start the camera. It recieves frames in the captureOutput method, as it is an AVCaptureVideoDataOutputSampleBufferDelegate.
 
 It saves frames in a @Published variable, so that the SwiftUI View can choose to listen in for it. When the camera is not showing,
 it won't for efficiency. It also acts as a state machine, as whenever self.state is set, it checks the gestureHasChanged method to see if there
 is an action to perform, and it will perform it.
 */
class VisionaryViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var videoIsShowing: Bool = true
    @Published var frame: NSImage?
    @Published var state: HandGesture = .none {
        didSet {
            gestureHasChanged(from: oldValue, to: state)
        }
    }
    
    // Variables that SwiftUI should never know about
    private var cameraFeed: CameraFeed?
    private var videoDataOutputQueue = DispatchQueue(label: "VideoOutput", qos: .userInteractive)
    private var handHandler = HandHandler()
    
    /**
     I've never used NSObject before, not sure what super.init() is for.
     */
    override init() {
        super.init()
        self.cameraFeed = CameraFeed(frameHandler: self, videoOutputQueue: self.videoDataOutputQueue)
    }
    
    /**
     This method runs when a new video frame is written. The frame data is stored in the sampleBuffer variable passed in.
     I am not sure if this is an efficient method to display video in SwiftUI.
     */
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Update the SwiftUI view
        DispatchQueue.main.sync {
            if self.videoIsShowing {
                let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
                let ciimage = CIImage(cvPixelBuffer: imageBuffer)
                let nsimage = NSImage.fromCIImage(ciimage)
                self.frame = nsimage
            }
            self.state = self.handHandler.processFrame(sampleBuffer)
        }
    }
    
    /**
     This method is run to determine how to react to a change from one gesture to another
     */
    private func gestureHasChanged(from previous: HandGesture, to current: HandGesture) {
        // closed -> open
        if previous == .closed && current == .open {
            let mc = "Mission Control"
            self.launchApp(named: mc)
            
        // open -> closed
        } else if previous == .open && current == .closed {
            let mc = "Mission Control"
            self.launchApp(named: mc)
        }
    }
    
    /**
     Launches an app from the Application directory.
     To open Mission Control, for example, pass in "Mission Control" as named.
     
     - Parameter named: The name (prefix only) of the .app file
     */
    private func launchApp(named: String) {
        if let app = FileManager.default.urls(
            for: .applicationDirectory,
            in: .systemDomainMask
        ).first?.appendingPathComponent("\(named).app") {
            let _ = NSWorkspace.shared.open(app)
        }
    }
}

/**
 THIS PIECE OF CODE IS NOT MY OWN
 
 A helper method to convert a CIImage to an NSImage for SwiftUI to display
 
 source: [Gary Bartos](https://rethunk.medium.com/convert-between-nsimage-and-ciimage-in-swift-d6c6180ef026)
 **/
extension NSImage {
    static func fromCIImage(_ ciImage: CIImage) -> NSImage {
        let rep = NSCIImageRep(ciImage: ciImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
}

