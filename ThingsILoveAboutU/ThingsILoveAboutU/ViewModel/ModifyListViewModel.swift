//
//  ModifyListScreenViewModel.swift
//  ThingsILoveAboutU
//
//  Created by Miguel Cocera on 8/2/26.
//

import PhotosUI
import SwiftUI

@Observable
class ModifyListViewModel {
    var list: DataList = DataList(id: UUID().uuidString, descriptionList: "", from: "", itemList: [ItemList(id: UUID().uuidString, content: "", image: nil)])
    
    var title: String = ""
    var from: String = ""
    
    func checkParamsOnExit() -> Bool{
        guard list.itemList.count >= 1 else {return false}
        
        let hasContent = !list.itemList[0].content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        if (list.itemList.count == 1){
            if (hasContent || list.itemList[0].image != nil){
                if(title.isEmpty){ title = "New List" }
                if (from.isEmpty){ from = "No one" }
            } else {
                return false
            }
        }
        
        return true
    }
    
    func loadImage(item:PhotosPickerItem) async throws -> Data?{
        return try await item.loadTransferable(type: Data.self) ?? nil
    }
    
    func deleteItem(item:ItemList){
        list.itemList.removeAll {$0.id == item.id}
    }
    
    func refresh(){
        list = DataList(copying: list)
    }
}
