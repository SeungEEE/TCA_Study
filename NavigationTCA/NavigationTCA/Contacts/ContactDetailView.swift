//
//  ContactDetailView.swift
//  NavigationTCA
//
//  Created by 이안 on 10/17/25.
//

import SwiftUI
import ComposableArchitecture

struct ContactDetailView: View {
  let store: StoreOf<ContactDetailFeature>
  
  var body: some View {
    Form {
      
    }
    .navigationBarTitle(Text(store.contact.name))
  }
}

#Preview {
  NavigationStack {
    ContactDetailView(
      store: Store(
        initialState: ContactDetailFeature.State(
          contact: Contact(id: UUID(), name: "Blob")
        )
      ) {
        ContactDetailFeature()
      }
    )
  }
}
