import Foundation
import AppAuth
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

extension Notification.Name {
    static var SignedIn: Notification.Name {
        return Notification.Name.init("SignedIn")
    }
    static var SignedOut: Notification.Name  {
        return Notification.Name.init("SignedOut")
    }
}

struct UserData: Codable {
    var oauthIdToken: String
    var idToken: String
    var refreshToken: String
    var localId: String
    var originalEmail: String
    var providerId: String
}

struct GoogleOAuthCredentials {
    static let label = "SAAoSXGClientCredentials"
    let clientID: String
    let clientSecret: String
    
    enum error: Error {
        case unhandledError(Status: OSStatus)
    }
    
    func save() throws {
        let clientID = self.clientID
        let clientSecret = self.clientSecret.data(using: .utf8)!
        
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrLabel as String: GoogleOAuthCredentials.label,
                                    kSecAttrAccount as String: clientID,
                                    kSecValueData as String: clientSecret]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {throw GoogleOAuthCredentials.error.unhandledError(Status: status)}
    }
    
    static func get() -> GoogleOAuthCredentials? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrLabel as String: GoogleOAuthCredentials.label,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status != errSecItemNotFound else {return nil}
        guard status == errSecSuccess else {return nil}
        
        guard let existingItem = item as? [String: Any],
            let secretData = existingItem[kSecValueData as String] as? Data,
            let clientSecret = String(data: secretData, encoding: .utf8),
            let clientID = existingItem[kSecAttrAccount as String] as? String
            else { return nil }
        
        return GoogleOAuthCredentials(clientID: clientID, clientSecret: clientSecret)
    }
}

class UserManager {
    lazy var userHandle: AuthStateDidChangeListenerHandle = {
        return Auth.auth().addStateDidChangeListener{ [weak self] auth, user in
            if let user = user {
                self?.user = user
                let db = Database.database()
                db.isPersistenceEnabled = true
            } else {
                self?.user = nil
            }
        }
    }()
    
    lazy var redirectHandler: OIDRedirectHTTPHandler = {
        let success = URL(string: "http://openid.github.io/AppAuth-iOS/redirect/")
        return OIDRedirectHTTPHandler(successURL: success)
    }()
    
    lazy var configuration: OIDServiceConfiguration = {
        let auth = URL(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        let token = URL(string: "https://www.googleapis.com/oauth2/v4/token")!
        return OIDServiceConfiguration(authorizationEndpoint: auth, tokenEndpoint: token)
    }()
    
    var credential: AuthCredential? {
        didSet {
            if let credential = credential {
                self.getFirebaseUser(for: credential)
            }
        }
    }
    
    var oauthCredentials: GoogleOAuthCredentials? {
        return GoogleOAuthCredentials.get()
    }
    
    var user: User? {
        didSet {
            if self.user != nil {
                NotificationCenter.default.post(name: .SignedIn, object: nil)
                Database.database().isPersistenceEnabled = true
            } else if self.user == nil {
                NotificationCenter.default.post(name: .SignedOut, object: nil)
                Database.database().isPersistenceEnabled = false
            }
        }
    }
    
    func getFirebaseUser(for credential: AuthCredential){
        Auth.auth().signInAndRetrieveData(with: credential) {[weak self] result, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let result = result {
                self?.user = result.user
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
        }
    }
    
    
    func getOIDTokens() {
        guard let oauthCredentials = self.oauthCredentials else {return}
        
        let redirectURI = redirectHandler.startHTTPListener(nil)
        let request = OIDAuthorizationRequest(
            configuration: configuration,
            clientId: oauthCredentials.clientID,
            clientSecret: oauthCredentials.clientSecret,
            scopes: [OIDScopeOpenID],
            redirectURL: redirectURI,
            responseType: OIDResponseTypeCode,
            additionalParameters: nil)
        
        redirectHandler.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request) {[weak self] state, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let state = state {
                guard let token = state.lastTokenResponse else {return}
                guard let idToken = token.idToken else {return}
                guard let accessToken = token.accessToken else {return}
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                self?.credential = credential
            }
        }
    }

    
    func signIn() {
        if let credential = self.credential {
            self.getFirebaseUser(for: credential)
        } else {
            self.getOIDTokens()
        }
    }

    func signOut() {
        self.credential = nil
        self.user = nil
    }

    init(){}
    
    deinit {
        Auth.auth().removeStateDidChangeListener(self.userHandle)
    }
}
