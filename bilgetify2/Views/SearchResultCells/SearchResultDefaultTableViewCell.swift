//
//  SearchResultDefaultTableViewCell.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 8.04.2023.
//

import UIKit
import SDWebImage
// bunun içerisinde o cell de ne görünmesini istiyorsak onu yazıcaz
class SearchResultDefaultTableViewCell: UITableViewCell {
    
    static let identifier = "SearchResultDefaultTableViewCell" // mainde verilen identifier

    private let label: UILabel = { // cell içinde bir label oluşturuyoruz
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    private let iconImageViewe: UIImageView = { // cell in içinde bi imageview oluşturuyoruz
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label) // cell in içine label ı bu şekilde ekleriz
        contentView.addSubview(iconImageViewe)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator // cell in sonundaki ok işareti
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height-10 // bulunduğun alanın yüksekliğinin -10 u kadar yüksekliğin olsun
        iconImageViewe.frame = CGRect(
            x: 10, // x ten soldan 10 pixel boşluk bırak
            y: 5, // y den soldan 5 pixel boşluk bırak
            width: imageSize,
            height: imageSize
        )
        iconImageViewe.layer.cornerRadius = imageSize/2 // kenar
        iconImageViewe.layer.masksToBounds = true
        label.frame = CGRect(x: iconImageViewe.right+10, y: 0, width: contentView.width-iconImageViewe.right-15, height: contentView.height) // sağdan +10 pixel boşluk bırak, y den 0, width i contentView ın bulunduğu alanın genişliği - ikonun sağdan 15 i kadar, height da contentView ın height ı kadar olucak
    }

    override func prepareForReuse() { // bu fonksiyonla yukarıda oluşturduğumuz label ın içini temizle diyoruz. tekrar tekrar üzerine bişiler yazmasın diye
        super.prepareForReuse()
        iconImageViewe.image = nil
        label.text = nil
    }

    func configure(with viewModel: SearchResultDefaultTableViewCellViewModel) { // gelen dataları label a yazacak ve image a da imageview ın özelliğini atayacak
        label.text = viewModel.title // sana bir viewmodel vericem onun içindeki title değişkenini al label ın text ine yaz
        iconImageViewe.sd_setImage(with: viewModel.imageURL, completed: nil) // viewmodel den gelen image ın url ini al imageview ın içine yaz
    }

}

