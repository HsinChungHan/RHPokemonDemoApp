//
//  PokeCardDetailCell.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/4/19.
//

import UIKit

class PokeCardDetailCell: UICollectionViewCell {
    lazy var imageView = makeImageView()
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
    }
}

private extension PokeCardDetailCell {
    func setupLayout() {
        [imageView].forEach { contentView.addSubview($0) }
        imageView.fillSuperView()
    }
}

extension PokeCardDetailCell {
    func configureCell(with cellModel: PokeCellModel) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self else { return }
            autoreleasepool {
                if let imageData = cellModel.imageData, let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
        }
    }
}

extension PokeCardDetailCell {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }
}
