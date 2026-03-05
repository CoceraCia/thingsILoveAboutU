//
//  Card.swift
//  ThingsILoveAboutU
//
//  Created by Miguel Cocera on 4/2/26.
//

import SwiftUI

struct AppCard: View {
    let num: Int
    let content: String
    let imageData: Data?
    let backColor: Color
    @Binding var isFlipped:Bool
    
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                frontView
                    .opacity(isFlipped ? 0 : 1)
                
                backView
                    .opacity(isFlipped ? 1 : 0)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(backColor)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .contentShape(RoundedRectangle(cornerRadius: 30)).shadow(color: .black.opacity(0.25),
                                                                     radius: 30,
                                                                     x: 0,
                                                                     y: 10)
            .compositingGroup()
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.8
            )
            .animation(.easeInOut(duration: 0.6), value: isFlipped)
        }
        
    }
    
    var frontView: some View {
        GeometryReader { geometry in
            
            ZStack{
                HStack{
                    if(imageData != nil){
                        Image(uiImage: UIImage(data: imageData!)!).resizable().scaledToFill()
                    } else {
                        Image("Image 1").resizable().scaledToFill()
                    }
                }
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }}
    
    var backView: some View {
        GeometryReader{geometry in
            ZStack{
                VStack(alignment: .leading) {
                    HStack {
                        Text(String(num))
                        Spacer()
                    }
                    Spacer()
                }.padding(20)
                Text("\(content)").font(.system(size: 32)).padding(20).multilineTextAlignment(.center)
            }.background(backColor).frame(width: geometry.size.width, height: geometry.size.height).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
    }
}

#Preview {
    @Previewable @State var isActive:LoadingState = .idle
    @Previewable @FocusState var isFocused:Bool
    @State var flipped:Bool = true
    
    ZStack{
        
        
        AppCard(num: 0, content: "Eskjkjkjkjkjkjkjkjkjjjjjjjjjjjjjjjjjjjjjjjjjjjjjkjkj", imageData: nil, backColor: .red, isFlipped: $flipped).padding()
        
        
    }
}
