//
//  ViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 01.05.2021.
//

import UIKit
import SwiftUI
import RealmSwift

import Charts
import SwipeCellKit
import ColorSlider
import ChameleonFramework
import WatchConnectivity

protocol UpdateMainScreenViewController {
    func update()
}

func addHaptic() {
    // ------- Haptic вибрация
    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    selectionFeedbackGenerator.selectionChanged()
    // -------
}

class MainScreenViewController: UIViewController, UIGestureRecognizerDelegate, UIColorPickerViewControllerDelegate {
  
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var preparedTableView: UITableView!
    @IBOutlet weak var limitTodayLabel: UILabel!
    @IBOutlet weak var addLimitButton: UIBarButtonItem!
 
    var realm = try! Realm()
    var categoryArray: Results<Category>?
    var moneyBoxes: Results<MoneyBox>?
    let defaults = UserDefaults.standard
    var session: WCSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.updateChartData()
        }
        checkLimit()
        configureWatchKitSesstion()
        sendAWData()
        checkLimitLabel()
        
        preparedTableView.delegate = self
        preparedTableView.dataSource = self
        preparedTableView.backgroundColor = UIColor.clear
        preparedTableView.layer.cornerRadius = 10
        preparedTableView.rowHeight = 60
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.backgroundColor = UIColor.clear
        mainTableView.layer.cornerRadius = 10
        mainTableView.rowHeight = 60
        mainTableView.showsHorizontalScrollIndicator = false
        mainTableView.showsVerticalScrollIndicator = false
    
        chartView.animate(xAxisDuration: 1, yAxisDuration: 1)
        
        categoryText.delegate = self
        
        tabBarController?.tabBar.tintColor = HexColor("#3762A5")
        
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sendAWData()
        checkLimitLabel()
        checkLimit()
    }
    
    override func viewWillAppear (_ animated: Bool) {
        super.viewWillAppear(animated)
        sendAWData()
        checkLimitLabel()
        checkLimit()
        updateChartData()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func checkLimitLabel() {
        let limit = defaults.double(forKey: "Limit")
        if limit > 0 {
            limitTodayLabel.text = "Ваш лимит: " + String(limit)
        } else if limit < 0 {
            limitTodayLabel.text = "Вы в минусе на: " + String(limit)
        } else {
            limitTodayLabel.text = "Лимит отсутствует"
        }
    }
    
    @objc func tapMainView(recognizer: UITapGestureRecognizer){
        backAnimate()
        tap.isEnabled = false
    }
    
    //MARK: - Money Box functionality
    
    func addCollectedToMoneyBox(sum: Double) {
        moneyBoxes = realm.objects(MoneyBox.self)
        if moneyBoxes!.count > 0 {
            for i in 0..<moneyBoxes!.count {
                do {
                    try realm.write({
                        if moneyBoxes![i].selected == true {
                            moneyBoxes![i].collected += sum
                        }
                    })
                } catch {
                    print("error")
                }
            }
        }
    }
    
    //MARK: - Present Limit View
    
    func checkLimit() {
        if let limitDate = defaults.object(forKey: "Date") as? Date {
            let limitValue = defaults.double(forKey: "Limit")
            if Date() >= limitDate {
                let newNotification = Notification()
                newNotification.date = limitDate
                newNotification.sum = limitValue
                if limitValue > 0 {
                    addCollectedToMoneyBox(sum: limitValue)
                    newNotification.done = true
                }
                newNotification.title = "Лимит"
                do {
                    try realm.write {
                        realm.add(newNotification)
                        defaults.setValue(nil, forKey: "Limit")
                        defaults.setValue(nil, forKey: "Date")
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    //MARK: - Chart
    
    @IBOutlet weak var chartView: PieChartView!
    
    private func updateChartData() {
        
        var downloadDataEnty: [PieChartDataEntry] = []
        var colors: [UIColor] = []
        categoryArray = realm.objects(Category.self)
        
        if let array = categoryArray {
            for i in array {
                let newPieChartData = PieChartDataEntry()
                if i.items.sum(ofProperty: "amount") > 0.0 {
                    newPieChartData.value = i.items.sum(ofProperty: "amount")
                } else {continue}
                if let color = HexColor(i.color) {
                    colors.append(color)
                }
                downloadDataEnty.append(newPieChartData)
            }
        }
        
        var allAmount: Double = 0
        if let array = categoryArray {
            for i in array {
                for j in i.items {
                    allAmount += j.amount
                }
            }
        }
        
//        let allAmount: Double = realm.objects(Item.self).sum(ofProperty: "amount")  // Сумма покупок за всё время
        chartView.centerAttributedText = NSAttributedString(string: String(allAmount), attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 14)!])
        chartView.holeColor = .clear
        chartView.transparentCircleColor = .clear
        
        let dataSet = PieChartDataSet(entries: downloadDataEnty, label: nil)
        dataSet.colors = colors
        dataSet.valueFont = .boldSystemFont(ofSize: 0)
        
        let data = PieChartData(dataSet: dataSet)
        chartView.data = data
        
        DispatchQueue.main.async {
            self.mainTableView.reloadData()
        }
        
    }
    
    //MARK: - Limit
    
    @IBAction func limitScreensButton(_ sender: UIBarButtonItem) {
        addHaptic()
        if defaults.object(forKey: "Date") as? Date != nil {
            performSegue(withIdentifier: "goToLimit", sender: self)
        } else {
            performSegue(withIdentifier: "goToCreateLimit", sender: self)
        }
    }
    
    //MARK: - Add Category
    
    @IBOutlet weak var addCategoryView: UIView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var sampleView: UIView!
    @IBOutlet weak var colorViewText: UILabel!
    @IBOutlet weak var categoryText: UITextField!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var viewAddAndColorButton: UIView!
    @IBOutlet var currencyButtons: [UIButton]!
    
    @IBOutlet weak var addCategoryOutlet: UIBarButtonItem!
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        addHaptic()
        addCategoryViewSettings()
    }
    
    var selectedCurrency = ""
    @IBAction func currency(_ sender: UIButton) {
        addHaptic()
        for i in currencyButtons {
            i.backgroundColor = .white
        }
        sender.backgroundColor = .clear
        if sender.tag == 1 {
            selectedCurrency = "$"
        } else if sender.tag == 2 {
            selectedCurrency = "Є"
        } else if sender.tag == 3 {
            selectedCurrency = "₽"
        }
        createButton.isEnabled = true
    }
    
    fileprivate func addCategoryViewSettings() {
        addBlurEffect()
        
        for i in currencyButtons {
            i.layer.cornerRadius = i.frame.size.height / 2
            i.backgroundColor = .white
        }
        
        tap = UITapGestureRecognizer(target: self, action: #selector(tapMainView))
        tap.isEnabled = true
        tap.delegate = self
        
        createButton.isEnabled = false
        
        sampleView.layer.cornerRadius = 10
        viewAddAndColorButton.layer.cornerRadius = 10
        colorView.layer.cornerRadius = colorView.frame.size.width/2
        colorView.backgroundColor = HexColor("#132743")
        colorButton.titleLabel?.text = ""
        
        colorViewText.font = UIFont.boldSystemFont(ofSize: 20)
        
        addCategoryView.alpha = 0
        addCategoryView.layer.cornerRadius = 10
        addCategoryView.center.y = view.center.x + 100
        addCategoryView.center.x = view.center.x
        addCategoryView.transform = CGAffineTransform(scaleX: 0.05, y: 0.1)
        
        categoryText.layer.cornerRadius = 10
        categoryText.attributedPlaceholder = NSAttributedString(string: "Название категории", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        
        view.addSubview(addCategoryView)
        blurEffectView.addGestureRecognizer(tap)
        
        addCategoryOutlet.isEnabled = false
        
        UIView.animate(withDuration: 0.2) {
            self.addCategoryView.center.y = self.view.center.y 
            self.addCategoryView.transform = CGAffineTransform.identity
            self.categoryText.becomeFirstResponder()
            self.addCategoryView.alpha = 1
        }
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func addCategoryButton(_ sender: UIButton) {
        if let category = categoryText.text {
            var colorHex: String = "132743"
            if let color = colorView.backgroundColor {
                colorHex = color.hexValue()
            }
            //Create Category
            let newCategory = Category()
            if category == "" {
                newCategory.title = "Новая категория"
            } else {
                newCategory.title = category
            }
            newCategory.color = colorHex
            //
            do {
                try realm.write {
                    realm.add(newCategory)
                    updateChartData()
                    backAnimate()
                    sendAWData()
                    addCategoryOutlet.isEnabled = true
                }
            } catch {
                print("Error added new Category")
            }
        }
    }
    
    @IBAction func closedCategoryView(_ sender: UIButton) {
        backAnimate()
    }
    
    func backAnimate() {
        self.blurEffectView.removeFromSuperview()
        categoryText.text = ""
        UIView.animate(withDuration: 0.25) {
            self.addCategoryView.alpha = 0
            self.addCategoryView.center.y = self.view.center.y + 300
            self.addCategoryView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
            self.addCategoryOutlet.isEnabled = true
        } completion: { _ in
            self.addCategoryView.removeFromSuperview()
        }
        navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        
    }
    
    private var blurEffectView = UIVisualEffectView()
    private var tap = UITapGestureRecognizer()
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.addSubview(blurEffectView)
    }
    
    //MARK: - Color Settings
    
    @IBOutlet weak var colorSettingsUIView: UIView!
    @IBOutlet weak var colorSlider: UIView!
    @IBOutlet weak var demonstrationView: UIView!
    @IBOutlet weak var demonstrationViewText: UILabel!
    
    var newColorSlider = ColorSlider()
    
    @IBAction func toColourSettings(_ sender: UIButton) {
        
        if #available(iOS 14.0, *) {
            let colorPickerVC = UIColorPickerViewController()
            colorPickerVC.delegate = self
            present(colorPickerVC, animated: true)
        } else {
            tap.isEnabled = false
            self.view.endEditing(true)

            demonstrationView.layer.cornerRadius = demonstrationView.frame.size.width/2
            demonstrationViewText.font = UIFont.boldSystemFont(ofSize: 20)

            let previewColorSlider = DefaultPreviewView()
            previewColorSlider.side = .right
            previewColorSlider.animationDuration = 0
            previewColorSlider.offsetAmount = 10

            newColorSlider = ColorSlider(orientation: .horizontal, previewView: previewColorSlider)
            newColorSlider.frame = CGRect(x: 0, y: 0, width: 300, height: 40)
            newColorSlider.center.x = colorSlider.center.x
            newColorSlider.center.y = newColorSlider.center.y + 25
            newColorSlider.addTarget(nil, action: #selector(changedColor(_:)), for: .valueChanged)

            colorSettingsUIView.layer.cornerRadius = 20
            colorSettingsUIView.center = view.center
            view.addSubview(colorSettingsUIView)

            colorSlider.addSubview(newColorSlider)
        }

    }
    
    @available(iOS 14.0, *)
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        let color = viewController.selectedColor
        colorView.backgroundColor = color
    }
    
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        colorView.backgroundColor = color
    }
    
    @objc func changedColor(_ slider: ColorSlider) {
        let color = slider.color
        demonstrationView.backgroundColor = color
    }
    
    @IBAction func plusAndMinusDark(_ sender: UIButton) {
        var darkRate: Float = 0
        var lightRate: Float = 0
        if sender.currentTitle == "+" {
            darkRate+=0.1
            demonstrationView.backgroundColor = demonstrationView.backgroundColor?.darken(byPercentage: CGFloat(darkRate))
        } else if sender.currentTitle == "-" {
            lightRate+=0.1
            demonstrationView.backgroundColor = demonstrationView.backgroundColor?.lighten(byPercentage: CGFloat(lightRate))
        }
    }
    
    @IBAction func addColor(_ sender: UIButton) {
        tap.isEnabled = true
        colorView.backgroundColor = demonstrationView.backgroundColor
        colorSettingsUIView.removeFromSuperview()
        newColorSlider.removeFromSuperview()
    }
    
    @IBAction func toBackFromColourSettings(_ sender: UIButton) {
        tap.isEnabled = true
        colorSettingsUIView.removeFromSuperview()
        newColorSlider.removeFromSuperview()
    }
    
}

//MARK: - Table View

extension MainScreenViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
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
            return categoryArray?.count ?? 2
        } else if tableView == preparedTableView {
            preparedTableView.isScrollEnabled = false
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == mainTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            cell.delegate = self
            if let category = categoryArray?[indexPath.row] {
                let categorySum: Double = category.items.sum(ofProperty: "amount")
                cell.layer.borderColor = UIColor.black.cgColor
                cell.layer.borderWidth = 0.25
                cell.view.backgroundColor = HexColor(category.color)
                cell.view.layer.cornerRadius = cell.view.frame.size.width/2
                cell.categoryName.text = category.title
                cell.amount.text = String(categorySum)
            }
            return cell
        } else if tableView == preparedTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AllPurchasesCell", for: indexPath)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    @objc func doubleTappedCell() {
        print("what")
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Удалить") { swipeAction, indexPath in
            if let array = self.categoryArray {
                do {
                    try self.realm.write {
                        self.realm.delete(array[indexPath.row].items)
                        self.realm.delete(array[indexPath.row])
                        self.updateChartData()
                        self.sendAWData()
                    }
                } catch {
                    print("Delete error")
                }
            }
        }
        let editAction = SwipeAction(style: .default, title: "Изменить") { swipeAction, indexPath in
        }
        
        deleteAction.backgroundColor = HexColor("#9B3636")
        
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == mainTableView {
            addHaptic()
            performSegue(withIdentifier: "goToItems", sender: self)
        } else if tableView == preparedTableView {
            addHaptic()
            performSegue(withIdentifier: "goToAllPurchases", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let destinationVC = segue.destination as! ItemsTableViewController
            if let indexPath = mainTableView.indexPathForSelectedRow {
                if let category = categoryArray?[indexPath.row] {
                    destinationVC.selectedCategory = category
                    destinationVC.title = category.title
                }
            }
        } else {
            guard let destination = segue.destination as? LimitViewController else { return }
            destination.delegate = self
        }
    }
    
    
    
}

//MARK: - WC (Apple Watch)

extension MainScreenViewController: WCSessionDelegate {
    
    func getCategoryNames() -> [String] {
        var arrayNames:[String] = []
        if let category = categoryArray {
            for i in 0..<category.count {
                arrayNames.append(category[i].title)
            }
        }
        return arrayNames
    }
    
    func sendAWData() {
        if WCSession.isSupported() {
            if let validSession = session {
                if let category = categoryArray {
                    let data: [String: Any] = ["categoryCount": category.count as Int, "categoryNames": getCategoryNames() as [String]]
                    do {
                        try validSession.updateApplicationContext(data)
                    } catch {
                        print("Error updateContext")
                    }
                }
            }
        }
    }
    
    func configureWatchKitSesstion() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print(error)
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
}

extension MainScreenViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == categoryText {
            colorViewText.text = categoryText.text ?? ""
            if colorViewText.text == "" {
                colorViewText.text = "Категория"
            }
            print(categoryText.text ?? "")
        }

    }
    
    
}

extension MainScreenViewController: UpdateMainScreenViewController {
    
    func update() {
        limitTodayLabel.text = "Лимит отсутствует"
    }

}

