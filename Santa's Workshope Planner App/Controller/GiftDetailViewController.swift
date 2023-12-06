//
//  GiftDetailViewController.swift
//  Santa's Workshope Planner App
//
//  Created by liga.griezne on 29/11/2023.
//

import UIKit
import CoreData

class GiftDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var selectedItem: SantaGift?
    var managedObjectContext: NSManagedObjectContext?
    var santasAddGifts = [SantaAddGift]()
    var selectedPersonID = 0
    var selectedPersonName = ""
    var initialBudget = 0.0
    var budget = 0.0
    var rowHeights = [Int]()
    var defaultRowHeight = 50
    @IBOutlet weak var giftPersonNameLabel: UILabel!
    @IBOutlet weak var totalBudgetLabel: UILabel!
    @IBOutlet weak var giftListTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            giftListTable.addGestureRecognizer(longPressGesture)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedObjectContext = appDelegate.persistentContainer.viewContext
        self.giftListTable.dataSource = self
        self.giftListTable.delegate = self
        loadCoreData()
        rowHeights = Array(repeating: defaultRowHeight, count: giftListTable.numberOfRows(inSection: 0))
        if let selectedSantaGift = selectedItem {
            selectedPersonName = selectedSantaGift.person ?? "Unknown Person"
            selectedPersonID = Int(selectedSantaGift.id)
            initialBudget = selectedSantaGift.budget
            budget = initialBudget
            updateTextFields()
        } else {
            print("selectedItem is nil")
        }
    }
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: giftListTable)
            if let indexPath = giftListTable.indexPathForRow(at: point) {
                showEditAlert(forIndexPath: indexPath)
            }
        }
    }
    func showEditAlert(forIndexPath indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Edit Gift", message: "Edit the gift details", preferredStyle: .alert)
        alertController.addTextField { textFieldValue in
            textFieldValue.text = self.santasAddGifts[indexPath.row].gift
        }
        alertController.addTextField { subtextFieldValue in
            subtextFieldValue.text = String(self.santasAddGifts[indexPath.row].giftPrice)
            subtextFieldValue.keyboardType = .decimalPad
        }
        let editActionButton = UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alertController.textFields?.first,
                  let subtitleTextField = alertController.textFields?.last else {
                return
            }
            let editedGift = self.santasAddGifts[indexPath.row]
            editedGift.gift = textField.text
            if let budgetText = subtitleTextField.text,
               let budgetValue = Double(budgetText) {
                editedGift.giftPrice = budgetValue
                self.saveCoreData()
                self.giftListTable.reloadRows(at: [indexPath], with: .automatic)
                self.budget = recalculateBudget(budget: initialBudget)
                self.updateTextFields()
            } else {
                self.showErrorMessage(message: "Please enter a valid price for the gift.")
            }
        }
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(editActionButton)
        alertController.addAction(cancelActionButton)
        present(alertController, animated: true)
    }
    func recalculateBudget(budget: Double) -> Double {
        var plannedExpense = 0.0
        self.santasAddGifts.forEach { item in
            if (item.personID == selectedPersonID) {
                plannedExpense += item.giftPrice
            }
        }
        return budget - plannedExpense
    }
    func updateTextFields() {
        giftPersonNameLabel.text = "\(selectedPersonName)"
        giftPersonNameLabel.textColor = UIColor(hex: "#6E140D")
        let formattedBudget = String(format: "%.2f", budget)
        totalBudgetLabel.text = "\(formattedBudget)"
    }
    @IBAction func addGiftToList(_ sender: Any) {
        let alertController = UIAlertController(title: "Santas Gift Workshop", message: "Do you want to add new Santa's gift?", preferredStyle: .alert)
        alertController.addTextField { textFieldValue in
            textFieldValue.placeholder = "Your gift here.."
        }
        alertController.addTextField { subtextFieldValue in
            subtextFieldValue.placeholder = "Price for gift here.."
            subtextFieldValue.keyboardType = .decimalPad
        }
        let addActionButton = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alertController.textFields?.first,
                  let subtitleTextField = alertController.textFields?.last,
                  let managedObjectContext = self.managedObjectContext,
                  let entity = NSEntityDescription.entity(forEntityName: "SantaAddGift", in: managedObjectContext) else {
                return
            }
            guard let budgetText = subtitleTextField.text,
                  let budgetValue = Double(budgetText) else {
                self.showErrorMessage(message: "Please enter a valid price for the gift.")
                return
            }
            let list = NSManagedObject(entity: entity, insertInto: managedObjectContext)
            list.setValue(textField.text, forKey: "gift")
            list.setValue(selectedPersonID, forKey: "personID")
            list.setValue(budgetValue, forKey: "giftPrice")
            self.saveCoreData()
            rowHeights.append(defaultRowHeight)
        }
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(addActionButton)
        alertController.addAction(cancelActionButton)
        present(alertController, animated: true)
    }
    func showErrorMessage(message: String) {
        let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        errorAlert.addAction(okAction)
        present(errorAlert, animated: true, completion: nil)
    }
// MARK: - TableView DataSource and Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return santasAddGifts.count
        }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "giftPriceCell", for: indexPath) as! GiftDetailTableViewCell
        let santaGift = santasAddGifts[indexPath.row]
        cell.giftNameLabel?.text = santaGift.gift ?? ""
        cell.giftPriceLabel?.text = String(format: "%.2f", santaGift.giftPrice)
        if santaGift.personID != selectedPersonID {
            rowHeights[indexPath.row] = 0
        }
        else {
            budget = recalculateBudget(budget: initialBudget)
            updateTextFields()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(rowHeights[indexPath.row])
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            self.managedObjectContext?.delete(self.santasAddGifts[indexPath.row])
            self.saveCoreData()
            self.rowHeights.remove(at: indexPath.row)
            self.budget = self.recalculateBudget(budget: self.initialBudget)
            self.updateTextFields()
            completionHandler(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    // MARK: - CoreData logic
    func loadCoreData() {
        let request: NSFetchRequest<SantaAddGift> = SantaAddGift.fetchRequest()
        do {
            let result = try managedObjectContext?.fetch(request)
            santasAddGifts = result ?? []
            self.giftListTable.reloadData()
        } catch {
            fatalError("Error in loading item into core data")
        }
    }
    func saveCoreData() {
        do {
            try managedObjectContext?.save()
            self.giftListTable.reloadData()
        } catch {
            fatalError("Error in saving item into core data")
        }
        loadCoreData()
    }
}
