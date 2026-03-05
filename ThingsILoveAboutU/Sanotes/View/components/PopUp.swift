//
//  PopUp.swift
//  ThingsILoveAboutU
//
//  Created by Miguel Cocera on 17/2/26.
//


import SwiftUI

enum LoadingState{
    case idle
    case loading
    case loaded
    case error
}

struct LoadingCard<NotStarted: View, Loaded: View, ErrorContent: View>: View {
    var state: LoadingState
    let backgroundColor: Color
    let loadMessage: String
    let notStartedContent: NotStarted
    let loadedContent: Loaded
    let errorContent: ErrorContent
    
    
    init(
        state: LoadingState,
        loadMessage: String,
        backgroundColor: Color,
        @ViewBuilder notStartedContent: () -> NotStarted,
        @ViewBuilder loadedContent: () -> Loaded,
        @ViewBuilder errorContent: () -> ErrorContent
    ) {
        self.state = state
        self.loadMessage = loadMessage
        self.notStartedContent = notStartedContent()
        self.loadedContent = loadedContent()
        self.errorContent = errorContent()
        self.backgroundColor = backgroundColor
    }
    var body: some View {
        GeometryReader{geo in
            VStack{
                switch state {
                case .idle:
                    notStartedContent
                case .loading:
                    ProgressView(loadMessage)
                case .loaded:
                    loadedContent
                case .error:
                    errorContent
                }
            }.frame(maxWidth: .infinity ,maxHeight: .infinity).animation(.easeInOut, value: state).padding(15)
        }.background(
            RoundedRectangle(cornerRadius: 40).fill(backgroundColor)
        )
    }
}



struct UploadCard:View {
    let state:LoadingState
    let backgroundColor:Color
    let code: String
    let loadMessage:String
    var onShareClicked:() -> Void
    
    
    var body: some View {
        LoadingCard(
            state: state,
            loadMessage: loadMessage,
            backgroundColor: backgroundColor,
            notStartedContent: { EmptyView() },
            loadedContent: { loadedContent },
            errorContent: { errorView }
        )
    }
    
    var loadedContent: some View {
        VStack{
            Spacer()
            VStack(spacing:20){
                Text("Everything done").font(.system(size: 20, weight: .bold))
                VStack{
                    Text("1 Copy the code")
                    Text("2 Insert it on the app")
                }
                VStack{
                    Text("Your code").font(.system(size: 13)).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 2)
                    HStack(spacing: 15){
                        ScrollView(.horizontal, showsIndicators: false){
                            Text(code).textSelection(.enabled)
                        }
                        Button{
                            UIPasteboard.general.string = code
                        }label: {
                            Image(systemName: "list.clipboard.fill").foregroundColor(.text)
                        }
                    }.padding(10).glassEffect()
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Button(action: onShareClicked){
                Text("Share it").frame(maxWidth:.infinity).padding(5)
            }.buttonStyle(.glass)
        }
    }
    
    var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text("Something went wrong")
                .font(.system(size: 16, weight: .semibold))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity).background(backgroundColor)
    }
}

struct ImportListCard:View{
    @FocusState.Binding var isInputFocused:Bool
    let state:LoadingState
    let loadMessage:String
    var onCodeSet:(_ text: String) -> Void
    var onClose:() -> Void
    @State var code:String = ""
    
    var body: some View {
        ZStack{
            LoadingCard(
                state: state,
                loadMessage: loadMessage,
                backgroundColor: .surfaceVariant,
                notStartedContent: { notStartedContent },
                loadedContent: { loadedContent },
                errorContent: { errorView }
            )
        }
    }
    
    var notStartedContent: some View {
        VStack{
            Text("Download a note").font(.system(size: 24, weight: .bold))
            Spacer()
            Text("❤️").font(.system(size: 80))
            Spacer()
            HStack(spacing: 5){
                ZStack{
                    Color.surface
                    TextField("Your code here",text: $code).padding(.horizontal, 10).focused($isInputFocused)
                }.frame(maxWidth: .infinity, maxHeight: 57).clipShape(RoundedRectangle(cornerRadius: 30))
                Button{onCodeSet(code)}label: {
                    Image(systemName: "paperplane")
                }.frame(width: 57, height: 57).background(RoundedRectangle(cornerRadius: 50).fill(.surface)).foregroundColor(.text)
            }
        }
    }
    
    var loadedContent: some View {
        VStack(spacing: 10){
            Image(systemName: "checkmark.circle").font(.system(size: 60))
            Text("Notes downloaded successfully")
        }.foregroundColor(.green)
    }
    
    var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text("Something went wrong")
                .font(.system(size: 16, weight: .semibold))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
