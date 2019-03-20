//
//  Upload+CoreDataProperties.swift
//  SXCD
//
//  Created by Alex Chow on 20/03/2019.
//  Copyright © 2019 British Broadcasting Corporation. All rights reserved.
//
//

import Foundation
import CoreData


extension Upload {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Upload> {
        return NSFetchRequest<Upload>(entityName: "Upload")
    }

    @NSManaged public var fileSize: Int64
    @NSManaged public var uploadedBytes: Int64
    @NSManaged public var uploadDate: NSDate?
    @NSManaged public var uuid: String?
    @NSManaged public var urlString: String?

}
