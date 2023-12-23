//
//  Coin-AppContext.swift
//  CombineEX2
//
//  Created by SHIRAISHI HIROYUKI on 2023/12/23.
//

import Foundation

extension AppContext {

    func loadCoinDatas(_ complision: @escaping (_ coinData: CoinDatas?, _ error: Error?) -> Void) {
        let url = URL(string: "https://raw.githubusercontent.com/atilsamancioglu/K21-JSONDataSet/master/crypto.json")

        APIManager.shared.callAPI(url: url, type: [CoinData].self) { result in
            complision(result, nil)
        } onFailure: { error in
            complision(nil, error)
        }
    }
}
