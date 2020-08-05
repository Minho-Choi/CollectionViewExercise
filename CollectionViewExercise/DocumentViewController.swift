//
//  DocumentViewController.swift
//  CollectionViewExercise
//
//  Created by Minho Choi on 2020/08/01.
//  Copyright © 2020 Minho Choi. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    var documentList = [ImageGallery]()
    var nameList = [String]()
    var deletedList = [ImageGallery]()
    
    lazy var list = [documentList, deletedList]
    
    @IBOutlet weak var documentTableView: UITableView! {
        didSet {
            documentTableView.delegate = self
            documentTableView.dataSource = self
        }
    }
    
    
    @IBAction func addDocumentBarButton(_ sender: UIBarButtonItem) {
        let name = "Untitled".madeUnique(withRespectTo: nameList)
        nameList.append(name)
        list[0].insert(ImageGallery(name: name, items: []), at: 0)
        documentTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "Recently Deleted"
        default: return ""
        } // 새로운 list를 만들기보다는 switch 문을 쓰는 것이 더 깔끔하다
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)
        cell.textLabel?.text = list[indexPath.section][indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            if indexPath.section == 0 {
                let deletingRow = indexPath
                let addingRow = IndexPath(row: 0, section: 1)
                documentTableView.performBatchUpdates({
                    list[1].insert(list[0][deletingRow.row], at: 0)
                    tableView.insertRows(at: [addingRow], with: .left)
                    list[0].remove(at: deletingRow.row)
                    tableView.deleteRows(at: [deletingRow], with: .left)
                })
            } else {
                let deletingRow = indexPath
                documentTableView.performBatchUpdates({
                    nameList = nameList.filter{$0 != list[1][deletingRow.row].name}
                    list[1].remove(at: deletingRow.row)
                    tableView.deleteRows(at: [deletingRow], with: .top)
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let undeleteAction = UIContextualAction(style: .normal, title: "Restore", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                
                
                let deletingRow = indexPath
                let addingRow = IndexPath(row: 0, section: 0)
                self.documentTableView.performBatchUpdates({
                    self.list[0].insert(self.list[1][deletingRow.row], at: 0)
                    tableView.insertRows(at: [addingRow], with: .left)
                    self.list[1].remove(at: deletingRow.row)
                    tableView.deleteRows(at: [deletingRow], with: .left)
                })
                
                success(true)
                
            })
            undeleteAction.backgroundColor = #colorLiteral(red: 0.1882352941, green: 0.8196078431, blue: 0.3450980392, alpha: 1)
            return UISwipeActionsConfiguration(actions:[undeleteAction])
        } else {
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "ImageGallery" {
            let collectionViewController = segue.destination.contents as! ViewController
            collectionViewController.optionalGallery = sender as? ImageGallery
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "ImageGallery", sender: list[indexPath.section][indexPath.row] )
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
    

}
