//
//  SignUpViewController.swift
//  URLDownloadImage
//
//  Created by max on 01.05.2020.
//  Copyright © 2020 max. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    
    //MARK: Variables and Constant
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
    
       return button
    }()
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        observeTextField()
        setContinueButton(enable: false)
        
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
    }
    

}
