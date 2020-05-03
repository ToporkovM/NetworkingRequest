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
import Firebase
import GoogleSignIn


class LoginViewController: UIViewController {
   
    
    var userProfile: UserProfile?
    
    //кнопка входа через email
    lazy var emailButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 32,
        y: 560,
        width: self.view.frame.width - 64,
        height: 50)
        button.setTitle("Sign in with email", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(presentSignInVC), for: .touchUpInside)
        return button
    }()
    
    // реализация дефолтной кнопки facebook
    lazy var fbLoginButton = { () -> FBLoginButton in
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32,
                                   y: 440,
                                   width: self.view.frame.width - 64,
                                   height: 50)
        loginButton.layer.cornerRadius = 5
        loginButton.setTitle("Sig In", for: .normal)
        
//        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.delegate = self
        return loginButton
    }()
    
    // реализация кастомной кнопки facebook
    /* lazy var customFbButton = { () -> UIButton in
        let customButtom = UIButton()
        customButtom.frame = CGRect(x: 32,
                                    y: 380,
                                    width: self.view.frame.width - 64,
                                    height: 50)
        customButtom.backgroundColor = UIColor(red: 10.0/255, green: 113.0/255, blue: 255.0/255, alpha: 1)
        customButtom.setTitle("Sign in and save data", for: .normal)
        customButtom.titleLabel?.textColor = .white
        customButtom.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customButtom.layer.cornerRadius = 5
        customButtom.addTarget(self,
                               action: #selector(targetCustomButton),
                               for: .touchUpInside)
        
        return customButtom
    }() */
    
    // реализация кастомной кнопки google
    lazy var googleButton: GIDSignInButton = {
        let loginButton = GIDSignInButton()
        loginButton.frame = CGRect(x: 32,
                                   y: 500,
                                   width: self.view.frame.width - 64,
                                   height: 50)
        loginButton.layer.cornerRadius = 5
        return loginButton
    }()
    
    
    //MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground()
        updateView()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
//        layoutButton()
    }
    
    //MARK: Private func
    
    private func updateView() {
        view.addSubview(fbLoginButton)
        //view.addSubview(customFbButton)
        view.addSubview(googleButton)
        view.addSubview(emailButton)
    }
    
    private func setGradientBackground() {
        let colorTop =  UIColor(red: 11.0/255.0,
                                green: 26.0/255.0,
                                blue: 189.0/255.0,
                                alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 112.0/255.0,
                                  green: 122.0/255.0,
                                  blue: 224.0/255.0,
                                  alpha: 1.0).cgColor

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
    
    @objc func presentSignInVC() {
        
        
        performSegue(withIdentifier: "SignIn", sender: self)
        
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
            print("successfully logget into Firbase, user")
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
    
    //сохранение данных в fairbase database
    private func savedDataInToFirebase() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = ["id": userProfile?.id as Any,
                        "name": userProfile?.name as Any,
                        "email": userProfile?.email as Any] as [String: Any]
        let value = [uid: userData]
        
        Database.database().reference().child("users").updateChildValues(value) { (error, _) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Successfully saved into firebase")
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

//MARK: Google SDK

extension LoginViewController: GIDSignInDelegate {
    
    //отслеживает регистрацию через google и регестрирует в firebase
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            print("unsuccessful attempt", error)
            return
        }
        
        print("successfully logget into Google")
        
        if let userName = user.profile.name, let email = user.profile.email {
           
            let data = ["name": userName, "email": email]
            userProfile = UserProfile(data: data)
        }
        //если проходит аутентификация
        guard let authentication = user.authentication else { return }
        //создаем токен удостоверяющий личность
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
        accessToken: authentication.accessToken)
        
        //входим в fairbase с данными пользователя
        Auth.auth().signIn(with: credential) { (user, error) in
            
            if let error = error {
                
                print("Error", error)
            }
            
            print("successfully logget into Firbase with Google")
            self.savedDataInToFirebase()

        }
    }
    
    
}
