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
        
        if let selectedSantaGift = selectedItem {
            print("Selected Person: \(selectedSantaGift.person ?? "Unknown Person")")
            print("Selected Budget: \(selectedSantaGift.budget)")
            
            giftPersonNameLabel.text = "\(selectedSantaGift.person ?? "Unknown Person")"
            totalBudgetLabel.text = "\(selectedSantaGift.budget)"
        } else {
            print("selectedItem is nil")
        }
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
                if let budgetText = subtitleTextField.text, let budgetValue = Double(budgetText) {
                    list.setValue(budgetValue, forKey: "giftPrice")
                }
                

                self.saveCoreData()
                self.santasAddGifts.append(list as! SantaAddGift)
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
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 44.0 // Adjust the height as needed
//    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Cell for row at index path: \(indexPath.row)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "giftPriceCell", for: indexPath) as! GiftDetailTableViewCell
        
        let santaGift = santasAddGifts[indexPath.row]
        cell.giftNameLabel?.text = santaGift.gift ?? ""
        cell.giftPriceLabel?.text = "\(santaGift.giftPrice)"
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // cell selected code here
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
    
//    func deleteAllCoreData() {
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "SantaGift")
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        do {
//            try managedObjectContext?.execute(deleteRequest)
//            santasGifts.removeAll()
//            self.giftListTable.reloadData()
//        } catch {
//            fatalError("Error in deleting all items from core data")
//        }
//    }
    
//    // MARK: - Empty view logic
//
//        func setEmptyViewGiftDetail(title: String, message: String) {
//            // Check if there are no items in the table view
//            guard self.santasGifts.isEmpty else {
//                // If there are items, reset background view and separator style
//                self.giftListTable.backgroundView = nil
//                self.giftListTable.separatorStyle = .singleLine
//                return
//            }
//
//            // Create a new empty view
//            let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.giftListTable.bounds.size.width, height: self.giftListTable.bounds.size.height))
//            let titleLabel = UILabel()
//            let messageLabel = UILabel()
//
//            titleLabel.translatesAutoresizingMaskIntoConstraints = false
//            messageLabel.translatesAutoresizingMaskIntoConstraints = false
//
//            titleLabel.textColor = UIColor.black
//            titleLabel.font = UIFont(name: "Quando-Regular", size: 23)
//
//            messageLabel.textColor = UIColor.black
//            messageLabel.font = UIFont(name: "PlayfairDisplay-Bold", size: 13)
//
//            emptyView.addSubview(titleLabel)
//            emptyView.addSubview(messageLabel)
//
//            titleLabel.topAnchor.constraint(equalTo: emptyView.topAnchor).isActive = true
//            titleLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20).isActive = true
//            titleLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20).isActive = true
//
//            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
//            messageLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20).isActive = true
//            messageLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20).isActive = true
//            messageLabel.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor).isActive = true
//
//            titleLabel.text = title
//            titleLabel.numberOfLines = 0
//            titleLabel.textAlignment = .center
//
//            messageLabel.text = message
//            messageLabel.numberOfLines = 0
//            messageLabel.textAlignment = .center
//
//            // Ensure that the title label wraps to multiple lines
//            titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
//            titleLabel.setContentHuggingPriority(.required, for: .vertical)
//
//            self.giftListTable.backgroundView = emptyView
//            self.giftListTable.separatorStyle = .none
//        }
//
//        func restoreTableViewStyleGiftDetail() {
//            self.giftListTable.backgroundView = nil
//            self.giftListTable.separatorStyle = .singleLine
//        }
    }
