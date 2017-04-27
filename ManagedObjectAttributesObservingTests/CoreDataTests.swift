//
//  CoreDataTests.swift
//  ManagedObjectAttributesObserving
//
//  Created by Andrey Kadochnikov on 27/04/2017.
//  Copyright © 2017 Andrey Kadochnikov. All rights reserved.
//

import Foundation
import CoreData
import XCTest

@testable import ManagedObjectAttributesObserving

class CoreDataTests: XCTestCase {
	lazy var persistentContainer: NSPersistentContainer = {
		/*
		The persistent container for the application. This implementation
		creates and returns a container, having loaded the store for the
		application to it. This property is optional since there are legitimate
		error conditions that could cause the creation of the store to fail.
		*/
		let container = NSPersistentContainer(name: "ManagedObjectAttributesObserving")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				
				/*
				Typical reasons for an error here include:
				* The parent directory does not exist, cannot be created, or disallows writing.
				* The persistent store is not accessible, due to permissions or data protection when the device is locked.
				* The device is out of space.
				* The store could not be migrated to the current model version.
				Check the error message to determine what the actual problem was.
				*/
				fatalError("Unresolved error \(error)")
			}
		})
		return container
	}()
	
	func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
		// Save changes in the application's managed object context before the application terminates.
		let context = persistentContainer.viewContext
		
		if !context.commitEditing() {
			NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
			return .terminateCancel
		}
		
		if !context.hasChanges {
			return .terminateNow
		}
		
		do {
			try context.save()
		} catch {
			let nserror = error as NSError
			
			// Customize this code block to include application-specific recovery steps.
			let result = sender.presentError(nserror)
			if (result) {
				return .terminateCancel
			}
			
			let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
			let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
			let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
			let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
			let alert = NSAlert()
			alert.messageText = question
			alert.informativeText = info
			alert.addButton(withTitle: quitButton)
			alert.addButton(withTitle: cancelButton)
			
			let answer = alert.runModal()
			if answer == NSAlertSecondButtonReturn {
				return .terminateCancel
			}
		}
		// If we got here, it is time to quit.
		return .terminateNow
	}
	
	override func tearDown() {
		super.tearDown()
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PersonManagedObject")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		let ctx = persistentContainer.viewContext
		_ = try? ctx.execute(request)
	}
}
