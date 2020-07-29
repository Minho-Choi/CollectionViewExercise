//
//  EmojiCollectionViewCell.swift
//  CollectionViewExercise
//
//  Created by Minho Choi on 2020/07/28.
//  Copyright © 2020 Minho Choi. All rights reserved.
//

import UIKit

class EmojiCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var aspectRatio: NSString {
        if let imageSize = imageView.image?.size {
            return NSString(string: String(Float(imageSize.height / imageSize.width)))
        } else {
            return "1"
        }
    }
    
    var imageURL: URL? {
        didSet {
            if let url = self.imageURL {
                spinner.startAnimating()
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    let urlContents = try? Data(contentsOf: url)
                    DispatchQueue.main.async { // UI 코드이므로 main에 넣어줌
                        if let imageData = urlContents, url == self?.imageURL { //이미지 로딩 후 다른 요청이 생겨 url이 바뀌는 경우 방지
                            self?.imageView.image = UIImage(data: imageData)
                            self?.spinner.stopAnimating()
                        }
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
}
