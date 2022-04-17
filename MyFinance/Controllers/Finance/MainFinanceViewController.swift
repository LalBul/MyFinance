//
//  MainFinanceViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 29.03.2022.
//

import Foundation
import UIKit
import RealmSwift
import ChameleonFramework
import UPCarouselFlowLayout
import SwiftUI

protocol UpdateDataViewController {
    func update()
}

class MainFinanceViewController: UIViewController, UpdateDataViewController {
    
    func update() {
        loadItems()
    }
    
    @IBOutlet weak var financeView: UIView!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var accountCollectionView: UICollectionView!
    
    var budget: Results<Budget>?
    var accounts: Results<Account>?
    var realm = try! Realm()
    var historyBudget: Results<HistoryBudget>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstAddBudget()
        setupLabelTap()
        
        accountCollectionView.layer.cornerRadius = 10
        accountCollectionView.dataSource = self
        accountCollectionView.delegate = self
        
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.showsVerticalScrollIndicator = false
            
        financeView.layer.cornerRadius = 20
        
        let layout = UPCarouselFlowLayout()
        layout.itemSize = CGSize(width: 160, height: 80)
        layout.scrollDirection = .horizontal;
        accountCollectionView.collectionViewLayout = layout
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        firstAddBudget()
    }
    
    func setupLabelTap() {
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
        self.budgetLabel.isUserInteractionEnabled = true
        self.budgetLabel.addGestureRecognizer(labelTap)
    }
    
    private var score = 0
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        addHaptic()
        if let budgetScore = budget?[0].collected {
            if score == 0 {
                budgetLabel.text = String(format: "%.2f", (budgetScore / 80 )) + " $"
                score += 1
            } else if score == 1 {
                budgetLabel.text = String(format: "%.2f", (budgetScore / 90 )) + " Є"
                score += 1
            } else if score == 2 {
                budgetLabel.text = String(format: "%.2f", (budgetScore)) + " ₽"
                score = 0
            }
        }
    }
    
    func firstAddBudget() {
        if budget?.count == 0 {
            let newBudget = Budget()
            newBudget.collected = 0
            do {
                try realm.write({
                    realm.add(newBudget)
                    loadItems()
                })
            } catch {
                print(error)
            }
        } else {
            loadItems()
        }
    }
    
    func loadItems() {
        accounts = realm.objects(Account.self)
        budget = realm.objects(Budget.self)
        historyBudget = realm.objects(HistoryBudget.self).sorted(byKeyPath: "date", ascending: false)
        if budget!.count > 0 {
            budgetLabel.text = String(format: "%.2f", budget?[0].collected ?? 123) + " ₽"
        }
        accountCollectionView.reloadData()
        mainTableView.reloadData()
    }
    
    @IBAction func addMoneyToBudget(_ sender: UIBarButtonItem) {
        do {
            try realm.write({
                budget?[0].collected += 100
                loadItems()
            })
        } catch {
            print(error)
        }
    }
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        let dateFormatter = DateFormatter()
        if sender.selectedSegmentIndex == 0 {
            historyBudget = realm.objects(HistoryBudget.self).sorted(byKeyPath: "date", ascending: false)
            mainTableView.reloadData()
        } else if sender.selectedSegmentIndex == 1 {
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            historyBudget = realm.objects(HistoryBudget.self).filter("dateDay == %@", dateFormatter.string(from: Date())).sorted(byKeyPath: "date", ascending: false)
            mainTableView.reloadData()
        } else if sender.selectedSegmentIndex == 2 {
            dateFormatter.dateFormat = "MM-yyyy"
            historyBudget = realm.objects(HistoryBudget.self).filter("dateMonth == %@", dateFormatter.string(from: Date())).sorted(byKeyPath: "date", ascending: false)
            mainTableView.reloadData()
        } else if sender.selectedSegmentIndex == 3 {
            dateFormatter.dateFormat = "yyyy"
            historyBudget = realm.objects(HistoryBudget.self).filter("dateYear == %@", dateFormatter.string(from: Date())).sorted(byKeyPath: "date", ascending: false)
            mainTableView.reloadData()
        }
        
    }
    
}

//MARK: - Table View
extension MainFinanceViewController: UITableViewDelegate, UITableViewDataSource {
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return historyBudget?.count ?? 1
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryBudget", for: indexPath) as! HistoryBudgetCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ru_RU")
        if let history = historyBudget?[indexPath.row] {
            if history.sum < 0 {
                cell.sum.textColor = .white
                cell.sum.text = String(history.sum)
            } else {
                cell.sum.textColor = HexColor("33A64B")
                cell.sum.text = "+" + String(history.sum)
            }
            cell.operation.text = history.operation
            cell.date.text = dateFormatter.string(from: history.date)
            cell.view.layer.cornerRadius = 10
            cell.imageRashod.layer.cornerRadius = 5
            cell.selectionStyle = .none
            
        }
        return cell
    }

}

extension MainFinanceViewController: UICollectionViewDelegate, UICollectionViewDataSource  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let acccountsCount = accounts?.count {
            if acccountsCount > 0 {
                self.accountCollectionView.restore()
                return acccountsCount
            } else {
                self.accountCollectionView.setEmptyMessage("Счетов пока нет")
                return 0
            }
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        
        if let configureCell = accountCollectionView.dequeueReusableCell(withReuseIdentifier: "AccountCell", for: indexPath) as? AccountCell {
            if let account = accounts?[indexPath.row] {
                configureCell.collected.text = String(account.collected)
                configureCell.currency.text = account.currency
                configureCell.title.text = account.title
                configureCell.index = indexPath // Функционал удаления Копилки

                configureCell.view.layer.cornerRadius = 10
            }
            cell = configureCell
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        addHaptic()
        performSegue(withIdentifier: "goToAccount", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddMoneyToBudget" {
            let destinationVC = segue.destination as! AddMoneyToBudgetViewController
            destinationVC.delegate = self
        } else if segue.identifier == "goToAccount" {
            let destinationVC = segue.destination as! AccountViewController
            if let indexPath = accountCollectionView.indexPathsForSelectedItems {
                if let account = accounts?[indexPath[0].row] {
                    destinationVC.selectedAccount = account
                    destinationVC.delegate = self
                }
            }
        } else if segue.identifier == "goToCreateAccount" {
            let destinationVC = segue.destination as! AddAccountViewController
            destinationVC.delegate = self
        }
    }

}

extension UICollectionView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .gray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        messageLabel.alpha = 0.8
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel;
    }

    func restore() {
        self.backgroundView = nil
    }
}
