//
//  PlayerViewController.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 15.04.2023.
//

import UIKit
import SDWebImage
// PlayerViewController SearchViewController ın üzerinde açılıyor
// PlayerViewController ile presenter haberleşecek. presenter da ekranı çizerken PlayerControlsView ile haberleşicek. o yüzden onları bu delegatelerle tanımladık
// PlayerViewControllerla PlaybackPresenter arasında bir bağ kurmak için (her zaman delegate design patterninde yaptığımız gibi) class ın içinde bir protocol tanımlıyoruz, bu protocol tipinde bir değişken tanımlıyoruz ve bu delagatele de haberleşmek istediğimiz class la bu delegate üzerinden haberleşiyoruz
// delegate : iki class arasında haberleşmek için bir protocol tanımlıyoruz. sonra o protocol tipinde bir değişken tanımlıyoruz. sonra o değişkeni de haberleşmek istediğimiz clasta kullanıyoruz
protocol PlayerViewControllerDelegate : AnyObject { // buradaki delegatelere PlaybackPresenter ile PlayerViewController arasında bir ilişki kurucaz.
    func didTapPlayPause() // butona tıklandı mı
    func didTapForward() // ileri butonuna mı tıklandı
    func didTapBackward() // geri tuşuna mı tıklandı
    func didSlideSlider(_ value : Float) // slider hareket mi etti
}


class PlayerViewController: UIViewController {

    weak var dataSource: PlayerDataSource? // PlayerViewController PlaybackPresenter daki PlayerDataSource delegate ini kullanıyor. bunu kullandığı için PlayerViewController kendisine gelicek trackle ilgili tüm bilgilere PlaybackPresenter daki delegate vasıtasıyla erişiyor. PlayerDataSource, PlaybackPresenter daki trackle ilgili  bilgileri tutabileceğimiz başka bir delegatetir
    weak var delegate: PlayerViewControllerDelegate?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    //buttonları çizecek controlview
    private let controlsView = PlayerControlsView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(controlsView) // sayfa yüklenirken controlsView ı PlayerViewController ın ana viewına ekle diyoruz. controlsView ın içinde ekranı çizen butonlar var. PlayerViewController da ekranı çizicek olan controlsView ile haberleşmek gerekiyor
        view.addSubview(imageView)
        controlsView.delegate = self // PlayerViewController daki butonlara bu controlsView.delegate ile erişiyoruz
        // Do any additional setup after loading the view.
        configureBarButtons()
        configure()
        
    }
    
    private func configure() { // private olduğu için diğer classlardan erişilemiyor
        print(dataSource?.imageURL)
        imageView.sd_setImage(with: dataSource?.imageURL, completed: nil) // SearchViewController dan tıkladığımız track in bilgileri buraya gelicek
        controlsView.configure(
            with: PlayerControlsViewViewModel( // burada view ı dolduracak olan viewmodelimiz var.  bu viewmodel e data SearchViewController dan geliyor. tıklanmış olan şarkıların bütün bilgilerini bu viewmodel aracılığıyla buraya taşıyoruz. bu viewmodelin içindeki verileri de controlsview deki songname, görsel ve subtitle a taşıyoruz
                title: dataSource?.songName, // SearchViewController dan tıkladığımız track in bilgileri buraya gelicek
                subtitle: dataSource?.subTitle
            )
        )
    }
    
    func refreshUI() // configure un diğer classlardan da erişilebilir olması için refreshUI diye bir fonksiyon tanımlıyoruz
    {
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        imageView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.width)
        controlsView.frame = CGRect(
            x: 10,
            y: imageView.bottom+10,
            width: view.width-20,
            height: view.height-imageView.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-15
        )

    }
    
    private func configureBarButtons() { // butonlar oluşturmayla alakalı kodlar
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapAction() {
        // Actions
    }

 
}

extension PlayerViewController : PlayerControlsViewDelegate { // PlayerControlsView daki protocolu kullanıyoruz. bu protocol vasıtasıyla da PlayerControlsView ile haberleşicek yani o butonlara erişebilcek
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapPlayPause()
    }
    
    func playerControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapForward()
    }

    func playerControlsViewDidTapBackwardsButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapBackward()
    }
    
    func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float) {
        delegate?.didSlideSlider(value)
    }
    
    
}
