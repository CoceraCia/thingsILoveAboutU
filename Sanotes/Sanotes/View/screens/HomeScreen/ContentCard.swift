//
//  ContentCard.swift
//  ThingsILoveAboutU
//
//  Created by Miguel Cocera on 17/2/26.
//

import SwiftUI

struct ContentCardHome:View{
    let title:String
    let from:String
    let image:Data?
    
    var body: some View {
        GeometryReader{geo in
            ZStack{
                VStack{
                    Group{
                        if let data = image, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: geo.size.width-15, maxHeight: 140)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        } else {
                            Image("Image 1").resizable().scaledToFill()
                                .frame(maxWidth: geo.size.width-15, maxHeight: 140) .clipped().clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
                    Spacer()
                    VStack(alignment:.leading){
                        Text(title).font(.system(size: 16, weight: .bold))
                        Text(from).font(.system(size: 12, weight: .medium))
                    }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 3)
                    Spacer()
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).padding(8)
            }.frame(maxWidth: geo.size.width, maxHeight: geo.size.height).background(RoundedRectangle(cornerRadius: 20).fill(.surfaceVariant))
        }
    }
}
