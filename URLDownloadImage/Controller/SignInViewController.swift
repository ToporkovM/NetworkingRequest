//
//  SignInViewController.swift
//  URLDownloadImage
//
//  Created by max on 01.05.2020.
//  Copyright © 2020 max. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    //MARK: Variables and Constants
    private lazy var continueButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        button.center = CGPoint(x: self.view.center.x,
                                y: self.view.center.y + 190)
        button.setTitle("Продолжить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
        button.backgroundColor = UIColor(red: 10.0/255, green: 113.0/255, blue: 255.0/255, alpha: 1)
        button.layer.cornerRadius = 5
        return button
    }()
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        setContinueButton(enable: false)
        observeTextField()
    }
    
    //MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //добавление уведомления на клавиатуру
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWilAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    //MARK: Actions
    @IBAction func signUpButton(_ sender: Any) {
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: private func
    private func updateView() {
        view.addSubview(continueButton)
    }
    
    //изменение активности и прозрачности кнопки
    private func setContinueButton(enable: Bool) {
        if enable {
            continueButton.alpha = 1
            continueButton.isEnabled = true
        } else {
            continueButton.alpha = 0.5
            continueButton.isEnabled = false
        }
    }
    
    //добавление функции проверки в textField
    private func observeTextField() {
        emailTextField.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
    }
    
    //MARK: Target
    //проверка на заполненые поля и изменение активности кнопки
    @objc private func textFieldChange() {
        guard let email = emailTextField.text,
            let password = passwordTextField.text
            else { return }
        let chek = !(email.isEmpty) && !(password.isEmpty)
        setContinueButton(enable: chek)
    }
    
    //добавление уведомления на клавиатуру и изменение положения кнопки "продожить"
    @objc func keyboardWilAppear(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        continueButton.center = CGPoint(x: view.center.x,
                                        y: view.frame.height -
                                            keyboardFrame.height -
                                            16.0 -
                                            continueButton.frame.height / 2)
    }
    
}
