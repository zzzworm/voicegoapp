//
//  TeacherPageView.swift
//  VoiceGo
//
//  Created by admin on 2025/6/5.
//  Copyright &#169; 2025 Shanghai Souler Information Technology Co., Ltd. All rights reserved.
//
import SwiftUI
import ComposableArchitecture

struct AITeacherPageView: View {
    let store: StoreOf<AITeacherPageFeature>
    
    private let imageHeightRatio: CGFloat = 0.6
    private let scrollItemSize = CGSize(width: 75, height: 100)
    

    var body: some View {
        content
            .enableInjection()
    }
    
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    
    @ViewBuilder private var content: some View {
        WithPerceptionTracking {
            GeometryReader { geometry in
                VStack(alignment:.leading, spacing: 0) {
                    // Image background (60% height)
                    ZStack(alignment: .bottomLeading) {
                        // Teacher's cover image
                        if !store.state.aiTeacher.coverUrl.isEmpty, let url = URL(string: store.state.aiTeacher.coverUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        
                                        .clipped()
                                case .failure(_):
                                    // Fallback to placeholder if image fails to load
                                    Color.gray.opacity(0.3)
                                        .frame(height: geometry.size.height * imageHeightRatio)
                                case .empty:
                                    // Show placeholder while loading
                                    Color.gray.opacity(0.3)
                                        .frame(height: geometry.size.height * imageHeightRatio)
                                @unknown default:
                                    Color.gray.opacity(0.3)
                                        .frame(height: geometry.size.height * imageHeightRatio)
                                }
                            }
                        } else {
                            // Fallback if no cover URL is available
                            Color.gray.opacity(0.3)
                                .frame(height: geometry.size.height * imageHeightRatio)
                        }
                        
                        // Teacher info overlay
                        VStack(alignment: .leading, spacing: 4) {
                            HStack{
                                Text(store.aiTeacher.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                if !store.aiTeacher.tags.isEmpty {
                                    Text(store.aiTeacher.tags.replacingOccurrences(of: ",", with: ", "))
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                            Text(store.state.aiTeacher.introduce)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }

                    teacherListView
                        .padding(EdgeInsets(top: 10, leading: 10, bottom:10, trailing: 0))
                    Spacer()
                    let selectedStyle = CTAButtonStyle(isSelected: true)
                    // Start Chat button
                    Button(action: {
                        // Handle start chat action
                        store.send(.tapTalkToTeacher(store.state.aiTeacher))
                    }) {
                        Text("开始聊天")
                            .font(.headline)
                    }
                    .buttonStyle(selectedStyle)
                    .padding()
                }
            }
            .navigationTitle(store.aiTeacher.name)
            .navigationBarTitleDisplayMode(.inline)

        }
    }
    
    // MARK: - View Variables
    
    @ViewBuilder
    private var teacherListView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.state.aiTeacherList) { teacher in
                        teacherItemView(for: teacher)
                            .id(teacher.id)
                            .onTapGesture {
                                store.send(.selectTeacher(teacher))
                            }
                            .onAppear {
                                // Scroll to selected teacher when view appears
                                if teacher.id == store.state.selectedTeacherId {
                                    withAnimation {
                                        proxy.scrollTo(teacher.id, anchor: .leading)
                                    }
                                }
                            }
                    }
                }
            }
            .onAppear {
                // Initial scroll to selected teacher
                if let selectedId = store.state.selectedTeacherId {
                    withAnimation {
                        proxy.scrollTo(selectedId, anchor: .center)
                    }
                }
            }
            .onChange(of: store.state.selectedTeacherId) { newValue in
                // Scroll when selected teacher changes
                if let newValue = newValue {
                    withAnimation {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
            
        }
    }
    
    @ViewBuilder
    private func teacherItemView(for teacher: AITeacher) -> some View {
        let isSelected = teacher.id == store.state.selectedTeacherId
        
        VStack(spacing: 4) {
            if let url = URL(string: teacher.coverUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: scrollItemSize.width, height: scrollItemSize.height - 20)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                            )
                    case .failure(_):
                        placeholderItem
                    case .empty:
                        ProgressView()
                            .frame(width: scrollItemSize.width, height: scrollItemSize.height - 20)
                    @unknown default:
                        placeholderItem
                    }
                }
            } else {
                placeholderItem
            }
            
            Text(teacher.name)
                .font(.caption)
                .foregroundColor(isSelected ? .blue : .primary)
                .lineLimit(1)
                .frame(width: scrollItemSize.width)
        }
    }
    
    private var placeholderItem: some View {
        let isSelected = store.state.selectedTeacherId == nil
        
        return Color.gray.opacity(0.3)
            .frame(width: scrollItemSize.width, height: scrollItemSize.height)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
    }
}

#Preview {
    NavigationView {
        AITeacherPageView(
            store: Store(
                initialState: AITeacherPageFeature.State(
                    aiTeacherList: IdentifiedArrayOf<AITeacher>.init([
                        AITeacher(
                        id: 1,
                        documentId: "test",
                        name: "Dr. Emily Carter",
                        introduce: "Expert in conversational English and business terminology.",
                        createdAt: Date(),
                        updatedAt: Date(),
                        publishedAt: Date(),
                        sex: "female",
                        difficultyLevel: 2,
                        tags: "Business,Advanced,IELTS",
                        coverUrl: "",
                        card: nil,
                        cardId: nil
                    )]),
                    selectedTeacherId: 1
                ),
                reducer: { AITeacherPageFeature() }
            )
        )
    }
}
