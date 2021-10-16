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
    
    var itemsArray: Results<Items>?
    var realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.backgroundColor = .clear
        mainTableView.layer.cornerRadius = 15
        mainTableView.rowHeight = 130
        
        loadItems()
    }
    
    func loadItems() {
        itemsArray = realm.objects(Items.self)
        itemsArray = itemsArray?.sorted(byKeyPath: "date")
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
        cell.backgroundColor = HexColor("132743")
        cell.layer.borderWidth = 0.2
        cell.layer.borderColor = UIColor.gray.cgColor
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        if let item = itemsArray?[indexPath.row] {
            cell.amount.text = String(item.amount)
            cell.name.text = item.title
            cell.date.text = formatter.string(from: item.date!)
            cell.category.text = item.parentCategory[0].title
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { swipeAction, indexPath in
            do {
                try self.realm.write {
                    
                }
            } catch {
                
            }
        }
        return [deleteAction]
    }
    
    
}
