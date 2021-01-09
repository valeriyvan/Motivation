//
//  AgeView.swift
//  Motivation
//
//  Created by Sam Soffes on 8/6/15.
//  Copyright (c) 2015 Sam Soffes. All rights reserved.
//

import Foundation
import ScreenSaver

class AgeView: ScreenSaverView {

    private lazy var sheetController: ConfigureSheetController = ConfigureSheetController()

    var isPreviewBug: Bool = false

    override init(frame: NSRect, isPreview: Bool) {
        // Radar# FB7486243, legacyScreenSaver.appex always returns true, unlike what used
        // to happen in previous macOS versions, see documentation here : https://developer.apple.com/documentation/screensaver/screensaverview/1512475-init$

        var preview = true

        // We can workaround that bug by looking at the size of the frame
        // It's always 296.0 x 184.0 when running in preview mode
        if frame.width > 400 && frame.height > 300 {
            if isPreview {
                isPreviewBug = true
            }
            preview = false
        }

        motivationLevel = Preferences().motivationLevel
        super.init(frame: frame, isPreview: preview)!
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }


    override var hasConfigureSheet: Bool {
        return true
    }

    override var configureSheet: NSWindow? {
        return sheetController.window
    }


	// MARK: - Properties

	private let textLabel: NSTextField = {
		let label = NSTextField()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.isEditable = false
		label.drawsBackground = false
		label.isBordered = false
		label.isBezeled = false
		label.isSelectable = false
		label.textColor = .white
        label.stringValue = "Здесь будет возраст"
		return label
	}()

	private var motivationLevel: MotivationLevel

	private var birthday: Date? {
		didSet {
            updateLabel()
			updateFont()
		}
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: - NSView

	override func draw(_ rect: NSRect) {
        super.draw(rect)
	}

	// If the screen saver changes size, update the font
	override func resize(withOldSuperviewSize oldSize: NSSize) {
		super.resize(withOldSuperviewSize: oldSize)
		updateFont()
	}


	// MARK: - ScreenSaverView

	override func animateOneFrame() {
        updateLabel()
    }

    private func updateLabel() {
        if let birthday = birthday {
            let age = ageForBirthday(birthday)
            let format = "%0.\(motivationLevel.decimalPlaces)f"
            textLabel.stringValue = String(format: format, age)
        } else {
            textLabel.stringValue = "Open Screen Saver Options to set your birthday."
        }
    }


	// MARK: - Private

	/// Shared initializer
	private func initialize() {
		// Set animation time interval
		animationTimeInterval = 1 / 30

		// Recall preferences
		birthday = Preferences().birthday

		// Setup the label
		addSubview(textLabel)
		addConstraints([
			NSLayoutConstraint(item: textLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: textLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
		])

		// Listen for configuration changes
		NotificationCenter.default.addObserver(self, selector: #selector(AgeView.motivationLevelDidChange(_:)), name: NSNotification.Name(rawValue: Preferences.motivationLevelDidChangeNotificationName), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AgeView.birthdayDidChange(_:)), name: NSNotification.Name(rawValue: Preferences.birthdayDidChangeNotificationName), object: nil)
	}

	/// Age calculation
	private func ageForBirthday(_ birthday: Date) -> Double {
		let calendar = Calendar.current
		let now = Date()

		// An age is defined as the number of years you've been alive plus the number of days, seconds, and nanoseconds
		// you've been alive out of that many units in the current year.
		let components = (calendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.day, NSCalendar.Unit.second, NSCalendar.Unit.nanosecond], from: birthday, to: now, options: [])

		// We calculate these every time since the values can change when you cross a boundary. Things are too
		// complicated to try to figure out when that is and cache them. NSCalendar is made for this.
		let daysInYear = Double(calendar.daysInYear(now) ?? 365)
		let hoursInDay = Double((calendar as NSCalendar).range(of: NSCalendar.Unit.hour, in: NSCalendar.Unit.day, for: now).length)
		let minutesInHour = Double((calendar as NSCalendar).range(of: NSCalendar.Unit.minute, in: NSCalendar.Unit.hour, for: now).length)
		let secondsInMinute = Double((calendar as NSCalendar).range(of: NSCalendar.Unit.second, in: NSCalendar.Unit.minute, for: now).length)
		let nanosecondsInSecond = Double((calendar as NSCalendar).range(of: NSCalendar.Unit.nanosecond, in: NSCalendar.Unit.second, for: now).length)

		// Now that we have all of the values, assembling them is easy. We don't get minutes and hours from the calendar
		// since it will overflow nicely to seconds. We need days and years since the number of days in a year changes
		// more frequently. This will handle leap seconds, days, and years.
		let seconds = Double(components.second!) + (Double(components.nanosecond!) / nanosecondsInSecond)
		let minutes = seconds / secondsInMinute
		let hours = minutes / minutesInHour
		let days = Double(components.day!) + (hours / hoursInDay)
		let years = Double(components.year!) + (days / daysInYear)

		return years
	}

	/// Motiviation level changed
	@objc private func motivationLevelDidChange(_ notification: Notification?) {
		motivationLevel = Preferences().motivationLevel
	}

	/// Birthday changed
	@objc private func birthdayDidChange(_ notification: Notification?) {
		birthday = Preferences().birthday
	}

	/// Update the font for the current size
	private func updateFont() {
		if birthday != nil {
			textLabel.font = fontWithSize(bounds.width / 10)
		} else {
			textLabel.font = fontWithSize(bounds.width / 30, monospace: false)
		}
	}

	/// Get a font
	private func fontWithSize(_ fontSize: CGFloat, monospace: Bool = true) -> NSFont {
		let font: NSFont
		if #available(OSX 10.11, *) {
			font = .systemFont(ofSize: fontSize, weight: NSFont.Weight.thin)
		} else {
			font = NSFont(name: "HelveticaNeue-Thin", size: fontSize)!
		}

		let fontDescriptor: NSFontDescriptor
		if monospace {
            fontDescriptor = font.fontDescriptor.addingAttributes([
                NSFontDescriptor.AttributeName.featureSettings: [
                    [
                        NSFontDescriptor.FeatureKey.typeIdentifier: kNumberSpacingType,
                        NSFontDescriptor.FeatureKey.selectorIdentifier: kMonospacedNumbersSelector
                    ]
                ]
            ])
		} else {
			fontDescriptor = font.fontDescriptor
		}

		return NSFont(descriptor: fontDescriptor, size: fontSize)!
	}
}
