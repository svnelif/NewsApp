import UIKit
import Firebase
import FirebaseAuth

class LogInViewController: UIViewController {

    
    @IBOutlet weak var emailTextL: UITextField!
    @IBOutlet weak var passwordTextL: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func loginClicked(_ sender: Any) {
        if emailTextL.text != "" && passwordTextL.text != "" {
            Auth.auth().signIn(withEmail: emailTextL.text!, password: passwordTextL.text!) { authdata, error in
                if error != nil{
                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error!")
                }else{
                    self.performSegue(withIdentifier: "toMenuVC", sender: nil)
                }
            }
        }else{
            makeAlert(titleInput: "Error!", messageInput: "No username or password entered.")
        }
    }
    
    
    @IBAction func signupClicked(_ sender: Any) {
        performSegue(withIdentifier: "toSignUpVC", sender: nil)
    }
    
    
    func makeAlert(titleInput:String, messageInput:String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
}

