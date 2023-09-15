//
//  AlbumViewController.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 9.04.2023.
//

import UIKit

class AlbumViewController: UIViewController {

    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )

            item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(60)
                ),
                subitem: item,
                count: 1
            )

            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .fractionalWidth(1)),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
            ]
            return section
        })
    )
    
    private let album : Album
    private var tracks = [AudioTrack]()
    private var viewModels = [AlbumCollectionViewCellViewModel]()

    
    init(album : Album) {
        self.album = album
        super.init(nibName : nil, bundle : nil)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.name
        
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        //section altına results
        collectionView.register(
            AlbumTrackCollectionViewCell.self,
            forCellWithReuseIdentifier: AlbumTrackCollectionViewCell.identifier
        )

        collectionView.register(
            AlbumHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: AlbumHeaderCollectionReusableView.identifier
        )
        
        // Do any additional setup after loading the view.
        collectionView.delegate = self // collection view ile ilgili işlemlerden album view controller da haberdar olsun
        collectionView.dataSource = self // collectionview a bir veri gelirse Album view controller haberdar olun
        
        self.albumleriGetir()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                            target: self,
                                                            action: #selector(tiklandi))
        
    }
    
    @objc func tiklandi()
    {

        let actionSheet = UIAlertController(title: album.name, message: "Actions", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Vazgeç", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Albümü Kaydet", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            APICaller.shared.saveAlbum(album: strongSelf.album) { success in
                if success {
                   // HapticsManager.shared.vibrate(for: .success)
                    NotificationCenter.default.post(name: .albumSavedNotification, object: nil)
                    print("albüm kaydedildi")
                }
                else {
                   // HapticsManager.shared.vibrate(for: .error)
                }
            }
        }))
        
        present(actionSheet,animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
  
    func albumleriGetir() {
        APICaller.shared.getAlbumDetails(for : album) { [weak self] result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let gelenAlbumDetayi):
                    print(gelenAlbumDetayi)
                    self?.tracks = gelenAlbumDetayi.tracks.items
                    //albüme ait şarkıların her biri için bir for döngüsü gibi compact map çalışır ve o an gelen track AlbumCollectionViewCelViewModel(nesnesini oluşuturur)
                   
                   // for(){
                       // self.viewModels.append(AlbumCollectionViewCellViewModel,AlbumCollectionViewCellViewModel,AlbumCollectionViewCellViewModel)
                   // }
                    self?.viewModels = gelenAlbumDetayi.tracks.items.compactMap({
                        AlbumCollectionViewCellViewModel(name: $0.name, artistName: $0.artists.first?.name ?? "-" )
                        })
                    print(self?.viewModels)
                    self?.collectionView.reloadData()
                   
                case .failure(let olusanHata):
                    print(olusanHata.localizedDescription)
                }
            }
            
        }
    }
}

extension AlbumViewController : UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AlbumTrackCollectionViewCell.identifier,
            for: indexPath
        ) as? AlbumTrackCollectionViewCell else {
            return UICollectionViewCell()
        }
        //o albume ait her bir şarkı AlbumCollectionViewCellViewModel nesnesini dönüştürüldü
        // ve her bir viewmodel nesnesi viewCelle configure fonksiyonu ile aktarıldı.
        cell.configure(with: viewModels[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        //collection view header ını
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: AlbumHeaderCollectionReusableView.identifier,
            for: indexPath
        ) as? AlbumHeaderCollectionReusableView,
        kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let headerViewModel = AlbumHeaderViewViewModel(name: album.name, ownerName: album.artists.first?.name, description: "Yayınlanma Tarihi : \(String.formattedDate(string : album.release_date))", artworkURL: URL(string : album.images.first?.url ?? ""))
        header.configure(with: headerViewModel)
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let index = indexPath.row
        let track = tracks[index]
        PlaybackPresenter.shared.startPlayback(from: self, track: track)
    }

    
    
    
}
extension AlbumViewController: AlbumHeaderCollectionReusableViewDelegate {
    func albumHeaderCollectionReusableViewDidTapPlayAll(_ header: AlbumHeaderCollectionReusableView) {
        print("yesil butona tıklandı")
        let tracksWithAlbum: [AudioTrack] = tracks.compactMap({ // içine AudioTrack tipinde veri alan bir array i o albume ait şarkılar şeklinde gönderiyoruz
            var track = $0
            track.album = self.album // track in içinde albume ait şarkılar olucak. bunları bir döngüyle nil olmayanları albume ekle diyecek
            return track
        })
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracksWithAlbum) // sonra bu şarkıları tracks: tracksWithAlbum buraya göndericek

    }
    
 
    
}
