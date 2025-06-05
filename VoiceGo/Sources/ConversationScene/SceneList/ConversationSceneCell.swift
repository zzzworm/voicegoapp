//
// ConversationSceneCell.swift
// voicegoapp
//
// Created by Cascade on [Current Date].
//

import SwiftUI
import ComposableArchitecture

struct ConversationSceneCell: View {
    let ConversationScene: ConversationScene
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
                .shadow(radius: 2)
            HStack {
                VStack(alignment: .leading) {
                    Text(ConversationScene.name).font(.headline).padding(.bottom, 2)
                    Text(ConversationScene.introduce)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                .padding(10)
                
                Spacer()
                
                Image(systemName: "person.circle") // Placeholder for teacher avatar
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                    .padding(10)
            }
        }
        .enableInjection()
    }
    
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    
}

struct ConversationSceneCell_Previews: PreviewProvider {
    static var previews: some View {
        ConversationSceneCell(
            ConversationScene: ConversationScene(
                id: 1,
                documentId: "teacher_1",
                name: "Dr. Emily Carter",
                introduce: "Expert in conversational English and business terminology. Helping you succeed in professional environments.",
                createdAt: Date(),
                updatedAt: Date(),
                publishedAt: Date(),
                sex: "female",
                difficultyLevel: 2,
                tags: "business,advanced,ielts",
                card: ConversationSceneCard(id: 1,
                                    openingSpeech: "Hello there!",
                                    simpleReplay: "Got it.",
                                    formalReplay: "Understood.",
                                    openingLetter: "Dear Student,",
                                    assistContent: "Let's practice.",
                                    categoryKey: "business"),
                cardId: 1
            )
        )
        .padding()
        .previewLayout(.fixed(width: 375, height: 100))
    }
}
