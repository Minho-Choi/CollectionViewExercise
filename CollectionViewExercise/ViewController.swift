//
//  ViewController.swift
//  CollectionViewExercise
//
//  Created by Minho Choi on 2020/07/28.
//  Copyright © 2020 Minho Choi. All rights reserved.
//

import UIKit
import Foundation

class ImageGallery {
    
    // create new gallery with name and items
    init(name: String, items: [Item]) {
        self.name = name
        self.items = items
    }
    
    // create new empty gallery
    init() {}
    
    struct Item {
        
        var imageURL: URL
        
        var ratio: Double
    }
    
    var name: String = "Untitled"
    
    
    var items = [Item]()
}


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    // Model
    
    var gallery = ImageGallery()
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.dragDelegate = self
            collectionView.dropDelegate = self
        }
    }
     // 화면 방향 전환 시 뷰 다시 그리기
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if let flowLayout = self.collectionView!.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.invalidateLayout()
        }
    }
    
    
    
    // Collection View Data Protocols
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery.items.count
    }
    // cell size set
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let aspectRatio = CGFloat(imageARStringSet[indexPath.item])
        let ratio = CGFloat(gallery.items[indexPath.item].ratio)
        let width = view.frame.width / 3.2
        print("frame size: \(width) * \(width * ratio)")
        return CGSize(width: width, height: width * ratio)
    }
    // cell shape & inner information set
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
        if let emojiCell = cell as? EmojiCollectionViewCell {
            emojiCell.imageURL = gallery.items[indexPath.item].imageURL
            emojiCell.aspectRatio = gallery.items[indexPath.item].ratio
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DetailImage", sender: gallery.items[indexPath.item].imageURL)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "DetailImage" {
            let detailViewController = segue.destination.contents as! CollectionViewCellViewController
            detailViewController.imageURL = sender as? URL
        }
    }
    
    // CollectionView Drop Delegate
    
    // available types view can handle
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        if session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: NSString.self) {
            return true
        }
        if session.localDragSession?.localContext as? UICollectionView == collectionView {
            return true
        }
        return false
    }
    
    // move or copy
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    // update view and model
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        // coordinator 내부에 여러 item이 있을 수 있다
        for item in coordinator.items {
            // 아이템이 본래 있던 자리(드래그가 시작된 자리)
            if let sourceIndexPath = item.sourceIndexPath {
                // 드래그한 아이템의 내용(attributedString)
                guard let galleryItem = item.dragItem.localObject as? ImageGallery.Item else { break }//, let imageAR = item.dragItem.localObject as? Double{
                    // performBatchUpdates의 효과는 모델과 뷰를 동시에 수정함으로써 싱크 유지
                collectionView.performBatchUpdates({
                    // 모델 편집 - 본래 위치에서 삭제 후 새로운 위치에 추가
                    gallery.items.remove(at: sourceIndexPath.item)
                    gallery.items.insert(galleryItem, at: destinationIndexPath.item)
                    // 뷰 편집 - 전체 뷰를 업데이트할 경우 애니메이션 실행되지 않으므로 부자연스러움
                    // 따라서 아이템을 하나씩 지우고 더하는 메소드를 사용
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                })
                    // 애니메이션 실행
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            } else { // 아이템이 외부에서 왔을 경우
                
                var url: URL?
                var ratio: Double?
                // get the UIImage data
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
                    // if image vaild
                    if let image = provider as? UIImage {
                        // calculate ratio
                        ratio = Double(image.size.height / image.size.width)
                            
                        }
                    }
                
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { [weak self] (provider, error) in
                    
                    url = provider as? URL
                    
                    if url != nil && ratio != nil {
                        
                        DispatchQueue.main.async {
                            
                            collectionView.performBatchUpdates({
                                
                                self?.gallery.items.insert(ImageGallery.Item(imageURL: url!, ratio: ratio!), at: destinationIndexPath.item)
                                
                                collectionView.insertItems(at: [destinationIndexPath])
                                
                                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                            })
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    // Drag

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        // cellForItem: Returns the visible cell object at the specified index path.
        let item = gallery.items[indexPath.item]
        
        let url = UIDragItem(itemProvider: NSItemProvider(object: item.imageURL as NSURL))
        
        url.localObject = item
        
        return [url]
    }
}

