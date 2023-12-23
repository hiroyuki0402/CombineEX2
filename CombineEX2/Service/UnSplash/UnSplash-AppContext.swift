//
//  UnSplash-AppContext.swift
//  CombineEX2
//
//  Created by SHIRAISHI HIROYUKI on 2023/12/23.
//

import Foundation

extension AppContext {
    func loadUnSplashDatas(_ complision: @escaping (_ coinData: UnSplashData?, _ error: Error?) -> Void) {
        let url = URL(string: "https://api.unsplash.com/search/photos?query=nature&client_id=APIKEY")

        APIManager.shared.callAPI(url: url, type: UnSplashData.self) { result in
            complision(result, nil)
        } onFailure: { error in
            complision(nil, error)
        }
    }
}
