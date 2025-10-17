//
//  ContactDetailFeature.swift
//  NavigationTCA
//
//  Created by 이안 on 10/17/25.
//

import ComposableArchitecture

@Reducer
struct ContactDetailFeature {
  @ObservableState
  struct State: Equatable {
    let contact: Contact
  }
  
  enum Action {
    
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      }
    }
  }
}
