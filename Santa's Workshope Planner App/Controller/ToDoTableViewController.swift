//
//  ToDoTableViewController.swift
//  Santa's Workshope Planner App
//
//  Created by liga.griezne on 01/12/2023.
//
import UIKit
import CoreData

class ToDoTableViewController: UITableViewController {
    @IBOutlet weak var countdownTillToDo: UIBarButtonItem!
    @IBOutlet weak var deleteAllToDo: UIBarButtonItem!
    var managedObjectContext: NSManagedObjectContext?
    var santasToDo = [SantaToDo]()
    var editingIndexPath: IndexPath?
    var countdownTimer: Timer?
    var countdownDuration: TimeInterval = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBarButtonItems()
        tableView.allowsSelection = true
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedObjectContext = appDelegate.persistentContainer.viewContext
        loadCoreData()
        updateBarButtonItems()
    }
    @IBAction func addNewItemTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Santas To Do Workshop ", message: "Do you want to add new task?", preferredStyle: .alert)
        alertController.addTextField { textFieldValue in
            textFieldValue.placeholder = "Your taskhere..."
        }
        let addActionButton = UIAlertAction(title: "Add", style: .default) { addActions in
            let textField = alertController.textFields?.first
            let entity = NSEntityDescription.entity(forEntityName: "SantaToDo", in: self.managedObjectContext!)
            let list = NSManagedObject(entity: entity!, insertInto: self.managedObjectContext)
            list.setValue(textField?.text, forKey: "task")
            self.saveCoreData()
            self.updateBarButtonItems()
        }
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(addActionButton)
        alertController.addAction(cancelActionButton)
        present(alertController, animated: true)
    }
    func updateBarButtonItems() {
        if santasToDo.isEmpty {
            countdownTillToDo.isEnabled = false
        } else {
            countdownTillToDo.isEnabled = true
        }
    }
    @IBAction func deleteAllToDoList(_ sender: Any) {
        let confirmDeleteAlert = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete all tasks?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.clearAllTasks()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            confirmDeleteAlert.addAction(deleteAction)
            confirmDeleteAlert.addAction(cancelAction)
            present(confirmDeleteAlert, animated: true)
        }
        func clearAllTasks() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "SantaToDo")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try managedObjectContext?.execute(deleteRequest)
                try managedObjectContext?.save()
                loadCoreData()
                updateBarButtonItems()
            } catch {
                fatalError("Error in delete items from core data")
            }
        }
    }
// MARK: - CoreData logic
extension ToDoTableViewController {
    func loadCoreData(){
        let request: NSFetchRequest<SantaToDo> = SantaToDo.fetchRequest()
        do {
            let result = try managedObjectContext?.fetch(request)
            santasToDo = result ?? []
            self.tableView.reloadData()
        } catch {
            fatalError("Error in loading items into core data")
        }
    }
    func saveCoreData(){
        do {
            try managedObjectContext?.save()
        } catch {
            fatalError("Error in saving items into core data")
        }
        loadCoreData()
    }
}
//MARK: - Empty view logic
extension UITableView {
     func setEmptyToDoView(title: String, message: String, targetMonth: Int, targetDay: Int) {
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
         let infoLabel = UILabel()
         let countdownLabel = UILabel()
         let imageView = UIImageView()
         let carImage = UIImageView()
         titleLabel.translatesAutoresizingMaskIntoConstraints = false
         messageLabel.translatesAutoresizingMaskIntoConstraints = false
         infoLabel.translatesAutoresizingMaskIntoConstraints = false
         countdownLabel.translatesAutoresizingMaskIntoConstraints = false
         imageView.translatesAutoresizingMaskIntoConstraints = false
         carImage.translatesAutoresizingMaskIntoConstraints = false
         titleLabel.textColor = UIColor.black
         titleLabel.font = UIFont(name: "Quando-Regular", size: 27)
         messageLabel.textColor = UIColor.black
         messageLabel.font = UIFont(name: "PlayfairDisplay-Bold", size: 13)
         infoLabel.textColor = UIColor(hex: "#6E140D") // Replace with your hex color
         infoLabel.font = UIFont(name: "PlayfairDisplay-Bold", size: 27) // Replace with your custom font
         countdownLabel.textColor = UIColor.black
         countdownLabel.font = UIFont(name: "PlayfairDisplay-Bold", size: 27)
         imageView.image = UIImage(named: "Lights 2")
         carImage.image = UIImage(named: "Car")
         emptyView.addSubview(titleLabel)
         emptyView.addSubview(messageLabel)
         emptyView.addSubview(infoLabel)
         emptyView.addSubview(countdownLabel)
         emptyView.addSubview(imageView)
         emptyView.addSubview(carImage)
         titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -80).isActive = true
         titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
         messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
         messageLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20).isActive = true
         messageLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20).isActive = true
         imageView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8).isActive = true
         imageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
         imageView.widthAnchor.constraint(equalToConstant: 376).isActive = true
         imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
         infoLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
         infoLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
         let infoLabelAttributedString = NSMutableAttributedString(string: "Countdown till Christmas")
         let infoLabelLetterSpacing: CGFloat = 1.5
         infoLabelAttributedString.addAttribute(NSAttributedString.Key.kern, value: infoLabelLetterSpacing, range: NSMakeRange(0, infoLabelAttributedString.length))
         infoLabel.attributedText = infoLabelAttributedString
         countdownLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 8).isActive = true
         countdownLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
         countdownLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 8).isActive = true
         countdownLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
         carImage.topAnchor.constraint(equalTo: countdownLabel.bottomAnchor, constant: 8).isActive = true
         carImage.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
         carImage.widthAnchor.constraint(equalToConstant: 376).isActive = true
         carImage.heightAnchor.constraint(equalToConstant: 30).isActive = true
         titleLabel.text = title
         messageLabel.text = message
         messageLabel.numberOfLines = 0
         messageLabel.textAlignment = .center
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
     func restoreToDoTableViewStyle() {
         self.backgroundView = nil
         self.separatorStyle = .singleLine
     }
 }
// MARK: - Table view data add to the cell and safari
extension ToDoTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if santasToDo.count == 0 {
            tableView.setEmptyToDoView(title: "Your Santa's Workshop", message: "Please press Add to create a new Santa's to-do", targetMonth: 12, targetDay: 25)
        } else {
            tableView.restoreToDoTableViewStyle()
        }
        return santasToDo.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "santaToDo", for: indexPath)
        let santasToDo = santasToDo[indexPath.row]
        cell.textLabel?.text = santasToDo.task
        cell.accessoryType = santasToDo.completed ? .checkmark : .none
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Cell tapped at section \(indexPath.section), row \(indexPath.row)")
        let selectedTask = santasToDo[indexPath.row]
        selectedTask.completed = !selectedTask.completed
        saveCoreData()
        tableView.reloadData()
    }
}
//MARK: - Delete table view row
extension ToDoTableViewController {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            self.managedObjectContext?.delete(self.santasToDo[indexPath.row])
            self.saveCoreData()
            if (self.santasToDo.isEmpty) {
                self.countdownTillToDo.isEnabled = false
            }
            completionHandler(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}

