//
//  SettingsViewController.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 30.04.2023.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var sections = [Section]() // 2 tane section ımız olucak bu controllerda
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        configureModels()

    }
    
    private func configureModels() {
        sections.append(Section(title: "Profil", options: [Option(title: "Profilini Gör", handler: { [weak self] in // birinci section a bunu ekliyoruz
            DispatchQueue.main.async { // Profilini Gör e tıklanınca arka planda viewProfile ı çağıracak
                self?.viewProfile()
            }
        })]))

        sections.append(Section(title: "Hesap", options: [Option(title: "Çıkış Yap", handler: { [weak self] in // ikincisine bunu
            DispatchQueue.main.async {
                self?.signOutTapped()
            }
        })]))
        
    }
    
    
    private func signOutTapped() { // çıkış yap a tıklanınca WelcomeViewController a yönlendiricek
       let alert = UIAlertController(title: "Çıkış Yap",
                                     message: "Emin Misiniz?",
                                     preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Çıkış Yap", style: .destructive, handler: { _ in
            AuthManager.shared.signOut { [weak self] signedOut in
                if signedOut {
                    DispatchQueue.main.async {
                        let navVC = UINavigationController(rootViewController: WelcomeViewController())
                        navVC.navigationBar.prefersLargeTitles = true
                        navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true, completion: {
                            self?.navigationController?.popToRootViewController(animated: false)
                        })
                    }
                }
            }
        }))
        present(alert, animated: true)
    }
    
    private func viewProfile() {
        let vc = ProfileViewController()
        vc.title = "Profile"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Call handler for cll
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler() // buraya tıklanınca viewProfile devreye giricek
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let model = sections[section]
        return model.title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    

}
