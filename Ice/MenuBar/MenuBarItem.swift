//
//  MenuBarItem.swift
//  Ice
//

import Cocoa

/// A type that represents an item in a menu bar.
struct MenuBarItem {
    let windowID: CGWindowID
    let frame: CGRect
    let title: String?
    let owningApplication: NSRunningApplication?
    let isOnScreen: Bool

    /// Creates a menu bar item.
    ///
    /// The parameters passed into this initializer are verified during the menu
    /// bar item's creation. If `itemWindow` does not represent a menu bar item
    /// in the menu bar represented by `menuBarWindow`, and if `menuBarWindow`
    /// does not represent a menu bar on the display represented by `display`,
    /// the initializer will fail.
    ///
    /// - Parameters:
    ///   - itemWindow: A window that contains information about the item.
    ///   - menuBarWindow: A window that contains information about the item's menu bar.
    ///   - display: The display that contains the item's menu bar.
    init?(itemWindow: WindowInfo, menuBarWindow: WindowInfo, display: DisplayInfo) {
        // validate menuBarWindow
        var menuBarIsValid: Bool {
            menuBarWindow.isOnScreen &&
            display.frame.contains(menuBarWindow.frame) &&
            menuBarWindow.owningApplication == nil &&
            menuBarWindow.windowLayer == kCGMainMenuWindowLevel &&
            menuBarWindow.title == "Menubar"
        }

        // validate itemWindow
        var itemWindowIsValid: Bool {
            guard
                itemWindow.windowLayer == kCGStatusWindowLevel,
                itemWindow.frame.minX != display.frame.minX,
                itemWindow.frame.minY == menuBarWindow.frame.minY,
                itemWindow.frame.maxY == menuBarWindow.frame.maxY
            else {
                return false
            }
            // AudioVideoModule doesn't seem to appear on screen, yet it still
            // returns `true` from the `isOnScreen` property; manually exclude
            // !!!: It *must* appear on screen under certain conditions. Investigate this.
            if itemWindow.owningApplication?.bundleIdentifier == "com.apple.controlcenter" {
                return itemWindow.title != "AudioVideoModule"
            }
            return true
        }

        guard 
            menuBarIsValid,
            itemWindowIsValid
        else {
            return nil
        }

        self.windowID = itemWindow.windowID
        self.frame = itemWindow.frame
        self.title = itemWindow.title
        self.owningApplication = itemWindow.owningApplication
        self.isOnScreen = itemWindow.isOnScreen
    }
}