//
//  MenuContentState.swift
//  [Un]MuteMic
//
//  Created by Eliseo Martelli on 08/07/23.
//  Copyright © 2023 CocoaHeads Brasil. All rights reserved.
//

import Foundation
import AppKit
import CoreAudio


class MenuContentState: ObservableObject {
    private var inputDeviceId: AudioDeviceID?
    
    private var inputChangeNotifier: InputChangeNotifier
    
    private var globalKeyMonitor: Any?
    
    @Published var isMuted: Bool = isHardwareMuted() {
        didSet {
            // Set muted
            if (isMuted) {
                currentVolume = 0;
            } else {
                currentVolume = restoreVolume
            }
            _ = setMutedOn(inputDeviceId!)
        }
    }
    
    private func setupAccessibility() {
        if accessibilityToggle {
            self.setupHotkey();
        } else {
            teardownHotkey();
        }
        UserDefaults.standard.setValue(accessibilityToggle, forKey: "globalToggle")
    }
    
    var accessibilityToggle: Bool {
        didSet {
            setupAccessibility()
        }
    }
    
    @Published var restoreVolume: Int = 75
    
    private var currentVolume: Int? {
        didSet {
            let source = String(format: "set volume input volume %1d", currentVolume!)
            let script = NSAppleScript.init(source: source)
            var error : NSDictionary? = nil
            script?.executeAndReturnError(&error)
            
            if (error != nil) {
                print("Error on script: \(error!.description)")
            }
        }
    }
    
    @Published var inputName: String
    
    func setupHotkey() {
        let accessibility = requestAccessibility()
        
        if !accessibility {
            // TODO: Open prompt.
            accessibilityToggle = false;
            return
        } else {
            globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: {
                event in
                if (event.modifierFlags.contains(.control) &&
                    event.modifierFlags.contains(.command) &&
                    event.charactersIgnoringModifiers == "m") {
                    self.isMuted.toggle()
                }
            })
        }
    }
    
    func teardownHotkey() {
        if globalKeyMonitor != nil {
            NSEvent.removeMonitor(globalKeyMonitor!);
        }
    }
    
    func requestAccessibility() -> Bool {
        let prompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options: NSDictionary = [prompt: true]
        let appHasPermission = AXIsProcessTrustedWithOptions(options)
        return appHasPermission
    }
    
    init() {
        self.inputDeviceId = getDefaultInputDevice()
        self.inputName = getDeviceName(self.inputDeviceId!)!
        self.accessibilityToggle = UserDefaults.standard.bool(forKey: "globalToggle")
        self.inputChangeNotifier = InputChangeNotifier()
        self.setupAccessibility()
        inputChangeNotifier.startListening()
        inputChangeNotifier.inputDeviceChangeCallback = {
            self.inputDeviceId = getDefaultInputDevice()
            self.inputName = getDeviceName(self.inputDeviceId!)!
            self.isMuted = isHardwareMuted();
        }
    }
    
    deinit {
        self.inputChangeNotifier.stopListening()
    }
}
