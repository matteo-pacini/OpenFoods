//
//  FoodListViewModel.swift
//  OpenFoods
//
//  Created by Matteo Pacini on 03/05/2024.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation
import UIKit

protocol FoodListViewModelDelegate: AnyObject {
    func foodListViewModel(_ sender: FoodListViewModel, foodsDidChange foods: [Food])
    func foodListViewModel(_ sender: FoodListViewModel, didFailWithError error: any Error)
}

@MainActor
final class FoodListViewModel: NSObject {

    weak var delegate: FoodListViewModelDelegate?

    @LazyInjected
    private var apiService: any APIService

    func viewDidAppear() {
        fetchFoods()
    }

    func didTapRefreshButton() {
        fetchFoods()
    }

    func toggleLikeFor(food: Food) {
        Task {
            do {
                let networkCall = food.isLiked ? apiService.unlike(food:) : apiService.like(food:)
                try await networkCall(food)
                // Refresh the list of foods - ideally, we would only fetch the exact food that was modified,
                // or even better - the API could just return the updated object so we can store it directly.
                let foods = try await apiService.getFoods()
                delegate?.foodListViewModel(self, foodsDidChange: foods)
            } catch {
                delegate?.foodListViewModel(self, didFailWithError: error)
            }
        }
    }

    private func fetchFoods() {
        Task {
            do {
                let foods = try await apiService.getFoods()
                delegate?.foodListViewModel(self, foodsDidChange: foods)
            } catch {
                delegate?.foodListViewModel(self, didFailWithError: error)
            }
        }
    }

}

