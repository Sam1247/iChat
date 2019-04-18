//
//  loginController+handlers.swift
//  iChat
//
//  Created by Abdalla Elsaman on 4/15/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleSelectProfile () {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[.editedImage] as? UIImage{
            selectedImageFromPicker = editedImage
        } else if let orignalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = orignalImage
        }
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func handleRegister () {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) {
            [weak self]
            user, error in
            if error != nil {
                print(error!)
                return
            }
            guard let userID = Auth.auth().currentUser?.uid else { return }
            // successfuly authenticating user
            
            //uploading image
            let imageName = UUID().uuidString
            let storageRef = Storage.storage().reference().child("images").child("\(imageName).jpg")
            if let uploadData = self?.profileImageView.image?.jpegData(compressionQuality: 0.1) {
                storageRef.putData(uploadData, metadata: nil) {
                    [weak self] (metadata, error) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    // saving image url 
                    storageRef.downloadURL {
                        (url, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        if let imageUrl = url?.absoluteString {
                            let values = ["name": name, "email": email, "profileImageUrl": imageUrl]
                            self?.registerUserIntoDataBase(userID: userID, values: values)
                        }
                    }
                }
            }
        }
    }
    
    private func registerUserIntoDataBase (userID: String, values: [String: String]) {
        let ref = Database.database().reference()
        let usersRef = ref.child("users").child(userID)
        
        
        usersRef.updateChildValues(values, withCompletionBlock: {
            [weak self] (err, ref) in
            if err != nil {
                print(err!)
                return
            }
            print("saved user successfuly in firebase db")
            //self?.messageController?.fetchUserAndSetupNavBarItem()
            //self?.messageController?.navigationItem.title = values["name"]
            let user = User()
            user.name = values["name"]
            user.email = values["email"]
            user.profileImageUrl = values["profileImageUrl"]
            self?.messageController?.setupNavBarWithUser(user: user)
            
            self?.dismiss(animated: true, completion: nil)
        })
    }
    
}
