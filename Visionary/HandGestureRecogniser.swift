//
//  HandGestureRecogniser.swift
//  Visionary
//
//  Created by Jake Davies on 05/08/2022.
//

import Vision

/**
 A collection of static methods to determine the state of a Hand
 */
struct HandGestureRecogniser {
    private init() {}
    private static let fingers: [VNHumanHandPoseObservation.JointsGroupName] = [.thumb, .indexFinger, .middleFinger, .ringFinger, .littleFinger]
    
    // notes it goes Tip > DIP > PIP > MCP
    private static let fingerTips: [VNHumanHandPoseObservation.JointName] = [.indexTip, .middleTip, .ringTip, .littleTip]
    private static let fingerMCPs: [VNHumanHandPoseObservation.JointName] = [.indexMCP, .middleMCP, .ringMCP, .littleMCP]
    
    /**
     Determines if a hand is open
     */
    static func isHandOpen(hand: VNHumanHandPoseObservation) -> Bool {
        do {
            // for each finger besides the thumb, check that the tip is higher than the mcp
            // if one fails this test, return false
            for index in 0..<fingerTips.count {
                let tip = try hand.recognizedPoint(fingerTips[index])
                let mcp = try hand.recognizedPoint(fingerMCPs[index])
                
                guard tip.y > mcp.y else { return false }
            }
            
            // TODO: Implement below later
            // for the thumb check that it is horizontally outwards (different for each hand)
        } catch {
            print("Point not available?")
        }
        return true
    }
    
    /**
     Determines if a hand is closed
     */
    static func isHandClosed(hand: VNHumanHandPoseObservation) -> Bool {
        do {
            // for each finger besides the thumb, check that the tip is lower than the mcp
            // if one fails this test, return false
            for index in 0..<fingerTips.count {
                let tip = try hand.recognizedPoint(fingerTips[index])
                let mcp = try hand.recognizedPoint(fingerMCPs[index])
                
                guard tip.y < mcp.y else { return false }
            }
            
            // TODO: Implement below later
            // for the thumb check that it is horizontally inwards (different for each hand)
        } catch {
            print("Imagine handling errors")
        }
        return true
    }
}
