//
//  HomeScreenViewModel.swift
//  ThingsILoveAboutU
//
//  Created by Miguel Cocera on 12/2/26.
//

import SwiftUI

@Observable
class HomeScreenViewModel {
    var state: LoadingState = .idle
    var db: FireBaseService = FireBaseService()
    
    func fetchData(id: String) async -> DataList?{
        do{
            guard let data = try await db.obtainData(id: id) else {return nil}
            state = .loaded
            return parseData(data: data)
        } catch {
            state = .error
            return nil
        }
    }
    
    private func parseData(data:NoteResponse) -> DataList{
        var itemList:[ItemList] = []
        
        for item in data.itemList{
            itemList.append(ItemList(id: item.id, content: item.content!, image: item.dataImage))
        }
        
        return DataList(id: UUID().uuidString, descriptionList: data.descriptionList!, from: data.from!, itemList: itemList)
    }
}
