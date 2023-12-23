//
//  MainSwiftItem.swift
//  CombineEX2
//
//  Created by SHIRAISHI HIROYUKI on 2023/12/23.
//

import SwiftUI

struct MainSwiftItem: View {
    // MARK: - プロパティー
    var data: Result

    /// 画像
    @State private var image: Image? = nil

    // MARK: - ボディー

    var body: some View {
        VStack {
            HStack {
                /// 画像
                imageView

                /// 説明文
                description

                Spacer()
            }
            .padding(.horizontal, 15)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 112)
    }

    // MARK: - メソッド

    /// 画像ロード
    private func loadImage() {
        Task {
            if let url = URL(string: data.urls?.thumb ?? "") {
                image = await ImageService.shared.loadImageAsImage(url: url)
            }
            return Image("")
        }
    }
}

// MARK: - MainSwiftItem内のアイテム

private extension MainSwiftItem {
    /// 画像
    private var imageView: some View {
        /// - Note: SwiftUIにおいてはキャッシュ処理にはKingFisherを使用してみた
        VStack {
            if let image = image {
                image
                    .resizable()
                    .frame(width: 135, height: 96)
            }else {
                ProgressView()
                    .onAppear { loadImage() }
            }
        }
        .frame(width: 135)
    }

    /// 説明
    private var description: some View {
        VStack {
            Text(data.description ?? "")
                .padding(.top, 8)
            Spacer()
        }
    }
}

#Preview {
    MainSwiftItem(data: ViewControllerViewModel().unSplashDatas[0])
}
