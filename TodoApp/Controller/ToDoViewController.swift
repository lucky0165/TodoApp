//
//  ViewController.swift
//  TodoApp
//
//  Created by Łukasz Rajczewski on 28/11/2020.
//

import UIKit
import CoreData

class ToDoViewController: UITableViewController {
    
    var items = [Item]()
    
    var selectedCategory: Category? {
        didSet {
            load()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // Save data to CoreData
    func save() {
        do {
            try context.save()
        } catch {
            print("Error saving items: \(error)")
        }
        tableView.reloadData()
    }
    
    // Retrieve data from CoreData
    func load(_ request: NSFetchRequest<Item> = Item.fetchRequest(), _ predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        do {
            items = try context.fetch(request)
        } catch {
            print("Error retrieving data: \(error)")
        }
        tableView.reloadData()
    }
    
    // MARK: - UITableView Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let item = items[indexPath.row]
        
        cell.textLabel?.text = items[indexPath.row].title
        
        // ternary operator ==> value = condition ? valueTrue : valueFalse
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    // MARK: - UITableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        items[indexPath.row].done = !items[indexPath.row].done
        save()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            let itemToRemove = self.items[indexPath.row]
            self.context.delete(itemToRemove)
            self.save()
            self.load()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let text = textField.text {
                let newItem = Item(context: self.context)
                newItem.title = text
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                
                self.items.append(newItem)
                
                self.save()
                
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Type an item name"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
}

// MARK: - UISearchBar Delegate
extension ToDoViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        let sort = NSSortDescriptor(key: "title", ascending: true)
        
        request.sortDescriptors = [sort]
        
        load(request, predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            load()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
     
        }
    }
    
    
}


