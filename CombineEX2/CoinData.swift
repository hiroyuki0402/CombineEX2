//
//  CoinData.swift
//  CombineEX2
//
//  Created by SHIRAISHI HIROYUKI on 2023/12/21.
//

import Foundation

struct CoinData: Codable {
    let currency: String
    let price: String
}
typealias CoinDatas = [CoinData]
