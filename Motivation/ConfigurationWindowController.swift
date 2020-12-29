//
//  ConfigurationWindowController.swift
//  Motivation
//
//  Created by Sam Soffes on 8/6/15.
//  Copyright (c) 2015 Sam Soffes. All rights reserved.
//

import AppKit

class ConfigurationWindowController: NSWindowController {

    // MARK: - Properties

    @IBOutlet weak var birthdatePicker: NSDatePicker!
	@IBOutlet weak var lightRadio: NSButton!
	@IBOutlet weak var moderateRadio: NSButton!
	@IBOutlet weak var terrifyingRadio: NSButton!

	override var windowNibName: String {
		return "Configuration"
	}


	// MARK: - NSWindowController

    @IBAction func time(_ sender: NSButton) {
        if birthdatePicker.datePickerElements.contains(.hourMinute) {
            birthdatePicker.datePickerElements = [.yearMonthDay]
        } else {
            birthdatePicker.datePickerElements = [.hourMinute, .yearMonthDay]
        }
    }

	override func windowDidLoad() {
		super.windowDidLoad()

		switch Preferences().motivationLevel {
		case .light: lightRadio.state = NSControl.StateValue.on
		case .moderate: moderateRadio.state = NSControl.StateValue.on
		case .terrifying: terrifyingRadio.state = NSControl.StateValue.on
		}
	}


	// MARK: - Action

	@IBAction func close(_ sender: AnyObject?) {
		if let window = window {
			window.sheetParent?.endSheet(window)
		}
	}

	@IBAction func levelDidChange(_ sender: AnyObject?) {
		guard let button = sender as? NSButton, let level = MotivationLevel(rawValue: UInt(button.tag)) else { return }
		Preferences().motivationLevel = level
	}
}
