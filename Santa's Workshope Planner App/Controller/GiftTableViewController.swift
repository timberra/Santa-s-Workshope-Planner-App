//
//  GiftTableViewController.swift
//  Santa's Workshope Planner App
//
//  Created by liga.griezne on 29/11/2023.
//

import UIKit
import CoreData

class GiftTableViewController: UITableViewController {
    @IBOutlet weak var countdownTillGift: UIBarButtonItem!
    var managedObjectContext: NSManagedObjectContext?
    var santasGifts = [SantaGift]()
    var santasAddGifts = [SantaAddGift]()
    var cellAddOrder = 0
    var isGiftViewEmpty: Bool {
            return santasGifts.isEmpty
        }
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBarButtonItems()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressGesture)
        let backButton = UIBarButtonItem()
        backButton.title = "Santa's nice list"
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
        let alertController = UIAlertController(title: "Santas Gift Workshop", message: "Do you want to add a new person for a gift?", preferredStyle: .alert)
            alertController.addTextField { textFieldValue in
                textFieldValue.placeholder = "Your person here.."
            }
            alertController.addTextField { subtextFieldValue in
                subtextFieldValue.placeholder = "Your budget here.."
                subtextFieldValue.keyboardType = .decimalPad
            }
            let addActionButton = UIAlertAction(title: "Add", style: .default) { addActions in
                guard let textField = alertController.textFields?.first,
                      let subtitletextField = alertController.textFields?.last,
                      let budgetText = subtitletextField.text,
                      let budgetValue = Double(budgetText) else {
                    self.showErrorMessage(message: "Please fill in budget field with numeric characters.")
                    return
                }
                let entity = NSEntityDescription.entity(forEntityName: "SantaGift", in: self.managedObjectContext!)
                let list = NSManagedObject(entity: entity!, insertInto: self.managedObjectContext)
                list.setValue(Date().timeIntervalSince1970, forKey: "id")
                list.setValue(textField.text, forKey: "person")
                list.setValue(budgetValue, forKey: "budget")
                list.setValue(self.cellAddOrder % 2 == 0 ? "#7a251f" : "#37523e", forKey: "cellColor")
                self.cellAddOrder += 1
                self.updateBarButtonItems()
                self.saveCoreData()
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
    func updateBarButtonItems() {
        if isGiftViewEmpty && !tableView.isEmptyGiftViewActive {
            countdownTillGift.isEnabled = false
        } else {
            countdownTillGift.isEnabled = true
        }
    }
}
//MARK: - Empty view logic
extension UITableView {
    var isEmptyGiftViewActive: Bool {
         return self.backgroundView != nil
     }
     func setEmptyGiftView(title: String, message: String, targetMonth: Int, targetDay: Int) {
         guard !isEmptyGiftViewActive else { return }
         self.backgroundView = nil
         self.separatorStyle = .singleLine
         let currentYear = Calendar.current.component(.year, from: Date())
         var targetComponents = DateComponents()
         targetComponents.year = currentYear
         targetComponents.month = targetMonth
         targetComponents.day = targetDay
         targetComponents.hour = 0
         targetComponents.minute = 0
         targetComponents.second = 0
         if let currentDate = Calendar.current.date(from: DateComponents(year: currentYear)),
             let targetDate = Calendar.current.date(from: targetComponents),
             currentDate > targetDate {
             targetComponents.year = currentYear + 1
         }
         guard let targetDate = Calendar.current.date(from: targetComponents) else {
             return
         }
         let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
         let titleLabel = UILabel()
         let messageLabel = UILabel()
         let infoLabel = UILabel() // Label for "Countdown till Christmas"
         let countdownLabel = UILabel()
         titleLabel.translatesAutoresizingMaskIntoConstraints = false
         messageLabel.translatesAutoresizingMaskIntoConstraints = false
         infoLabel.translatesAutoresizingMaskIntoConstraints = false
         countdownLabel.translatesAutoresizingMaskIntoConstraints = false
         titleLabel.textColor = UIColor.black
         titleLabel.font = UIFont(name: "Quando-Regular", size: 27)
         messageLabel.textColor = UIColor.black
         messageLabel.font = UIFont(name: "PlayfairDisplay-Bold", size: 13)
         infoLabel.textColor = UIColor(hex: "#6E140D") // Replace with your hex color
         infoLabel.font = UIFont(name: "PlayfairDisplay-Bold", size: 27) // Replace with your custom font
         countdownLabel.textColor = UIColor.black
         countdownLabel.font = UIFont(name: "PlayfairDisplay-Bold", size: 27)
         emptyView.addSubview(titleLabel)
         emptyView.addSubview(messageLabel)
         emptyView.addSubview(infoLabel)
         emptyView.addSubview(countdownLabel)
         titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -40).isActive = true
         titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
         messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
         messageLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20).isActive = true
         messageLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20).isActive = true
         infoLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8).isActive = true
         infoLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
         countdownLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 8).isActive = true
         countdownLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
         titleLabel.text = title
         messageLabel.text = message
         messageLabel.numberOfLines = 0
         messageLabel.textAlignment = .center
         infoLabel.text = "Countdown till Christmas"
         Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
             let currentDate = Date()
             let calendar = Calendar.current
             let components = calendar.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: targetDate)
             if let days = components.day, let hours = components.hour, let minutes = components.minute, let seconds = components.second {
                 let formattedTime = String(format: "%02dd %02dh %02dm %02ds", days, hours, minutes, seconds)
                 countdownLabel.text = formattedTime
             }
             if currentDate >= targetDate {
                 timer.invalidate()
                 countdownLabel.text = "Merry Christmas!"
             }
         }
         self.backgroundView = emptyView
     }
     func restoreGiftTableViewStyle() {
         guard isEmptyViewActive else { return }

         self.backgroundView = nil
         self.separatorStyle = .singleLine
     }
 }
// MARK: - Table view data add to the cell
extension GiftTableViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if santasGifts.count == 0 {
            tableView.setEmptyGiftView(title: "Your Santa's Workshop", message: "Please press Add to create a new Santa's person", targetMonth: 12, targetDay: 25)
        } else {
            tableView.restoreGiftTableViewStyle()
        }
        return santasGifts.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "santaGiftCell", for: indexPath)
        let santasGift = santasGifts[indexPath.row]
        cell.textLabel?.text = santasGift.person
        if let cellColor = santasGift.value(forKey: "cellColor") as? String {
            cell.backgroundColor = UIColor(hex: cellColor)
        } else {
            cell.backgroundColor = .white
        }
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
                if (self.santasGifts.isEmpty) {
                    self.countdownTillGift.isEnabled = false
                }
                completionHandler(true)
            }
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
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
