//
//  PokemonCard.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/4/17.
//

import UIKit

class PokemonCardCell: UICollectionViewCell {
    lazy var bgView = makeBackgroundView()
    lazy var nameLabel = makeNameLabel()
    lazy var imageView = makeImageView()
    lazy var gradientLayer = makeGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        nameLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        gradientLayer.frame = bgView.bounds
    }
}

extension PokemonCardCell {
    func setupLayout() {
        [bgView, imageView, nameLabel].forEach { contentView.addSubview($0) }
        bgView.fillSuperView(inset: .init(top: 16, left: 16, bottom: 0, right: 16))
        nameLabel.constraint(bottom: bgView.snp.bottom, leading: bgView.snp.leading, trailing: bgView.snp.trailing, padding: .init(top: 0, left: 0, bottom: 16, right: 0))
        imageView.constraint(bottom: nameLabel.snp.top, centerX: contentView.snp.centerX, padding: .init(top: 0, left: 0, bottom: 16, right: 0), size: .init(width: 200, height: 230))
        
    }
}

extension PokemonCardCell {
    func configureCell(with cellModel: PokeCellModel) {
        nameLabel.text = cellModel.name
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self else { return }
            autoreleasepool {
                if let imageData = cellModel.imageData, let image = UIImage(data: imageData) {
                    let bgColor = image.getDominantColor(brightnessAdjustment: 0.5)
                    DispatchQueue.main.async {
                        self.gradientLayer.colors = [UIColor.clear.cgColor, bgColor.cgColor, UIColor.clear.cgColor]
                        self.imageView.image = image
                        self.bgView.backgroundColor = bgColor
                    }
                }
            }
        }
        
    }
}

private extension PokemonCardCell {
    func makeNameLabel() -> UILabel {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }
    
    func makeBackgroundView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 20.0
        view.layer.addSublayer(gradientLayer)
        return view
    }
    
    func makeGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = CGRect.init(x: 0, y: 0, width: bounds.width - 32, height: bounds.height - 16)
        layer.locations = [0.0, 0.5, 1.0]
        return layer
    }
}
