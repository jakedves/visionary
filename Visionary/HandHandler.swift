//
//  HandHandler.swift
//  Visionary
//
//  Created by Jake Davies on 05/08/2022.
//

import Vision

/**
 This struct is for handling the hand. It takes in an image buffer, and uses Vision
 to detect a hand. It takes in an image through the processFrame() method, which will return
 the state of the hand if there is one, or HandGesture.none otherwise.
 */
struct HandHandler {
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
    /**
     Set the maximum amount of hands we want to count.
     */
    init(maxHandCount: Int = 1) {
        handPoseRequest.maximumHandCount = maxHandCount
    }
    
    /**
     This method allows us to change the maximum number of hands Vision will look for.
     More hands => More latency => Slower app.
     
     - Note: `self.processFrame()` only processes one hand, so don't use this unless you plan to update
     the other methods in this struct as well.
     */
    func updateMaxHandCount(to newMax: Int) {
        handPoseRequest.maximumHandCount = newMax
    }
        
    /**
     This method should to called to give the HandHandler a new frame to process.
     
     The line `guard let firstHand = observations?.first else { return .none }` is extreme. Typically you would want this
     struct to have a buffer of states, and only return .none when it is sure there is no hands, as it is likely a hand could be
     missed for a single frame using Vision. i.e. If there has been 5 frames in a row without a hand, then return .none
     
     - Note: To adjust this to process multiple hands, return an `[HandGesture]`, and if you want to detect two hands (a user's left
     hand and right hand), you can assign each index in that array to one hand, and Vision does have a method to tell if a hand is a left
     or right hand, so then you can update the correct hand only. i.e. array[0] = right hand, array[1] = left, update the one that has changed.
     */
    func processFrame(_ sampleBuffer: CMSampleBuffer, handNotFoundState: HandGesture = HandGesture.none) -> HandGesture {
        let visionHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            try visionHandler.perform([handPoseRequest])
            
            // we need at least one hand or we are wasting processing on nothing, any more hands can be handled from obeservations array
            let observations = handPoseRequest.results
            guard let firstHand = observations?.first else { return handNotFoundState }
            return self.processHand(hand: firstHand)
        } catch {
            print("Error in HandHandler.processFrame()")
            print("Something went wrong when performing the hand pose request")
        }
        return handNotFoundState
    }
    
    /**
     Takes in a hand pose observation and returns the new state.
     */
    private func processHand(hand: VNHumanHandPoseObservation) -> HandGesture {
        if HandGestureRecogniser.isHandOpen(hand: hand) {
            return .open
        } else if HandGestureRecogniser.isHandClosed(hand: hand) {
            return .closed
        }
        return .none
    }
}

/**
 This enum describes the different states our hand can be in. In the Apple version they
 use a buffer and also have states like .possibleOpen, .possibleClose which makes the transitions
 smoother. For a full app I'd recommend considering that approach.
 */
enum HandGesture {
    case open
    case closed
    case none
}
