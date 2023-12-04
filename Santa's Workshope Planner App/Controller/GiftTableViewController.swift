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
    var santasAddGifts = [SantaAddGift]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
                tableView.addGestureRecognizer(longPressGesture)
        let backButton = UIBarButtonItem()
        backButton.title = "BACK" 
        backButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "PlayfairDisplay-Bold", size: 13)!], for: .normal)
        self.navigationItem.backBarButtonItem = backButton
        tableView.allowsSelection = true
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                managedObjectContext = appDelegate.persistentContainer.viewContext
                loadCoreData()
    }
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
           if gestureRecognizer.state == .began {
               let touchPoint = gestureRecognizer.location(in: tableView)
               if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                   showEditAlert(indexPath: indexPath)
               }
           }
       }
    func showEditAlert(indexPath: IndexPath) {
            let alertController = UIAlertController(title: "Edit Person", message: "Edit the person and budget values", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Edit person"
                textField.text = self.santasGifts[indexPath.row].person
            }
            alertController.addTextField { textField in
                textField.placeholder = "Edit budget"
                textField.text = "\(self.santasGifts[indexPath.row].budget)"
                textField.keyboardType = .decimalPad
            }
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                let personTextField = alertController.textFields?.first
                let budgetTextField = alertController.textFields?.last
                self.santasGifts[indexPath.row].person = personTextField?.text
                if let budgetText = budgetTextField?.text, let budgetValue = Double(budgetText) {
                    self.santasGifts[indexPath.row].budget = budgetValue
                }
                self.saveCoreData()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
        }
    
    @IBAction func addNewPersonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Santas Gift Workshop", message: "Do you want to add new person for gift?", preferredStyle: .alert)
        alertController.addTextField { textFieldValue in
            textFieldValue.placeholder = "Your person here.."
        }
        alertController.addTextField { subtextFieldValue in
            subtextFieldValue.placeholder = "Your budget here.."
        }
        let addActionButton = UIAlertAction(title: "Add", style: .default) { addActions in
            let textField = alertController.textFields?.first
            let subtitletextField = alertController.textFields?.last
            let entity = NSEntityDescription.entity(forEntityName: "SantaGift", in: self.managedObjectContext!)
            let list = NSManagedObject(entity: entity!, insertInto: self.managedObjectContext)
            list.setValue(Date().timeIntervalSince1970, forKey: "id")
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
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        self.backgroundView = emptyView
    }
    func restoreTableViewStyleGift() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
// MARK: - Table view data add to the cell
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
}
    //MARK: - Delete table view row
    extension GiftTableViewController{
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
                let personToDelete = self.santasGifts[indexPath.row]
                let associatedGifts = self.santasAddGifts.filter { $0.personID == personToDelete.id }
                for gift in associatedGifts {
                    self.managedObjectContext?.delete(gift)
                }
                self.managedObjectContext?.delete(personToDelete)
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



        
    

