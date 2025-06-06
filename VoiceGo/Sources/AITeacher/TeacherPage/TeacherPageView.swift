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
    private let scrollItemSize = CGSize(width: 35, height: 100)
    
    var body: some View {
        WithPerceptionTracking {
            GeometryReader { geometry in
                VStack(spacing: 0) {
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
                                        .frame(height: geometry.size.height * imageHeightRatio)
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
                    
                    // Scrollable teacher list
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(store.state.aiTeacherList) { teacher in
                                if  let url = URL(string: teacher.coverUrl) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: scrollItemSize.width, height: scrollItemSize.height)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        case .failure(_):
                                            Color.gray.opacity(0.3)
                                                .frame(width: scrollItemSize.width, height: scrollItemSize.height)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        case .empty:
                                            ProgressView()
                                                .frame(width: scrollItemSize.width, height: scrollItemSize.height)
                                        @unknown default:
                                            Color.gray.opacity(0.3)
                                                .frame(width: scrollItemSize.width, height: scrollItemSize.height)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                    }
                                } else {
                                    Color.gray.opacity(0.3)
                                        .frame(width: scrollItemSize.width, height: scrollItemSize.height)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 16)
                    
                    Spacer()
                    
                    // Start Chat button
                    Button(action: {
                        // Handle start chat action
                    }) {
                        Text("开始聊天")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
                .navigationTitle(store.aiTeacher.name)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    NavigationView {
        AITeacherPageView(
            store: Store(
                initialState: AITeacherPageFeature.State(
                    aiTeacher: AITeacher(
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
                    )
                ),
                reducer: { AITeacherPageFeature() }
            )
        )
    }
}
