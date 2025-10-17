//
//  AddContactView.swift
//  NavigationTCA
//
//  Created by 이안 on 10/17/25.
//

import SwiftUI
import ComposableArchitecture

struct AddContactView: View {
  @Bindable var store: StoreOf<AddContactFeature>
  
  var body: some View {
    Form {
      TextField("Name", text: $store.contact.name.sending(\.setName))
      Button("Save") {
        store.send(.saveButtonTapped)
      }
    }
    
    .toolbar {
      ToolbarItem {
        Button("Cancel") {
          store.send(.cancelButtonTapped)
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    AddContactView(
      store: Store(
        initialState: AddContactFeature.State(
          contact: Contact(
            id: UUID(),
            name: "Blob"
          )
        )
      ) {
        AddContactFeature()
      }
    )
  }
}
