//
//  chatLogController.swift
//  iChat
//
//  Created by Abdalla Elsaman on 4/17/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UIViewController {
    
    let tableView = UITableView()
    let inputTextField = UITextField()
    let cellId = "cellId"
    var messages = [Message]()
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let userMessageRef = Database.database().reference().child("user-messages").child(uid)
        userMessageRef.observe(.childAdded) { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)

            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                //print(snapshot)
                guard let dictionary = snapshot.value as? [String: Any] else {
                    return
                }
                let message = Message()
                message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.toId = dictionary["toId"] as? String
                message.timeStamp = dictionary["timestamp"] as? Int
                if message.chatPartnerId() == self.user?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }

            }, withCancel: nil)
        }
    }
    
    override func loadView() {
        super.loadView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        setupTableView()
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        setupInputComponents()
        setUpkeyboardObservers()

    }
    
    
    func setUpkeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        // to avoid memory leaks (avoid calling the funciton many times
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleKeyboardWillShow (notification: NSNotification) {
        let keyboardFrame = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as?  CGRect
        let keyboardDuration = notification.userInfo?["UIKeyboardAnimationDurationUserInfoKey"]
        //print(notification.userInfo)
        containerViewButtomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration! as! TimeInterval) {
            // to animate constraints
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyboardWillHide (notification: NSNotification) {
        let keyboardDuration = notification.userInfo?["UIKeyboardAnimationDurationUserInfoKey"]
        containerViewButtomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration! as! TimeInterval) {
            // to animate constraints
            self.view.layoutIfNeeded()
        }
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.height, height: 80)
    }
    
    var containerViewButtomAnchor: NSLayoutConstraint?
    
    

    
    func setupInputComponents() {
    
        let containerView = UIView()
        containerView.backgroundColor = .white
        //containerView.backgroundColor = UIColor.red
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        // adding constrains
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        containerViewButtomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewButtomAnchor?.isActive = true
        
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        // adding constrains
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        inputTextField.placeholder = "Enter message..."
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(inputTextField)
        
        // adding constrains
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let sepratorLineView = UIView()
        sepratorLineView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        sepratorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sepratorLineView)
        
        // adding constrains
        sepratorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        sepratorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        sepratorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        sepratorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    @objc func handleSend() {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user?.id!
        let fromId = Auth.auth().currentUser?.uid
        let timesnap = Int(NSDate().timeIntervalSince1970)
        let values = ["text": inputTextField.text!, "toId": toId!, "fromId": fromId!, "timestamp": timesnap] as [String : Any]
        //childRef.updateChildValues(values)]
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            // client-side fan-out for data consistency
            
            let userMessageRef = Database.database().reference().child("user-messages").child(fromId!)
            let messageId = childRef.key!
            userMessageRef.updateChildValues([messageId: 1])
            
            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toId!)
            recipientUserMessageRef.updateChildValues([messageId: 1])
        }
        
        DispatchQueue.main.async {
            self.inputTextField.text = ""
        }
    }
    
}

extension ChatLogController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatMessageCell
        cell.messageLabel.text = messages[indexPath.row].text
        let toId = messages[indexPath.row].toId
        cell.profileImageUrl = user?.profileImageUrl
        cell.isInComing = toId != user?.id
        return cell
    }
    
}
