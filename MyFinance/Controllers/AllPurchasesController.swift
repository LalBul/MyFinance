//
//  AllPurchasesController.swift
//  MyFinance
//
//  Created by Вова Сербин on 28.09.2021.
//

import UIKit
import SwipeCellKit
import ChameleonFramework
import RealmSwift

class AllPurchasesController: UIViewController {
    
    @IBOutlet weak var mainTableView: UITableView!
    
    var itemsArray: Results<Item>?
    var realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.backgroundColor = .clear
        mainTableView.layer.cornerRadius = 20
        mainTableView.rowHeight = 130
        mainTableView.showsHorizontalScrollIndicator = false
        mainTableView.showsVerticalScrollIndicator = false
        
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        loadItems()
    }
    
    func loadItems() {
        itemsArray = realm.objects(Item.self)
        mainTableView.reloadData()
    }
    
}

extension AllPurchasesController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PurchasesCell", for: indexPath) as! AllPurchasesItemCell
        cell.delegate = self
        
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.white
        cell.layer.borderWidth = CGFloat(3)
        cell.layer.borderColor = view.backgroundColor?.cgColor
        
        cell.colorCategory.layer.cornerRadius = cell.colorCategory.frame.size.width / 2
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        if let item = itemsArray?[indexPath.row] {
            cell.amount.text = String(item.amount)
            cell.name.text = item.title
            cell.date.text = formatter.string(from: item.date!)
            cell.category.text = item.parentCategory[0].title
            cell.colorCategory.backgroundColor = HexColor(item.parentCategory[0].color)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { swipeAction, indexPath in
            do {
                try self.realm.write {
                    let newHistoryItem = HistoryItem()
                    let itemsData = self.itemsArray![indexPath.row]
                    newHistoryItem.category = itemsData.parentCategory[0].title
                    newHistoryItem.date = itemsData.date
                    newHistoryItem.title = itemsData.title
                    newHistoryItem.amount = itemsData.amount
                    self.realm.add(newHistoryItem)
                    self.realm.delete(self.itemsArray![indexPath.row])
                    tableView.reloadData()
                }
            } catch {
                print("Delete error")
            }
        }
        return [deleteAction]
    }
    
    
}
