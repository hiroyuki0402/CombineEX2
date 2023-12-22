//
//  ViewControllerViewModel.swift
//  CombineEX2
//
//  Created by SHIRAISHI HIROYUKI on 2023/12/21.
//

import Foundation

class ViewControllerViewModel {
    
    var coindatas: CoinDatas = []

    init() {
        fetchCoinDatas()
    }

    private func fetchCoinDatas() {
        AppContext.shared.loadData { coinData, _ in
            guard let coinData = coinData else { return }
            self.coindatas = coinData
        }
    }

    func getData(at index: Int) -> CoinData {
        return coindatas[index]
    }

}

