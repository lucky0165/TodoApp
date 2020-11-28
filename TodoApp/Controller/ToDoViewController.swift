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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        load()
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
    func load() {
        do {
            items = try context.fetch(Item.fetchRequest())
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

    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let text = textField.text {
                let newItem = Item(context: self.context)
                newItem.title = text
                newItem.done = false
                
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
