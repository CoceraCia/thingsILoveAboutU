//
//  Extensions.swift
//  ThingsILoveAboutU
//
//  Created by Miguel Cocera on 18/2/26.
//

import UIKit

extension UIImage {
    func resized(toMaxDimension maxDimension: CGFloat) -> UIImage? {
        let aspectRatio = size.width / size.height
        var newSize: CGSize
        
        // Si la imagen ya es pequeña, no hacemos nada
        if size.width <= maxDimension && size.height <= maxDimension {
            return self
        }
        
        if aspectRatio > 1 { // Paisaje
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else { // Retrato o cuadrado
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
