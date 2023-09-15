//
//  PlaybackPresenter.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 9.04.2023.
//

import Foundation
import AVFoundation
import UIKit
// PlaybackPresenter üzerinden playerViewController ı çağırıyoruz. playerViewController da PlayerControlsView ı çağırıyor. ekranı ona göre çiziyor. 3 basamaklı bir şeyimiz var
// PlaybackPresenter PlayerViewController ı açıcak. bu iki class da butonlarımızı çizeceğimiz PlayerControlsView classını kullanıyolar
// PlaybackPresenter ekranı çizerken PlayerControlsView den faydalanıyor
protocol PlayerDataSource : AnyObject { // çalınacak şarkının adı subtitle ı ve görseli varsa onları bu PlayerDataSource ta kontrol ediyoruz.
    // biz bir protocol u kullandığımız zaman protocol un içindeki fonksiyon ya da değişkenleri tanımlamamız gerekiyor
    var songName : String? {get} // sadece okuma özelliği olan bir değişken
    var subTitle : String? {get} // sadece okuma özelliği olan bir değişken
    var imageURL : URL? {get}
}

final class PlaybackPresenter {
    static let shared = PlaybackPresenter() // her şarkı için bu class tan nesne devreye gireceği için singleton olmalı
    
    private var track : AudioTrack?
    private var tracks = [AudioTrack]()
    
    
    var playerVc : PlayerViewController?
    var player : AVPlayer? // ios un kendi player objesi
    var playerQueue : AVQueuePlayer? // gelen listeyi kuyruğa alıcak
    
    var index = 0
    
    var currentTrack : AudioTrack? {
        if let track = track, tracks.isEmpty { // bize gelen track şarkı listesi eğer isEmpty ise. yani bize bir liste geldiğinde liste boşsa güncel şarkıyı yazsın
            return track // var olan şarkıyı dönsün
        }
        
        else if let player = self.playerQueue, !tracks.isEmpty { // değilse o an listedeki şarkı neyse onun index numarasını dönsün. yani boş değilse ilk sırada 0. indexteki şarkıyı çalıcaz
            return tracks[index]
        }
        return nil
    }
    
    //kendisine gelen tek bir şarkı için çalışacak fonksiyon
    func startPlayback(from viewController : UIViewController, track : AudioTrack)
    { // bu fonksiyon PlayerViewController bir nesne oluşturucak. PlayerViewController a gideceğimizi söyliycez
      // şarkının içindeki değerleri track objesinin içine parametre olarak gelen değeri atıycaz. bu fonksiyon kendisine gelen şarkının urlini alıyor
        guard let url = URL(string: track.preview_url ?? "") else { // şarkının url i geliyor
            return
        }
        player = AVPlayer(url: url) // o url i player ın constructor ına veriyoruz. AVPlayer classının constructorına o anki şarkının url ini gönderiyoruz
        player?.volume = 0.5 // sonra volume le beraber çalmaya başlayacak. şarkının değerine 0.5 değerini atıyoruz

        
        self.track = track
        let vc = PlayerViewController()
        vc.title = track.name
        vc.delegate = self // bu bize butonlara tıklandığını vericek
        vc.dataSource = self
        //viewController.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        
        viewController.present(UINavigationController(rootViewController: vc), animated: true) { [weak self] in
            self?.player?.play()
        }
        self.playerVc = vc
        
    }
    
    
    func startPlayback( // bu da bir şarkı array i geldiği zaman çalışacak fonksiyon
        from viewController: UIViewController,
        tracks: [AudioTrack]
    ) {
        self.tracks = tracks
        self.track = nil

        print(self.tracks)
        //kendisine array şeklinde gelen listenin içinde
        //şarkının url nil olmayan kayıtları kuyruğa ekleyecek ekleyecek
        self.playerQueue = AVQueuePlayer(items: tracks.compactMap({
            guard let url = URL(string: $0.preview_url ?? "") else { // burası bir playlist gibi gelicek
                return nil
            }
            return AVPlayerItem(url: url) // sıradaki şarkının çalması için AVPlayerItem a o anki şarkının url ini gönderiyoruz
        }))
        self.playerQueue?.volume = 0.5
        self.playerQueue?.play()

        let vc = PlayerViewController()
        vc.dataSource = self
        vc.delegate = self
        viewController.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        self.playerVc = vc
    }
    
    
}


extension PlaybackPresenter: PlayerViewControllerDelegate {
    func didTapPlayPause() {
        if let player = player {
            if player.timeControlStatus  == .playing { // şarkı çalıyorsa
                player.pause() // durdur
            }
            else if player.timeControlStatus == .paused { // şarkı durmuşsa
                player.play() // çal
            }
        }
        else if let player = playerQueue { // tek bi şarkı da gelse bir şarkı listesi de gelse
            if player.timeControlStatus  == .playing { // kuyruktaki herhangi bir şarkının durumu çalıyorsa
                player.pause() // durdur
            }
            else if player.timeControlStatus == .paused { // duruyorsa
                player.play() // çal
            }
        }
    }
    
    func didTapForward() {
        if tracks.isEmpty { // track listesi boş değilse
            // Not playlist or album
            player?.pause()
        }
        else if let player = playerQueue { // kuyruktaki şarkıları çalmaya başla
            player.advanceToNextItem()
            index += 1
            print(index)
            playerVc?.refreshUI() // her şarkıda butonları tekrar çiz
        }
    }
    
    func didTapBackward() { // geri tuşuna basıldığında o anki çalan şarkı durur ve sıradaki şarkı çalar
        if tracks.isEmpty {
            // Not playlist or album
            player?.pause()
            player?.play()
        }
        else if let firstItem = playerQueue?.items().first {
            playerQueue?.pause()
            playerQueue?.removeAllItems()
            playerQueue = AVQueuePlayer(items: [firstItem]) // ilk sıradaki elemanı çalmaya başla
            playerQueue?.play()
            playerQueue?.volume = 0.5
        }
    }
    
    func didSlideSlider(_ value: Float) { // slider hareket ettikçe değişen değeri player ın volume değişkenine aktar
        //şarkıda istediğim saniyeye gidebilme
        player?.volume = value // volume ses açma
        
    }
    
    
}

extension PlaybackPresenter: PlayerDataSource { // buradan değerleri alıyoruz. bize gelen şarkının adını albumunu ve görselini kontrol edebileceğimiz bir extensionla delegatei  bu classa entegre ettik
    var songName: String? { // bu şarkı ismi bize nereden gelicek
        return currentTrack?.name
    }
    
    var subTitle: String? { // subTitle ın değerleri nereden gelicek
        return currentTrack?.artists.first?.name    }
    
    var imageURL: URL? { // imageURL in değerleri nereden gelicek
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
    
    
}
