//
//  SearchResultsViewController.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 8.04.2023.
//


import UIKit

struct SearchSection {
    let title: String
    let results: [SearchResult]
}

protocol SearchResultsViewControllerDelegate: AnyObject {
    func didTapResult(_ result : SearchResult)
}


// searchviewcontrollerda(searchviewcontroller interactor gibi çalışıcak) arama sonucunda çıkan dataları buraya, SearchResultsViewController a, aktarıcaz
class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate : SearchResultsViewControllerDelegate?
    
    
    private var sections: [SearchSection] = [] // restapi den gelen verileri(albumler, playlistler vs) kategorili şekilde gösterebilmek için bu array e ihtiyaç var
    private let tableView : UITableView = { // kodla bir tableview oluştur diyoruz

            let abc = UITableView(frame : .zero, style: .grouped) // tüm ekranı kaplasın, gruplayarak göster
            abc.backgroundColor = .systemBackground
        abc.register(SearchResultDefaultTableViewCell.self, forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier)
        abc.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
            return abc

        }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds // bulunduğu alanın genişliği kadar bir tableview getirecek
    }

    func update(with results: [SearchResult]) { // restapi den çekmiş olduğumuz array in içindeki array lere göre tableview ımı hem kategorili şekilde göstermem gerek hem de o kategoriye ait dataları da gösteriyoruz
        let artists = results.filter({
            switch $0 {
            case .artist: return true
            default: return false
            }
        })

        let albums = results.filter({
            switch $0 {
            case .album: return true
            default: return false
            }
        })

        let tracks = results.filter({
            switch $0 {
            case .track: return true
            default: return false
            }
        })

        let playlists = results.filter({
            switch $0 {
            case .playlist: return true
            default: return false
            }
        })

        self.sections = [ // en yukarda boş oluşturduğum section ın içine aşağıdakileri ekliyoruz
            SearchSection(title: "Songs", results: tracks),
            SearchSection(title: "Artists", results: artists),
            SearchSection(title: "Playlists", results: playlists),
            SearchSection(title: "Albums", results: albums)
        ]

        tableView.reloadData()
        tableView.isHidden = results.isEmpty
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count // o an gelen section ın içindeki count kadar
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = sections[indexPath.section].results[indexPath.row] // her bir section ın içindeki result lar sırayla gelicek

        switch result { // gelen verinin içindeki eleman
        case .artist(let artist): // artist ise, gelen artisti göster
            guard let cell = tableView.dequeueReusableCell( // gelen datayla o an sıradaki eleman neyse onun için bir cell oluşturuyoruz o cell in SearchResultDefaultTableViewCell olduğundan emin oluyoruz
                withIdentifier: SearchResultDefaultTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultDefaultTableViewCell else {
                return  UITableViewCell()
            }
            let viewModel = SearchResultDefaultTableViewCellViewModel( // sonrasında gelen datayla bunu bağlıyoruz
                title: artist.name,
                imageURL: URL(string: artist.images?.first?.url ?? "")
            )
            cell.configure(with: viewModel)
            return cell
        case .album(let album): // gelen verinin içindeki eleman album ise gelen albumu goster
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultSubtitleTableViewCell else {
                return  UITableViewCell()
            }
            let viewModel = SearchResultSubtitleTableViewCellViewModel(
                title: album.name,
                subtitle: album.artists.first?.name ?? "",
                imageURL: URL(string: album.images.first?.url ?? "")
            )
            cell.configure(with: viewModel)
            return cell
        case .track(let track): // gelen verinin içindeki eleman track ise gelen tracki goster
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultSubtitleTableViewCell else {
                return  UITableViewCell()
            }
            let viewModel = SearchResultSubtitleTableViewCellViewModel(
                title: track.name,
                subtitle: track.artists.first?.name ?? "-",
                imageURL: URL(string: track.album?.images.first?.url ?? "")
            )
            cell.configure(with: viewModel)
            return cell
        case .playlist(let playlist): // gelen verinin içindeki eleman playlist ise gelen playlisti goster
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultSubtitleTableViewCell else {
                return  UITableViewCell()
            }
            let viewModel = SearchResultSubtitleTableViewCellViewModel(
                title: playlist.name,
                subtitle: playlist.owner.display_name,
                imageURL: URL(string: playlist.images.first?.url ?? "")
            )
            cell.configure(with: viewModel)
            return cell
        }
    }
  
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title // SearchSection daki yazıları("Songs","Artists","Playlists","Albums") her bir section da göstericek
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //ilgili tableview ın ilgili kategori altındaki kayıtlardan hangi sıradaki elemana
        // tıkladık bilgisini burada alıyoruz
        print(indexPath.row)
        print(sections[indexPath.section].results.count)
        let result = sections[indexPath.section].results[indexPath.row]
        delegate?.didTapResult(result)

    }
}
