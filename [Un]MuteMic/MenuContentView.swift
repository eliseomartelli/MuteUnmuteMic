//
//  MenuContentView.swift
//  [Un]MuteMic
//
//  Created by Eliseo Martelli on 08/07/23.
//  Copyright © 2023 CocoaHeads Brasil. All rights reserved.
//

import SwiftUI

struct MenuContentView: Scene {
    @ObservedObject var menuContentState = MenuContentState()
    
    
    @ViewBuilder var menuView: some View {
        Text(menuContentState.inputName)
        Toggle(isOn: $menuContentState.isMuted, label: {
            Text("Muted")
        })
        .keyboardShortcut(KeyEquivalent("m"), modifiers: [.command, .control])
        Divider()
        Text("Default input volume:")
        ForEach(0...4, id: \.self) { number in
            Toggle(isOn: .init(
                get: {() -> Bool in
                    return menuContentState.restoreVolume == number*25;
                },
                set: { status in
                    if status {
                        menuContentState.restoreVolume = number*25;
                    }
                }), label: {
                    Text(String(format: "%d%%", arguments: [number*25]))
                })
            .keyboardShortcut(
                KeyEquivalent(Character(String(format: "%d", arguments: [number]))), modifiers: .command)
        }
        
        Divider()
        Toggle(isOn: $menuContentState.accessibilityToggle, label: {
            Text("Accessibility service")
        })
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }.keyboardShortcut("q")
    }
    
    @State var selected: Bool = false
    var body: some Scene {
        MenuBarExtra(content:{
            menuView
        }, label: {
            Image(systemName: menuContentState.isMuted ? "mic.slash.fill" : "mic.fill")
        })
        
    }
}
