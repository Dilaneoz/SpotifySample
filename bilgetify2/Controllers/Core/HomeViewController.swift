//
//  HomeViewController.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 8.04.2023.
//

import UIKit
// burada SearchViewController da yaptığımız gibi yapmış olduğumuz aramaya göre albüm mü yoksa playlist mi gelicek onu organize ediyoruz. collectionvew ı section lara bölücez
// bu uygulama çalıştığı zaman 3 tane servise gitmek gerekicek. yeni yayınlananlar(New Releases) bi servisten gelicek, size özel(Featured Playlists) kısmı ayrı ve tavsiye edilenler(Recommended Tracks) kısmı ayrı bi servisten gelicek
enum BrowseSectionType {
    case newReleases(viewModels: [NewReleasesCellViewModel]) // 1
    case featuredPlaylists(viewModels: [FeaturedPlaylistCellViewModel]) // 2
    case recommendedTracks(viewModels: [RecommendedTrackCellViewModel]) // 3

    var title: String {
        switch self {
        case .newReleases:
            return "Yeni Yayınlananlar" // newReleases seçilirse Yeni Yayınlananlar yazsın
        case .featuredPlaylists:
            return "Size Özel"
        case .recommendedTracks:
            return "Tavsiye Edilenler"
        }
    }
}

class HomeViewController: UIViewController {

