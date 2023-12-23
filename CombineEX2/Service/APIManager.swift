//
//  APIManager.swift
//  CombineEX2
//
//  Created by SHIRAISHI HIROYUKI on 2023/12/23.
//

import Foundation
import Combine
import UIKit

class APIManager {
    /// キャンセル可能な購読を管理するセット
    private var cancelbels: Set<AnyCancellable> = []

    /// APIManagerのシングルトンインスタンス
    static let shared = APIManager()

    /// HTTPステータスコードが成功範囲
    private let normal = 200 ... 299

    /// 画像のキャッシュを管理するためのNSCacheインスタンス
    let imageCache = NSCache<NSURL, UIImage>()

    /// APIを呼び出し、結果をCodableオブジェクトにデコードするメソッド
    /// - Parameters:
    ///   - url: APIのエンドポイントURL
    ///   - type: デコードするデータの型
    ///   - onSuccess: データ取得に成功した場合の処理を行うクロージャ
    ///   - onFailure: エラー発生時の処理を行うクロージャ
    func callAPI<T: Codable>(url: URL?, type: T.Type, onSuccess: @escaping (T) -> Void, onFailure: @escaping (Error) -> Void) {
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
                    onFailure(error)
                }
            } receiveValue: { responseData in
                onSuccess(responseData)
            }
            .store(in: &cancelbels)
    }

    /// 指定されたURLから画像をロードし、UIImageオブジェクトを返すメソッド
    /// - Parameter url: 画像のURL
    /// - Returns: UIImageオブジェクトを返すAnyPublisherインスタンス
    func loadImage(for url: URL) -> AnyPublisher<UIImage?, Never> {
        if let cachedImage = imageCache.object(forKey: url as NSURL) {
            return Just(cachedImage).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { data, _ in UIImage(data: data) }
            .handleEvents(receiveOutput: { image in
                if let image = image {
                    self.imageCache.setObject(image, forKey: url as NSURL)
                }
            })
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}

/// APIからのエラーを表すカスタムエラー列挙型
enum CustomError: Error {
    case codingError(error: Error)
    case inavalit
}
