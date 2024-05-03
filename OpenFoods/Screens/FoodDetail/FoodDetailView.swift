//
//  FoodDetailView.swift
//  OpenFoods
//
//  Created by Matteo Pacini on 03/05/2024.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import SwiftUI


struct FoodDetailView: View {

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy 'at' HH:mm"
        return formatter
    }()

    let food: Food

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Image
                AsyncImage(url: food.photoURL, content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                }, placeholder: {
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(height: 250)
                })
                // Description
                Text(verbatim: food.description)
                    .lineLimit(nil)
                    .padding()
                // Update time
                HStack {
                    Text("Last updated:")
                        .bold()
                    Text(verbatim: Self.dateFormatter.string(from: food.lastUpdatedDate))
                }
                // Push to top
                Spacer()
            }
        }
        .navigationTitle(food.name)
    }
}

