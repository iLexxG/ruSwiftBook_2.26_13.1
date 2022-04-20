//
//  TaskListViewController.swift
//  CoreDemoApp
//
//  Created by Alexey Efimov on 18.04.2022.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    //MARK: - Private Properties
    private var taskList: [Task] = []
    private let cellID = "task"
    
    //MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
        taskList = StorageManager.shared.fetchData()
    }
    
    //MARK: - Private Methods
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do?", .save)
    }
}

//MARK: - AlertController
extension TaskListViewController {
    private func showAlert(
        with title: String,
        and message: String,
        _ action: Action,
        _ index: IndexPath = IndexPath(row: 0, section: 0)
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            
            if action == .save {
                StorageManager.shared.performAction(with: task, .save)
                taskList = StorageManager.shared.fetchData()
                let cellIndex = IndexPath(row: self.taskList.count - 1, section: 0)
                tableView.insertRows(at: [cellIndex], with: .automatic)
            } else if action == .update {
                StorageManager.shared.performAction(with: task, at: index.row, .update)
                tableView.reloadRows(at: [index], with: .automatic)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
            textField.text = action == .save ? "" : self.taskList[index.row].title
        }
        present(alert, animated: true)
    }
}

//MARK: - TableView Override Methods
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            StorageManager.shared.performAction(at: indexPath.row, .delete)
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(with: "Edit task", and: "Enter new task name", .update ,indexPath)
    }
}
