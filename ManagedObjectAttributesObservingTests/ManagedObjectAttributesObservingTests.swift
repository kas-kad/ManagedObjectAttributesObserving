//
//  ManagedObjectAttributesObservingTests.swift
//  ManagedObjectAttributesObservingTests
//
//  Created by Andrey Kadochnikov on 27/04/2017.
//  Copyright © 2017 Andrey Kadochnikov. All rights reserved.
//

import XCTest
import CoreData
import Foundation

@testable import ManagedObjectAttributesObserving

class ManagedObjectAttributesObservingTests: CoreDataTests {
	
	func testThatChangeHandlerTriggerred() {
		weak var expectation1 = expectation(description: "Person 1 observed")
		weak var expectation2 = expectation(description: "Person 2 observed")
		
		let ctx = persistentContainer.viewContext
		
		if	let person1 = PersonManagedObject.MM_findAllWithPredicate(NSPredicate(format: "name == %@", "1.1"), context: ctx)!.first,
			let person2 = PersonManagedObject.MM_findAllWithPredicate(NSPredicate(format: "name == %@", "2.1"), context: ctx)!.first {
		
			let observingKeyPath = "name"
			let person1newId = "1.2"
			let person2newId = "2.2"
			
			ManagedObjectNotificationCenter.defaultCenter.addObserver(observer: self, observee: person1, forKeyPath: observingKeyPath, handler: { (keyPath, newValue) in
				XCTAssertEqual(newValue as? String, person1newId, "The new value must be passed to handler")
				XCTAssertEqual(keyPath, observingKeyPath, "The keypath should be that particluar one which we are observing")
				expectation1?.fulfill()
			})
			
			ManagedObjectNotificationCenter.defaultCenter.addObserver(observer: self, observee: person2, forKeyPath: observingKeyPath, handler: { (keyPath, newValue) in
				XCTAssertEqual(newValue as? String, person2newId, "The new value must be passed to handler")
				XCTAssertEqual(keyPath, observingKeyPath, "The keypath should be that particluar one which we are observing")
				expectation2?.fulfill()
			})
			
			person1.name = person1newId
			person2.name = person2newId
			ctx.MM_saveToPersistentStoreAndWait()
		}
		
		waitForExpectations(timeout: 2) { error in
			XCTAssertTrue(true)
		}
	}
	
	func testThatChangeHandlerNotTriggerred() {
		
		weak var expectation = self.expectation(description: "Test finished")
		let ctx = persistentContainer.viewContext
		if let person = PersonManagedObject.MM_findFirstInContext(ctx){
			let observingKeyPath = "birthdate"
			
			ManagedObjectNotificationCenter.defaultCenter.addObserver(observer: self, observee: person, forKeyPath: observingKeyPath, handler: { (keyPath, newValue) in
				XCTFail("Handler must not be triggered, because we changed different key")
			})
			
			person.name = "2"
			ctx.MM_saveToPersistentStoreAndWait()
		} else {
			XCTFail()
		}
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
			expectation?.fulfill()
		}
		waitForExpectations(timeout: 1) { error in
			XCTAssertTrue(true)
		}
	}
	
	func testThatRemovedObserverNotTriggerred() {
		weak var expectation = self.expectation(description: "Test finished")
		let ctx = persistentContainer.viewContext
		if let person = PersonManagedObject.MM_findFirstInContext(ctx){
			do {
				let observingKeyPath = "name"
				ManagedObjectNotificationCenter.defaultCenter.addObserver(observer: self, observee: person, forKeyPath: observingKeyPath, handler: { (keyPath, newValue) in
					XCTFail("Handler must not be triggered, because we removed the observer")
				})
				ManagedObjectNotificationCenter.defaultCenter.removeObserver(observer: self, observee: person, forKeyPath: observingKeyPath)
				person.name = "2"
				ctx.MM_saveToPersistentStoreAndWait()
			}
			do {
				let observingKeyPath = "name"
				ManagedObjectNotificationCenter.defaultCenter.addObserver(observer: self, observee: person, forKeyPath: observingKeyPath, handler: { (keyPath, newValue) in
					XCTFail("Handler must not be triggered, because we removed the observer")
				})
				ManagedObjectNotificationCenter.defaultCenter.removeAllObservers()
				person.name = "2"
				ctx.MM_saveToPersistentStoreAndWait()
			}
		} else {
			XCTFail()
		}
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
			expectation?.fulfill()
		}
		waitForExpectations(timeout: 1) { error in
			XCTAssertTrue(true)
		}
	}
	
	func testObservationsNotDuplicated() {
		let ctx = persistentContainer.viewContext
		if let person = PersonManagedObject.MM_findFirstInContext(ctx){
			var observationsCounter = 0
			weak var expectation = self.expectation(description: "Test finished")
			let observingKeyPath = "name"
			
			ManagedObjectNotificationCenter.defaultCenter.addObserver(observer: self, observee: person, forKeyPath: observingKeyPath, handler: { (keyPath, newValue) in
				observationsCounter += 1
			})
			
			ManagedObjectNotificationCenter.defaultCenter.addObserver(observer: self, observee: person, forKeyPath: observingKeyPath, handler: { (keyPath, newValue) in
				observationsCounter += 1
			})
			
			person.name = "2"
			ctx.MM_saveToPersistentStoreAndWait()
			
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
				expectation?.fulfill()
			}
			waitForExpectations(timeout: 1) { error in
				XCTAssertEqual(observationsCounter, 1, "Observations must not duplicate")
			}
		} else {
			XCTFail()
		}
	}
}
