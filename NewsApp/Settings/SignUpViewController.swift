import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextS: UITextField!
    @IBOutlet weak var passwordTextS: UITextField!
    @IBOutlet weak var passwordTextS2: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func SignUpS(_ sender: Any) {
        
        if emailTextS.text != "" && passwordTextS.text != "" {
            if passwordTextS.text == passwordTextS2.text {
                Auth.auth().createUser(withEmail: emailTextS.text!, password: passwordTextS.text!) { authdata, error in
                    if error != nil{
                        self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error!")
                    }else{
                        self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                    }
                }
            }else{
                makeAlert(titleInput: "Error!", messageInput: "Passwords are not the same.")
            }
        }else{
            makeAlert(titleInput: "Error!", messageInput: "No username or password entered.")
        }
        
    }
    
    
    func makeAlert(titleInput:String, messageInput:String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }

}
