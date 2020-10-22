//
//  ViewController.swift
//  boos
//
//  Created by Developer on 21/10/2020.
//  Copyright © 2020 learnandcodes. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import ProgressHUD

class ViewController: UIViewController {

    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var edtFullName: UITextField!
    
    @IBOutlet weak var edtEmailAddress: UITextField!
    
    @IBOutlet weak var edtPassword: UITextField!
    
    @IBOutlet weak var btnSignUp: UIButton!
    
    
    //init Firebase database
    var ref: DatabaseReference!
    
    //variables
    var image:UIImage?=nil
    var indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUi()
    }

    
    func setUi(){
        
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presendPicker))
        profileImageView.addGestureRecognizer(tapGesture)
        
        
      
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubviewToFront(view)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @objc func presendPicker(){
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker,animated: true,completion: nil)
        
        
    }
    

    
    
    
    
    @IBAction func signupAccount(_ sender: Any) {
        
        ProgressHUD.show()
        
        self.view.endEditing(true)
       
        guard let email = self.edtEmailAddress.text, !email.isEmpty else {
            ProgressHUD.showError("Please add email")
            return
        }
        guard let password = self.edtPassword.text, !password.isEmpty else {
             ProgressHUD.showError("Please add password")
            return
        }
        guard let username = self.edtFullName.text, !username.isEmpty else {
             ProgressHUD.showError("Please add username")
           return
        }
        
        
        guard let imageSelect = self.image else{
            print("Image is nil")
            return
        }
        
        guard let imageData = image?.jpegData(compressionQuality: 0.4) else{
            return
        }
        
        
        
       
        
        
        ref = Database.database().reference()
        Auth.auth().createUser(withEmail: email, password: password)
        {(authResult, error) in
            if let user = authResult?.user {
                
                
                var signUpData: Dictionary<String,Any> =
                [
                    "userName": username,
                    "email" : user.email,
                    "password": password
                ]
                
                
                
                
                let storageRef = Storage.storage().reference(forURL: "gs://boos-ca560.appspot.com/")
                let storageProfileRef = storageRef.child("profile_Images").child(user.uid)
                
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                storageProfileRef.putData(imageData, metadata: metadata)
                { (storageMeta, error) in
                    
                    if error != nil{
                        print(error?.localizedDescription)
                        ProgressHUD.showError("Uploading Issue")
                        return
                    }
                    
            
                    storageProfileRef.downloadURL { (URL, error) -> Void in
                      if (error != nil) {
                        // Handle any errors
                      } else {
                        // Get the download URL for 'images/stars.jpg
                        let UrlString = URL?.absoluteString
                        signUpData["profileImage"] = UrlString
                        print(UrlString)
                        
                        
                        
                        //update data to database
                    self.ref.child("users").child(user.uid).updateChildValues(signUpData,withCompletionBlock: {
                            (error, ref) in
                            if error == nil
                            {
                                 ProgressHUD.dismiss()
                                
                            
                                print("done")
                                self.indicator.stopAnimating()
                            }
                            else
                            {
                                print("error in code")
                            }
                        })
                        
                        
                        
                        
                       // you will get the String of Url
                      }
                    }
                    
                    
                }
                
                
    
                print(user.email)
                
                
            } else {
                
            }
        }

        
    }
    
    
    

}



extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let backgroundImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
    
    image = backgroundImage
    profileImageView.image = backgroundImage

    picker.dismiss(animated: true, completion: nil)
    
    }
    
}
