//
//  MyViewController.swift
//  SwiftCoreData
//
//  Created by Akash on 10/11/17.
//  Copyright © 2017 Akash. All rights reserved.
//

import UIKit
import CoreData

class MyViewController: UIViewController ,UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate{

    let appDel = UIApplication.shared.delegate as! AppDelegate
    var students: [Student] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var searchController : UISearchController!
    
    @IBOutlet var studentTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonAction))
        self.navigationItem.rightBarButtonItems = [addButton,searchButton]
        let ascendingButton = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(ascendingButtonAction))
        
        self.navigationItem.leftBarButtonItems = [ascendingButton]
        getData()
    }
    @objc func ascendingButtonAction()  {
        print("ascendingButtonAction")
        students.removeAll()
        do {
            let fetchStudent = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
//            fetchStudent.predicate = NSPredicate(format: "name")
            fetchStudent.sortDescriptors = [NSSortDescriptor(key: "age", ascending: false)]
            students = try context.fetch(fetchStudent) as! [Student]
        } catch {
            print("Fetching Failed")
        }
        studentTableView.reloadData()
    }
    
    @objc func addButtonAction()  {
        print("Add")
        let alert = UIAlertController(title: "Name", message: "Enter a text", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Age"
            textField.keyboardType = .numberPad
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            guard let studentName = alert?.textFields![0].text!,
                let studentAge = alert?.textFields![1].text!  else {return}
            print(studentName)
            print(studentAge)
            self.addStudent(name: studentName, age: Int16(studentAge)!)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: {_ in
            print("cancel")
        }))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    @objc func searchButtonAction()  {
        print("Search")
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        
        self.navigationItem.titleView = searchController.searchBar
        
        self.definesPresentationContext = true
        
    }
    
    func addStudent(name: String,age: Int16) {
        
        let student = Student(context: context)
        student.name = name
        student.age = age
        appDel.saveContext()
        print("Saved")
        getData()
        
    }
    
    func getData() {
        students.removeAll()
        do {
            students = try context.fetch(Student.fetchRequest())
        } catch {
            print("Fetching Failed")
        }
        studentTableView.reloadData()

    }

    func updateSearchResults(for searchController: UISearchController) {
        print(searchController.searchBar.text ?? "")
//        if let searchStr = searchController.searchBar.text{
//            getSearchedData(strSearch: searchStr)
//        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(searchBar.text!)
        
        if let searchStr = searchBar.text{
            getSearchedData(strSearch: searchStr)
        }
        self.navigationItem.titleView = nil
    }
    
    func getSearchedData(strSearch: String) {
        do{
            let searchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
            searchRequest.predicate = NSPredicate(format: "%K CONTAINS[c] %@", "name", strSearch)
            students = try context.fetch(searchRequest) as! [Student]
            print(students)
        } catch{
            print("Fetching Failed")
        }
        studentTableView.reloadData()
    }
    
}
extension MyViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
extension MyViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath) as! StudentCell
        let student = students[indexPath.row]
        cell.nameLabel?.text = student.name
        cell.ageLabel?.text = "\(student.age)"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let student = students[indexPath.row]
        
        if editingStyle == .delete {
            context.delete(student)
            do {
                try context.save()
            } catch let error as NSError {
                print("Error While Deleting Note: \(error.userInfo)")
            }
        }
       getData()
        
    }
}

class StudentCell: UITableViewCell {
    
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
