//
//  AddEditList.swift
//  ThingsILoveAboutU
//
//  Created by Miguel Cocera on 6/2/26.
//

import SwiftUI
import SwiftData
import PhotosUI

enum HeaderField: Hashable {
    case from
    case title
    case card
}

struct ModifyListScreen: View {
    @State private var vm = ModifyListViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @FocusState private var isFocused: HeaderField?
    @FocusState private var focusedItemId: String?
    
    @State private var isAnyEditorFocused: Bool = false
    @State private var loseFocus:Bool = false
    
    init(list: DataList? = nil) {
        if let list {
            self.vm.list = list
            self.vm.from = list.from
            self.vm.title = list.descriptionList
        }
    }
    
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading, spacing: 10) {
                topBar
                ScrollViewReader { proxy in
                    ScrollView(.vertical) {
                            ForEach(Array($vm.list.itemList.enumerated()), id: \.element.id) { index, $item in
                                
                                TextEditorPlusImage(vm:vm,item:$item, focusedItemId: $focusedItemId, isAnyEditorFocused: $isAnyEditorFocused, loseFocus: $loseFocus).contextMenu {
                                    Button(role: .destructive) {
                                        vm.deleteItem(item: item)
                                        vm.refresh()
                                    } label: { Label("Delete", systemImage: "trash") }
                                }
                            }.onChange(of: vm.list.itemList.count) {
                                withAnimation {
                                    proxy.scrollTo("BOTTOM", anchor: .bottom)
                                }
                            }
                        
                        Color.clear
                            .frame(height: 1)
                            .id("BOTTOM")
                    }
                }
                
                ZStack{
                    Button("Add Item") {
                        let newItem = ItemList(id: UUID().uuidString, content: "", image: nil)
                        vm.list.itemList.append(newItem)
                        focusedItemId = vm.list.itemList[ vm.list.itemList.count - 1].id
                    }.buttonStyle(.plain).foregroundColor(Color.blue)
                }.frame(maxWidth: .infinity)
                Spacer()
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(10)
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color("surface")).foregroundColor(Color("text")).navigationBarBackButtonHidden(true)
        
    }
    
    var topBar: some View {
        HStack(alignment: .top){
            VStack{
                HStack{
                    Text("From:").font(.system(size: 20, weight: .semibold))
                    TextField("Your Name", text: $vm.from).font(.system(size: 20, weight: .medium))
                        .textFieldStyle(.plain)
                        .onChange(of: vm.from){oldValue, newValue in
                            vm.list.from = newValue
                        }.focused($isFocused, equals: .from)
                        .onSubmit {
                            isFocused = .title
                        }.submitLabel(.next)
                }
                
                TextField("Your title here", text: $vm.title)
                    .font(.system(size: 30, weight: .black))
                    .onSubmit {
                        isFocused = nil
                        if (vm.list.itemList.count > 0){
                            focusedItemId = vm.list.itemList[0].id
                        }
                    }.submitLabel(.next)
                    .textFieldStyle(.plain)
                    .font(.system(size: 30))
                    .onChange(of: vm.title){oldValue, newValue in
                        vm.list.descriptionList = newValue
                    }.focused($isFocused, equals: .title)
                
            }.onChange(of: isFocused){ oldValue, newValue in
                isAnyEditorFocused = (newValue != nil || focusedItemId != nil)
            }.onChange(of: loseFocus){oldValue, newValue in
                if newValue {
                    isFocused = nil
                    loseFocus = false
                }
            }
            VStack{
                if !isAnyEditorFocused {
                    Button {
                        if (vm.checkParamsOnExit()){
                            modelContext.insert(vm.list)
                        }
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward").frame(width: 30, height: 40).font(.system(size: 30))
                    }.buttonStyle(.glass)
                } else {
                    Button {
                        isFocused = nil
                        focusedItemId = nil
                        isAnyEditorFocused = false
                        loseFocus = true
                    } label: {
                        Image(systemName: "checkmark").foregroundColor(.white)
                            .frame(width: 30, height: 40).font(.system(size: 30))
                    }.buttonStyle(.glassProminent)
                    
                    
                }
                Text("\(vm.list.itemList.count) notes")
            }
        }.padding(10)
    }
}


#Preview {
    ModifyListScreen(list:nil)
}

private struct TextEditorPlusImage: View {
    let vm: ModifyListViewModel
    @State var selectedItem: PhotosPickerItem? = nil
    @Binding var item: ItemList
    
    var focusedItemId: FocusState<String?>.Binding
    @FocusState var isFocused: Bool
    @Binding var isAnyEditorFocused: Bool
    @Binding var loseFocus: Bool
    
    
    var body: some View {
        ZStack{
            HStack(alignment: .bottom){
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    
                    if let data = item.image, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage).resizable()
                            .scaledToFill()
                    } else {
                        VStack(spacing: 10){
                            Image(systemName: "photo")
                            Text("No Image").font(.system(size: 10))
                        }.frame(maxWidth: .infinity,maxHeight: .infinity).background(.surface)
                    }
                }.frame(width: 170, height: 188)
                    .clipped().clipShape(RoundedRectangle(cornerRadius: 20)).padding(.vertical, 5).padding(.leading, 5).onChange(of: selectedItem){_, newItem in
                        guard let newItem else {return}
                        Task{
                            item.image = try await vm.loadImage(item: newItem)
                        }
                    }
                
                
                TextEditor(text:$item.content)
                    .focused(focusedItemId, equals: item.id)
                    .onChange(of: focusedItemId.wrappedValue) {
                        let newValue = focusedItemId.wrappedValue
                        if newValue != $item.id {
                            
                        } else {
                            isAnyEditorFocused = true
                        }
                    }
                    .frame(maxHeight: 188)
                    .scrollContentBackground(.hidden).padding(.vertical, 5).padding(.trailing, 5)
            }
        }.background(
            RoundedRectangle(cornerRadius: 25).fill(Color("surfaceVariant"))
        ).onChange(of: loseFocus){oldValue, newValue in
            if newValue {
                isFocused = false
                loseFocus = false
            }
        }
    }
}

