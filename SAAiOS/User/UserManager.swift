//
//  UserManager.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 12/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import Firebase
import FirebaseUI

extension Notification.Name {
    static let userChange = Notification.Name("userChange")
}

class UserManager: NSObject, FUIAuthDelegate {
    private var handle: AuthStateDidChangeListenerHandle!
    var user: User? {
        didSet {
            let notification = Notification.init(name: .userChange)
            NotificationCenter.default.post(notification)
        }
    }
    
    func signIn() -> UINavigationController? {
        guard let authUI = FUIAuth.defaultAuthUI() else {return nil}
        authUI.delegate = self
        
        authUI.providers = [FUIGoogleAuth()]
        return authUI.authViewController()
    }
    
    func signOut(){
        guard let authUI = FUIAuth.defaultAuthUI() else {return}
        do {
            try authUI.signOut()
            self.user = nil
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error {
            print(error)
        } else if let dataResult = authDataResult {
            self.user = dataResult.user
        }
    }
    
    override init() {
        super.init()
        let handle = Auth.auth().addStateDidChangeListener{auth, user in
            self.user = user
        }
        self.handle = handle
    }
}
