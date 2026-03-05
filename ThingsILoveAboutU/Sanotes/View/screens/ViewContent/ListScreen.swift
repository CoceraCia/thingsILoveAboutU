//
//  ContentView.swift
//  ThingsILoveAboutU
//
//  Created by Miguel Cocera on 4/2/26.
//

import SwiftUI
import SwiftData

struct ListScreen: View {
    let list: DataList
    @State private var vm = ContentViewModel()

    
    @State private var showUploadCard = false
    @State private var showShareAlert = false
    @State var goEdit = false
    @State var backColor:Color = .surface
    @State var textColor:Color = .text
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Spacer()
                if !list.itemList.isEmpty {
                    TabView(selection: $selectedIndex) {
                        ForEach(Array(list.itemList.enumerated()), id: \.element.id) { index, item in
                            CardViewModify(backgroundColor:backColor,index: index, item: item).tag(index).padding()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                Spacer()
            }
            .navigationDestination(isPresented: $goEdit) {
                ModifyListScreen(list: list)
            }
            topBar.padding()
            
            if showUploadCard { uploadCard }
        }
        .background(backColor).foregroundColor(textColor).animation(.easeInOut(duration: 0.35), value: backColor)
        .onChange(of: selectedIndex) {
            guard let data = list.itemList[selectedIndex].image else {
                backColor = .surface
                textColor = .text
                return
            }
            UIImage(data:data)!.getColors(quality: .high) { colors in
                        guard let colors else { return }
                        DispatchQueue.main.async {
                            backColor = Color(uiColor: colors.background)
                            textColor = Color(uiColor: colors.secondary)
                        }
                    }
        }.task {
            do{
                try await vm.checkDocUploaded(docId: list.id)
            } catch {}
            
            if list.itemList.isEmpty {return}
            guard let data = list.itemList[0].image else {return}
            UIImage(data:data)!.getColors(quality: .high) { colors in
                        guard let colors else { return }
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut(duration: 0.4)){
                                backColor = Color(uiColor: colors.background)
                                textColor = Color(uiColor: colors.secondary)
                            }
                        }
                    }
        }
        .sheet(isPresented: $showShareAlert) { alert }.navigationBarBackButtonHidden(true)
        
    }
    
    @Environment(\.dismiss) private var dismiss
    var topBar: some View{
        HStack(spacing:11){
            VStack(alignment: .leading){
                Text(verbatim: "From").font(.system(size: 24))
                Text(list.from).font(.system(size: 32, weight: .bold))
            }
            Spacer()
            Button{
                goEdit = true
            }label: {
                Image(systemName: "pencil").font(.system(size: 30))
            }.foregroundColor(textColor)
            Button{
                withAnimation(.interpolatingSpring(stiffness: 100, damping: 10)){
                    if (vm.isDocUploaded == .error){
                        vm.isDocUploaded = .idle
                    }
                    showUploadCard = true
                }
                
            }label: {
                Image(systemName: "square.and.arrow.up").font(.system(size: 30))
            }.foregroundColor(textColor)
            Spacer().frame(width: 5)
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.backward").frame(width: 30, height: 40).font(.system(size: 30))
            }.buttonStyle(.glass)
        }.padding(.horizontal, 8)
    }
    
    
    @ViewBuilder
    var uploadCard: some View {
        ZStack{
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(.text).opacity(0.3).onTapGesture {
            if (vm.isDocUploaded == .loaded){
                withAnimation(.interpolatingSpring(stiffness: 100, damping: 10)){
                    showUploadCard = false
                }
            }
        }
        UploadCard(state: vm.isDocUploaded, backgroundColor: backColor, code:list.id, loadMessage: "Uploading..."){
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 10)){
                showUploadCard = false
            }
            showShareAlert = true
        }.frame(maxWidth: .infinity,maxHeight: 300).padding(5).transition(.asymmetric(
            insertion: .scale(scale: 0, anchor: .top),
            removal: .scale(scale: 0, anchor: .top)
        )).task {
            do{
                if (vm.isDocUploaded == .idle){
                    try await vm.uploadData(list: list)
                }
            } catch {
                vm.isDocUploaded = .error
            }
        }
    }
    
    @State var isDocUploaded: Bool = false
    var text: String { "Hello copy this code to the clipboard and download this beatiful note\nYour code: \(list.id)" }
    let url = URL(string: "https://github.com/CoceraCia")
    
    @ViewBuilder
    var alert: some View {
        if let url {
            ActivityView(activityItems: [text, url])
        } else {
            ActivityView(activityItems: [text])
        }
        
    }
}

#Preview {
    ListScreen(list: DataList(id: "prueba", descriptionList: "", from: "", itemList: []))
}

