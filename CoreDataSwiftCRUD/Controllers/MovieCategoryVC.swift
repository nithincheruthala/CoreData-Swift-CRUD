//
//  TableViewController.swift
//  CoreDataSwiftCRUD
//
//  Created by Nithin Cheruthala on 04/11/2022.
//

import UIKit
import CoreData

class MovieCategoryVC: UITableViewController {
    
    var movieCategory = [MovieCategory]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCategory()
    }
    
    @IBAction func addMovieCategoryAction(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) {(action) in
            let newCategory = MovieCategory(context: self.context)
            newCategory.title = textField.text
            self.movieCategory.append(newCategory)
            self.saveCategory()
        }
        alert.addTextField {(alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! MoviesListVC
        if let  indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = movieCategory[indexPath.row]
        }
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieCategory.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCategoryCell", for: indexPath)
        cell.textLabel?.text = movieCategory[indexPath.row].title
        return cell
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "movieVC", sender: self)
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, sourceView, completionHandler) in
            
            var textField = UITextField()
            let alert = UIAlertController(title: "Update Category", message: "", preferredStyle: .alert)
            let editAction = UIAlertAction(title: "Update", style: .default) {(action) in
                
                // MARK: - Update value
                self.movieCategory[indexPath.row].setValue(textField.text, forKey: "title")
                self.saveCategory()
            }
            alert.addTextField {(alertTextField) in
                alertTextField.text = self.movieCategory[indexPath.row].title
                textField = alertTextField
            }
            alert.addAction(editAction)
            self.addCancelAlertAction(alert: alert, completionHandlder: completionHandler)
        }
        editAction.backgroundColor = UIColor.systemBlue
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            let alert = UIAlertController(title: "Do you really want to delete?", message: "", preferredStyle: .actionSheet)
            let deleteAlertaction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                
                //MARK: - Delete value
                self.context.delete(self.movieCategory[indexPath.row])
                self.movieCategory.remove(at: indexPath.row)
                self.saveCategory()
            }
            self.addCancelAlertAction(alert: alert, completionHandlder: completionHandler)
            alert.addAction(deleteAlertaction)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    //MARK: - CoreDate
    func saveCategory() {
        do {
            try context.save()
        }catch {
            print(error)
        }
        self.tableView.reloadData()
    }
    func loadCategory() {
        let request : NSFetchRequest<MovieCategory> = MovieCategory.fetchRequest()
        do {
            self.movieCategory =  try context.fetch(request)
        }catch{
            print(error)
        }
        tableView.reloadData()
    }
    
    func addCancelAlertAction(alert : UIAlertController, completionHandlder: @escaping (Bool) -> Void) {
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            DispatchQueue.main.async {
                self.tableView.setEditing(false, animated: true)
                completionHandlder(true)
            }
        }
        alert.addAction(cancelAlertAction)
        self.present(alert, animated: true)
    }
}
