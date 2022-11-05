//
//  MoviesListVC.swift
//  CoreDataSwiftCRUD
//
//  Created by Nithin Cheruthala on 05/11/2022.
//

import UIKit
import CoreData

class MoviesListVC: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var moviesList = [Movie]()
    var selectedCategory : MovieCategory? {
        didSet {
            self.loadMovies()
            self.title = String(describing: self.selectedCategory?.title ?? "")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
    }
    
    @IBAction func addMoviesAction(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) {(action) in
            let newMovie = Movie(context: self.context)
            newMovie.name = textField.text
            newMovie.parentCategory = self.selectedCategory
            self.moviesList.append(newMovie)
            self.saveMovies()
        }
        alert.addTextField {(alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.moviesList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "moviesCell", for: indexPath)
        cell.textLabel?.text = self.moviesList[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, sourceView, completionHandler) in
            
            var textField = UITextField()
            let alert = UIAlertController(title: "Update Category", message: "", preferredStyle: .alert)
            let editAction = UIAlertAction(title: "Update", style: .default) {(action) in
                
                // MARK: - Update value
                self.moviesList[indexPath.row].setValue(textField.text, forKey: "name")
                self.saveMovies()
            }
            alert.addTextField {(alertTextField) in
                alertTextField.text = self.moviesList[indexPath.row].name
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
                self.context.delete(self.moviesList[indexPath.row])
                self.moviesList.remove(at: indexPath.row)
                self.saveMovies()
            }
            self.addCancelAlertAction(alert: alert, completionHandlder: completionHandler)
            alert.addAction(deleteAlertaction)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    func saveMovies() {
        do {
            try context.save()
        }catch {
            print(error)
        }
        self.tableView.reloadData()
    }
    
    func loadMovies(with request: NSFetchRequest<Movie> = Movie.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.title MATCHES %@", self.selectedCategory!.title!)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        do {
            self.moviesList =  try context.fetch(request)
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

//MARK: - SearchBar delegetes
extension MoviesListVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Movie> = Movie.fetchRequest()
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        self.loadMovies(with: request, predicate: predicate)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadMovies()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
