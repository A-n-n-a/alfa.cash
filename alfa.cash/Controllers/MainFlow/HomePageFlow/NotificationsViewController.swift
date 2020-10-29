//
//  NotificationsViewController.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 18.05.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class NotificationsViewController: BaseViewController {

    @IBOutlet weak var tableView: ACTableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var notifications = [ACNotification]() {
        didSet {
            backgroundView.alpha = notifications.isEmpty ? 1 : 0
            tableView.reloadData()
        }
    }
    
    var backgroundView = TableBackgroundView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTransactionsNavBar(title: "NOTIFICATIONS".localized())
        tableView.register(cellClass: NotificationTableViewCell.self)
        getNotifications()
        ApplicationManager.needCheckNotifications = true
        
        backgroundView.setupWithTitle("NO_NOTIFICATIONS_FOUND".localized())
        backgroundView.hideIcon()
        tableView.backgroundView = backgroundView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func getNotifications() {
        activityIndicator.startAnimating()
        NetworkManager.getNotifications { [weak self] (notifications, error) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                if let error = error {
                    self?.showError(error)
                }
                if let notifications = notifications {
                    self?.notifications = notifications
                }
            }
        }
    }
}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId(NotificationTableViewCell.self)) as! NotificationTableViewCell
        cell.notification = notifications[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
