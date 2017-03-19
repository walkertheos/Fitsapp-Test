//
//  Objects.swift
//  Fitsapp Test
//
//  Created by Theodore S. Walker on 3/18/17.
//  Copyright © 2017 TheoWalker. All rights reserved.
//

import Foundation
import RealmSwift

// define Item object with three instance fields
class Item: Object {
    dynamic var name = ""
    dynamic var importance = -1
    dynamic var date = Date()
}
