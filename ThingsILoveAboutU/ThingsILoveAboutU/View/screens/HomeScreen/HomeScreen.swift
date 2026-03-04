//
//  HomeScreen.swift
//  ThingsILoveAboutU
//
//  Created by Miguel Cocera on 6/2/26.
//
import SwiftUI
import SwiftData

struct HomeScreen:View{
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DataList.createdAt, order: .reverse)
    private var items: [DataList]
    
    @State var vm = HomeScreenViewModel()
    
    @State private var isActive: Bool = false
    @State private var importOne: Bool = false
    @State private var goNewOne: Bool = false
    
    @FocusState private var isFieldFocused: Bool
    @State private var idToImport: String = ""
    
    
    var body: some View {
        ZStack(alignment: .top){
            VStack{
                topBar.padding(.horizontal, 20).padding(.top, 20)
                
                grid.padding(5)
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            if (importOne) {
                showImportPopup
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color("surface")).foregroundColor(Color("text")).navigationDestination(isPresented: $goNewOne){
            ModifyListScreen()
        }.task(id: vm.state){
            print(idToImport)
            if vm.state == .loading{
                let nItem = await vm.fetchData(id: idToImport.trimmingCharacters(in: .whitespacesAndNewlines))
                guard let nItem else {return}
                modelContext.insert(nItem)
            }
        }
    }
    
    
    var topBar: some View{
        HStack{
            Text("Your notes").font(.system(size: 40, weight: .black))
            Spacer()
            Button{
                if (vm.state == .loaded || vm.state == .error){
                    vm.state = .idle
                }
                withAnimation(.interpolatingSpring(stiffness: 100, damping: 10)) {
                    importOne = true
                }
            }label: {
                Image(systemName: "square.and.arrow.down").font(.system(size: 30))
            }
            Button{goNewOne = true}label: {
                Image(systemName: "plus").font(.system(size: 30))
            }
        }
    }
    
    
    
    var grid: some View{
        VStack{
            ScrollView{
                Grid(horizontalSpacing: 5, verticalSpacing: 5){
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        if index.isMultiple(of: 2){
                            GridRow {
                                NavigationLink {
                                    ListScreen(list: item)
                                } label: {
                                    ContentCardHome(title: item.descriptionList, from: item.from, image: item.itemList[0].image).frame(maxWidth: .infinity, minHeight: 203, maxHeight: 203)
                                }.contextMenu {
                                    NavigationLink {
                                        ModifyListScreen(list: item)
                                    } label: { Label("Edit", systemImage: "pencil") }
                                    Button(role: .destructive) {
                                        modelContext.delete(item)
                                    } label: { Label("Delete", systemImage: "trash") }
                                }
                                
                                if index + 1 < items.count{
                                    NavigationLink {
                                        ListScreen(list: items[index + 1])
                                    } label: {
                                        ContentCardHome(title: items[index + 1].descriptionList, from: items[index + 1].from, image: items[index + 1].itemList[0].image).frame(maxWidth: .infinity, minHeight: 203, maxHeight: 203)
                                    }.contextMenu {
                                        NavigationLink {
                                            ModifyListScreen(list: items[index + 1])
                                        } label: { Label("Edit", systemImage: "pencil") }
                                        Button(role: .destructive) {
                                            modelContext.delete(items[index + 1])
                                        } label: { Label("Delete", systemImage: "trash") }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var showImportPopup: some View{
        VStack{}.frame(maxWidth: .infinity, maxHeight: .infinity).background(.black.opacity(0.3)).onTapGesture {
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 10)) {
                isFieldFocused = false
                importOne = false
            }
        }
        ImportListCard(
            isInputFocused:$isFieldFocused,
            state: vm.state,
            loadMessage: "Downloading assets...",
            onCodeSet: {code in
                if(code.trimmingCharacters(in: .whitespacesAndNewlines) != ""){
                    idToImport = code
                    vm.state = .loading
                }
            },
            onClose: {importOne.toggle()}).frame(height: 236).padding(.horizontal, 5).padding(.top, 72).transition(.asymmetric(
                insertion: .scale(scale: 0, anchor: .top),
                removal: .scale(scale: 0, anchor: .top)
            ))
    }
    
}

#Preview {
    HomeScreen()
    
}
