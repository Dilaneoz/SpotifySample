//
//  TabBarViewController.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 8.04.2023.
//



import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

      let vc1 = HomeViewController()
      let vc2 = SearchViewController()
      let vc3 = LibraryViewController()
    
        vc1.title = "Gözat"
        vc2.title = "Ara"
        vc3.title = "Kütüphane"
        // UITabBarController ımızı oluştururke bizim bir navigation controllerımızın olması gerek diyoruz. bunu scenedelegate in içinde tanımlamamız gerek
        vc1.navigationItem.largeTitleDisplayMode = .always // title lar daima görülsün
        vc2.navigationItem.largeTitleDisplayMode = .always
        vc3.navigationItem.largeTitleDisplayMode = .always
        
        let nav1 = UINavigationController(rootViewController: vc1) // navigation controller gitmek istediğimiz ekranları bir array içinde tutar. bunların yönetiminden sorumlu bir class tır
        let nav2 = UINavigationController(rootViewController: vc2)
        let nav3 = UINavigationController(rootViewController: vc3)
        
        nav1.navigationBar.tintColor = .label // bu bir label
        nav2.navigationBar.tintColor = .label
        nav3.navigationBar.tintColor = .label
        
        nav1.tabBarItem = UITabBarItem(title: "Gözat", image: UIImage(named: "home"), tag: 1) // tag kısmı : bi component e tag la bir etiket veriyoruz. o etiket üzerinden ilgili component e aynı storyboard id gibi erişebilmemizi sağlayan bir property. o etiket üzerinden buna eriş buna bu özelliği ata gibi şeyler de yapılabilir. yani bir id veriyoruz
        nav2.tabBarItem = UITabBarItem(title: "Ara", image: UIImage(named: "search"), tag: 1)
        nav3.tabBarItem = UITabBarItem(title: "Kütüphane", image: UIImage(named: "library"), tag: 1)
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        
        setViewControllers([nav1,nav2,nav3], animated: false)
        
        
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
