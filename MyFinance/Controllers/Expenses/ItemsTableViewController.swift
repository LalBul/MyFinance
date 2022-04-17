//
//  ItemsViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 01.05.2021.
//

import UIKit
import RealmSwift
import ChameleonFramework
import SwipeCellKit
import SwiftUI
import ViewAnimator

protocol UpdateItemsTableViewController {
    func update()
}

class ItemsTableViewController: UITableViewController, SwipeTableViewCellDelegate, UpdateItemsTableViewController {
    
    func update() {
        loadItems()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        
        tableView.rowHeight = 100
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        defaultValue = defaults.double(forKey: "Limit")
        
        let imageView = UIImageView()
            NSLayoutConstraint.activate([
                imageView.heightAnchor.constraint(equalToConstant: 10),
                imageView.widthAnchor.constraint(equalToConstant: 80)
            ])
        imageView.layer.cornerRadius = 5
        imageView.backgroundColor = HexColor(selectedCategory!.color)
            
        let hStack = UIStackView(arrangedSubviews: [imageView])
        hStack.spacing = 5
        hStack.alignment = .center
        
        navigationItem.titleView = hStack
        
        self.tabBarController?.tabBar.isHidden = true
        
        let animation = AnimationType.from(direction: .left, offset: 100)
        UIView.animate(views: tableView.visibleCells,
                       animations: [animation])
  
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
                            
    let realm = try! Realm()
    var items: Results<Item>?

    var selectedCategory: Category?
    let defaults = UserDefaults.standard
    var defaultValue: Double = 0
    
    @IBOutlet weak var addItemOutlet: UIBarButtonItem!
    
    func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "date", ascending: true)
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddItem" {
            let destinationVC = segue.destination as! AddItemViewController
            destinationVC.selectedCategory = selectedCategory
            destinationVC.delegate = self
        }
        
    }
    
    //MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsCell", for: indexPath) as! ItemCell
        cell.delegate = self
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        if let item = items?[indexPath.row] {
            cell.buyName.text = item.title
            cell.buyPrice.text = String(item.amount)
            cell.buyDate.text = formatter.string(from: item.date ?? Date())
            cell.layer.borderWidth = CGFloat(3)
            cell.layer.borderColor = view.backgroundColor?.cgColor
            cell.view.layer.cornerRadius = 15
            cell.view.layer.masksToBounds = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Удалить") { swipeAction, indexPath in
            do {
                try self.realm.write {
                    let newHistoryItem = HistoryItem()
                    if let categoryItem = self.selectedCategory {
                        let itemsData = categoryItem.items[indexPath.row]
                        newHistoryItem.category = categoryItem.title
                        newHistoryItem.date = itemsData.date
                        newHistoryItem.title = itemsData.title
                        newHistoryItem.amount = itemsData.amount
                        self.realm.add(newHistoryItem)
                        
                    }
                    self.realm.delete((self.selectedCategory?.items[indexPath.row])!)
                    self.loadItems()
                }
            } catch {
                print("Fail delete cell")
            }
        }
        deleteAction.backgroundColor = HexColor("#9B3636")
        return [deleteAction]
    }
    
}




