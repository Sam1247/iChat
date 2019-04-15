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
            user, error in
            if error != nil {
                print(error!)
                return
            }
            guard let userID = Auth.auth().currentUser?.uid else { return }
            // successfuly authenticating user
            
            //uploading image
            
            let storageRef = Storage.storage().reference()
            
            storageRef.putData(<#T##uploadData: Data##Data#>, metadata: <#T##StorageMetadata?#>, completion: <#T##((StorageMetadata?, Error?) -> Void)?##((StorageMetadata?, Error?) -> Void)?##(StorageMetadata?, Error?) -> Void#>)
            
            
            let ref = Database.database().reference(fromURL: "https://ichat-43b15.firebaseio.com/")
            let usersRef = ref.child("users").child(userID)
            let values = ["name": name, "email": email]
            
            usersRef.updateChildValues(values, withCompletionBlock: {
                [weak self] (err, ref) in
                if err != nil {
                    print(err!)
                    return
                }
                print("saved user successfuly in firebase db")
                self?.dismiss(animated: true, completion: nil)
            })
            
        }
    }
    
}
