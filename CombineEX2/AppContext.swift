//
//  AppContext.swift
//  CombineEX2
//
//  Created by SHIRAISHI HIROYUKI on 2023/12/21.
//

import Foundation


class AppContext {
    static let shared = AppContext()
}

extension AppContext {

    func loadData(_ complision: @escaping (_ coinData: CoinDatas?, _ error: Error?) -> Void) {
        let url = URL(string: "https://raw.githubusercontent.com/atilsamancioglu/K21-JSONDataSet/master/crypto.json")
        APIManager.shared.callAPI(url: url, type: [CoinData].self) { result in
            switch result {
            case .success(let success):
                complision(success, nil)
            case .failure(let failure):
                complision(nil, failure)
            }
        }
    }
}
