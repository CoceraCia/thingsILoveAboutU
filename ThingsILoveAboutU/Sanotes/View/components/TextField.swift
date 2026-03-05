//
//  TextField.swift
//  ThingsILoveAboutU
//
//  Created by Miguel Cocera on 6/2/26.
//

import SwiftUI

struct NakedTextField: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.backgroundColor = .clear
        tf.textAlignment = .left
        tf.setContentHuggingPriority(.defaultLow, for: .horizontal)
        tf.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
}

struct AppBasicTextField: View {
    @Binding var text: String
    let placeholder: String
    @FocusState var isFocused:Bool
    
    let onValueChange: (String) -> Void
    let onSubmit: () -> Void
    
    
    
    
    var body: some View {
        TextField(placeholder, text: $text).textFieldStyle(.plain).onChange(of: text){oldValue, newValue in
            onValueChange(newValue)
        }.focused($isFocused).onSubmit {
            onSubmit()
        }.submitLabel(.next)
    }
}
