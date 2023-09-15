//
//  WelcomeViewController.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 8.04.2023.
//


import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "bilgetify2"
     
        view.addSubview(imageView) // nesneler bu şekilde eklenmeli
        view.addSubview(overlayView)
        view.backgroundColor = .blue
        view.addSubview(signInButton)
        view.addSubview(label)
        view.addSubview(logoImageView)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() { // nesnelerin konumlandırılmasıyla ilgili bilgiler bu fonksiyona yazılır
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds // imageView e tüm ekranı kapla diyoruz
        
        signInButton.frame = CGRect(
            x: 20,
            y: view.frame.height-50-view.safeAreaInsets.bottom,
            width: view.frame.width-40,
            height: 50
        )
        logoImageView.frame = CGRect(x: (view.frame.width-120)/2, y: (view.frame.height-350)/2, width: 120, height: 120)
        label.frame = CGRect(x: 30, y: logoImageView.frame.height+30, width: view.frame.width-60, height: 150)
        
        signInButton.addTarget(self, action: #selector(LoginMi), for: .touchUpInside) // for: .touchUpInside bu kısım ne zaman fonksiyonun çağırılacağını belirtir. yani butona tıklandığında LoginMi fonksiyonu devreye girecek
    }
    
    private let signInButton : UIButton = { // sign in butonunun özellikleri
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Giriş Yap", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let imageView : UIImageView = { // imageView in özellikleri
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "albums")
        return imageView
    }()
    
    private let logoImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logo")
        return imageView
    }()
    
    private let label : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 32)
        label.text = "Milyonlarca Şarkıyı Dinle!"
        return label
    }()
    
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        return view
    }()
    
    
    @objc func LoginMi() {
        let vc = AuthViewController()
        vc.completionHandler = { [weak self] success in
            DispatchQueue.main.async {
                self?.handleSignIn(success: success) // giriş başarılıysa success ver
            }
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

    private func handleSignIn(success: Bool) { // kişi login se onu TabBarViewController a gönderen bir fonksiyon yazıyoruz. giriş yap butonuna basıldığında arka planda bu fonksiyon devreye girer. bu da authviewcontroller dan gelen bilgilere göre anasayfaya yönlendirecek ya da bir hata çıkaracak
        // Log user in or yell at them for error
        guard success else { // kullanıcı adı ve şifre yanlışsa bir popup sayfa çıkartır
            let alert = UIAlertController(title: "Oops",
                                          message: "Something went wrong when signing in.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }

        let mainAppTabBarVC = TabBarViewController() // işlem başarılıysa anasayfaya dönmesini sağlar
        mainAppTabBarVC.modalPresentationStyle = .fullScreen
        present(mainAppTabBarVC, animated: true)
    }
       

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
