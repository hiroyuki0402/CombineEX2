//
//  TestCell.swift
//  CombineEX2
//
//  Created by SHIRAISHI HIROYUKI on 2023/12/23.
//

import UIKit

class TestCell: UITableViewCell {

    @IBOutlet weak var imageView2: UIImageView!

    @IBOutlet weak var label: UILabel!
    

    func configure(text: String? = nil) {

        label.text = text == nil ? nil: text
    }

    func setImage(image: UIImage? = nil) {
        imageView2.image = image == nil ? nil: image
    }
}
