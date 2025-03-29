//
//  SampleData.swift
//  VoiceGo
//
//  Created by zzzworm on 2025/3/28.
//

extension StudyTool {
    static var sample: [StudyTool] {
        [
            .init(
                id: 1,
                title: "AI翻译",
                description: "支持中文翻译",
                category: "men's clothing",
                imageString: "tshirt"
            ),
            .init(
                id: 2,
                title: "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops",
                description: "Your perfect pack for everyday use and walks in the forest. Stash your laptop (up to 15 inches) in the padded sleeve, your everyday",
                category: "men's clothing",
                imageString: "bag"
            ),
            .init(
                id: 3,
                title: "Mens Cotton Jacket",
                description: "Great outerwear jackets for Spring/Autumn/Winter, suitable for many occasions, such as working, hiking, camping, mountain/rock climbing, cycling, traveling or other outdoors. Good gift choice for you or your family member. A warm hearted love to Father, husband or son in this thanksgiving or Christmas Day.",
                category: "men's clothing",
                imageString: "jacket"
            )
        ]
    }
}
