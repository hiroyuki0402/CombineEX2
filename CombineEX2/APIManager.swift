//
//  APIManager.swift
//  CombineEX2
//
//  Created by SHIRAISHI HIROYUKI on 2023/12/21.
//

import Foundation
import Combine

class APIManager {
    private var cancelbels: Set<AnyCancellable> = []

    static let shared = APIManager()

    private let normal = 200 ... 299

    func callAPI<T: Codable>(url: URL?, type: T.Type, complision: @escaping ( Result<T, Error>) -> Void) {
        guard let url = url else { return }
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, self.normal.contains(response.statusCode) else {
                    throw CustomError.inavalit
                }
                return output.data
            }
            .decode(type: type.self, decoder: JSONDecoder())
            .mapError { error in
                switch error {
                case is DecodingError:
                    return CustomError.codingError(error: error)
                default:
                    return CustomError.inavalit
                }
            }
            .sink { completion in
                if case .failure(let error) = completion {
                    complision(.failure(error))
                }
            } receiveValue: { responseData in
                complision(.success(responseData))
            }
            .store(in: &cancelbels)

    }
}

enum CustomError: Error {
    case codingError(error: Error)
    case inavalit
}
