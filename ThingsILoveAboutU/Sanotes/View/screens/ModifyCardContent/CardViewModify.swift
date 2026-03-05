//
//  Untitled.swift
//  ThingsILoveAboutU
//
//  Created by Miguel Cocera on 17/2/26.
//

import SwiftUI

struct CardViewModify: View {
    let backgroundColor: Color
    let index:Int
    let item: ItemList
    @State var isFlipped: Bool = false
    @State private var isAnimating = false
    let flipDuration: Double = 0.6
    
    var body: some View {
        
        AppCard(num: index + 1, content: item.content, imageData: item.image, backColor: backgroundColor, isFlipped: $isFlipped)
            .frame(maxWidth: .infinity).frame(height: 500)
            .onTapGesture{
                    guard !isAnimating else { return }
                            isAnimating = true
                    withAnimation(.easeInOut(duration: 0.6)) {
                        isFlipped.toggle()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + flipDuration) {
                                isAnimating = false
                            }
                }
    }
}
