//
//  PropertyView.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/4/27.
//

import UIKit

class PropertyView: UIView {
    struct PropertyViewModel {
        let icon: String
        let title: String
        let value: String
    }
    
    lazy var icon = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var valueLabel = makeValueLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PropertyView {
    func configureView(with model: PropertyViewModel) {
        icon.image = UIImage(named: model.icon)?.withRenderingMode(.alwaysTemplate)
        titleLabel.text = model.title
        valueLabel.text = model.value
    }
}

fileprivate extension PropertyView {
    func setupLayout() {
        [icon, titleLabel, valueLabel].forEach {
            addSubview($0)
        }
        icon.constraint(top: snp.top, leading: snp.leading, size: .init(width: 28, height: 28))
        titleLabel.constraint(top: icon.snp.top, leading: icon.snp.trailing, centerY: icon.snp.centerY, padding: .init(top: 0, left: 8, bottom: 0, right: 0))
        valueLabel.constraint(top: icon.snp.bottom, bottom: snp.bottom, leading: snp.leading, trailing: snp.trailing, padding: .init(top: 16, left: 0, bottom: 0, right: 0))
    }
}

fileprivate extension PropertyView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .lightGray
        label.textAlignment = .left
        return label
    }
    
    func makeValueLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .semibold)
        label.textColor = .white
        label.alpha = 0.8
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.layer.borderWidth = 1.0
        label.layer.borderColor = UIColor.lightGray.cgColor
        return label
    }
}
