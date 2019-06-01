//
//  ChatMessageCell.swift
//  iChat
//
//  Created by Abdalla Elsaman on 6/1/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit

class ChatMessageCell: UITableViewCell {
    
    let messageLabel = UILabel()
    let bubblebackgroundView = UIView()
    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    
    var profileImageView = UIImageView()
    
    
    var isInComing: Bool! {
        didSet {
            bubblebackgroundView.backgroundColor = isInComing ? .white: .yellow
            messageLabel.textColor = .black
            if isInComing {
                leadingConstraint.isActive = true
                trailingConstraint.isActive = false
                setupProfileImage()
            } else {
                leadingConstraint.isActive = false
                trailingConstraint.isActive = true
            }
        }
    }
    
    func setupProfileImage () {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = UIImage(named: "ChatProfile")
        profileImageView.layer.cornerRadius = 16
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        addSubview(profileImageView)
        // constrains
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        //bubblebackgroundView.backgroundColor = .yellow
        bubblebackgroundView.layer.cornerRadius = 12
        bubblebackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bubblebackgroundView)
        // constrains
        
        addSubview(messageLabel)
        //messageLabel.backgroundColor = .green
        //        messageLabel.text = "OS is to provide auto sizing cells for UITableView components. In today's lesson we look at how to implement a custom cell that provides auto sizing using anchor constraints.  This technique is very easy and requires very little customiz"
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        // constrains
        
        let constrains = [messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 32),
                          messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
                          messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
                          
                          bubblebackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -16),
                          bubblebackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -16),
                          bubblebackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
                          bubblebackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16)
        ]
        NSLayoutConstraint.activate(constrains)
        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 56)
        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
