//
//  CollectionViewCellViewController.swift
//  CollectionViewExercise
//
//  Created by Minho Choi on 2020/07/30.
//  Copyright © 2020 Minho Choi. All rights reserved.
//

import UIKit

class CollectionViewCellViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var detailImageView: UIImageView!
    
    var image: UIImage? {
        get {
            return detailImageView.image
        }
        set {
            detailImageView?.image = newValue
            detailImageView?.sizeToFit()
//            DetailScrollView?.contentSize = detailImageView.frame.size
            spinner?.stopAnimating()
        }
    }
    
    var viewControllerIsOnScreen: Bool {
        return view.window != nil
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageURL: URL? {
        didSet {
            image = nil
            
            if viewControllerIsOnScreen {
                if let uncoveredURL = imageURL?.imageURL {
                    fetchImage(url: uncoveredURL)
                    print(uncoveredURL)
                } else {
                    print("url is not set")
                }
            }
        }
    }
    

//    @IBOutlet weak var DetailScrollView: UIScrollView! {
//        didSet {
//            DetailScrollView.minimumZoomScale = 1.0
//            DetailScrollView.maximumZoomScale = 5.0
//            DetailScrollView.delegate = self
//            DetailScrollView.addSubview(detailImageView)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if imageURL == nil {
            imageURL = URL(string: "https://image.shutterstock.com/image-vector/no-sign-vector-on-white-600w-205782049.jpg")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)

         // Check if we need to fetch the image
        if detailImageView.image == nil{
            fetchImage(url: imageURL!.imageURL)
         }
     }
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return detailImageView
//    }
    
    func fetchImage(url: URL) {
        spinner.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            if let urlContents = try? Data(contentsOf: url) {
                
                DispatchQueue.main.async { // UI 코드이므로 main에 넣어줌
                    
                    self?.detailImageView.image = UIImage(data: urlContents)
                }
            } else {
                
                self?.detailImageView.image = UIImage(systemName: "xmark.rectangle")
            }
        }
    }
}