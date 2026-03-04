//
//  List.swift
//  ThingsILoveAboutU
//
//  Created by Miguel Cocera on 5/2/26.
//

import Foundation
import UIKit


struct NoteResponse: Decodable {
    let id: String
    let descriptionList: String? // Ajusta si es Array o String según tu data.get("description")
    let from: String?
    let itemList: [NoteItem]
}

struct NoteItem: Decodable {
    let id: String
    let content: String?
    let image: String? // Aquí vendrá el base64
    
    // Propiedad calculada para obtener la imagen directamente
    var dataImage: Data? {
        guard let base64String = image,
              let data = Data(base64Encoded: base64String) else { return nil }
        return data
    }
}

