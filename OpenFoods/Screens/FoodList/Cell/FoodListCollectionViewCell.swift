//
//  FoodListCollectionViewCell.swift
//  OpenFoods
//
//  Created by Matteo Pacini on 03/05/2024.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

// MARK: - Delegate

protocol FoodListCollectionViewCellDelegate: AnyObject {
    func foodListCollectionViewCell(_ sender: FoodListCollectionViewCell, didTapOnLikeButtonForFood food: Food)

}

// MARK: - Cell

@MainActor
final class FoodListCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = String(describing: FoodListCollectionViewCell.self)

    // MARK: Public properties

    weak var delegate: FoodListCollectionViewCellDelegate?

    var food: Food? {
        didSet {
            update()
        }
    }

    // MARK: Private properties

    private var currentImageTask: DownloadTask?

    // MARK: Views

    lazy var imageView: UIImageView = {
        $0.backgroundColor = .gray
        $0.translatesAutoresizingMaskIntoConstraints = false;
        $0.clipsToBounds = true;
        $0.contentMode = .scaleAspectFill
        return $0
    }(UIImageView(frame: .zero))

    lazy var imageViewGradient: CAGradientLayer = {
        $0.startPoint = .init(x: 0.5, y: 0.0)
        $0.endPoint = .init(x: 0.5, y: 1.0)
        $0.locations = [
            0.0,
            0.5,
            1.0
        ]
        $0.colors = [
            UIColor.black.cgColor,
            UIColor.clear.cgColor,
            UIColor.black.cgColor
        ]
        return $0
    }(CAGradientLayer())

    lazy var descriptionLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .white
        $0.numberOfLines = 0
        return $0
    }(UILabel(frame: .zero))


    lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 14, weight: .bold)
        $0.textColor = .white
        $0.numberOfLines = 1
        return $0
    }(UILabel(frame: .zero))

    lazy var likeButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.titleLabel?.font = .systemFont(ofSize: 35)
        $0.setTitle("🩶", for: .normal)
        $0.setTitle("❤️", for: .selected)
        $0.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        return $0
    }(UIButton(type: .custom))

    // MARK: UICollectionViewCell lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup

    private func setup() {
        contentView.backgroundColor = .white

        contentView.addSubview(imageView)
        imageView.layer.insertSublayer(imageViewGradient, at: 0)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(likeButton)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 50),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -8),

            likeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

        ])

        // Forces an initial layout pass so the gradient is displayed correctly
        // at cell creation.
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }

    // MARK: Update

    private func update() {
        guard let food else { return }

        currentImageTask = imageView.kf.setImage(
            with: food.photoURL
        )

        descriptionLabel.text = food.description
        titleLabel.text = "\(food.name) (🌐 \(food.countryOfOrigin))"
        likeButton.isSelected = food.isLiked

        contentView.setNeedsLayout()

    }

    // MARK: Reuse

    override func prepareForReuse() {
        
        super.prepareForReuse()

        currentImageTask?.cancel()
        currentImageTask = nil

        imageView.backgroundColor = .gray

        descriptionLabel.text = nil
        titleLabel.text = nil
        likeButton.isSelected = false


    }

    // MARK: Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update gradient frame without implicit animations
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        imageViewGradient.frame = imageView.bounds
        CATransaction.commit()
    }

    // MARK: Actions

    @objc 
    private func didTapLikeButton() {
        guard let food else { return }
        delegate?.foodListCollectionViewCell(self, didTapOnLikeButtonForFood: food)
    }

}
