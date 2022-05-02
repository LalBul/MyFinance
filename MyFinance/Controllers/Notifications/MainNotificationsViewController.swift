//
//  MainNotificationsViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 03.04.2022.
//

import UIKit
import RealmSwift
import ViewAnimator
import ChameleonFramework

class MainNotificationsViewController: UIViewController {

    @IBOutlet weak var mainTableView: UITableView!
    
    var realm = try! Realm()
    
    var notificationsArray: Results<Notification>?
    var mainScreen = MainScreenViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNotifications()
        mainScreen.checkLimit()
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.backgroundColor = UIColor.clear
        mainTableView.layer.cornerRadius = 10
        mainTableView.rowHeight = 70
        mainTableView.separatorStyle = .none
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        
        let animation = AnimationType.from(direction: .top, offset: 100)
        UIView.animate(views: mainTableView.visibleCells,
                       animations: [animation])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainScreen.checkLimit()
        loadNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainScreen.checkLimit()
        loadNotifications()
    }
    
    func loadNotifications() {
        notificationsArray = realm.objects(Notification.self).sorted(byKeyPath: "date", ascending: false)
        mainTableView.reloadData()
    }
    

}

extension MainNotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == mainTableView {
            return notificationsArray?.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current
        if let notification = notificationsArray?[indexPath.row] {
            if notification.done == true {
                cell.done.textColor = HexColor("33A64B")
                cell.done.text = "Выполнено"
                cell.sum.text = "+" + String(notification.sum)
            } else {
                cell.done.textColor = HexColor("D05C5C")
                cell.done.text = "Не выполнено"
                cell.sum.text = String(notification.sum)
            }
            cell.date.text = dateFormatter.string(from: notification.date!)
            cell.title.text = String(notification.title)
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 0.25
            cell.selectionStyle = .none
        }
        return cell
        
    }
}
