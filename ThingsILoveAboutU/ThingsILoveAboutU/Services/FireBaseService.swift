//
//  FireBaseController.swift
//  ThingsILoveAboutU
//
//  Created by Miguel Cocera on 5/2/26.
//


import FirebaseCore
import FirebaseStorage
import FirebaseFirestore
import FirebaseFunctions

enum AppError: LocalizedError {
    case general
    case invalidResponse
    case decodingFailed
    case custom(message: String)

    var errorDescription: String? {
        switch self {
        case .general:
            return "There was a general error"
        case .invalidResponse:
            return "La respuesta del servidor no es válida."
        case .decodingFailed:
            return "No se pudo decodificar la respuesta."
        case .custom(let message):
            return message
        }
    }
}

extension String: @retroactive LocalizedError {
    public var errorDescription: String? { return self }
}

class FireBaseService {
    
    private let db = Firestore.firestore()
    private let functions = Functions.functions()
    
    
    func obtainData(id:String) async throws -> NoteResponse? {
        //functions.useEmulator(withHost: "localhost", port: 5001)
        let parameters = ["shareId": id]
        
        do {
            let result = try await functions.httpsCallable("claim_note").call(parameters)
            guard let data = try? JSONSerialization.data(withJSONObject: result.data) else {
                throw AppError.decodingFailed
            }
            let decodedResponse = try JSONDecoder().decode(NoteResponse.self, from: data)
            return decodedResponse
        } catch let error as NSError {
            if error.domain == FunctionsErrorDomain {
                let code = FunctionsErrorCode(rawValue: error.code)
                let message = error.localizedDescription
                let details = error.userInfo[FunctionsErrorDetailsKey]
                
                print("Error de Cloud Function [\(code ?? .unknown)]: \(message)")
                print("Detalles técnicos: \(details ?? "n/a")")
                
                throw AppError.custom(message: String(describing: details))
            } else {
                print("Error general: \(error.localizedDescription)")
                throw AppError.custom(message: error.localizedDescription)
            }
        }
    }
    
    private struct ItemListDTO: Sendable {
        let index: Int
        let id: String
        let content: String
        let image: Data?
    }
    
    
    func uploadEverything(dataList: DataList) async throws {
        let functions = Functions.functions()
        //functions.useEmulator(withHost: "localhost", port: 5001)
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        
        var itemListForPython: [[String: Any]] = []
        
        
        for item in dataList.itemList {
            var itemDict: [String: Any] = ["id": item.id, "content": item.content]
            
            if let imageData = item.image, let originalImage = UIImage(data: imageData) {
                
                // PASO 1: Redimensionar (Máximo 1024px)
                let resizedImage = originalImage.resized(toMaxDimension: 1280)
                
                // PASO 2: Comprimir (Calidad 0.7 es el punto dulce)
                if let optimizedData = resizedImage?.jpegData(compressionQuality: 0.8) {
                    itemDict["imageBase64"] = optimizedData.base64EncodedString()
                }
            }
            itemListForPython.append(itemDict)
        }
        
        let payload: [String: Any] = [
            "device_id": deviceID,
            "list_id": dataList.id,
            "description": dataList.descriptionList,
            "from": dataList.from,
            "items": itemListForPython
        ]
        
        do {
            // Llamamos a la función "centralizada"
            let _ = try await functions.httpsCallable("process_complete_upload").call(payload)
            print("Misión cumplida: Todo en manos de Python")
        } catch {
            print("Error en el envío: \(error.localizedDescription)")
            throw AppError.custom(message: String(describing: error.localizedDescription))
        }
    }
    
    func docExists(docId: String) async -> Bool {
        do {
            let doc = try await db.collection("listas").document(docId).getDocument()
            return doc.exists
        } catch {
            return false
        }
    }
    
    
    func testConnection() {
        db.collection("listas").limit(to: 1).getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error Firestore:", error)
            } else {
                print("✅ Conectado a Firestore. Docs:", snapshot?.documents.count ?? 0)
            }
        }
    }
}

