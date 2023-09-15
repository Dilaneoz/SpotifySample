//
//  LibraryToggleView.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 29.04.2023.
//

import UIKit

protocol LibraryToggleViewDelegate: AnyObject {
    func libraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView) // playlist e tıklanınca çalışmasını istediğimiz method. bu protokol un içindeki iki fonksiyonu kullanabilmek için LibraryViewController daki extensionda LibraryToggleViewDelegate tan türeticez
    func libraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView)
}

class LibraryToggleView: UIView {

    enum State { // kullanıcının hangisini seçtiğini kontrol etmek için bi enum tanımladık. state tipinde bi enum tanımladık
        case playlist // 1
        case album // 2
    }

    var state: State = .playlist // onu da default olarak playlist e atıyoruz. "case playlist case album" üstteki bu enumun içinde 1 ve 2 değerleri var aslında. yani state e sanki playlist seçilmiş gibi bir değer atadık. album seçilirse buradaki state değişkeninin değeri 2 olucak gibi düşünelim

    weak var delegate: LibraryToggleViewDelegate?

    private let playlistButton: UIButton = { // bu butona tıklandığında bi view çiziyor
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Playlists", for: .normal)
        return button
    }()

    private let albumsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Albümler", for: .normal)
        return button
    }()

    private let indicatorView: UIView = { // kütüphanede playlist ve albümler yazılarının altında yeşil bir çizgi oluşturucak
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(playlistButton)
        addSubview(albumsButton)
        addSubview(indicatorView)
        playlistButton.addTarget(self, action: #selector(didTapPlaylists), for: .touchUpInside)
        albumsButton.addTarget(self, action: #selector(didTapAlbums), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc private func didTapPlaylists() { // playlist seçildiyse bi titreme animasyonuyla delegate i kullanarak diğer viewcontroller ın bağlantısını sağladık
        state = .playlist // playliste tıklandıysa state imizin değişkeni 1 oluyor
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
        delegate?.libraryToggleViewDidTapPlaylists(self)
    }

    @objc private func didTapAlbums() { // albume tıklandıysa state değişkeni 2 oluyor
        state = .album
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
        delegate?.libraryToggleViewDidTapAlbums(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playlistButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        albumsButton.frame = CGRect(x: playlistButton.right, y: 0, width: 100, height: 40)
        layoutIndicator()
    }

    func layoutIndicator() { // yeşil çizgi şeklinde olan indicator un nasıl çizildiği
        switch state {
        case .playlist:
            indicatorView.frame = CGRect(
                x: 0,
                y: playlistButton.bottom,
                width: 100,
                height: 3
            )
        case .album:
            indicatorView.frame = CGRect(
                x: 100,
                y: playlistButton.bottom,
                width: 100,
                height: 3
            )
        }
    }

    func update(for state: State) {
        self.state = state
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
    }
}
