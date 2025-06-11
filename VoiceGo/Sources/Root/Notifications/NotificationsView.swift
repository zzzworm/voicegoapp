//
//  NotificationsView.swift
// VoiceGo
//
//  Created by Anatoli Petrosyants on 05.10.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - NotificationsFeatureView

struct NotificationsView : View {
    @Bindable var store: StoreOf<NotificationsFeature>

    
    var body: some View {
        content
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    @ViewBuilder private var content: some View {
        WithPerceptionTracking {
            NavigationStack {
                ZStack(alignment: .center) {
                    if store.items.isEmpty {
                        if #available(iOS 17.0, *) {
                            ContentUnavailableView {
                                Label("You don't have any notifications.", systemImage: "bell.fill")
                                    .font(.title2)
                                    .foregroundColor(Color.black)
                            }
                        } else {
                            VStack {
                                Label("You don't have any notifications.", systemImage: "bell.fill")
                                    .font(.title2)
                                    .foregroundColor(Color.black)
                            }
                        }
                    } else {
                        List(store.items, id: \.id) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(item.title)")
                                    .font(.body)
                                    .fontWeight(.bold)
                                
                                Text("\(item.description)")
                                    .font(.footnote)
                                    .foregroundColor(Color.black.opacity(0.6))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                store.send(.view(.onNotificationTap(notification: item)))
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Mark as read") {
                                    store.send(.view(.onNotificationTap(notification: item)))
                                }
                                .tint(.blue)
                            }
                        }
                        .environment(\.defaultMinListRowHeight, 54)
                        .listRowBackground(Color.clear)
                        .listStyle(.plain)
                    }
                }
                .padding()
                .navigationTitle("Notifications (\(store.items.count))")
            }
            .badge(store.items.count)
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}
