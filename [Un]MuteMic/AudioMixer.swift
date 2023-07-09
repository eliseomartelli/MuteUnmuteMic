//
//  AudioMixer.swift
//  [Un]MuteMic
//
//  Created by Eliseo Martelli on 09/07/23.
//  Copyright © 2023 CocoaHeads Brasil. All rights reserved.
//

import Foundation
import CoreAudio

func getDefaultInputDevice() -> AudioDeviceID? {
    var deviceID: AudioDeviceID = 0
    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultInputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    
    var size = UInt32(MemoryLayout<AudioDeviceID>.size)
    let status = AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &propertyAddress,
        0,
        nil,
        &size,
        &deviceID
    )
    
    if status == noErr {
        return deviceID
    } else {
        print("Error getting default input device: \(status)")
        return nil
    }
}

func getMutedOn(_ inputDevice: AudioDeviceID) -> Bool {
    
    var muted: DarwinBoolean = false;
    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultInputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    
    var size = UInt32(MemoryLayout<DarwinBoolean>.size)
    let status = AudioObjectGetPropertyData(
        inputDevice,
        &propertyAddress,
        0,
        nil,
        &size,
        &muted
    )
    
    if status != noErr {
        print("Error getting mute state: \(status)")
    }
    
    return muted.boolValue;
}

func getDeviceName(_ deviceID: AudioDeviceID) -> String? {
    var deviceName: CFString? = nil
    var propSize = UInt32(MemoryLayout<CFString?>.size)

    
    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioObjectPropertyName,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    
    let errorCode = AudioObjectGetPropertyData(
        deviceID,
        &propertyAddress,
        0,
        nil,
        &propSize,
        &deviceName
    )
    
    if errorCode != noErr {
        print("Error in getAudioDeviceName: \(errorCode)")
        return nil
    }
    
    if let name = deviceName as String? {
        return name
    } else {
        return "<Unamed device>"
    }
}



func isHardwareMuted() -> Bool {
    guard let inputDevice = getDefaultInputDevice() else {
        return false;
    }
    
    return getMutedOn(inputDevice);
}


func setMutedOn(_ inputDevice: AudioDeviceID) -> Bool {
    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultInputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    
    var setMute: Bool = true;
    
    var theMute: UInt32 = setMute ? 1 : 0
    let propSize = UInt32(MemoryLayout<UInt32>.size)
    
    if (AudioObjectHasProperty(inputDevice, &propertyAddress)) {
        let error = AudioObjectSetPropertyData(inputDevice, &propertyAddress, 0, nil, propSize, &theMute)
        
        setMute = error != noErr
        if (error != noErr) {
            print("Error in setMutedOn: \(error)")

        }
    } else {
        print("Error in setMutedOn: Mute not supported")
        setMute = false
    }
    return setMute
}
