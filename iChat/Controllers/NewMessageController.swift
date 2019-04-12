//
//  NewMessageController.swift
//  iChat
//
//  Created by Abdalla Elsaman on 4/12/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit

class NewMessageController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    
    @objc func handleCancel () {
        dismiss(animated: true, completion: nil)
    }
}
