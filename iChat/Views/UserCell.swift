//
//  UserCell.swift
//  iChat
//
//  Created by Abdalla Elsaman on 4/18/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            setupNameAndProfile()
            self.detailTextLabel?.text = message?.text
            if let timestamp = message?.timeStamp {
                let timestampDate = NSDate(timeIntervalSince1970: TimeInterval(timestamp))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate as Date)
            }
        }
    }
    
    private func setupNameAndProfile() {
        
        if let id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observe(.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
                    }
                }
            }, withCancel: nil )
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 62, y: (textLabel?.frame.origin.y)! - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRect(x: 62, y: (detailTextLabel?.frame.origin.y)! + 2, width: (detailTextLabel?.frame.width)!, height: (detailTextLabel?.frame.height)!)
    }
    
    let profileImageView = UIImageView()
    
    let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        // adding constrains
        profileImageView.image = UIImage(named: "ChatProfile")
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 24
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        addSubview(timeLabel)
        // timeLabel.text = "dasddsdad"
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.textColor = UIColor.darkGray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // adding constrains
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
