//
//  CrossUtil.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/3/30.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

import SwiftUI

struct StackNavigationView<RootContent>: View where RootContent: View {
    @Binding var currentSubview: AnyView
    @Binding var showingSubview: Bool
    let rootView: () -> RootContent
    
    init(currentSubview: Binding<AnyView>, showingSubview: Binding<Bool>,
    @ViewBuilder rootView: @escaping () -> RootContent) {
            self._currentSubview = currentSubview
            self._showingSubview = showingSubview
            self.rootView = rootView
        }
    
    var body: some View {
        VStack {
            if !showingSubview {
                rootView()
            } else {
                StackNavigationSubview(isVisible: $showingSubview) {
                    currentSubview
            }
            .transition(.move(edge: .trailing))
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
}


private struct StackNavigationSubview<Content>: View where Content: View {
    @Binding var isVisible: Bool
    let contentView: () -> Content
    
    var body: some View {
        VStack {
            contentView() // subview
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isVisible = false
                    }
                }, label: {
                    Label("back", systemImage: "chevron.left")
                })
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}


extension Error where Self:Equatable
{
    fileprivate
    func equals(_ other:any Error) -> Bool
    {
        (other as? Self).map { $0 == self } ?? false
    }
}
