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
    var selectedPerson = ""
    var initialBudget = 0.0
    var budget = 0.0
    var rowHeights = [Int]()
    var defaultRowHeight = 50
    
    @IBOutlet weak var giftPersonNameLabel: UILabel!
    @IBOutlet weak var totalBudgetLabel: UILabel!
    @IBOutlet weak var giftListTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                       managedObjectContext = appDelegate.persistentContainer.viewContext

        print("ViewDidLoad is called.")
        self.giftListTable.dataSource = self
        self.giftListTable.delegate = self
        loadCoreData()

        rowHeights = Array(repeating: defaultRowHeight, count: giftListTable.numberOfRows(inSection: 0))

    
        if let selectedSantaGift = selectedItem {
            selectedPerson = selectedSantaGift.person ?? "Unknown Person"
            initialBudget = selectedSantaGift.budget
            budget = initialBudget
            print("Selected Person: \(selectedSantaGift.person ?? "Unknown Person")")
            print("Selected Budget: \(selectedSantaGift.budget)")
            
            updateTextFields()
        } else {
            print("selectedItem is nil")
        }
    }
    
    func updateTextFields(){
        giftPersonNameLabel.text = "\(selectedPerson)"
        totalBudgetLabel.text = "\(budget)"
    }
    
    @IBAction func addGiftToList(_ sender: Any) {
        let alertController = UIAlertController(title: "Santas Gift Workshop", message: "Do you want to add new gift?", preferredStyle: .alert)
            alertController.addTextField { textFieldValue in
                textFieldValue.placeholder = "Your gift here.."
            }
            alertController.addTextField { subtextFieldValue in
                subtextFieldValue.placeholder = "Price for gift here.."
            }
            let addActionButton = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
                guard let self = self,
                      let textField = alertController.textFields?.first,
                      let subtitleTextField = alertController.textFields?.last,
                      let managedObjectContext = self.managedObjectContext,
                      let entity = NSEntityDescription.entity(forEntityName: "SantaAddGift", in: managedObjectContext) else {
                    return
                }

                let list = NSManagedObject(entity: entity, insertInto: managedObjectContext)
                list.setValue(textField.text, forKey: "gift")
                list.setValue(selectedPerson, forKey: "personID")
                if let budgetText = subtitleTextField.text, let budgetValue = Double(budgetText) {
                    list.setValue(budgetValue, forKey: "giftPrice")
                }

                self.saveCoreData()
                self.santasAddGifts.append(list as! SantaAddGift)
                budget = initialBudget
                rowHeights.append(defaultRowHeight)
            }
            let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
            alertController.addAction(addActionButton)
            alertController.addAction(cancelActionButton)
            present(alertController, animated: true)
        }
    
    // MARK: - TableView DataSource and Delegate methods
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return santasAddGifts.count
        }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Cell for row at index path: \(indexPath.row)")
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "giftPriceCell", for: indexPath) as! GiftDetailTableViewCell
        
        let santaGift = santasAddGifts[indexPath.row]
        cell.giftNameLabel?.text = santaGift.gift ?? ""
        cell.giftPriceLabel?.text = "\(santaGift.giftPrice)"
        
        if santaGift.personID != selectedPerson {
            rowHeights[indexPath.row] = 0
        }
        else {
            budget -= santaGift.giftPrice
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
            self.budget = self.initialBudget
            self.updateTextFields()
            self.managedObjectContext?.delete(self.santasAddGifts[indexPath.row])
            self.saveCoreData()
            completionHandler(true)
        }
        

        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

    }

    
    // MARK: - CoreData logic
    
    func loadCoreData() {
        let request: NSFetchRequest<SantaAddGift> = SantaAddGift.fetchRequest()
        do {
            let result = try managedObjectContext?.fetch(request)
            santasAddGifts = result ?? []
            print("Number of gifts loaded: \(santasAddGifts.count)")
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
    
    func deleteAllCoreData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "SantaGift")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedObjectContext?.execute(deleteRequest)
            santasAddGifts.removeAll()
            self.giftListTable.reloadData()
        } catch {
            fatalError("Error in deleting all items from core data")
        }
    }
}
