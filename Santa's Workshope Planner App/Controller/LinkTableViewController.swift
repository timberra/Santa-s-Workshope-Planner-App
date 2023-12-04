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
    var managedObjectContext: NSManagedObjectContext?
    var santasLinks = [SantaLink]()
    var editingIndexPath: IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = true
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedObjectContext = appDelegate.persistentContainer.viewContext
        loadCoreData()
    }
    @IBAction func addNewItemTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Santas Link Workshop", message: "Do you want to add new link", preferredStyle: .alert)
        alertController.addTextField { textFieldValue in
            textFieldValue.placeholder = "Your title here..."
        }
        alertController.addTextField { subtextFieldValue in
            subtextFieldValue.placeholder = "Your link here..."
        }
        let addActionButton = UIAlertAction(title: "Add", style: .default) { addActions in
            let textField = alertController.textFields?.first
            let subtitletextField = alertController.textFields?.last

            let entity = NSEntityDescription.entity(forEntityName: "SantaLink", in: self.managedObjectContext!)
            let list = NSManagedObject(entity: entity!, insertInto: self.managedObjectContext)
            list.setValue(textField?.text, forKey: "linkDetail")
            list.setValue(subtitletextField?.text, forKey: "link")
            self.saveCoreData()
        }
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(addActionButton)
        alertController.addAction(cancelActionButton)
        present(alertController, animated: true)
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
    func setEmptyView(title: String, message: String) {
            self.backgroundView = nil
            self.separatorStyle = .singleLine
            let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            let titleLabel = UILabel()
            let messageLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.textColor = UIColor.black
            titleLabel.font = UIFont(name: "Quando-Regular", size: 27)
            messageLabel.textColor = UIColor.black
            messageLabel.font = UIFont(name: "PlayfairDisplay-Bold", size: 13)
            emptyView.addSubview(titleLabel)
            emptyView.addSubview(messageLabel)
            titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
            titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
            messageLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20).isActive = true
            messageLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20).isActive = true
            titleLabel.text = title
            messageLabel.text = message
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            self.backgroundView = emptyView
        }

        func restoreTableViewStyle() {
            self.backgroundView = nil
            self.separatorStyle = .singleLine
        }
    }
// MARK: - Table view data add to the cell and safari
extension LinkTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if santasLinks.count == 0 {
            tableView.setEmptyView(title: "Your Santa's Workshop", message: "Please press Add to create a new link item")
        } else {
            tableView.restoreTableViewStyle()
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
            // Your delete logic here
            self.managedObjectContext?.delete(self.santasLinks[indexPath.row])
            self.saveCoreData()
            completionHandler(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

    }
}
