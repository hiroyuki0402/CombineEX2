//
//  ViewController.swift
//  CombineEX2
//
//  Created by SHIRAISHI HIROYUKI on 2023/12/21.
//

import UIKit
import Combine
import SwiftUI

class ViewController: UIViewController {
    // MARK: - プロパティー

    /// ViewModel
    private let model = ViewControllerViewModel()

    /// Combineフレームワークで使用する購読をキャンセル可能なオブジェクトのセット
    private var cancellables: Set<AnyCancellable> = []

    @IBOutlet weak var tableView: UITableView!

    private var isShowingUpBUtton: Bool = false

    private var upButton: UIImageView?

    // MARK: - ライフサイクル

    override func viewDidLoad() {
        super.viewDidLoad()

        /// テーブルビューの初期設定を行う
        configureTableView()

        /// 右下にボタンを作成する
        createUpbutton()

        /// ビューモデルからのデータを購読するバインディングを設定する
        setupBiding()
    }

    // MARK: - メソッド

    /// テーブルビューの構築設定
    private func configureTableView() {
        tableView.register(UINib(nibName: "TestCell", bundle: nil), forCellReuseIdentifier: "TestCell")
    }

    /// バイディングの設定
    private func setupBiding() {
        model.$coindatas
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    /// データの作成
    func createData() {
        model.coindatas.append(.init(currency: "白石", price: "10000"))
    }

    /// 右下ボタン構築
    func createUpbutton() {
        let upIconView = UIImageView()
        self.view.addSubview(upIconView)
        upIconView.image = UIImage(named: "arrow_up")
        upIconView.alpha = 0.7
        upIconView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            upIconView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            upIconView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            upIconView.heightAnchor.constraint(equalToConstant: 100),
            upIconView.widthAnchor.constraint(equalToConstant: 100)
        ])

        upIconView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(upcell))
        upIconView.addGestureRecognizer(tapGesture)

        upIconView.backgroundColor = .clear
        upButton = upIconView
    }

    // MARK: - ハンドラー

    /// SwiftUIで作成した画面へ遷移
    @IBAction func moveToMainBySwiftUI(_ sender: Any) {
        let swiftUIView = MainSwiftUI()
        let hostingController = UIHostingController(rootView: swiftUIView)
        self.present(hostingController, animated: true, completion: nil)
    }
    

    /// セルを上部に戻す
    @objc func upcell(sender: UITapGestureRecognizer) {
        if !tableView.visibleCells.isEmpty {
            print(IndexPath())
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            createData()
        }
    }
}

// MARK: - UIScrollView

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let upButton = upButton, scrollView.contentOffset.y > 0 {
            upButton.isHidden = false
        } else {
            upButton?.isHidden = true
        }
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.unSplashDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TestCell", for: indexPath) as? TestCell else {
            return UITableViewCell()
        }

        let data = model.getUnSplashDatas(at: indexPath.row)
        cell.configure(text: data.description)

        /// 画像を取得して取得成功時はセルにそのまま貼り付ける
        if let urlString = data.urls?.thumb, let imageUrl = URL(string: urlString) {
            APIManager.shared.loadImage(for: imageUrl)
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    // TODO: - エラーハンドリングや追加の処理

                } receiveValue: { [weak cell] image in
                    cell?.setImage(image: image)
                }
                .store(in: &cancellables)
        }


        return cell
    }
}

