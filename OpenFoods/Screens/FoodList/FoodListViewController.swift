//
//  ViewController.swift
//  OpenFoods
//
//  Created by Oliver Kirkland on 16/08/23.
//  Copyright © 2023 OpenTable, Inc. All rights reserved.
//

import UIKit
import SwiftUI

@MainActor
final class FoodListViewController: UIViewController {

    enum FoodListSection: Int {
        case main
    }

    typealias DataSource = UICollectionViewDiffableDataSource<FoodListSection, Food>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<FoodListSection, Food>

    // MARK: View Model

    var viewModel: FoodListViewModel! {
        didSet {
            viewModel.delegate = self
        }
    }

    // MARK: Data Source

    private lazy var dataSource: DataSource =
    .init (
        collectionView: collectionView
    ) { [weak self] (collectionView, indexPath, food) in
        guard let foodCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FoodListCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? FoodListCollectionViewCell else {
            fatalError("Could not dequeue a food cell - has the cell been registered?")
        }
        foodCell.delegate = self
        foodCell.food = food
        return foodCell
    }

    // MARK: Views

    lazy var collectionView: UICollectionView = {
        $0.backgroundColor = .white
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(
            FoodListCollectionViewCell.self,
            forCellWithReuseIdentifier: FoodListCollectionViewCell.reuseIdentifier
        )
        $0.delegate = self
        return $0
    }(UICollectionView(frame: .zero, 
                       collectionViewLayout: FoodListCollectionViewFlowLayout()))

    // MARK: UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Foods"
        view.addSubview(collectionView)
        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationItem.rightBarButtonItem =
        UIBarButtonItem(systemItem: .refresh, primaryAction: UIAction(handler: { [weak self] _ in
            self?.viewModel.didTapRefreshButton()
        }))

        viewModel.viewDidAppear()
    }

    // MARK: Layout

    private func setupConstraints() {

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])

    }

}

// MARK: - UICollectionViewDelegate

extension FoodListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let tappedFood = dataSource.itemIdentifier(for: indexPath) else {
            debugPrint("WARNING: A food has been selected but cannot be found in the data source (?)")
            return
        }

        let detailView = FoodDetailView(food: tappedFood)
        let detailHostingController = UIHostingController(rootView: detailView)

        navigationController?.pushViewController(detailHostingController, animated: true)
    }

}

// MARK: - View Model Delegate

extension FoodListViewController: FoodListViewModelDelegate {

    func foodListViewModel(_ sender: FoodListViewModel, foodsDidChange foods: [Food]) {

        var snapshot = DataSourceSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(foods)
        dataSource.apply(snapshot)

    }

    func foodListViewModel(_ sender: FoodListViewModel, didFailWithError error: any Error) {

        let alertController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alertController.addAction(.init(title: "Dismiss", style: .default))

        self.present(alertController, animated: true)

    }

}

// MARK: - FoodListCollectionViewCellDelegate

extension FoodListViewController: FoodListCollectionViewCellDelegate {

    func foodListCollectionViewCell(_ sender: FoodListCollectionViewCell, didTapOnLikeButtonForFood food: Food) {
        viewModel.toggleLikeFor(food: food)
    }

}
