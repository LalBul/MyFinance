//
//  SettingsTableViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 29.04.2022.
//

import UIKit
import RealmSwift

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 50
        tableView.separatorStyle = .none
    }
    
    var realm = try! Realm()
    let defaults = UserDefaults.standard

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! SettingsCell
        
        cell.title.text = "Очистка всех данных"
        cell.view.layer.cornerRadius = 10
        cell.imageSetting.image = UIImage(named: "trashImage")
        cell.imageSetting.backgroundColor = .white
        cell.imageSetting.layer.cornerRadius = 5
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            do {
                try realm.write({
                    let alert = UIAlertController(title: "Удалить все данные?", message: "" ,         preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Отмена", style: UIAlertAction.Style.default, handler: { _ in
                        addHaptic()
                                //Cancel Action
                    }))
                    alert.addAction(UIAlertAction(title: "Удалить", style: UIAlertAction.Style.default, handler: { [self](_: UIAlertAction!) in
                        do {
                            try self.realm.write {
                                addHaptic()
                                realm.deleteAll()
                                defaults.setValue(nil, forKey: "Limit")
                                defaults.setValue(nil, forKey: "Date")
                                let newBudget = Budget()
                                newBudget.collected = 0
                                realm.add(newBudget)
                                tabBarController?.selectedIndex = 0
                            }
                        } catch {print(error)}
                    }))
                    self.present(alert, animated: true, completion: nil)
                })
            } catch {
                print(error)
            }
        }
    }
   

}
