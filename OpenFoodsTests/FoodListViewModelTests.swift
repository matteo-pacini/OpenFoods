//
//  OpenFoodsTests.swift
//  OpenFoodsTests
//
//  Created by Matteo Pacini on 03/05/2024.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import XCTest
import Swinject
@testable import OpenFoods

final class MockFoodListViewModelDelegate: NSObject, FoodListViewModelDelegate {
    @objc dynamic var foodsDidChangeCalled = false
    func foodListViewModel(_ sender: OpenFoods.FoodListViewModel, foodsDidChange foods: [OpenFoods.Food]) {
        foodsDidChangeCalled = true
    }
    @objc dynamic var didFailWithErrorCalled = false
    func foodListViewModel(_ sender: OpenFoods.FoodListViewModel, didFailWithError error: any Error) {
        didFailWithErrorCalled = true
    }
}

final class FoodListViewModelTests: XCTestCase {

    var sut: FoodListViewModel!

    override func setUp() async throws {
        // Set up a new dependency graph for each test
        OpenFoods.dependencyContainer = Container()

        // Set up a new mock api service for each test
        OpenFoods.dependencyContainer.register(APIService.self, factory: { _ in MockAPIService() })
            .implements(MockAPIService.self)
            .inObjectScope(.container)

        // Set up a new view model for each test
        sut = await FoodListViewModel()
    }

    func test_fetchesFoodsWhenTheViewAppears() async {

        @Injected var mockAPIService: MockAPIService

        let expectation =
        XCTKeyPathExpectation(
            keyPath: \.getFoodsCalled,
            observedObject: mockAPIService,
            expectedValue: true
        )

        await sut.viewDidAppear()

        await fulfillment(of: [expectation], timeout: 10)

        XCTAssertTrue(mockAPIService.getFoodsCalled)

    }

    @MainActor
    func test_callsTheDelegateIfFoodsAreFetchedWhenTheViewAppears() async {

        let mockDelegate = MockFoodListViewModelDelegate()
        sut.delegate = mockDelegate

        let expectation =
        XCTKeyPathExpectation(
            keyPath: \.foodsDidChangeCalled,
            observedObject: mockDelegate,
            expectedValue: true
        )

        sut.viewDidAppear()

        await fulfillment(of: [expectation], timeout: 10)

        XCTAssertTrue(mockDelegate.foodsDidChangeCalled)

    }

    @MainActor
    func test_callsTheDelegateIfAnErrorOccursWhenTheViewAppears() async {

        let mockDelegate = MockFoodListViewModelDelegate()
        sut.delegate = mockDelegate

        let expectation =
        XCTKeyPathExpectation(
            keyPath: \.didFailWithErrorCalled,
            observedObject: mockDelegate,
            expectedValue: true
        )

        @Injected var mockAPIService: MockAPIService
        mockAPIService.getFoodsResult = .failure(APIServiceImplementation.Error.invalidStatusCode(500))

        sut.viewDidAppear()

        await fulfillment(of: [expectation], timeout: 10)

        XCTAssertTrue(mockDelegate.didFailWithErrorCalled)

    }

}
