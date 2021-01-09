//
//  ConfigureSheetController.swift
//  Motivation
//
//  Created by Sam Soffes on 8/6/15.
//  Copyright (c) 2015 Sam Soffes. All rights reserved.
//

import AppKit

class ConfigureSheetController: NSObject {

    // MARK: - Properties

    @IBOutlet var window: NSWindow?
    @IBOutlet weak var birthdatePicker: NSDatePicker!
	@IBOutlet weak var lightRadio: NSButton!
	@IBOutlet weak var moderateRadio: NSButton!
	@IBOutlet weak var terrifyingRadio: NSButton!

    override init() {
        super.init()
        let myBundle = Bundle(for: ConfigureSheetController.self)
        myBundle.loadNibNamed("Configuration", owner: self, topLevelObjects: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        switch Preferences().motivationLevel {
        case .light: lightRadio.state = .on
        case .moderate: moderateRadio.state = .on
        case .terrifying: terrifyingRadio.state = .on
        }
        if let birthday = Preferences().birthday {
            birthdatePicker.dateValue = birthday
        }
    }

    @IBAction func dateDidChange(_ sender: NSDatePicker) {
        Preferences().birthday = sender.dateValue
    }

    @IBAction func time(_ sender: NSButton) {
        if birthdatePicker.datePickerElements.contains(.hourMinute) {
            birthdatePicker.datePickerElements = [.yearMonthDay]
        } else {
            birthdatePicker.datePickerElements = [.hourMinute, .yearMonthDay]
        }
    }

    @IBAction func close(_ sender: NSButton) {
        if let window = window {
            window.close()
        }
    }

	@IBAction func levelDidChange(_ sender: AnyObject?) {
		guard let button = sender as? NSButton, let level = MotivationLevel(rawValue: UInt(button.tag)) else { return }
		Preferences().motivationLevel = level
	}
}
