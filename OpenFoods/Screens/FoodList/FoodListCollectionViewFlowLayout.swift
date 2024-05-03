//
//  FoodListCollectionViewFlowLayout.swift
//  OpenFoods
//
//  Created by Matteo Pacini on 03/05/2024.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import UIKit

final class FoodListCollectionViewFlowLayout: UICollectionViewFlowLayout {

    private enum Constants {
        static let itemSpacing: CGFloat = 8
        static let cellHeightAsParentHeightRatio: CGFloat = 0.4
        static let leftInset: CGFloat = 16
        static let rightInset: CGFloat = 16
    }

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }

        self.minimumInteritemSpacing = Constants.itemSpacing

        // Width
        var cellWidth = collectionView.bounds.inset(
            by: collectionView.layoutMargins
        ).width
        cellWidth = cellWidth - Constants.leftInset - Constants.rightInset

        // Height
        let cellHeight = collectionView.bounds.inset(
            by: collectionView.layoutMargins
        ).height * Constants.cellHeightAsParentHeightRatio

        self.itemSize = .init(width: cellWidth, height: cellHeight)

    }

}
