import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextSu: UITextField!
    @IBOutlet weak var passwordTextSu: UITextField!
    @IBOutlet weak var passwordTextSu2: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func SignUpS(_ sender: Any) {
        
        if emailTextSu.text != "" && passwordTextSu.text != "" {
            if passwordTextSu.text == passwordTextSu2.text {
                Auth.auth().createUser(withEmail: emailTextSu.text!, password: passwordTextSu.text!) { authdata, error in
                    if error != nil{
                        self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error!")
                    }else{
                        self.performSegue(withIdentifier: "toMenuVC", sender: nil)
                    }
                }
            }else{
                makeAlert(titleInput: "Error!", messageInput: "Passwords are not the same.".localized)
            }
        }else{
            makeAlert(titleInput: "Error!", messageInput: "No username or password entered.".localized)
        }
        
    }
    
    
    @IBAction func LogInS(_ sender: Any) {
        performSegue(withIdentifier: "toLogInVC", sender: nil)
    }
    
    func makeAlert(titleInput:String, messageInput:String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }

}
