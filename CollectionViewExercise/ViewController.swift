//
//  ViewController.swift
//  CollectionViewExercise
//
//  Created by Minho Choi on 2020/07/28.
//  Copyright © 2020 Minho Choi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {

 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // Model
    var emojiSet = [1.5, 0.5, 0.77, 2, 1, 0.8, 0.33, 0.8, 1.1, 1.9, 0.6, 0.7, 1]
    var imageURLArray = [URL]()
    
    private var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(128.0))
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.dragDelegate = self
            collectionView.dropDelegate = self
        }
    }
    // Collection View Setting Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiSet.count
    }
    // cell size set
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let aspectRatio = CGFloat(emojiSet[indexPath.item])
        let width = view.frame.width / 4.2
        let height = width * aspectRatio
        return CGSize(width: width, height: height)
    }
    // cell shape & inner information set
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
        if let emojiCell = cell as? EmojiCollectionViewCell {
            let text = NSAttributedString(string: String(emojiSet[indexPath.item]), attributes: [.font:font])
            emojiCell.emojiLabel.attributedText = text
            emojiCell.layer.borderWidth = 3.0
            emojiCell.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        return cell
    }
    // CollectionView Drop Delegate
    
    // available types view can handle
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
//        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
        return session.canLoadObjects(ofClass: NSString.self)
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
                if let attributedString = item.dragItem.localObject as? NSAttributedString {
                    // performBatchUpdates의 효과는 모델과 뷰를 동시에 수정함으로써 싱크 유지
                    collectionView.performBatchUpdates({
                        // 모델 편집 - 본래 위치에서 삭제 후 새로운 위치에 추가
                        emojiSet.remove(at: sourceIndexPath.item)
                        emojiSet.insert(NSString(string: attributedString.string).doubleValue, at: destinationIndexPath.item)
                        // 뷰 편집 - 전체 뷰를 업데이트할 경우 애니메이션 실행되지 않으므로 부자연스러움
                        // 따라서 아이템을 하나씩 지우고 더하는 메소드를 사용
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    // 애니메이션 실행
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else { // 아이템이 외부에서 왔을 경우
                // placeholdercell을 추가하여 드롭 수행
                let placeholderContext = coordinator.drop(
                    item.dragItem,
                    to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceholderCell")
                )
                // 드래그 아이템을 attributedString으로 받는 과정 - 당연히 error 발생가능
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { (provider, error) in
                    // main 큐에서 코드 수행 - 뷰와 관련된 코드이므로
                    DispatchQueue.main.async {
                        // 받는 데 성공했을 경우
                        if let attributedString = provider as? NSAttributedString {
                            // 플레이스홀더 셀을 내용이 들어간 셀로 치환
                            placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                self.emojiSet.insert(NSString(string: attributedString.string).doubleValue, at: insertionIndexPath.item)
                            })
                            // 받는 데 실패했을 경우
                        } else {
                            // 플레이스홀더 셀을 지움
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }


    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        // cellForItem: Returns the visible cell object at the specified index path.
        if let attributedString = (collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.emojiLabel.attributedText {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributedString))
            dragItem.localObject = attributedString
            return [dragItem]
        } else {
            return []
        }
    }
}

