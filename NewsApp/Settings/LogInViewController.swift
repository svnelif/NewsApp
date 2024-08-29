import UIKit
import Firebase
import FirebaseAuth

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextL: UITextField!
    @IBOutlet weak var passwordTextL: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ekstra ayarları burada yapabilirsiniz.
    }

    @IBAction func loginClicked(_ sender: Any) {
        // Text field'ların boş olup olmadığını kontrol et
        guard let email = emailTextL.text, !email.isEmpty,
              let password = passwordTextL.text, !password.isEmpty else {
            makeAlert(titleInput: "Error!".localized, messageInput: "No username or password entered.".localized)
            return
        }
        
        // Firebase Auth ile giriş yap
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                // Hata varsa alert göster
                self?.makeAlert(titleInput: "Error!".localized, messageInput: error.localizedDescription)
            } else {
                // Başarılı girişte segue yap
                self?.performSegue(withIdentifier: "toMenuVC", sender: nil)
            }
        }
    }
    
    @IBAction func signupClicked(_ sender: Any) {
        // Sign Up sayfasına geçiş yap
        performSegue(withIdentifier: "toSignUpVC", sender: nil)
    }
    
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK".localized, style: .cancel)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
}
