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
    @IBOutlet weak var birthdayIncludesTimeToggle: NSButton!
	@IBOutlet weak var lightRadio: NSButton!
	@IBOutlet weak var moderateRadio: NSButton!
	@IBOutlet weak var terrifyingRadio: NSButton!

    private var pickerElements: NSDatePicker.ElementFlags {
        if birthdayIncludesTime {
            return [.yearMonthDay, .hourMinute]
        } else {
            return [.yearMonthDay]
        }
    }

    private var birthdayIncludesTime: Bool { birthdayIncludesTimeToggle.state.rawValue != 0 }

    private var calendarComponents: Set<Calendar.Component> {
        if birthdayIncludesTime {
            return [.year, .month, .day, .hour, .minute]
        } else {
            return [.year, .month, .day]
        }
    }

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
        
        let birthDate: Date
        let timeIsIncluded: Bool
        if let dateComponents = Preferences().birthdayComponents,
           let date = Calendar.current.date(from: dateComponents)
        {
            birthDate = date
            timeIsIncluded = dateComponents.hour != nil
        } else {
            // Probably, first launch
            birthDate = Date()
            timeIsIncluded = false
        }
        birthdatePicker.dateValue = birthDate
        birthdayIncludesTimeToggle.state = timeIsIncluded ? .on : .off
        birthdatePicker.datePickerElements = pickerElements
    }

    @IBAction func dateDidChange(_ sender: NSDatePicker) {
        updateDate()
    }

    private func updateDate() {
        Preferences().birthdayComponents =
            Calendar
                .current
                .dateComponents(calendarComponents,
                                from: birthdatePicker.dateValue)

    }

    @IBAction func time(_ sender: NSButton) {
        birthdatePicker.datePickerElements = pickerElements
        updateDate()
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
