//
//  ImageManager.swift
//  CombineEX2
//
//  Created by SHIRAISHI HIROYUKI on 2023/12/23.
//

import Foundation
import SwiftUI
import Kingfisher
import Combine

/// 画像のダウンロードとキャッシュを管理するサービスクラス
class ImageService {
    // MARK: - プロパティー
    /// 画像のキャッシュを管理するためのNSCacheインスタンス
    let imageCache = NSCache<NSURL, UIImage>()

    /// シングルトンインスタンス
    static let shared = ImageService()

    /// の画像キャッシュ
    private let cache: ImageCache

    /// 最後にキャッシュをクリアした時刻を記録する
    private var lastCacheClearDate: Date? {
        get {
            UserDefaults.standard.object(forKey: UserDefaultsKeys.lastCacheClearDate) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.lastCacheClearDate)
        }
    }

    // MARK: - 初期化

    /// デフォルトキャッシュを設定
    private init() {
        cache = ImageCache.default
    }

    // MARK: - メソッド

    /// 指定されたURLから非同期に画像をロードし、SwiftUIのImageとして返す
    /// - Parameter url: ロードする画像のURL
    /// - Returns: ダウンロードされた画像
    func loadImageAsImage(url: URL) async -> Image {
        /// キャッシュのキーをURLから生成
        let cacheKey = url.absoluteString

        /// キャッシュから画像を試みて取得
        if let cachedImage = getImageFromCache(forKey: cacheKey) {
            return cachedImage
        }

        /// キャッシュに画像がない場合は、ネットワークから画像をロード
        do {
            let uiImage = try await loadImage(url: url)
            if let uiImage = uiImage {
                /// ロードした画像をキャッシュに保存
                cacheImage(uiImage, forKey: cacheKey)
                return Image(uiImage: uiImage)
            }
        } catch {
            return Image("")
        }
        return Image("")
    }

    /// 指定されたURLから非同期に画像をロードする
    /// - Parameter url: ロードする画像のURL
    /// - Returns: ロードされたUIImage。エラーの場合はnilを返す
    private func loadImage(url: URL) async throws -> KFCrossPlatformImage? {
        try await withCheckedThrowingContinuation { continuation in
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let imageResult):
                    continuation.resume(returning: imageResult.image)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
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

    /// 画像キャッシュをクリアする
    func clearCache() {
        cache.clearMemoryCache()
        cache.clearDiskCache()
    }

    /// キャッシュから指定されたキーに対応する画像を取得する
    /// - Parameter key: 取得する画像のキー
    /// - Returns: キャッシュされている画像のSwiftUI Image。キャッシュに画像がない場合はnilを返す
    func getImageFromCache(forKey key: String) -> Image? {
        if let uiImage = cache.retrieveImageInMemoryCache(forKey: key) {
            return Image(uiImage: uiImage)
        }
        return nil
    }

    /// 指定された画像をキャッシュに保存する
    /// - Parameters:
    ///   - image: キャッシュするUIImage
    ///   - key: 画像を識別するためのキー
    func cacheImage(_ image: UIImage, forKey key: String) {
        cache.store(image, forKey: key)
    }

    /// 6時間ごとにキャッシュをクリアするメソッド
    func clearCacheIfNeeded() {
        let now = Date()
        let sixHours: TimeInterval = 6 * 60 * 60

        if let lastClearDate = lastCacheClearDate, now.timeIntervalSince(lastClearDate) < sixHours {
            /// まだ6時間経過していない場合は何もしない
            return
        }

        /// キャッシュをクリア
        clearCache()

        /// 最終クリア時刻を更新
        lastCacheClearDate = now
    }
}
