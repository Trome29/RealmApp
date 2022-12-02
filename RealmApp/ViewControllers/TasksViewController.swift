//
//  TaskViewController.swift
//  RealmApp
//
//  Created by Roman on 01.12.2022.
//

import UIKit
import RealmSwift

class TasksViewController: UITableViewController {
    
    private let cellID = "cell"
    private var currentTasks: Results<Task>!
    private var completedTasks: Results<Task>!
    
    var taskList: TaskList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.name
        
        setupView()
    }
    
    private func setupView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton]
        currentTasks = taskList.tasks.filter("isComplete = false")
        completedTasks = taskList.tasks.filter("isComplete = true")
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }
}
// MARK: - Table view data source
extension TasksViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "ТЕКУЩИЕ ЗАДАЧИ" : "ВЫПОЛНЕННЫЕ ЗАДАЧИ"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let task = indexPath.section == 0
        ? currentTasks[indexPath.row]
        : completedTasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { _, _, _ in
            StorageManager.shared.delete(task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Изменить") { [unowned self] _, _, isDone in
            showAlert(with: task) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneTitle = indexPath.section == 0 ? "Выполнена" : "Не выполнена"
        
        let doneAction = UIContextualAction(style: .normal, title: doneTitle) { [weak self] _, _, isDone in
            StorageManager.shared.done(task)
            let currentTaskIndex = IndexPath(
                row: self?.currentTasks.index(of: task) ?? 0,
                section: 0
            )
            let completedTaskIndex = IndexPath(
                row: self?.completedTasks.index(of: task) ?? 0,
                section: 1
            )
            let destinationIndexRow = indexPath.section == 0 ? completedTaskIndex : currentTaskIndex
            tableView.moveRow(at: indexPath, to: destinationIndexRow)
            
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
}

// MARK: - Alert
extension TasksViewController {
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? "Изменить задачу" : "Новая задача"
        
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "Что вы хотите сделать?")
        
        alert.action(with: task) { newValue, note in
            if let task = task, let completion = completion {
                StorageManager.shared.rename(task, to: newValue, withNote: note)
                completion()
            } else {
                self.save(task: newValue, withNote: note)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func save(task: String, withNote note: String) {
        StorageManager.shared.save(task, withNote: note, to: taskList) { task in
            let rowIndex = IndexPath(row: currentTasks.index(of: task) ?? 0, section: 0)
            tableView.insertRows(at: [rowIndex], with: .automatic)
        }
    }
}
