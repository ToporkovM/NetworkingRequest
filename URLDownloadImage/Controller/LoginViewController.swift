//
//  LoginViewController.swift
//  URLDownloadImage
//
//  Created by max on 19.04.2020.
//  Copyright © 2020 max. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    var userProfile: UserProfile?
    
    lazy var fbLoginButton = { () -> FBLoginButton in
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32, y: 490, width: self.view.frame.width - 64, height: 50)
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 0.5
        
//        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.delegate = self
        return loginButton
    }()
    
    // реализация кастомной кнопки
    lazy var customFbButton = { () -> UIButton in
        let customButtom = UIButton()
        customButtom.frame = CGRect(x: 32, y: 420, width: self.view.frame.width - 64, height: 50)
        customButtom.backgroundColor = .blue
        customButtom.setTitle("Sign in and save data", for: .normal)
        customButtom.titleLabel?.textColor = .white
        customButtom.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customButtom.layer.cornerRadius = 5
        customButtom.layer.borderWidth = 0.5
        customButtom.addTarget(self, action: #selector(targetCustomButton), for: .touchUpInside)
        
        return customButtom
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground()
        updateView()
//        layoutButton()
    }
    
    private func updateView() {
        view.addSubview(fbLoginButton)
        view.addSubview(customFbButton)
    }
    
    private func setGradientBackground() {
        let colorTop =  UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 255.0/255.0, green: 94.0/255.0, blue: 58.0/255.0, alpha: 1.0).cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds

        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func layoutButton() {
        
        fbLoginButton.widthAnchor.constraint(equalToConstant: view.frame.width - 60).isActive = true
        fbLoginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        fbLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        fbLoginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 180).isActive = true
                
    }
    
}

//MARK: Facebook SDK

extension LoginViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if error != nil {
            guard let errorNotOptional = error else { return }
            print(errorNotOptional)
        }
        
        //если токен авторизации верный, то закрываем LoginViewController
            guard AccessToken.isCurrentAccessTokenActive else { return }
        self.authInToFirebase()
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Did log out")

    }
    
    //закрытие LoginViewController
    private func closeVC() {
        
        dismiss(animated: true)
    }
    
    //авторизация в firbase с помощью facebook
    private func authInToFirebase() {
        
        let accesToken = AccessToken.current
        guard let tokenString = accesToken?.tokenString else { return }
        let credentials = FacebookAuthProvider.credential(withAccessToken: tokenString)
        
        Auth.auth().signIn(with: credentials) { (user, error) in
            if let error = error {
                print("error: ", error)
                return
            }
            print("successfully logget in to Firbase, user")
            self.fetchFacebookFields()
        }
    }
    
    //запрос параметров из facebook и добавление их в структуру UserProfile
    private func fetchFacebookFields() {
        
        GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start { (_, result, error) in
            
            if let error = error {
                print(error)
                return
            }
            guard let userData = result as? [String: Any] else { return }
            print(userData)
            self.userProfile = UserProfile(data: userData)
            print(self.userProfile?.name ?? "nil")
            self.savedDataInToFirebase()
        }
    }
    
    //сохранение данных из facebook в fairbase database
    private func savedDataInToFirebase() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = ["id": userProfile?.id as Any, "name": userProfile?.name as Any] as [String: Any]
        let value = [uid: userData]
        
        Database.database().reference().child("users").updateChildValues(value) { (error, _) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Successfully saved in to firebase")
            self.closeVC()
        }
    }

    //селектор для кастомной кнопки
    @ objc private func targetCustomButton() {
        
        LoginManager().logIn(permissions: ["email, public_profile"], from: self) { (result, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let result = result else { return }
            if result.isCancelled { return }
            else {
                self.authInToFirebase()
            }
        }
    }
}
