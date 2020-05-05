//
//  SignUpViewController.swift
//  URLDownloadImage
//
//  Created by max on 01.05.2020.
//  Copyright © 2020 max. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    
    //MARK: Variables and Constant
    private let activityIndicator = UIActivityIndicatorView()
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        button.center = CGPoint(x: self.view.center.x,
                                y: self.view.center.y + 190)
        button.setTitle("Регистрация", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
        button.backgroundColor = UIColor(red: 10.0/255, green: 113.0/255, blue: 255.0/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(goSignUpButton), for: .touchUpInside)
    
       return button
    }()
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        observeTextField()
        setContinueButton(enable: false)
        createActivity()
        
    }
    
    //MARK: ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWilAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    //MARK: Action
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private Func
    private func updateView() {
        view.addSubview(signUpButton)
    }
    
    private func setContinueButton(enable: Bool) {
        if enable {
            signUpButton.alpha = 1
            signUpButton.isEnabled = true
        } else {
            signUpButton.alpha = 0.5
            signUpButton.isEnabled = false
        }
    }
    
    private func observeTextField() {
        emailTextField.addTarget(self, action: #selector(changeTextField), for: .editingChanged)
        nameTextField.addTarget(self, action: #selector(changeTextField), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(changeTextField), for: .editingChanged)
        confirmTextField.addTarget(self, action: #selector(changeTextField), for: .editingChanged)
    
    }
    
    private func createActivity() {
        activityIndicator.style = .medium
        activityIndicator.color = .white
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = signUpButton.center
        view.addSubview(activityIndicator)
    }
    
    //MARK: Target
    @objc private func changeTextField() {
        guard let email = emailTextField.text,
            let name = nameTextField.text,
            let password = passwordTextField.text,
            let confirm = confirmTextField.text else { return }
        
        let chek = !(email.isEmpty) &&
            !(name.isEmpty) &&
            !(password.isEmpty) &&
            password == confirm
        setContinueButton(enable: chek)
    }
    
    @objc func keyboardWilAppear(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        signUpButton.center = CGPoint(x: view.center.x,
                                        y: view.frame.height -
                                            keyboardFrame.height -
                                            16.0 -
                                            signUpButton.frame.height / 2)
        activityIndicator.center = signUpButton.center
    }
    
    //регистрация в firbase по email
    @objc func goSignUpButton() {
        setContinueButton(enable: false)
        signUpButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            let userName = nameTextField.text
            else { return }
        
        //запрос на регистрацию нового пользователя
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if let error = error {
                print(error.localizedDescription)
                self.setContinueButton(enable: true)
                self.signUpButton.setTitle("Sign Up", for: .normal)
                self.activityIndicator.stopAnimating()
            }
            print("Successfully into Firbase with email")
            
            //запрос на изменение имени
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                
                changeRequest.displayName = userName
                changeRequest.commitChanges { (error) in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        self.setContinueButton(enable: true)
                        self.signUpButton.setTitle("Sign Up", for: .normal)
                        self.activityIndicator.stopAnimating()
                    }
                    //закрываем 3 viewController
                    self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
            
        }
    }
    
    //скрытие клавиатуры
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            view.endEditing(true)
        }
    }
}
