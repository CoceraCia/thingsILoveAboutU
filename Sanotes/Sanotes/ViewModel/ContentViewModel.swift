//
//  ContentViewModel.swift
//  ThingsILoveAboutU
//
//  Created by Miguel Cocera on 5/2/26.
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class ContentViewModel {
    var db: FireBaseService = FireBaseService()
    var isDocUploaded: LoadingState = .idle

    func checkDocUploaded(docId: String) async throws {
        let success = await db.docExists(docId: docId)
        if success{
            isDocUploaded = .loaded
        }
    }
    
    func uploadData(list:DataList) async throws{
        isDocUploaded = .loading
        do {
            try await db.uploadEverything(dataList: list)
        } catch {
            isDocUploaded = .error
        }
        isDocUploaded = .loaded
    }
    
    func obtainBackgrounColor(for:Int, item:ItemList) -> Color?{
        guard let data = item.image else {return nil}
        var color:Color? = nil
        UIImage(data:data)!.getColors(quality: .high) { colors in
                    guard let colors else { return}
                    DispatchQueue.main.async {
                        color = Color(uiColor: colors.detail)
                    }
                }
        return color
    }
}

