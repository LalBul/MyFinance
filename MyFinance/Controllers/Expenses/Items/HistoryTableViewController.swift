//
//  HistoryViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 03.07.2021.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ViewAnimator
import ChameleonFramework

class HistoryTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    var realm = try! Realm()
    var historyItemsArray: Results<HistoryItem>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        addHaptic()
        
        tableView.rowHeight = 100
        self.tabBarController?.tabBar.isHidden = true
        
        let animation = AnimationType.from(direction: .right, offset: 50)
        UIView.animate(views: tableView.visibleCells,
                       animations: [animation])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadItems()
    }

    @IBAction func deleteAllHistory(_ sender: UIBarButtonItem) {
        addHaptic()
        do {
            try realm.write {
                realm.delete(historyItemsArray!)
                tableView.reloadData()
            }
        } catch {
            print("Error delete all history")
        }
    }
    
    func loadItems() {
        historyItemsArray = realm.objects(HistoryItem.self)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyItemsArray?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoryCell
        cell.delegate = self
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        if let historyArray = historyItemsArray?[indexPath.row] {
            
            print(historyArray)
            
            if historyArray.parentCategory[0].currency == "₽" {
                cell.amount.text = String(format:"%.2f", historyArray.amount)
            } else if historyArray.parentCategory[0].currency == "Є" {
                cell.amount.text = String(format:"%.2f", historyArray.amountInEU)
            } else if historyArray.parentCategory[0].currency == "$" {
                cell.amount.text = String(format:"%.2f", historyArray.amountInUS)
            }
            
            cell.amount.text?.append(" \(historyArray.parentCategory[0].currency)")
            
            cell.category.text = historyArray.parentCategory[0].title
            cell.date.text = formatter.string(from: historyArray.date!)
            cell.name.text = historyArray.title
            
            cell.view.layer.cornerRadius = 15
            cell.view.layer.masksToBounds = true
            cell.layer.borderWidth = CGFloat(3)
            cell.layer.borderColor = view.backgroundColor?.cgColor
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Удвлить") { swipeAction, indexPath in
            do {
                try self.realm.write {
                    self.realm.delete(self.historyItemsArray![indexPath.row])
                    tableView.reloadData()
                }
            } catch {
                print("Fail delete cell")
            }
        }
        deleteAction.backgroundColor = HexColor("#9B3636")
        return [deleteAction]
    }
    
}
