//
//  Food.swift
//  OpenFoods
//
//  Created by Matteo Pacini on 03/05/2024.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation

struct Food {

    let id: Int
    let name: String
    let isLiked: Bool
    let photoURL: URL
    let description: String
    let countryOfOrigin: String
    let lastUpdatedDate: Date

}

extension Food: Equatable { }

extension Food: Hashable { }

extension Food: Decodable { }

extension Food: Identifiable { }
