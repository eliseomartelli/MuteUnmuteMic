//
//  AppDelegate.m
//  MuteUnmuteMic
//
//  Copyright © 2015 CocoaHeads Brasil. All rights reserved.
//

#import "AudioMixer.h"

static NSInteger const kDefaultVolume = 75;

@interface AppDelegate ()

@property (nonatomic) NSStatusItem *menuItem;
@property (nonatomic) BOOL muted;
@property (nonatomic) NSInteger inputVolumeToUnmute;

@end

@implementation AppDelegate

BOOL checkAccessibility(void);

BOOL checkAccessibility(void){
    NSDictionary* opts = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    return AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)opts);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self initDefaults];
    [self configureStatusBar];
    [self updateInputVolume];
    
    if (checkAccessibility()) {
        NSLog(@"Accessibility Enabled");
    }
    else {
        NSLog(@"Accessibility Disabled");
        [self constructErrorWithDescription:@"Enable accessibility to use ctrl+cmd+m hotkey."];
    }
    
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^(NSEvent *event){
        // Activate app when pressing
        if([event modifierFlags] & NSEventModifierFlagControl && [event modifierFlags] & NSEventModifierFlagCommand && [[event charactersIgnoringModifiers] compare:@"m"] == 0) {
            [self toggleMute];
        }
    }];
    
}

-(NSError*) constructErrorWithDescription:(NSString*)description {
    return [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier
                               code:0
                           userInfo:@{
        NSLocalizedDescriptionKey: description
    }];
}


- (void)initDefaults
{
    _muted = IsHardwareMuted();
    _inputVolumeToUnmute = kDefaultVolume;
}

- (void)configureStatusBar
{
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    
    NSStatusItem *menuItem =
    [statusBar statusItemWithLength:NSVariableStatusItemLength];
    [menuItem setToolTip:@"[Un]MuteMic"];
    [menuItem setImage:[NSImage imageNamed:@"mic_on"]];
    [menuItem setHighlightMode:YES];
    
    [menuItem setTarget:self];
    [menuItem setAction:@selector(menuItemClicked:)];
    [menuItem.button sendActionOn:NSLeftMouseUpMask|NSRightMouseUpMask];
    
    self.menuItem = menuItem;
}

- (void)menuItemClicked:(id)sender
{
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    
    if ((event.modifierFlags & NSControlKeyMask) || (event.type == NSRightMouseUp)) {
        [self showMenu];
    } else {
        [self toggleMute];
    }
}

- (void)toggleMute
{
    self.muted = !self.muted;
    [self updateInputVolume];
}

- (void)updateInputVolume
{
    BOOL muted = self.muted;
    
    NSInteger volume;
    NSString *imageName;
    if (muted) {
        volume = 0;
        imageName = @"mic_off";
    } else {
        volume = self.inputVolumeToUnmute;
        imageName = @"mic_on";
    }
    
    // set volume
    NSString *source =
    [NSString stringWithFormat:@"set volume input volume %ld", (long)volume];
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    NSDictionary *errorInfo = nil;
    [script executeAndReturnError:&errorInfo];
    
    if (errorInfo) {
        NSLog(@"Error on script %@", errorInfo);
    }
    
    // set hardware mute
    SetHardwareMute(muted);
    
    // set image
    self.menuItem.image = [NSImage imageNamed:imageName];
}

- (void)showMenu
{
    [self.menuItem popUpStatusItemMenu:self.menu];
}

- (IBAction)didSetVolumeInput:(NSMenuItem *)sender
{
    for (NSMenuItem *item in sender.menu.itemArray) {
        item.state = 0;
    }
    sender.state = 1;
    
    self.inputVolumeToUnmute = [sender.title integerValue];
    [self updateInputVolume];
}


@end
