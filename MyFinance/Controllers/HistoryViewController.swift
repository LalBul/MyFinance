//
//  HistoryViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 03.07.2021.
//

import UIKit
import RealmSwift
import SwipeCellKit

class HistoryViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        
        tableView.rowHeight = 94
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadItems()
        
    }
    
    var realm = try! Realm()
    var historyItemsArray: Results<HistoryItems>?
    
    @IBAction func deleteAllHistory(_ sender: UIBarButtonItem) {
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
        historyItemsArray = realm.objects(HistoryItems.self)
        historyItemsArray = historyItemsArray?.sorted(byKeyPath: "date")
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyItemsArray?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        cell.delegate = self
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        if let historyArray = historyItemsArray?[indexPath.row] {
            cell.category.text = historyArray.category
            cell.date.text = formatter.string(from: historyArray.date!)
            cell.name.text = historyArray.name
            cell.amount.text = String(historyArray.amount)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { swipeAction, indexPath in
            do {
                try self.realm.write {
                    self.realm.delete(self.historyItemsArray![indexPath.row])
                    tableView.reloadData()
                }
            } catch {
                print("Fail delete cell")
            }
        }
        return [deleteAction]
    }
    
    
    
}
