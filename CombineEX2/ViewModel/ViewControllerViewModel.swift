//
//  ViewControllerViewModel.swift
//  CombineEX2
//
//  Created by SHIRAISHI HIROYUKI on 2023/12/21.
//

import Foundation
import Combine

class ViewControllerViewModel {
    // MARK: - プロパティー

    @Published var coindatas: CoinDatas = []
    @Published var unSplashDatas: [Result] = []

    // MARK: - 初期化
    init() {
        fetchDatas()
    }

    // MARK: - メソッド

    /// データの取得
    private func fetchDatas() {
        /// コインデータのロード
        AppContext.shared.loadCoinDatas { coinData, _ in
            guard let coinData = coinData else { return }
            self.coindatas = coinData
        }

        /// UnSplashのデータを表示
        AppContext.shared.loadUnSplashDatas { unSplashData, error in
            guard let unSplashData = unSplashData else { return }
            self.unSplashDatas = unSplashData.results
        }
    }

    /// コインデータの取得
    /// - Parameter index: 指定のIndex
    /// - Returns: 指定されたデータ
    func getCoinData(at index: Int) -> CoinData {
        return coindatas[index]
    }

    /// UnSplashデータの取得
    /// - Parameter index: 指定のIndex
    /// - Returns: 指定されたデータ
    func getUnSplashDatas(at index: Int) -> Result {
        return unSplashDatas[index]
    }

}

