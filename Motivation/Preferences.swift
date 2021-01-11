//
//  Preferences.swift
//  Motivation
//
//  Created by Sam Soffes on 8/6/15.
//  Copyright (c) 2015 Sam Soffes. All rights reserved.
//

import Foundation
import ScreenSaver

enum MotivationLevel: UInt {
	case light, moderate, terrifying

	var decimalPlaces: UInt {
		switch self {
		case .light: return 7
		case .moderate: return 8
		case .terrifying: return 9
		}
	}
}

class Preferences: NSObject {

	// MARK: - Properties

	static var birthdayDidChangeNotificationName = "Preferences.birthdayDidChangeNotification"
	static var motivationLevelDidChangeNotificationName = "Preferences.motivationLevelDidChangeNotification"

    var birthdayComponents: DateComponents? {
        get {
            if let data = defaults?.object(forKey: "BirthdayComponents") as? Data,
               let dateComponents = try? JSONDecoder().decode(DateComponents.self, from: data) {
                return dateComponents
            } else if let timestamp = defaults?.object(forKey: "Birthday") as? TimeInterval {
                // Trying read Date stored by earlier version
                defaults?.removeObject(forKey: "Birthday")
                let date = Date(timeIntervalSince1970: timestamp)
                // Here we suppose time of birth is not included
                return Calendar.current.dateComponents([.year, .month, .day], from: date)
            } else {
                // Not available. Probably, first launch.
                return nil
            }
        }
        set {
            if let jsonData = try? JSONEncoder().encode(newValue) {
                defaults?.setValue(jsonData, forKey: "BirthdayComponents")
                defaults?.synchronize()
            }
            let notificationName = Notification.Name(rawValue: type(of: self).birthdayDidChangeNotificationName)
            NotificationCenter.default.post(name: notificationName, object: newValue)
        }
    }

	var motivationLevel: MotivationLevel {
		get {
			let uint = defaults?.object(forKey: "MotivationLevel") as? UInt
			return uint.flatMap { MotivationLevel(rawValue: $0) } ?? .terrifying
		}

		set {
			defaults?.set(newValue.rawValue, forKey: "MotivationLevel")
			defaults?.synchronize()

            let notificationName = Notification.Name(rawValue: type(of: self).motivationLevelDidChangeNotificationName)
			NotificationCenter.default.post(name: notificationName, object: newValue.rawValue)
		}
	}

	private let defaults: ScreenSaverDefaults? = {
		let bundleIdentifier = Bundle(for: Preferences.self).bundleIdentifier
		return bundleIdentifier.flatMap { ScreenSaverDefaults(forModuleWithName: $0) }
	}()
}
