//
//  APIService.swift
//  OpenFoods
//
//  Created by Matteo Pacini on 03/05/2024.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation

// MARK: - Protocol

protocol APIService {
    func getFoods() async throws -> [Food]
    func like(food: Food) async throws
    func unlike(food: Food) async throws
}

// MARK: - Implementation

final class APIServiceImplementation {

    enum Error: LocalizedError {
        case invalidStatusCode(Int)
        case couldNotLikeFood(Food)
        case couldNotUnlikeFood(Food)
        var errorDescription: String? {
            switch self {
            case let .invalidStatusCode(code):
                """
                Server replied with invalid status code: \(code).
                """
            case let .couldNotLikeFood(food):
                """
                Could not like food \"\(food.name)\" (id: \(food.id)).
                """
            case let .couldNotUnlikeFood(food):
                """
                Could not unlike food \"\(food.name)\" (id: \(food.id)).
                """
            }
        }
    }

    static let remote: URL =
        .init(string: "https://opentable-dex-ios-test-d645a49e3287.herokuapp.com/api/v1/Mpacini")!

    private lazy var decoder = {
        $0.dateDecodingStrategy = .iso8601
        return $0
    }(JSONDecoder())

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30 // seconds
        configuration.timeoutIntervalForResource = 30 // seconds
        return URLSession(configuration: configuration)
    }()

}

extension APIServiceImplementation: APIService {

    func getFoods() async throws -> [Food] {
        let request = URLRequest(url: Self.remote.appending(path: "food"))
        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode < 200 || httpResponse.statusCode > 299 {
            throw Error.invalidStatusCode(httpResponse.statusCode)
        }
        return try decoder.decode([Food].self, from: data)
    }
    
    func like(food: Food) async throws {
        struct Response: Decodable { let success: Bool }
        let requestURL =
        Self.remote
            .appending(path: "food")
            .appending(path: "\(food.id)")
            .appending(path: "like")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode < 200 || httpResponse.statusCode > 299 {
            throw Error.invalidStatusCode(httpResponse.statusCode)
        }
        let status = try decoder.decode(Response.self, from: data)
        guard status.success else  {
            throw Error.couldNotLikeFood(food)
        }
    }
    
    func unlike(food: Food) async throws {
        struct Response: Decodable { let success: Bool }
        let requestURL =
        Self.remote
            .appending(path: "food")
            .appending(path: "\(food.id)")
            .appending(path: "unlike")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode < 200 || httpResponse.statusCode > 299 {
            throw Error.invalidStatusCode(httpResponse.statusCode)
        }
        let status = try decoder.decode(Response.self, from: data)
        guard status.success else  {
            throw Error.couldNotUnlikeFood(food)
        }
    }

}
