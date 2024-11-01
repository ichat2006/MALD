//
//  GenericApi.swift
//  
//
//  Created by Ishaan Chaturvedi
//


import Foundation

protocol GenericApi {
    var session: URLSession { get }
    func fetch<T: Codable>(type: T.Type, with request: URLRequest) async throws -> T
    func fetchString(with request: URLRequest) async throws -> String
}

extension GenericApi {
    func fetch<T: Codable>(type: T.Type, with request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        return try handleResponse(data: data, response: response, expectedType: type)
    }
    
    func fetchString(with request: URLRequest) async throws -> String {
        let (data, response) = try await session.data(for: request)
        return try handleStringResponse(data: data, response: response)
    }
    
    private func handleResponse<T: Codable>(data: Data, response: URLResponse, expectedType: T.Type) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.requestFailed(description: "Invalid response")
        }
        print("HttpResponse status Code: \(httpResponse.statusCode) ")
        guard httpResponse.statusCode == 200 else {
            throw ApiError.responseUnsuccessful(description: "Status code: \(httpResponse.statusCode)")
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(expectedType, from: data)
        } catch {
            throw ApiError.jsonConversionFailure(description: error.localizedDescription)
        }
    }
    
    private func handleStringResponse(data: Data, response: URLResponse) throws -> String {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.requestFailed(description: "Invalid response")
        }
        print("HttpResponse status Code: \(httpResponse.statusCode) ")
        guard httpResponse.statusCode == 200 else {
            throw ApiError.responseUnsuccessful(description: "Status code: \(httpResponse.statusCode)")
        }
        
        if let stringResponse = String(data: data, encoding: .utf8) {
            return stringResponse
        } else {
            throw ApiError.jsonConversionFailure(description: "Failed to convert data to string")
        }
    }
}
