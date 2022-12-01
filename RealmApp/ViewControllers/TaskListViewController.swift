//
//  ViewController.swift
//  RealmApp
//
//  Created by Roman on 01.12.2022.
//

import UIKit

class TaskListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        title = "Task list"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor.black
        
        navBarAppearance.titleTextAttributes = [.foregroundColor : UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor : UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationItem.leftBarButtonItem  = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        
    }
}

