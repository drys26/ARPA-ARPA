

import UIKit
import Firebase

class LoginWithEmailController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var switchView: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var rmLabel: UILabel!
    @IBOutlet weak var forgotPass: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLoginDesign()
        
    }

    @IBAction func toogleBack(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupLoginDesign(){
        
        activityIndicator.isHidden = true
        
        emailTextField.layer.cornerRadius = emailTextField.frame.size.height / 2
        emailTextField.layer.borderWidth = 2
        emailTextField.layer.borderColor = UIColor.white.cgColor
        emailTextField.leftViewMode = .always
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        let imageView = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
        let image = UIImage(named: "icons8-message_filled")
        imageView.image = image
        paddingView.addSubview(imageView)
        emailTextField.leftView = paddingView
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        
        
        passwordTextField.layer.cornerRadius = passwordTextField.frame.size.height / 2
        passwordTextField.layer.borderWidth = 2
        passwordTextField.layer.borderColor = UIColor.white.cgColor
        passwordTextField.leftViewMode = .always
        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        let imageView2 = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
        let image2 = UIImage(named: "icons8-lock_filled")
        imageView2.image = image2
        paddingView2.addSubview(imageView2)
        passwordTextField.leftView = paddingView2
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        
        
        loginButton.layer.cornerRadius = loginButton.frame.size.height / 2
        
    }
    
    @IBAction func toogleLogin(_ sender: Any) {
        
        if emailTextField.text == "" {
            
        }
        else if passwordTextField.text == "" {
            
        }
        else{
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            UIView.animate(withDuration: 1, animations: { 
                self.emailTextField.alpha = 0
                self.passwordTextField.alpha = 0
                self.loginButton.alpha = 0
                self.switchView.alpha = 0
                self.rmLabel.alpha = 0
                self.forgotPass.alpha = 0
                
                
            })
            Auth.auth().signIn(withEmail: "\(emailTextField.text!)", password: "\(passwordTextField.text!)") { (user, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: "\(error?.localizedDescription ?? "")", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    UIView.animate(withDuration: 1, animations: {
                        self.emailTextField.alpha = 1
                        self.passwordTextField.alpha = 1
                        self.loginButton.alpha = 1
                        self.switchView.alpha = 1
                        self.rmLabel.alpha = 1
                        self.forgotPass.alpha = 1
                        
                        
                    })
                }
                else{
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.performSegue(withIdentifier: "goToHomePage", sender: nil)
                }
            }
        }
        
        
        
    }
    


}
