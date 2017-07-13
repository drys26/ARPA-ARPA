

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit

class LoginViewController: UIViewController , GIDSignInDelegate , GIDSignInUIDelegate {



    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var whatsBestLogo: UIImageView!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var loginExistingAccountButton: UIButton!
    
    
    var databaseRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //setting up the design buttons
        
        setupButton()
        
        
        //listener for users who's already logged in
         Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "goToMainPage", sender: nil)
            }
            else{
                print("no user")
            }
        })
        
        
        
        databaseRef = Database.database().reference()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        whatsBestLogo.tintColor  = UIColor.white
       
    }
    
    @IBAction func toogleFacebookLogin(_ sender: Any) {
        
        
        //instantiate fblogin manager
        let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
        
        //set fblogin manager's behavior
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.web
        
        //setting fblogin access information permissions
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
            
            //if error not found continue
            if error == nil {
                
                let fbLoginResult: FBSDKLoginManagerLoginResult = result!
                
                //check fblogin permission if granted
                if (fbLoginResult.grantedPermissions != nil){
                    if (fbLoginResult.grantedPermissions.contains("email")){
                    
                        //instantiate credentials to take fbaccesstokens
                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                        
                        //firebase authentication using fblogin token
                    Auth.auth().signIn(with: credential, completion: { (user, err) in
                        
                        //if error found
                        if let error = err{
                            print("Failed to create a Firebase User with Facebook Account", error)
                            return
                        }
                        //if error not found continue and get user's name, email, and photoURL
                        
                        print(user?.displayName ?? "")
                        print(user?.email ?? "")
                        print(user?.photoURL?.absoluteString ?? "")
                        
                        //save user's dictionary to database
                        let userDictionary = ["display_name": (user?.displayName)!,"email_address": (user?.email)!, "photo_url": (user?.photoURL?.absoluteString)!, "cover_photo_url": (user?.photoURL?.absoluteString)!] as [String: Any]
                        self.databaseRef.child("Users").child((user?.uid)!).setValue(userDictionary)
                        
                        //get more user's data
                        self.getFBUserData()
                        
                    })
                    
                    }
                    else{
                        print("Login Result didn't fetch Email")
                    }
                }
                else{
                    print("\(fbLoginResult.grantedPermissions)")
                }
                
            }
            else{
                print(error?.localizedDescription ?? "")
            }
        }
        
    }
    
    func getFBUserData(){
        
        //take fbuser's info using the access token and granted permissions
        if (FBSDKAccessToken.current().tokenString) != nil {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, friends, birthday, cover, devices, picture.type(large)"]).start(completionHandler: { (connection, result, error) in
                //error found
                if error != nil {
                    print("Failed to start graph request", error ?? "")
                    return
                    
                }
                //error not found continue to listener
                print("Successfully Created a Firebase User with Facebook Account")
                print(result ?? "GG")
                
            })
            
            
        }
    }
    
    
    @IBAction func SignUpButton(_ sender: Any) {
        
        performSegue(withIdentifier: "goToRegister", sender: nil)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //animation on start up
        UIView.animate(withDuration: 1, animations: {
            self.heightConstraint.constant = 75
            self.view.layoutIfNeeded()
        }) { (true) in
            UIView.animate(withDuration: 0.5, animations: {
                self.googleButton.alpha = 1
            }, completion: { (true) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.facebookButton.alpha = 1
                }, completion: { (true) in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.createAccountButton.alpha = 1
                    }, completion: { (true) in
                        UIView.animate(withDuration: 0.5, animations: { 
                            self.loginExistingAccountButton.alpha = 1
                        })
                    })
                })
            })
        }
        
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        //return a light content of status bar
        return .lightContent
    }
    
    func setupButton(){
        
        //setup login buttons
        loginExistingAccountButton.alpha = 0
        googleButton.alpha = 0
        facebookButton.alpha = 0
        createAccountButton.alpha = 0
        googleButton.layer.cornerRadius = googleButton.frame.size.height / 2
        facebookButton.layer.cornerRadius = facebookButton.frame.size.height / 2
        createAccountButton.layer.cornerRadius = createAccountButton.frame.size.height / 2
        createAccountButton.layer.borderColor = UIColor.white.cgColor
        createAccountButton.layer.borderWidth = 2
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("User Sign in to Google")
        
        //instantiate google authentication
        guard let authentication = user.authentication else { return }
        
        //take access token from google authentication provider
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        //proceed to firebase login
        Auth.auth().signIn(with: credential) { (user1, error) in
            print("User Sign in to Firebase")
            
            //save information to firebase database
            self.databaseRef.child("Users").child((user1?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                let snapshot = snapshot.value as? NSDictionary
                if snapshot == nil {
                    
                    //instantiate user's information
                    let userDictionary = ["display_name": (user1?.displayName)! ,"email_address" : (user1?.email)! , "photo_url" : (user1?.photoURL?.absoluteString)!, "cover_photo_url": (user1?.photoURL?.absoluteString)!,"search_name": user1?.displayName?.lowercased()] as [String : Any]
                    
                    //save user's data to database
                    self.databaseRef.child("Users").child((user1?.uid)!).setValue(userDictionary)
                    
                }
                //self.performSegue(withIdentifier: "goToMainPage", sender: nil)
            })
        }
    }
    
    @IBAction func googleSignInAction(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func toogleLoginEmail(_ sender: Any) {
        performSegue(withIdentifier: "goToLogin", sender: nil)
        
    }
    
    
}

