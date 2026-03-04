//
//  DataList.swift
//  ThingsILoveAboutU
//
//  Created by Miguel Cocera on 6/2/26.
//

import SwiftUI
import SwiftData

@Model
final class DataList{
    var id:String
    var descriptionList:String
    var from:String
    var itemList: [ItemList]
    var createdAt: Date?
        
    init(id: String, descriptionList: String, from: String, itemList: [ItemList], createdAt:Date? = Date()) {
        self.id = id
        self.descriptionList = descriptionList
        self.from = from
        self.itemList = itemList
        self.createdAt = createdAt
    }
    
    init(copying other:DataList) {
        self.id = other.id
        self.descriptionList = other.descriptionList
        self.from = other.from
        self.itemList = other.itemList
        self.createdAt = other.createdAt
    }
}

@Model
final class ItemList {
    var id: String
    var content: String
    @Attribute(.externalStorage)
    var image: Data?
    
    init(id:String, content: String, image: Data?) {
        self.id = id
        self.content = content
        self.image = image
    }
}
