//
//  ViewController.swift
//  iChat
//
//  Created by Abdalla Elsaman on 4/12/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleNewMessage))
        checkIfUserLoggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    }
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                //print(snapshot)
                let messageId = snapshot.key
                self.fetchMessagesWithMessageId(messageId: messageId)
                
            }, withCancel: nil)
        }, withCancel: nil)
        //print(messageId)
    }
    
    private func fetchMessagesWithMessageId (messageId: String) {
        let messageRef = Database.database().reference().child("messages").child(messageId)
        
        messageRef.observeSingleEvent(of: .value, with: {
            [weak self] (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                let message = Message()
                message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.toId = dictionary["toId"] as? String
                message.timeStamp = dictionary["timestamp"] as? Int
                if let chatPartner = message.chatPartnerId() {
                    self?.messagesDictionary[chatPartner] = message
                }
                
                // fix reloading many times i hope xD
                self?.timer?.invalidate()
                self?.timer = Timer.scheduledTimer(timeInterval: 1, target: self!, selector: #selector(self?.handleReloadTable), userInfo: nil, repeats: false)
                //print(message.text!)
            }
            }, withCancel: nil)
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable () {
        self.messages = Array(self.messagesDictionary.values)
        //TODO:  problem i don't have to sort the array everytime
        self.messages.sort(by: { (message1, message2) -> Bool in
            return message1.timeStamp! > message2.timeStamp!
        })
        DispatchQueue.main.async {
            self.tableView.reloadData()
            print("reloaded message controller table view!")
        }
    }
    
//    func observeMessages() {
//        let ref = Database.database().reference().child("messages")
//        ref.observe(.childAdded, with: {
//            [weak self] (snapshot) in
//            if let dictionary = snapshot.value as? [String: Any] {
//                let message = Message()
//                message.fromId = dictionary["fromId"] as? String
//                message.text = dictionary["text"] as? String
//                message.toId = dictionary["toId"] as? String
//                message.timeStamp = dictionary["timestamp"] as? Int
//                if let toId = message.toId {
//                    self?.messagesDictionary[toId] = message
//                    self?.messages = Array((self?.messagesDictionary.values)!)
//                    self?.messages.sort(by: { (message1, message2) -> Bool in
//                        return message1.timeStamp! > message2.timeStamp!
//                    })
//
//                }
//                DispatchQueue.main.async {
//                    self?.tableView.reloadData()
//                }
//
//                print(message.text!)
//            }
//        }, withCancel: nil)
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value, with: {
            [weak self] (snapshot) in
            
            //print(snapshot)
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = User()
            user.name = dictionary["name"] as? String
            user.email = dictionary["email"] as? String
            user.profileImageUrl = dictionary["profileImageUrl"] as? String
            user.id = chatPartnerId
            
            self?.showChatControllerFor(user: user)
            
        }, withCancel: nil)
        
    }
    
    @objc func handleNewMessage () {
        let newMessageController = NewMessageController()
        // delegation
        // TODO memory management
        newMessageController.messageController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
        
    }
    
    func checkIfUserLoggedIn () {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            //handleLogout()
        } else {
            fetchUserAndSetupNavBarItem()
        }
    }
    
    func fetchUserAndSetupNavBarItem () {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        Database.database().reference().child("users").child(uid).observe(.value, with: {
            [weak self] (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //self?.navigationItem.title = dictionary["name"] as? String
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                self?.setupNavBarWithUser(user: user)
            }
        })
    }
    
    func setupNavBarWithUser (user: User) {
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        //titleView.backgroundColor = UIColor.red
        navigationItem.titleView = titleView
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
        }
        containerView.addSubview(profileImageView)
        
        // setting constrains
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLable = UILabel()
        containerView.addSubview(nameLable)
        nameLable.text = user.name
        nameLable.translatesAutoresizingMaskIntoConstraints = false
        
        // setting constrains
        nameLable.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLable.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLable.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLable.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        //titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    @objc func showChatControllerFor(user: User) {
        let chatController = ChatLogController()
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    @objc func handleLogout () {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }

}

