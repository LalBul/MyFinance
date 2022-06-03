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
        addAnimation()
     
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
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        navigationItem.titleView = hStack
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        tabBarController?.tabBar.isHidden = true

        tableView.rowHeight = 100
        tableView.dataSource = self
    
        defaultValue = defaults.double(forKey: "Limit")

  
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadItems()
    
    }
                            
    let realm = try! Realm()
    var items: Results<Item>?
    var selectedCategory: Category?
    let defaults = UserDefaults.standard
    var defaultValue: Double = 0
    
    @IBOutlet weak var addItemOutlet: UIBarButtonItem!
    
    var segmentedControl = UISegmentedControl()
    var controlSegmentIndex = 0
    
    func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "date")
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.35) {
                self.tableView.reloadData()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddItem" {
            let destinationVC = segue.destination as! AddItemViewController
            destinationVC.selectedCategory = selectedCategory
            destinationVC.delegate = self
        }
        
    }
    
    func addAnimation() {
        let animation = AnimationType.from(direction: .left, offset: 100)
        UIView.animate(views: tableView.visibleCells,
                       animations: [animation])
    }
    
    //MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items?.count == 0 {
            tableView.setEmptyMessage("Покупок пока нет")
        } else {
            tableView.restore()
        }
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsCell", for: indexPath) as! ItemCell
        cell.delegate = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ru_RU")
        if let item = items?[indexPath.row], let category = selectedCategory {
            if category.currency == "₽" {
                cell.buyPrice.text = String(format:"%.2f", item.amount)
            } else if category.currency == "Є" {
                cell.buyPrice.text = String(format:"%.2f", item.amountInEU)
            } else if category.currency == "$" {
                cell.buyPrice.text = String(format:"%.2f", item.amountInUS)
            }
            cell.buyPrice.text?.append(" \(category.currency)")
            cell.buyName.text = item.title
            cell.buyDate.text = dateFormatter.string(from: item.date)
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
                    if let item = self.items?[indexPath.row], let category = self.selectedCategory {
                        print(item)
                        let newHistoryItem = HistoryItem()
                        newHistoryItem.category = category.title
                        newHistoryItem.date = item.date
                        newHistoryItem.title = item.title
                        print(category.currency, item.amount)
                        newHistoryItem.addCurrencyMoney(currency: "₽", amount: item.amount)
                        self.selectedCategory?.history.append(newHistoryItem)
                        self.realm.add(newHistoryItem)
                        self.realm.delete(item)
                    }
                    self.tableView.reloadData()
                }
            } catch {
                print("Fail delete cell")
            }
        }
        deleteAction.backgroundColor = HexColor("#9B3636")
        return [deleteAction]
    }
    


    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        header.backgroundColor = .clear
        
        let items = ["Всё", "День", "Месяц", "Год"]
        
        segmentedControl = UISegmentedControl(items: items)
        segmentedControl.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30)
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        segmentedControl.selectedSegmentTintColor = HexColor("295A9B")
        segmentedControl.backgroundColor = HexColor("1C3459")
        segmentedControl.center = header.center
        header.addSubview(segmentedControl)
        segmentedControl.edgesToSuperview(excluding: .bottom, insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        segmentedControl.height(30)

        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    @objc func segmentedControlValueChanged(_ segmentedControl: UISegmentedControl) {
        addHaptic()
        let dateFormatter = DateFormatter()
        switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            items = selectedCategory?.items.sorted(byKeyPath: "date", ascending: true)
        case 1:
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            items = selectedCategory?.items.filter("dateDay == %@", dateFormatter.string(from: Date()))
        case 2:
            dateFormatter.dateFormat = "MM-yyyy"
            items = selectedCategory?.items.filter("dateMonth == %@", dateFormatter.string(from: Date()))
        case 3:
            dateFormatter.dateFormat = "yyyy"
            items = selectedCategory?.items.filter("dateYear == %@", dateFormatter.string(from: Date()))
        default:
            break
        }
        UIView.transition(with: tableView,
                          duration: 0.15,
                          options: .transitionCrossDissolve,
                          animations: { self.tableView.reloadData() })
        
    }

    
}




