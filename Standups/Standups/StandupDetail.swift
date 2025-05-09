//
//  StandupDetail.swift
//  Standups
//
//  Created by 이승진 on 5/7/25.
//

import ComposableArchitecture
import SwiftUI

struct StandupDetailFeature: Reducer {
    struct State: Equatable {
        @PresentationState var editStandup: StandupFormFeature.State?
        var standup: Standup
    }
    
    enum Action {
        case cancelEditStandupButtonTapped
        case deleteButtonTapped
        case deleteMeetings(atOffsets: IndexSet)
        case editButtonTapped
        case editStandup(PresentationAction<StandupFormFeature.Action>)
        case saveStandupButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelEditStandupButtonTapped:
                state.editStandup
                return .none
            case .deleteButtonTapped:
                return .none
            case .deleteMeetings(atOffsets: let indices):
                state.standup.meetings.remove(atOffsets: indices)
                return .none
            case .editButtonTapped:
                state.editStandup = StandupFormFeature.State(standup: state.standup)
                return .none
            case .editStandup:
                return .none
            case .saveStandupButtonTapped:
                guard let standup = state.editStandup?.standup
                else { return .none }
                state.standup = standup
                state.editStandup = nil
                return .none
            }
        }
        .ifLet(\.$editStandup, action: /Action.editStandup) {
            StandupFormFeature()
        }
    }
}

struct StandupDetailView: View {
    let store: StoreOf<StandupDetailFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            List {
                Section {
                    NavigationLink {
                        
                    } label: {
                        Label("Start Meeting", systemImage: "timer")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    }
                    
                    HStack {
                        Label("Length", systemImage: "clock")
                        Spacer()
                        Text(viewStore.standup.duration.formatted(.units()))
                    }
                    
                    HStack {
                        Label("Theme", systemImage: "paintpalette")
                        Spacer()
                        Text("Bubblegum")
                            .padding(4)
                            .foregroundColor(viewStore.standup.theme.accentColor)
                            .background(viewStore.standup.theme.mainColor)
                            .cornerRadius(4)
                    }
                } header: {
                    Text("Standup Info")
                }
                
                if !viewStore.standup.meetings.isEmpty {
                    Section {
                        ForEach(viewStore.standup.meetings) { metting in
                            NavigationLink {
                                
                            } label: {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text(metting.date, style: .date)
                                    Text(metting.date, style: .time)
                                }
                            }
                        }
                        .onDelete { indices in
                            viewStore.send(.deleteMeetings(atOffsets: indices))
                        }
                    } header: {
                        Text("Past meetings")
                    }
                }
                
                Section {
                    ForEach(viewStore.standup.attendees) { attendee in
                        Label(attendee.name, systemImage: "person")
                    }
                } header: {
                    Text("Attendees")
                }
                
                Section {
                    Button("Delete") {
                        viewStore.send(.deleteButtonTapped)
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(viewStore.standup.title)
            .toolbar {
                Button("Edit") {
                    viewStore.send(.editButtonTapped)
                }
            }
            .sheet(store: self.store.scope(
                state: \.$editStandup,
                action: { .editStandup($0) })) { store in
                NavigationStack {
                    StandupFormView(store: store)
                        .navigationTitle("Edit standup")
                        .toolbar {
                            ToolbarItem {
                                Button("Save") {
                                    viewStore.send(.saveStandupButtonTapped)
                                }
                            }
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    viewStore.send(.cancelEditStandupButtonTapped)
                                }
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    MainActor.assumeIsolated {
        NavigationStack {
            StandupDetailView(
                store: Store(initialState:
                        StandupDetailFeature.State(standup: .mock)) {
                            StandupDetailFeature()
                        }
            )
        }
    }
}
