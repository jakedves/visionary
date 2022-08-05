//
//  CameraFeed.swift
//  Visionary
//
//  Created by Jake Davies on 05/08/2022.
//

import AVFoundation

/**
 This class should setup the camera. It will send new frames from the camera
 to VisionaryViewModel through the delegate in the constructor.
 */
class CameraFeed {
    private var videoSession: AVCaptureSession?
    
    // could make these settable, will have to have a didSet tho to update the capture session output device
    let frameHandler: AVCaptureVideoDataOutputSampleBufferDelegate
    let videoOutputQueue: DispatchQueue?
    
    /**
     This class will start the AV session as soon as an instance is created
     */
    init(frameHandler: AVCaptureVideoDataOutputSampleBufferDelegate, videoOutputQueue: DispatchQueue?) {
        self.frameHandler = frameHandler
        self.videoOutputQueue = videoOutputQueue
        
        setupAVSession()
        videoSession?.startRunning()
    }
    
    /**
     This method creates an AVSession, attaches an input camera, sets up an output stream and then
     assigns videoSession to that session.
     */
    private func setupAVSession() {
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        setupInputDevice(session)
        setupVideoDataOutputStream(session)
        
        session.commitConfiguration()
        videoSession = session
    }
    
    /**
     This method looks for a camera device and adds it to an AVCaptureSession
     */
    private func setupInputDevice(_ session: AVCaptureSession) {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else { return }
        
        if session.canAddInput(cameraInput) {
            session.addInput(cameraInput)
        }
    }
    
    /**
     This method creates a video data output stream and connects it to an AVCaptureSession
     */
    private func setupVideoDataOutputStream(_ session: AVCaptureSession) {
        let output = AVCaptureVideoDataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.alwaysDiscardsLateVideoFrames = true
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            output.setSampleBufferDelegate(self.frameHandler, queue: self.videoOutputQueue)
        }
    }
}
