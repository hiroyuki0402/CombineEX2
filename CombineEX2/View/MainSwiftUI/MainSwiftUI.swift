//
//  MainSwiftUI.swift
//  CombineEX2
//
//  Created by SHIRAISHI HIROYUKI on 2023/12/23.
//

import SwiftUI

struct MainSwiftUI: View {
    // MARK: - プロパティー
    @StateObject var model = ViewControllerViewModel()
    
    // MARK: - ボディー

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                ForEach(model.unSplashDatas) { data in
                    MainSwiftItem(data: data)
                    Divider()
                }//: ループ

            }//: LazyVStack

        }//: ScrollView

    }//: ボディー
}

#Preview {
    MainSwiftUI()
}
