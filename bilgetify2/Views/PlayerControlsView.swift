//
//  PlayerControlsView.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 15.04.2023.
//

import Foundation
import UIKit
// bu view dan türeyen bir class
protocol PlayerControlsViewDelegate: AnyObject {
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapBackwardsButton(_ playerControlsView: PlayerControlsView)
    func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float)
}

struct PlayerControlsViewViewModel {
    let title: String?
    let subtitle: String?
}

final class PlayerControlsView: UIView {

    private var isPlaying = true

    weak var delegate: PlayerControlsViewDelegate? // descriptionLabel ın bottom ında gözükücek
    // PlayerViewController ın içindeki delegate e erişmek için bu delegate adında bir değişken tanımlıyoruz
    
    private let volumeSlider: UISlider = { // kodla slider oluşturuyoruz
        let slider = UISlider()
        slider.value = 0.5
        return slider
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Şarkı"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Subtitle "
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private let backButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "backward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "forward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()

    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "pause", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame) // türediği class ın constructor ına kendisini veriyoruz
        backgroundColor = .clear // clear : bulunduğu şey neyse background u da öyle olur
        addSubview(nameLabel)
        addSubview(subtitleLabel)

        addSubview(volumeSlider)
        volumeSlider.addTarget(self, action: #selector(didSlideSlider(_:)), for: .valueChanged)

        addSubview(backButton)
        addSubview(nextButton)
        addSubview(playPauseButton)

        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)

        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc func didSlideSlider(_ slider: UISlider) {  // şarkının neresinde olunduğunun hareket çubuğu
        let value = slider.value
        delegate?.playerControlsView(self, didSlideSlider: value) // delegate vasıtasıyla yukarıdaki protocolun içindeki fonksiyonları kullanmak isteyenlere bu delegate aracılığıyla erişebilmelerini sağlıyoruz
    }

    @objc private func didTapBack() {
        delegate?.playerControlsViewDidTapBackwardsButton(self)
    }

    @objc private func didTapNext() {
        delegate?.playerControlsViewDidTapForwardButton(self)
    }

    @objc private func didTapPlayPause() {
        self.isPlaying = !isPlaying // eğer şarkı çalıyorsa
        delegate?.playerControlsViewDidTapPlayPauseButton(self) // bu fonksiyona view ın kendisini vericez

        // Update icon
        let pause = UIImage(systemName: "pause", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular)) // pause image ını bu bu değişkene atadık
        let play = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular)) // play i buna

        playPauseButton.setImage(isPlaying ? pause : play, for: .normal) // eğer pause durumundaysa play aktif olsun, play e bastıysa da pause aktif olsun
    }

    override func layoutSubviews() { // butonlar view ın neresinde gözükecek
        super.layoutSubviews()
        nameLabel.frame = CGRect(x: 0, y: 0, width: width, height: 50)
        subtitleLabel.frame = CGRect(x: 0, y: nameLabel.bottom+10, width: width, height: 50)

        volumeSlider.frame = CGRect(x: 10, y: subtitleLabel.bottom+20, width: width-20, height: 44)

        let buttonSize: CGFloat = 60
        playPauseButton.frame = CGRect(x: (width - buttonSize)/2, y: volumeSlider.bottom + 30, width: buttonSize, height: buttonSize)
        backButton.frame = CGRect(x: playPauseButton.left-80-buttonSize, y: playPauseButton.top, width: buttonSize, height: buttonSize)
        nextButton.frame = CGRect(x: playPauseButton.right+80, y: playPauseButton.top, width: buttonSize, height: buttonSize)
    }

    func configure(with viewModel: PlayerControlsViewViewModel) {
        nameLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
    }
}
