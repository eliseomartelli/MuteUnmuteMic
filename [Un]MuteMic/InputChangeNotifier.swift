//
//  InputChangeNotifier.swift
//  [Un]MuteMic
//
//  Created by Eliseo Martelli on 09/07/23.
//  Copyright © 2023 CocoaHeads Brasil. All rights reserved.
//

import Foundation
import CoreAudio

class InputChangeNotifier {
    var inputDeviceChangeCallback: (() -> Void)?
    var inputDeviceID: AudioDeviceID = 0
    
    func listener(_: Any, _: Any) {
        // This block will be called when the default input device changes
        // Invoke the callback function if provided
        self.inputDeviceChangeCallback?()
    }
    
    func startListening() {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        // Register a listener for default input device changes
        let status = AudioObjectAddPropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            DispatchQueue.main,
            listener(_:_:)
        )
        
        if status == noErr {
            // Retrieve the initial default input device ID
            inputDeviceID = getDefaultInputDevice()!
        } else {
            print("Error adding property listener: \(status)")
        }
    }
    
    func stopListening() {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        // Remove the listener for default input device changes
        let status = AudioObjectRemovePropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            DispatchQueue.main,
            listener(_:_:)
        )
        
        if status != noErr {
            print("Error removing property listener: \(status)")
        }
    }
}
