//
//  ViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 01.05.2021.
//

import UIKit
import RealmSwift
import Charts
import SwipeCellKit
import ColorSlider
import ChameleonFramework
import WatchConnectivity

class MainScreenViewController: UIViewController {

    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var limitTodayLabel: UILabel!
    @IBOutlet weak var addLimitButton: UIBarButtonItem!
    
    var realm = try! Realm()
    var categoryArray: Results<Category>?
    var items: Results<Items>?
    let defaults = UserDefaults.standard
    
    var session: WCSession?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        limitViewPresent()
        updateChartData()
        
        configureWatchKitSesstion()
    
        mainTableView.backgroundColor = UIColor.clear
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.layer.cornerRadius = 20
        mainTableView.rowHeight = 60
        
        navigationController?.navigationBar.barTintColor = HexColor("1D2D50")
    }
    
    override func viewWillAppear (_ animated: Bool) {
        setGradientBackground()
        let limit = defaults.double(forKey: "Limit")
        if limit > 0 {
            addLimitButton.isEnabled = false
            limitTodayLabel.text = "Left: " + String(limit)
        } else if limit < 0 {
            addLimitButton.isEnabled = false
            limitTodayLabel.text = String(limit)
        } else {
            limitTodayLabel.text = "There is no limit"
        }
        updateChartData()
    }
    
    func configureWatchKitSesstion() {
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    //MARK: - Present Limit View
    
    @IBOutlet var startLimitView: UIView!
    @IBOutlet weak var limitLabel: UILabel!
    
    @IBAction func okLimit(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25) {
            self.startLimitView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.startLimitView.center.y += 500
        } completion: { _ in
            self.startLimitView.removeFromSuperview()
        }
    }
    
    func limitViewPresent() {
        
        if let limitDate = defaults.object(forKey: "Date") as? Date {
            let limitValue = defaults.double(forKey: "Limit")
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            if formatter.string(from: Date()) != formatter.string(from: limitDate) { // Следующий день лимита
                if limitValue > 0 {
                    limitLabel.text = "You saved \(limitValue)"
                } else if limitValue < 0 {
                    limitLabel.text = "You are in the red by \(limitValue)"
                } else {
                    limitLabel.text = "There was no limit"
                }
                defaults.setValue(nil, forKey: "Limit")
                defaults.setValue(nil, forKey: "Date")
                limitLabel.layer.cornerRadius = 10
                startLimitView.center = view.center
                startLimitView.layer.cornerRadius = 15
                view.addSubview(startLimitView)
            } else {
                // Тот-же день лимита
            }
        }
    }
    
   
    //MARK: - Chart
    
    @IBOutlet weak var chartView: PieChartView!
    var downloadDataEnty: [PieChartDataEntry] = []
    
    func getCategoryNames() -> [String] {
        var arrayNames:[String] = []
        if let category = categoryArray {
            for i in 0...category.count {
                arrayNames.append(category[i].title)
            }
        }
        return arrayNames
    }
    
    private func updateChartData() {
        
        downloadDataEnty = []
        var colors: [UIColor] = []
        categoryArray = realm.objects(Category.self)
        
        // Передача Apple Watch
        if session?.activationState == .activated {
            if let validSession = self.session, validSession.isReachable {
                let data: [String: Any] = ["categoryCount": categoryArray?.count as Any]
                let categoryNames: [String: Any] = ["categoryNames": getCategoryNames() as Any]
                validSession.sendMessage(data, replyHandler: nil, errorHandler: nil)
                validSession.sendMessage(categoryNames, replyHandler: nil, errorHandler: nil)
            }
        }
        //
        
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
        
        let allAmount: Double = realm.objects(Items.self).sum(ofProperty: "amount")  // Сумма покупок за всё время
        chartView.centerText = String(allAmount)
        
        let dataSet = PieChartDataSet(entries: downloadDataEnty, label: nil)
        dataSet.colors = colors
        dataSet.valueFont = .boldSystemFont(ofSize: 0)
        
        let data = PieChartData(dataSet: dataSet)
        chartView.data = data
        
        mainTableView.reloadData()
        
    }
    
    func setGradientBackground() { // Градиент
        let colorTop = UIColor(hexString: "213C66")!.darken(byPercentage: 0.15)!.cgColor
        let colorBottom = UIColor(.black).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    
    //MARK: - Add Category
    
    @IBOutlet weak var addCategoryUIView: UIView!
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorViewText: UILabel!
    @IBOutlet weak var categoryText: UITextField!
    
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    private var blurEffectView = UIVisualEffectView()
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        
        navigationController?.navigationBar.isHidden = true
        
        colorView.layer.cornerRadius = 10
        colorButton.setImage(UIImage(named:"palette"), for: .normal)
        backButton.setImage(UIImage(named:"back"), for: .normal)
        colorView.backgroundColor = HexColor("#132743")
        
        colorViewText.font = UIFont.boldSystemFont(ofSize: 20)
        
        addCategoryUIView.layer.cornerRadius = 20
        addCategoryUIView.center = view.center
        addCategoryUIView.transform = CGAffineTransform(scaleX: 0.05, y: 0.1)
        
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        categoryText.layer.cornerRadius = 10
        categoryText.attributedPlaceholder = NSAttributedString(string: "Category name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        
        blurEffectView.frame = view.bounds
        view.addSubview(blurEffectView)
        view.addSubview(addCategoryUIView)
        
        UIView.animate(withDuration: 0.2) {
            self.addCategoryUIView.transform = CGAffineTransform.identity
        }
    }
    
    @IBAction func addCategoryCancel(_ sender: UIButton) {
        backAnimate()
        blurEffectView.removeFromSuperview()
    }
    
    @IBAction func addCategoryButton(_ sender: UIButton) {
        if let category = categoryText.text {
            var colorHex: String = "132743"
            if let color = colorView.backgroundColor {
                colorHex = color.hexValue()
            }
            
            let newCategory = Category()
            newCategory.title = category
            newCategory.color = colorHex
            do {
                try realm.write {
                    realm.add(newCategory)
                    updateChartData()
                    backAnimate()
                }
            } catch {
                print("Error added new Category")
            }
        }
        navigationController?.navigationBar.isHidden = false
        blurEffectView.removeFromSuperview()
    }
    
    func backAnimate() {
        categoryText.text = ""
        UIView.animate(withDuration: 0.2) {
            self.addCategoryUIView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        } completion: { _ in
            self.addCategoryUIView.removeFromSuperview()
        }
        navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: - Color Settings
    
    @IBOutlet weak var colorSettingsUIView: UIView!
    
    @IBOutlet weak var colorSlider: UIView!
    @IBOutlet weak var demonstrationView: UIView!
    @IBOutlet weak var demonstrationViewText: UILabel!
    
    var newColorSlider = ColorSlider()
    
    @IBAction func toColourSettings(_ sender: UIButton) {
        
        demonstrationView.layer.cornerRadius = 10
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
        colorView.backgroundColor = demonstrationView.backgroundColor
        colorSettingsUIView.removeFromSuperview()
        newColorSlider.removeFromSuperview()
    }
    
    @IBAction func toBackFromColourSettings(_ sender: UIButton) {
        colorSettingsUIView.removeFromSuperview()
        newColorSlider.removeFromSuperview()
    }
    
    @objc func changedColor(_ slider: ColorSlider) {
        let color = slider.color
        demonstrationView.backgroundColor = color
    }
    
    
}

//MARK: - Table View

extension MainScreenViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categoryArray!.count <= 5 {
            mainTableView.isScrollEnabled = false
        } else {
            mainTableView.isScrollEnabled = true
        }
        return categoryArray?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        if let category = categoryArray?[indexPath.row] {
            cell.textLabel?.text = category.title
            cell.contentView.backgroundColor = HexColor(category.color)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { swipeAction, indexPath in
            if let array = self.categoryArray {
                do {
                    try self.realm.write {
                        self.realm.delete(array[indexPath.row].items)
                        self.realm.delete(array[indexPath.row])
                        self.updateChartData()
                    }
                } catch {
                    print("Delete error")
                }
            }
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let destinationVC = segue.destination as! ItemsViewController
            if let indexPath = mainTableView.indexPathForSelectedRow {
                if let category = categoryArray?[indexPath.row] {
                    destinationVC.selectedCategory = category
                }
            }
        }
    }
    
    
}

extension MainScreenViewController: WCSessionDelegate {
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
    }
    
}

