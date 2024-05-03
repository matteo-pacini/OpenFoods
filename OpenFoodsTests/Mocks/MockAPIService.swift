//
//  MockAPIService.swift
//  OpenFoodsTests
//
//  Created by Matteo Pacini on 03/05/2024.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation
@testable import OpenFoods

final class MockAPIService: NSObject, APIService {

    @objc dynamic var getFoodsCalled = false
    var getFoodsResult: Result<[Food], Error> = .success([])

    @objc dynamic var likeCalled = false
    var likeResult: Result<Void, Error> = .success(())

    @objc dynamic var unlikeCalled = false
    var unlikeResult: Result<Void, Error> = .success(())

    func getFoods() async throws -> [Food] {
        getFoodsCalled = true
        switch getFoodsResult {
        case .success(let success):
            return success
        case .failure(let failure):
            throw failure
        }
    }
    
    func like(food: Food) async throws {
        likeCalled = true
        switch likeResult {
        case .success(let success):
            return success
        case .failure(let failure):
            throw failure
        }
    }
    
    func unlike(food: Food) async throws {
        unlikeCalled = true
        switch unlikeResult {
        case .success(let success):
            return success
        case .failure(let failure):
            throw failure
        }
    }
    

}