    // aşağıdaki servislerden çektiğimiz datalar buraya atanacak. içine album, playlist, AudioTrack. AudioTrack tipinde veri alan arraylara atanacak. sonra aşağılarda bu array leri configureModels ile her birini viewmodellere taşıycaz
    private var newAlbums: [Album] = []
    private var playlists: [Playlist] = []
    private var tracks: [AudioTrack] = []
    private var sections = [BrowseSectionType]() // sections searchresult taki gibi çalışacak. kendisine gelen enum daki tip neyse ona göre section ları oluşturucaz. o section ların içinde array in içinde array mantığıyla verileri tutmamızı sağlıycak
    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in // UICollectionViewCompositionalLayout, collectionview ın kendi içinde hem aşağı hem yukarı hareket edebilmesini sağlayan bi layout türü
            return HomeViewController.createSectionLayout(section: sectionIndex)
        }
    )

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gözat"
        view.backgroundColor = .systemBackground // sistemin varsayılan rengi
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .done,
            target: self,
            action: #selector(didTapSettings)
        )
        configureCollectionView()
        fetchData()
        addLongTapGesture()
    
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }


    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self,
                                forCellWithReuseIdentifier: "cell")
        collectionView.register(NewReleaseCollectionViewCell.self,
                                forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(FeaturedPlaylistCollectionViewCell.self,
                               forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
       collectionView.register(RecommendedTrackCollectionViewCell.self,
                                forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.register(
            TitleHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TitleHeaderCollectionReusableView.identifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
    }

    
    @objc func didTapSettings() {
        let vc = SettingsViewController()
        vc.title = "Settings"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func fetchData() { // 3 tane asenkron fonksiyon çalışmasını sonra işleri bitince gruptan ayrılmasını istiycez
        let group = DispatchGroup() // asenkron olarak birden fazla api isteği attığımızda kullanırız. 3 servisle aralarında bi şey kuruyoruz
        group.enter()
        group.enter()
        group.enter()
        var newReleases: NewReleasesResponse? // 3 servisten gelen response ları burada oluşturuyoruz
        var featuredPlaylist: FeaturedPlaylistsResponse?
        var recommendations: RecommendationsResponse?
        
        // New Releases
        APICaller.shared.getNewReleases { result in // servisten gelen datalara göre yeni yayınlananlar
            defer { // defer ertelemek anlamına gelir.
                group.leave() // sonra bu kod çalışacak. gruptan ayrılmasını istiyoruz
            }
            switch result { // defer ile beraber önce bu kod bloğu çalışacak
            case .success(let model):
                newReleases = model // servisten gelen data neyse onunla eşitliyoruz
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        // Featured Playlists
        APICaller.shared.getFeaturedPlaylists { result in
            defer {
                group.leave()
            }

            switch result {
            case .success(let model):
                featuredPlaylist = model
            case .failure(let error):
                print(error.localizedDescription)

            }
        }
        
        
        // Recommended Tracks
        APICaller.shared.gerRecommendedGenres { result in // burada gerRecommendedGenres servisi çağırılıyor
            switch result {
            case .success(let model):
                let genres = model.genres
                var seeds = Set<String>() // o servisten seeds dediğimiz yapı geliyor
                while seeds.count < 5 {
                    if let random = genres.randomElement() {
                        seeds.insert(random)
                    }
                }

                APICaller.shared.getRecommendations(genres: seeds) { recommendedResult in // yukarıda bi servis çağırılıyor o servisten gelen dataya göre de burada başka bi servis çağırılıyor(getRecommendations). verileri çekerken detaylarını da çekiyoruz
                    defer {
                        group.leave()
                    }

                    switch recommendedResult {
                    case .success(let model):
                        recommendations = model

                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        group.notify(queue: .main) { // çekmiş olduğumuz dataları burada toparlıycaz. kuyrukta 3 tane asenkron çağırdığımız fonksiyonlardan gelen değerlerden yeni yayınlananların albumlerini ve onun içindeki item ları newAlbums,playlists,tracks objelerine/arraylarine dolduruyoruz
            guard let newAlbums = newReleases?.albums.items,
                  let playlists = featuredPlaylist?.playlists.items,
                  let tracks = recommendations?.tracks else {
                fatalError("Models hatalı")
            }
            self.configureModels( // array leri configureModels ile her birini viewmodellere taşıycaz. yani array lerin içindeki elemanları(newAlbums vs) configureModels dediğimiz viewmodelle ilişkilendiriyoruz. bunun içinde aslında restapi den çekmiş olduğumuz veriler var(20 tane 50 tane vs). bu array lerin içindeki verileri de NewReleasesCellViewModel ile ilişkilendirilmesini sağlıycaz
                newAlbums: newAlbums,
                playlists: playlists,
                tracks: tracks
            )
        }
    }
    
    private func configureModels( // yukarıdaki 3 fonksiyonun işi bittikten sonra(datalar çekildikten sonra) gelen dataları aynı bi notification center(bildirim) gibi viewmodellere doldurucaz. sonra bu viewmodelleri de ilgili cell lere taşıycaz
        newAlbums: [Album],
        playlists: [Playlist],
        tracks: [AudioTrack]
    ) {
        self.newAlbums = newAlbums
        self.playlists = playlists
        self.tracks = tracks
        
        // home sayfasında newReleases section ı içinde göstermek için önce viewmodel i atıycaz. bu viewmodel i atamakla beraber birazdan collectionviewcell i de çekmiş olduğumuz datalarla her bir cell de, bu viewmodel içindeki verileri o cell in içindeki label lara imageview ların içine doldurucaz. configureModels in yaptığı aslında bu. kendisine gelen veri kümesiyle önce viewmodellere gelen dataları doldurucak sonra bunları ilgili section ların içine ekliycek
        // newReleases içindeki her bir elemanı al, içinde boş eleman olup olmadığını kontrol et, sonrasında içine NewReleasesCellViewModel tipinde veri alan bir array in içine ekle. mesela o an gelen albumun ismini resmini vs
        sections.append(.newReleases(viewModels: newAlbums.compactMap({ // compactMap, biz ona bi veri kümesi verdiğimizde o veri kümesi içindeki elemanlarda nil olmayan değerleriyle beraber tekrar bizim istediğimiz arka plandaki bi array in içine bunları dolduruyor
            return NewReleasesCellViewModel( // arrayde bu var NewReleasesCellViewModel. sana verdiğim array in içindeki elemanların nil olup olmadığını kontrol et, sonra bunları NewReleasesCellViewModel ile ilişkilendirerek içine viewmodel tipinde veri alan bi array in içine ekle
                name: $0.name,
                artworkURL: URL(string: $0.images.first?.url ?? ""),
                numberOfTracks: $0.total_tracks,
                artistName: $0.artists.first?.name ?? "-"
            )
        })))

        sections.append(.featuredPlaylists(viewModels: playlists.compactMap({
            return FeaturedPlaylistCellViewModel(
                name: $0.name,
                artworkURL: URL(string: $0.images.first?.url ?? ""),
                creatorName: $0.owner.display_name
            )
        })))

        sections.append(.recommendedTracks(viewModels: tracks.compactMap({
            return RecommendedTrackCellViewModel(
                name: $0.name,
                artistName: $0.artists.first?.name ?? "-",
                artworkURL: URL(string: $0.album?.images.first?.url ?? "")
            )
        })))
        print(sections)
        collectionView.reloadData()
    }
    
    
    private func addLongTapGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        collectionView.isUserInteractionEnabled = true
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) { // ilgili şarkıya uzun basınca Playlist'e eklemek ister misiniz? diye sorulacak
        guard gesture.state == .began else {
            return
        }

        let touchPoint = gesture.location(in: collectionView)
        print("point: \(touchPoint)")

        guard let indexPath = collectionView.indexPathForItem(at: touchPoint),
              indexPath.section == 2 else {
            return
        }

        let model = tracks[indexPath.row]

        let actionSheet = UIAlertController(
            title: model.name,
            message: "Playlist'e eklemek ister misiniz?",
            preferredStyle: .actionSheet
        )

        actionSheet.addAction(UIAlertAction(title: "Vazgeç", style: .cancel, handler: nil))

        actionSheet.addAction(UIAlertAction(title: "Playlist'e Ekle", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let vc = LibraryPlaylistsViewController()
                vc.selectionHandler = { playlist in
                    APICaller.shared.addTrackToPlaylist(
                        track: model,
                        playlist: playlist
                    ) { success in
                        print("Playlist'e başarıyla eklendi: \(success)")
                    }
                }
                vc.title = "Playlist seçiniz"
                self?.present(UINavigationController(rootViewController: vc),
                              animated: true, completion: nil)
            }
        }))

        present(actionSheet, animated: true)
    }
}
// yukarıda çekmiş olduğumuz verileri viewmodel a atadık. viewmodel le beraber her bir sectionda neler var, collectionview ın içinde kaç kayıt veri var, her bir satırda neler olucak onu söyliycez
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    //kaç kategori olacak
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    //her bir kategoride kaçar kayıt gösterilecek gösterilecek
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(sections.count)
        let type = sections[section] // her cell de olduğu gibi her section içinde de gizli bi for var
        switch type {
            //o anki gelen section daki kayıt sayısı
        case .newReleases(let viewModels):
            return viewModels.count // gelen tip newReleases ise orda kaç tane ilgili viewmodel eleman/kayıt varsa göster
        case .featuredPlaylists(let viewModels):
            //o anki gelen section daki kayıt sayısı
            return viewModels.count
        case .recommendedTracks(let viewModels):
            //o anki gelen section daki kayıt sayısı
            return viewModels.count
        }
    }
    
    //her bir kategoride gelen kayıt sayısanı göre her bir kaydın görünümü ne olacak
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
        switch type {
        case .newReleases(let viewModels): // type ı newReleases seçildiyse newReleases cell i devreye girsin,
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NewReleaseCollectionViewCell.identifier,
                for: indexPath
            ) as? NewReleaseCollectionViewCell else {
                return UICollectionViewCell()
            }
            let viewModel = viewModels[indexPath.row] // o cell e de verilerin aktarılabilmesi için ilgili viewmodel deki veriler eklensin
            cell.configure(with: viewModel)
            return cell
        case .featuredPlaylists(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier,
                for: indexPath
            ) as? FeaturedPlaylistCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        case .recommendedTracks(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier,
                for: indexPath
            ) as? RecommendedTrackCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        }
    }
    static func createSectionLayout(section: Int) -> NSCollectionLayoutSection { // createSectionLayout, kendisine gelen section mesela 0 ise onun genişliğini yüksekliğini ayarlıycak
        let supplementaryViews = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(50)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        // section ların içine grupları grupların içine de item ları ekliyoruz
        switch section {
            //yeni yayınlalanların ekranı burada çiziliyorz
        case 0:
            // Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2) // her bir item için yukarıdan aşağıdan sağdan soldan 2 pixellik boşluk bırakıcak
            
            // Vertical group in horizontal group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(390)
                ),
                subitem: item,
                count: 3 // alt alta 3 kayıt göstericek
            )
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .absolute(390)
                ),
                subitem: verticalGroup,
                count: 1 // burada 1 kayıt gösterilecek
            )
            
            // Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = supplementaryViews
            return section
            //size özelin ekran tasarımı burada yapılıyor
        case 1:
            // Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(200)
                )
            )

            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(400)
                ),
                subitem: item,
                count: 2
            )

            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(400)
                ),
                subitem: verticalGroup,
                count: 1
            )

            // Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryViews
            return section
            
        case 2:
            // Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )

            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(80)
                ),
                subitem: item,
                count: 1
            )

            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = supplementaryViews
            return section
        default:
            // Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(390)
                ),
                subitem: item,
                count: 1
            )
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = supplementaryViews
            return section
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        //HapticsManager.shared.vibrateForSelection()
        let section = sections[indexPath.section]
        switch section {
        case .featuredPlaylists:
            let playlist = playlists[indexPath.row]
            let vc = PlaylistViewController(playlist: playlist)
            vc.title = playlist.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .newReleases:
            let album = newAlbums[indexPath.row]
            let vc = AlbumViewController(album: album)
            vc.title = album.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .recommendedTracks:
            let track = tracks[indexPath.row]
            PlaybackPresenter.shared.startPlayback(from: self, track: track)
        }
    }
    
}
