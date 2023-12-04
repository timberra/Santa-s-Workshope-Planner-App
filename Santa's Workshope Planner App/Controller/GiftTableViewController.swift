//
//  GiftTableViewController.swift
//  Santa's Workshope Planner App
//
//  Created by liga.griezne on 29/11/2023.
//

import UIKit
import CoreData

class GiftTableViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext?
    var santasGifts = [SantaGift]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem()
        backButton.title = "BACK" // Set your custom text here
        backButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "PlayfairDisplay-Bold", size: 13)!], for: .normal)
        self.navigationItem.backBarButtonItem = backButton
        tableView.allowsSelection = true
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                managedObjectContext = appDelegate.persistentContainer.viewContext
                loadCoreData()
        

    }
    @IBAction func addNewPersonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Santas Gift Workshop", message: "Do you want to add new person for gift?", preferredStyle: .alert)
        alertController.addTextField { textFieldValue in
            textFieldValue.placeholder = "Your gift here.."
            
        }
        alertController.addTextField { subtextFieldValue in
            subtextFieldValue.placeholder = "Your budget here.."
        }
        let addActionButton = UIAlertAction(title: "Add", style: .default) { addActions in
            let textField = alertController.textFields?.first
            let subtitletextField = alertController.textFields?.last

            let entity = NSEntityDescription.entity(forEntityName: "SantaGift", in: self.managedObjectContext!)
            let list = NSManagedObject(entity: entity!, insertInto: self.managedObjectContext)
            list.setValue(textField?.text, forKey: "person")
            if let budgetText = subtitletextField?.text, let budgetValue = Double(budgetText) {
                list.setValue(budgetValue, forKey: "budget")
            }

            self.saveCoreData()
        }
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(addActionButton)
        alertController.addAction(cancelActionButton)
        present(alertController, animated: true)
    }
    
}

    
 
    //MARK: - Empty view logic
    extension UITableView {
        func setEmptyViewGift(title: String, message: String) {

            self.backgroundView = nil
            self.separatorStyle = .singleLine

            let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            let titleLabel = UILabel()
            let messageLabel = UILabel()
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            
            titleLabel.textColor = UIColor.black
            titleLabel.font = UIFont(name: "Quando-Regular", size: 23)
            
            messageLabel.textColor = UIColor.black
            messageLabel.font = UIFont(name: "PlayfairDisplay-Bold", size: 13)
            
            emptyView.addSubview(titleLabel)
            emptyView.addSubview(messageLabel)
            
            titleLabel.topAnchor.constraint(equalTo: emptyView.topAnchor).isActive = true
            titleLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20).isActive = true
            titleLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20).isActive = true
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
            messageLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20).isActive = true
            messageLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20).isActive = true
            messageLabel.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor).isActive = true
            
            titleLabel.text = title
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            
            messageLabel.text = message
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            
            // Ensure that the title label wraps to multiple lines
            titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
            titleLabel.setContentHuggingPriority(.required, for: .vertical)
            
            self.backgroundView = emptyView
        }

        func restoreTableViewStyleGift() {
            self.backgroundView = nil
            self.separatorStyle = .singleLine
        }
    }
    
    // MARK: - Table view data add to the cell and safari
    extension GiftTableViewController{
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if santasGifts.count == 0 {
                tableView.setEmptyView(title: "Your Santa's Workshop", message: "Please press Add to create a person")
            } else {
                tableView.restoreTableViewStyleGift()
            }
            return santasGifts.count
        }
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "santaGiftCell", for: indexPath)
            let santasGift = santasGifts[indexPath.row]
            
            cell.textLabel?.text = santasGift.person
            
            return cell
        }
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("Cell tapped at section \(indexPath.section), row \(indexPath.row)")
        }
    }
// MARK: - CoreData logic
extension GiftTableViewController{
    func loadCoreData(){
        let request: NSFetchRequest<SantaGift> = SantaGift.fetchRequest()
        do {
            let result = try managedObjectContext?.fetch(request)
            santasGifts = result ?? []
            self.tableView.reloadData()
        } catch {
            fatalError("Error in loading item into core data")
        }
    }
    func saveCoreData(){
        do {
            try managedObjectContext?.save()
        } catch {
            fatalError("Error in saving item into core data")
        }
        loadCoreData()
    }
    func deleteAllCoreData(){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "SantaGift")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedObjectContext?.execute(deleteRequest)
            santasGifts.removeAll()
            self.tableView.reloadData()
        }catch {
            fatalError("Error in deleting all item from core data")
        }
    }
}
//MARK: - Delete table view row
extension GiftTableViewController{
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in

            self.managedObjectContext?.delete(self.santasGifts[indexPath.row])
            self.saveCoreData()
            completionHandler(true)
        }
        

        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

    }
}
//MARK: - Send data

extension GiftTableViewController {


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GiftDetailView" {
            if let indexPath = tableView.indexPathForSelectedRow,
               let secondViewController = segue.destination as? GiftDetailViewController{
                let selectedSantaGift = santasGifts[indexPath.row]
                secondViewController.selectedItem = selectedSantaGift
            }
        }
    }
}



        
    

