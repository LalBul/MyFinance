//
//  AccountViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 14.04.2022.
//

import UIKit
import RealmSwift
import ChameleonFramework

class AccountViewController: UIViewController, UpdateDataViewController {

    @IBOutlet weak var mainTableView: UITableView!

    weak var delegate: MainFinanceViewController?
    var selectedAccount: Account?
    var accountHistories: Results<AccountHistory>?

    var realm = try! Realm()
    
    func update() {
        loadItems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.showsVerticalScrollIndicator = false
        mainTableView.allowsSelection = false
        mainTableView.separatorStyle = .none
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadItems()
    }
    
    func loadItems() {
        accountHistories = selectedAccount?.history.sorted(byKeyPath: "date", ascending: false)
        mainTableView.reloadData()
    }
    
    @IBAction func deleteAccount(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Удалить счёт?", message: "" ,         preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Назад", style: UIAlertAction.Style.default, handler: { _ in
                    //Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "Удалить", style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
            do {
                try self.realm.write {
                    self.realm.delete(self.selectedAccount!)
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } catch {print(error)}
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addCashToAccount(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToAddMoneyToAccount", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddMoneyToAccount" {
            let destinationVC = segue.destination as! AddMoneyToAccountViewController
            destinationVC.selectedAccount = selectedAccount
            destinationVC.delegate = self
        }
    }
    
    
}

//MARK: - Table View
extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return selectedAccount?.history.count ?? 0
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountHistory", for: indexPath) as! HistoryBudgetCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ru_RU")
         if let accountHistory = accountHistories?[indexPath.row] {
             if accountHistory.sum < 0 {
                 cell.sum.textColor = .white
                 cell.sum.text = String(accountHistory.sum) + " \(selectedAccount?.currency ?? "")"
             } else {
                 cell.sum.textColor = HexColor("33A64B")
                 cell.sum.text = "+" + String(accountHistory.sum) + " \(selectedAccount?.currency ?? "")"
             }
             cell.operation.text = accountHistory.operation
             cell.date.text = dateFormatter.string(from: accountHistory.date)
             cell.view.layer.cornerRadius = 10
             cell.imageRashod.layer.cornerRadius = 5
         }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
        header.backgroundColor = .clear
        let title = UILabel()
        if let selectedAccount = selectedAccount {
            title.text = "\(selectedAccount.title): \(selectedAccount.collected) \(selectedAccount.currency)"
        }
        title.font = UIFont(name: "HelveticaNeue-Bold", size: 26)
        title.textAlignment = .center
        header.addSubview(title)
        title.edgesToSuperview(excluding: .bottom, insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), usingSafeArea: true)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }


}

