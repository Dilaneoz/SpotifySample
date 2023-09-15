//
//  AlbumReusableHeaderView.swift
//  openspotify
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 23.09.2022.
//

import SDWebImage
import UIKit
protocol AlbumHeaderCollectionReusableViewDelegate: AnyObject { // play butonuna tıklandığında AlbumHeaderCollectionReusableView ile AlbumViewController ın haberleşebilmesi için bir protocol tanımladık
    func albumHeaderCollectionReusableViewDidTapPlayAll(_ header: AlbumHeaderCollectionReusableView)
}

final class AlbumHeaderCollectionReusableView: UICollectionReusableView { // burada header da görünmesini istediğimiz şeyler nelerse onları oluşturduk (label, image vs)
    static let identifier = "AlbumHeaderCollectionReusableView"

    weak var delegate: AlbumHeaderCollectionReusableViewDelegate? // bu protocol un tipinde de bir değişken tanımladık. bu delegate değişkeniyle de play butonuna basıldığında AlbumViewController ın içerisinde bu albumun paylaşılmasıyla ilgili bir pop up çıkarıcaz

    private let nameLabel: UILabel = { // albumun adı
        let label = UILabel() // UILabel class ından bir nesne oluşturduk
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .light)
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()

    private let playAllButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        let image = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        addSubview(ownerLabel)
        addSubview(playAllButton)
        playAllButton.addTarget(self, action: #selector(didTapPlayAll), for: .touchUpInside) // playAllButton a tıklandığında didTapPlayAll fonksiyonu devreye girsin
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

   

    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = height/1.8
        imageView.frame = CGRect(x: (width-imageSize)/2, y: 20, width: imageSize, height: imageSize) // y den 20 pixellik bi boşluk

        nameLabel.frame = CGRect(x: 10, y: imageView.bottom, width: width-20, height: 44)
        descriptionLabel.frame = CGRect(x: 10, y: nameLabel.bottom, width: width-20, height: 44)
        ownerLabel.frame = CGRect(x: 10, y: descriptionLabel.bottom, width: width-20, height: 44) // descriptionLabel ın bottom ında gözükücek

        playAllButton.frame = CGRect(x: width-80, y: height-80, width: 60, height: 60)
    }

    func configure(with viewModel: AlbumHeaderViewViewModel) {
        nameLabel.text = viewModel.name
        ownerLabel.text = viewModel.ownerName
        descriptionLabel.text = viewModel.description
        imageView.sd_setImage(with: viewModel.artworkURL, placeholderImage: UIImage(systemName: "photo"), completed: nil)
    }
    
    @objc private func didTapPlayAll() {
        delegate?.albumHeaderCollectionReusableViewDidTapPlayAll(self)
    }
    
}
