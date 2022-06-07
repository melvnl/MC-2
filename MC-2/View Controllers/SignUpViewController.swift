//
//  SignUpViewController.swift
//  MC-2
//
//  Created by Stefanus Hermawan Sebastian on 07/06/22.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var namaTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.tintColor = UIColor(red: 255/255, green: 77/255, blue: 109/255, alpha: 1)
    }
    
    //validate password
    func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    //Check the fields and validate that the data is correct. If everything is correct, this method returns nil. Otherwise, it returns the error message.
    func validationFields() -> String? {
        
        // Check that all fields are filled in
        if namaTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Tolong isi semua bagian formulir pendaftaran"
        }
        
        // Check if the password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isPasswordValid(cleanedPassword) == false {
            // Password is not secure enough
            return "Pastikan password minimal terdiri dari 8 karakter, berisi karakter spesial, dan berisi nomor."
        }
        
        return nil
    }
    
    
    @IBAction func signUpTapped(_ sender: Any) {
//        Validate the fields
        let error = validationFields()
        
        if error != nil {
            //there's something wrong with the fields,show error message
            showError(error!)
        }else {
            
            // Create cleaned versions of the data
            let nama = namaTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //  Create the user
            Auth.auth().createUser(withEmail: email, password: password) { result, err in
                //Check for errors
                if err != nil {
                    //there was an error creating user
                    self.showError("Error dalam membuat akun")
                }else {
                    // User was created successfully, now store name & username
                    let db = Firestore.firestore()
                    db.collection("users").addDocument(data: ["nama":nama, "username":username, "uid":result!.user.uid]) { error in
                        if error != nil {
                            //show error message
                            self.showError("Error dalam menyimpan data akun")
                        }
                    }
                    // Transition to the home screen
                    self.transitionToHome()
                }
            }
                    
            
        }

    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }

    func transitionToHome() {
        
    }
}
