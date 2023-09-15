//
//  LibraryViewController.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 8.04.2023.
//

import UIKit

class LibraryViewController: UIViewController { // bunun içine playlist albumumuzu ve kodla scrollview oluşturucaz. scrollview akranın sağa sola kaymasını sağlayacak

    private let playlistsVC = LibraryPlaylistsViewController()
    private let albumsVC = LibraryAlbumsViewController()
    public var selectionHandler: ((Playlist) -> Void)?
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        return scrollView
    }()

    private let toggleView = LibraryToggleView() // sekmeleri çizmemizi sağlıyor. içinde iki farklı viewcontroller var. playlist ve album

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(toggleView)
        toggleView.delegate = self // toggleView da yaptığımız işlemlerden LibraryViewController da haberdar olması için delegate ile ikisini birleştiriyoruz 
        
        view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.width*2, height: scrollView.height)
        scrollView.delegate = self
        // Do any additional setup after loading the view.
        addChildren()
        updateBarButtons()
        
        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        }
    }
    
    
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top+55, // yukarıdan 55 pixel aşağı inicek
            width: view.width,
            height: view.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-55
        )
        toggleView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: 200,
            height: 55
        )
    }
    
    
    private func updateBarButtons() {
        switch toggleView.state { // state ten 1 gelirse sağ üstte artı butonu çıkıcak 2 gelirse buton gözükmesin. artıya basınca da playlistviewcontroller daki showCreatePlaylistAlert fonksiyonu devreye giricek
        case .playlist:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        case .album:
            navigationItem.rightBarButtonItem = nil
        }
    }

    
    
    @objc private func didTapAdd() {
        playlistsVC.showCreatePlaylistAlert()
    }

    
    private func addChildren() { // scrollView ın içine bi viewcontroller getirmek için bu fonksiyonda şunları yapıyoruz
        addChild(playlistsVC) // playlist i seçtiyse kullanıcı addChild fonksiyonu kendisine bi viewcontroller geldiğinde gidicek o scrollview ın içine ekliycek
        scrollView.addSubview(playlistsVC.view) // kendisine gelen playlistsVC ın view ını scrollView in addSubview ına ekliycek
        playlistsVC.view.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: scrollView.height) // playlistsVC ı scrollview ın tamamını kaplıycak şekilde ekliycek
        playlistsVC.didMove(toParent: self)
        
        addChild(albumsVC)
        scrollView.addSubview(albumsVC.view) // albumvc ı scrollview a ekliyoruz
        albumsVC.view.frame = CGRect(x: view.width, y: 0, width: scrollView.width, height: scrollView.height)
        albumsVC.didMove(toParent: self)

        
    }


}

extension LibraryViewController: LibraryToggleViewDelegate {
    func libraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView) {
        print("playliste tıklandı")
        scrollView.setContentOffset(.zero, animated: true)
        updateBarButtons()
    }
    
    func libraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView) { // albume tıklanırsa updateBarButtons fonksiyonunu çağır
        print("albümlere  tıklandı")
        scrollView.setContentOffset(CGPoint(x: view.width, y: 0), animated: true)
        updateBarButtons()
    }
    
    
}



extension LibraryViewController: UIScrollViewDelegate { // scrollview ın da  bi delegate i var
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= (view.width-100) { // scrollview x koordinatında hareket ettikçe albumviewcontroller ın animasyonlu bi şekilde hareket etmesini sağlayacak. albumler tıklanırsa -100 değerinde hareket edicek playlists tıklanırsa +100 değerinde hareket edicek. her yapıldığında da toggleView.update fonksiyonu animasyonlu bi şekilde layoutIndicator çizecek
            toggleView.update(for: .album) // scrollview da albume tıklandıysa animasyon halini göstericek yani toggleview ın içindeki update fonksiyonuna gidicek o da layoutindicator dediğimiz metodu çağırıcak ve o da playlist ya da albumun ekranını göstericek
            updateBarButtons()
        }
        else {
            toggleView.update(for: .playlist)
            updateBarButtons()
        }
    }
}



