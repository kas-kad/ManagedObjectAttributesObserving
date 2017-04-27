//
//  ManagedObjectExtension.swift
//  ManagedObjectAttributesObserving
//
//  Created by Andrey Kadochnikov on 27/04/2017.
//  Copyright © 2017 Andrey Kadochnikov. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
	public func addObserver(observer: NSObject, forKeyPath keyPath: String, handler: @escaping ObservationHandler) {
		if isKeyObservable(key: keyPath) {
			ManagedObjectNotificationCenter.defaultCenter.addObserver(observer: observer, observee: self, forKeyPath: keyPath, handler: handler)
		}
	}
	
	open override func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions, context: UnsafeMutableRawPointer?) {
		addObserver(observer: observer, forKeyPath: keyPath) { (keyPath, newValue) in
			observer.observeValue(forKeyPath: keyPath, of: self, change: [NSKeyValueChangeKey.newKey: newValue], context: context)
		}
	}
	
	open override func removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
		ManagedObjectNotificationCenter.defaultCenter.removeObserver(observer: observer, observee: self, forKeyPath: keyPath)
	}
	
	open override func removeObserver(_ observer: NSObject, forKeyPath keyPath: String, context:UnsafeMutableRawPointer?) {
		ManagedObjectNotificationCenter.defaultCenter.removeObserver(observer: observer, observee: self, forKeyPath: keyPath)
	}
	
	private func isKeyObservable(key: String) -> Bool {
		guard let ctx = managedObjectContext, let entityDesc = NSEntityDescription.entity(forEntityName: type(of: self).entityName, in: ctx) else {
			return false
		}
		return entityDesc.attributeKeys.contains(key)
	}
	
	class var entityName: String {
		return NSStringFromClass(self).components(separatedBy: ".").last!
	}
}
