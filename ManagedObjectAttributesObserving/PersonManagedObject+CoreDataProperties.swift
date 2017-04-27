//
//  PersonManagedObject+CoreDataProperties.swift
//  ManagedObjectAttributesObserving
//
//  Created by Andrey Kadochnikov on 27/04/2017.
//  Copyright © 2017 Andrey Kadochnikov. All rights reserved.
//

import Foundation
import CoreData


extension PersonManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonManagedObject> {
        return NSFetchRequest<PersonManagedObject>(entityName: "PersonManagedObject")
    }

    @NSManaged public var birthdate: NSDate?
    @NSManaged public var id: Int32
    @NSManaged public var name: String?

}
