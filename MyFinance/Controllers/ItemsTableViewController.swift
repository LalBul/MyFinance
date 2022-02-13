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

class ItemsTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    @IBOutlet weak var addItemOutlet: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        
        tableView.rowHeight = 100
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        defaultValue = defaults.double(forKey: "Limit")
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
    
    func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "date")
        tableView.reloadData()
    }
    
    //MARK: - Add Item
    
    @IBOutlet var addItemView: UIView!
    
    @IBOutlet weak var wasteTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var cancelOutlet: UIButton!
    
    private var blurEffectView = UIVisualEffectView()
    
    fileprivate func addItemViewSettings(_ sender: UIBarButtonItem) {
        tableView.isScrollEnabled = false
        
        addItemView.layer.cornerRadius = 15
        addItemView.center = view.center
        addItemView.center.y -= 500
        addItemView.center.x += 150
        addItemView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        
        wasteTextField.attributedPlaceholder = NSAttributedString(string: "What did you spend it on?", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)])
        wasteTextField.layer.cornerRadius = 15
        
        amountTextField.attributedPlaceholder = NSAttributedString(string: "Amount", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
        amountTextField.layer.cornerRadius = 20
        amountTextField.keyboardType = .decimalPad
        
        cancelOutlet.setImage(UIImage(named:"cancel"), for: .normal)
        
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(blurEffectView)
        view.addSubview(addItemView)
        
        UIView.animate(withDuration: 0.25) {
            self.addItemView.center.y = 250
            self.addItemView.center.x = self.view.center.x
            self.addItemView.transform = CGAffineTransform.identity
            sender.isEnabled = false
        }
    }
    
    @IBAction func addItemButton(_ sender: UIBarButtonItem) {
        addItemViewSettings(sender)
    }
    
    @IBAction func addItem(_ sender: UIButton) {
        let numberFormatter = NumberFormatter()
        numberFormatter.decimalSeparator = ","
        if let waste = wasteTextField.text, let amount = amountTextField.text {
            var format = numberFormatter.number(from: amount)
            if format == nil {
                numberFormatter.decimalSeparator = "."
                format = numberFormatter.number(from: amount)
            }
            guard let amountInDouble = format as? Double else {fatalError("Error converting in Double")}
            let newItem = Item()
            newItem.date = Date()
            newItem.title = waste
            newItem.amount = amountInDouble
            do {
                try realm.write {
                    selectedCategory?.items.append(newItem)
                    if defaults.double(forKey: "Limit") > 0  {
                        defaults.setValue(defaultValue-amountInDouble, forKey: "Limit")
                    }
                    backAnimate()
                    tableView.reloadData()
                }
            } catch {
                print("Error save item")
            }
        }
    }
    
    @IBAction func cancelAddItem(_ sender: UIButton) {
        backAnimate()
    }
    
    func backAnimate() {
        blurEffectView.removeFromSuperview()
        navigationController?.navigationBar.isHidden = false
        tableView.isScrollEnabled = true
        wasteTextField.text = ""
        amountTextField.text = ""
        UIView.animate(withDuration: 0.25) {
            self.addItemView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.addItemView.center.y += 500
        } completion: { _ in
            self.addItemView.removeFromSuperview()
        }
        addItemOutlet.isEnabled = true
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
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { swipeAction, indexPath in
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
                    tableView.reloadData()
                }
            } catch {
                print("Fail delete cell")
            }
        }
        return [deleteAction]
    }
    
}

