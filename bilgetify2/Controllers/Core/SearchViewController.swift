//
//  SearchViewController.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 8.04.2023.
//

import SafariServices
import UIKit

class SearchViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate  {


    let searchController: UISearchController = {
        let vc = UISearchController(searchResultsController: SearchResultsViewController())
        vc.searchBar.placeholder = "Songs, Artists, Albums"
        vc.searchBar.searchBarStyle = .minimal
        vc.definesPresentationContext = true
        return vc
    }()
    
    
    private let collectionView: UICollectionView = UICollectionView( // collection view oluşturuyoruz
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ -> NSCollectionLayoutSection? in // CompositionalLayout collectionview içinde hem sağa sola hem de yukarı aşağı hareket etmemizi sağlayan yapıdır
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))) //.fractionalWidth(1) verilen alanın genişliği neyse o kadar geniş olucak demek

            item.contentInsets = NSDirectionalEdgeInsets( // her bir item yukarıdan 2, soldan 7, aşağıdan 2, sağdan 7 pixel boşluk bıraksın
                top: 2,
                leading: 7,
                bottom: 2,
                trailing: 7
            )

            let group = NSCollectionLayoutGroup.horizontal( // yatayda gözükmesi için bir grup oluşturuyoruz
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(150)),
                subitem: item,
                count: 2 // iki tane grup olucak yani yan yana iki tane(grubu anlamak için collectionview yapısını incele)
            )

            group.contentInsets = NSDirectionalEdgeInsets( // konumlarını ayarlıyoruz
                top: 10,
                leading: 0,
                bottom: 10,
                trailing: 0
            )

            return NSCollectionLayoutSection(group: group)
        })
    )


    // MARK: - Lifecycle
    private var categories = [Category]()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        searchController.searchResultsUpdater = self // searchbar da yaptığım işlemlerden searchviewcontroller ın da haberdar olmasını sağlarız (tableview larda vs yapılan işlem)
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController // search bar ı eklemek için bunu yaparız
        
        view.addSubview(collectionView)
        collectionView.register(CategoryCollectionViewCell.self,
                                forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        
    
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        //singleton
        APICaller.shared.getCategories { [weak self] result in // sana bi result gelirse onu işle
            DispatchQueue.main.async {
                switch result { // gelen result ın içinde
                case .success(let categories): // case success ise bir kategori gelicek. gelen kategoriyi let categories e atadık. yani completion handler la arka plandan çekilen dataları let categories altında tutmak istedik
                    self?.categories = categories // bu categories i yukarıda tanımladığımız categories ile ilişkilendirdik
                    self?.collectionView.reloadData()
                case .failure(let error): // hata gelirse let error objesine atansın
                    print(error.localizedDescription) // ve ekrana yazdırılsın
                }
            }
        }
     
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

 
    // veri alınacak ve alınan veri searchResultsViewController a gönderilecek
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { // yazmış olduğumuz her karakterle bağdaşan şarkıyı aşağıda vericek olan fonksiyon
        
        print("searchText",searchText)
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController,
              let query = searchBar.text, // search bar ın içine girilen text i
              !query.trimmingCharacters(in: .whitespaces).isEmpty else { // boşluk karakterleri önemsemeden oluştur
            return
        }
        resultsController.delegate = self
        // resultsController.delegate = self
        APICaller.shared.search(with: searchText) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let results):
                    //print(results)
                    resultsController.update(with: results) // gelen json datayı yazmış olduğumuz kodlarla kendi modelimize uygun bir hale getirdik
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
       
    }
    
    func updateSearchResults(for searchController: UISearchController) {
    }
}


extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell( // her bir cell CategoryCollectionViewCell olucak
                withReuseIdentifier: CategoryCollectionViewCell.identifier,
                for: indexPath
        ) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        let category = categories[indexPath.row]
        cell.configure( // eğer cell oluştuysa o cell in cell.configure fonksiyonuna bir view model vericez. bu view model de bize yukarıdaki "let category = categories[indexPath.row]" buradan gelicek
            with: CategoryCollectionViewCellViewModel(
                title: category.name,
                artworkURL: URL(string: category.icons.first?.url ?? "") // ilk gelen elemanın url ini ver ya da boş bir değer ver
            )
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
       // HapticsManager.shared.vibrateForSelection()
        let category = categories[indexPath.row]
        let vc = CategoryViewController(category: category)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension SearchViewController : SearchResultsViewControllerDelegate {
    
    func didTapResult(_ result: SearchResult) {
        print("arama sonucu gelen verilerin detayına tıklandı")
        print(result)
        
        switch result {
        case .artist(let model) :
            guard let url = URL(string: model.external_urls["spotify"] ?? "") else {return }
            let vc = SFSafariViewController(url: url)
            present(vc,animated: true)
        case .album(let model):
            let vc = AlbumViewController(album: model)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated:true)
            
        case .track(model: let model):
            print("şarkı çalmaya başlayacak")
            PlaybackPresenter.shared.startPlayback( // güncel track neyse onu PlaybackPresenter.shared.startPlayback bu singleton objesi üzerinden track objesini göndericez(kafanın içindeki gözün içindeki renk gibi bu yapı). bu fonksiyona o anki tıklanan şarkı gönderiliyor. buradan PlaybackPresenter classındaki startPlayback fonksiyonuna geçiliyor
                from: self, track: model
            )
        case .playlist(model: let model):
          let vc = PlaylistViewController(playlist: model)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated:true)
            
        }
        
        
    }
    
    
}


