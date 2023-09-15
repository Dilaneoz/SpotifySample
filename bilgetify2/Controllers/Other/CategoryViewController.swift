//
//  CategoryViewController.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 29.04.2023.
//

import UIKit

class CategoryViewController: UIViewController {
    let category: Category

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ -> NSCollectionLayoutSection? in
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))

        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(250)
            ),
            subitem: item,
            count: 2
        )
        group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        return NSCollectionLayoutSection(group: group)
    }))

    // MARK: - Init

    init(category: Category) { // constructor ına bi kategori göndericez
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private var playlists = [Playlist]() // o kategoriye ait bi playlist oluşturacak

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = category.name // constructor ına gelen category.name ini vericez
        view.addSubview(collectionView)
        view.backgroundColor = .systemBackground // kodla bi CategoryViewController oluşturduğumuz için background u olması gerekiyor
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            FeaturedPlaylistCollectionViewCell.self,
            forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier // FeaturedPlaylistCollectionViewCell tıklandığında bize bi playlist göstericek
        )
        collectionView.delegate = self
        collectionView.dataSource = self

        APICaller.shared.getCategoryPlaylists(category: category) { [weak self] result in // o kategoriye ait playlist i getir. git apicaller dan ilgili metoda o an gelen kategoriyi gönder
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    self?.playlists = playlists // ve arka planda bize gelen playlisti yukarıda tanımladığımız playlist ile eşleştir. o playlist e göre de aşağıdaki hangi satırda ne gösterileceği kaç tane olacağı vs çalışacak
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}

extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count // kaç kayıt veri göstericem
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell { // satırda gösterceğim şey ne olucak
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier, // FeaturedPlaylistCollectionViewCell oluşturucaksın diyoruz
            for: indexPath
        ) as? FeaturedPlaylistCollectionViewCell else {
            return UICollectionViewCell()
        }
        let playlist = playlists[indexPath.row]
        cell.configure(with: FeaturedPlaylistCellViewModel( // playlist in içinde kaç tane şarkı varsa hepsini tek tek viewmodel ile çizicek
            name: playlist.name,
            artworkURL: URL(string: playlist.images.first?.url ?? ""),
            creatorName: playlist.owner.display_name
        )
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = PlaylistViewController(playlist: playlists[indexPath.row]) // her tıklandığında PlaylistViewController a gidicek
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

}

