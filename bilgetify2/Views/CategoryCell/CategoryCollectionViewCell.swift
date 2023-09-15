//
//  CategoryCollectionViewCell.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 8.04.2023.
//

import Foundation
import UIKit
import SDWebImage

class CategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "CategoryCollectionViewCell" // maindeki identifier

    private let imageView: UIImageView = { // cell in içindeki imageview
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.image = UIImage(systemName: "music.quarternote.3", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .regular))
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()

    private let colors: [UIColor] = [ // renkleri ekliyoruz
        .systemPink,
        .systemBlue,
        .systemPurple,
        .systemOrange,
        .systemGreen,
        .systemRed,
        .systemYellow,
        .darkGray,
        .systemTeal
    ]

    override init(frame: CGRect) { // label ve imageview i de bu cell in içinde gösterebilmek için bu fonksiyonu yazıyoruz
        super.init(frame: frame) // super.init demek türediğim sınıfın constructor ına oluşturucağım frame i gönderiyorum demek
        contentView.layer.cornerRadius = 8 // kenarlara biraz ovallik veriyoruz
        contentView.layer.masksToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        imageView.image = UIImage(systemName: "music.quarternote.3", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .regular))
    }

    override func layoutSubviews() { // label ve imageview ın konumlarını oluşturuyoruz
        super.layoutSubviews()

        label.frame = CGRect(x: 10, y: contentView.height/2, width: contentView.width-20, height: contentView.height/2) // soldan 10 pixel boşluk bırak, genişlik contentview ın genişliğinin -20 si olsun
        imageView.frame = CGRect(x: contentView.width/2, y: 10, width: contentView.width/2, height: contentView.height/2)
    }

    func configure(with viewModel: CategoryCollectionViewCellViewModel) {
        label.text = viewModel.title
        imageView.sd_setImage(with: viewModel.artworkURL, completed: nil) // sanırım aşağı indikçe yükleniyor işareti gözükmesin dedik
        contentView.backgroundColor = colors.randomElement() // yukarıda eklediğimiz renkleri her bir cell de random bir şekilde göstericek
    }
}

