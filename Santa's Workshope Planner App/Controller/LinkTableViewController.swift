//
//  LinkTableViewController.swift
//  Santa's Workshope Planner App
//
//  Created by liga.griezne on 28/11/2023.
//

import UIKit
import CoreData
import SafariServices


class LinkTableViewController: UITableViewController {
    @IBOutlet weak var countdownTillLink: UIBarButtonItem!
    var managedObjectContext: NSManagedObjectContext?
    var santasLinks = [SantaLink]()
    var editingIndexPath: IndexPath?
    var countdownTimer: Timer?
    var countdownDuration: TimeInterval = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBarButtonItems()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressGesture)
        updateBarButtonItems()
        tableView.allowsSelection = true
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedObjectContext = appDelegate.persistentContainer.viewContext
        loadCoreData()
        updateBarButtonItems()
    }
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: point) {
                showEditAlert(forIndexPath: indexPath)
            }
        }
    }
    func showEditAlert(forIndexPath indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Edit Link", message: "Edit the link details", preferredStyle: .alert)

        alertController.addTextField { textFieldValue in
            textFieldValue.text = self.santasLinks[indexPath.row].linkDetail
        }
        alertController.addTextField { subtextFieldValue in
            subtextFieldValue.text = self.santasLinks[indexPath.row].link
        }
        let editActionButton = UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alertController.textFields?.first,
                  let subtitleTextField = alertController.textFields?.last else {
                return
            }
            let editedLink = self.santasLinks[indexPath.row]
            editedLink.linkDetail = textField.text
            editedLink.link = subtitleTextField.text
            self.saveCoreData()
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(editActionButton)
        alertController.addAction(cancelActionButton)
        present(alertController, animated: true)
    }
    @IBAction func addNewItemTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Santas Link Workshop", message: "Do you want to add a new link", preferredStyle: .alert)
        alertController.addTextField { textFieldValue in
            textFieldValue.placeholder = "Your title here..."
        }
        alertController.addTextField { subtextFieldValue in
            subtextFieldValue.placeholder = "Your link here..."
        }
        let addActionButton = UIAlertAction(title: "Add", style: .default) { addActions in
            let textField = alertController.textFields?.first
            let subtitletextField = alertController.textFields?.last
            guard let link = subtitletextField?.text,
                  link.lowercased().hasPrefix("http://") || link.lowercased().hasPrefix("https://") else {
                let invalidLinkAlert = UIAlertController(title: "Invalid Link", message: "Please enter a valid link starting with 'http://' or 'https://'", preferredStyle: .alert)
                invalidLinkAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(invalidLinkAlert, animated: true, completion: nil)
                return
            }
            let entity = NSEntityDescription.entity(forEntityName: "SantaLink", in: self.managedObjectContext!)
            let list = NSManagedObject(entity: entity!, insertInto: self.managedObjectContext)
            list.setValue(textField?.text, forKey: "linkDetail")
            list.setValue(link, forKey: "link")
            self.saveCoreData()
            self.updateBarButtonItems()
        }
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(addActionButton)
        alertController.addAction(cancelActionButton)
        present(alertController, animated: true)
    }
    func updateBarButtonItems() {
        if santasLinks.isEmpty {
            countdownTillLink.isEnabled = false
        } else {
            countdownTillLink.isEnabled = true
        }
    }
}
// MARK: - CoreData logic
extension LinkTableViewController {
    func loadCoreData(){
        let request: NSFetchRequest<SantaLink> = SantaLink.fetchRequest()
        do {
            let result = try managedObjectContext?.fetch(request)
            santasLinks = result ?? []
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
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "SantaLink")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedObjectContext?.execute(deleteRequest)
            santasLinks.removeAll()
            self.tableView.reloadData()
        }catch {
            fatalError("Error in deleting all item from core data")
        }
    }
}
//MARK: - Empty view logic
extension UITableView {
     func setEmptyLinkView(title: String, message: String, targetMonth: Int, targetDay: Int) {
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
         infoLabel.textColor = UIColor(hex: "#6E140D")
         infoLabel.font = UIFont(name: "PlayfairDisplay-Bold", size: 27) 
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
         imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
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
         carImage.widthAnchor.constraint(equalToConstant: 500).isActive = true
         carImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
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
     func restoreLinkTableViewStyle() {
         self.backgroundView = nil
         self.separatorStyle = .singleLine
    }
}
// MARK: - Table view data add to the cell and safari
extension LinkTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if santasLinks.count == 0 {
            tableView.setEmptyLinkView(title: "Your Santa's Workshop", message: "Please press Add to create a new Santa's Link", targetMonth: 12, targetDay: 25)
        } else {
            tableView.restoreToDoTableViewStyle()
        }
        return santasLinks.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "santaLinkCell", for: indexPath)
        let santasLink = santasLinks[indexPath.row]
        
        cell.textLabel?.text = santasLink.linkDetail
        cell.detailTextLabel?.text = santasLink.link
        cell.accessoryType = santasLink.completed ? .checkmark : .none
        cell.selectionStyle = .default // Add this line
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Cell tapped at section \(indexPath.section), row \(indexPath.row)")
        let selectedLink = santasLinks[indexPath.row]
        guard let linkURLString = selectedLink.link, let linkURL = URL(string: linkURLString) else {
            print("Error: Invalid link URL")
            return
        }
        let safariViewController = SFSafariViewController(url: linkURL)
        present(safariViewController, animated: true, completion: nil)
    }
}
//MARK: - Delete table view row
extension LinkTableViewController {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            self.managedObjectContext?.delete(self.santasLinks[indexPath.row])
            self.saveCoreData()
            if (self.santasLinks.isEmpty) {
                self.countdownTillLink.isEnabled = false
            }
            completionHandler(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}
