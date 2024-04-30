//
//  PokemonViewController.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/26.
//

import RHInterface
import RHUIComponent
import SVGKit
import UIKit

class PokemonViewController: UIViewController {
    let networkService = PokemonsNetworkRemoteService()
    let codableStoreService = PokemonsCodableStoreService()
    let actorCodablePokemonsStoreService = PokemonsActorCodableStoreService()
    let actorCodablePokemonStoreService = PokemonActorCodableStoreService()
    let actorCodableImageDataStoreService = PokemonActorCodableImageStoreService()
    lazy var respository = PokemonsRepository(networkService: networkService, codableStoreService: codableStoreService, actorCodableStoreService: actorCodablePokemonStoreService, actorCodablePokemonsStoreService: actorCodablePokemonsStoreService, actorCodableImageDataStoreService: actorCodableImageDataStoreService)
    
    lazy var useCase: PokemonsUseCaseProtocol = MainQueueDispatcherDecorator(decoratee: PokemonsUseCase(repository: respository))
    lazy var viewModel = PokemonViewModel(useCase: useCase)
    
    lazy var overallStackView = makeStackView()
    lazy var imageView = makeImageView()
    lazy var idLabel = makeLabel(with: "ID: ")
    lazy var nameLabel = makeLabel(with: "Name: ")
    lazy var weightLabel = makeLabel(with: "Weight: ")
    lazy var heightLabel = makeLabel(with: "Height: " )
    let bgImageView = UIImageView(image: .init(named: "background"))
    init(pokemonName: String) {
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
        viewModel.pokemonName = pokemonName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        viewModel.loadPokemon()
    }
}

// MARK: - PokemonViewModelDelegate
extension PokemonViewController: PokemonViewModelDelegate {
    func pokemonViewModel(with pokemonViewModel: PokemonViewModel, didLoad pokemonImage: UIImage) {
        imageView.image = pokemonImage
    }
    
    func pokemonViewModel(with pokemonViewModel: PokemonViewModel, didUpdatePokemon name: String) {
        navigationItem.title = name
    }
    
    func pokemonViewModel(with pokemonViewModel: PokemonViewModel, didLoad pokemon: PokemonDomainModel) {
        idLabel.text = "\(idLabel.text ?? "") \(pokemon.id)"
        nameLabel.text = "\(nameLabel.text ?? "") \(pokemon.name)"
        weightLabel.text = "\(weightLabel.text ?? "") \(pokemon.weight)"
        heightLabel.text = "\(heightLabel.text ?? "") \(pokemon.id)"
    }
    
    func pokemonViewModel(with pokemonViewModel: PokemonViewModel, didLoad pokemonImage: Data) {
        let image = UIImage(data: pokemonImage)
        imageView.image = image
    }
    
    func pokemonViewModel(with pokemonViewModel: PokemonViewModel, didLoad error: PokemonNetworkServiceError) {
        
    }
}

// MARK: - Helpers
private extension PokemonViewController {
    func setupUI() {
//        view.backgroundColor = Color.Red.v400
        view.addSubview(bgImageView)
        view.addSubview(overallStackView)
        
        bgImageView.fillSuperView()
        overallStackView.fillSuperViewWithSafeArea(inset: .init(top: 16, left: 16, bottom: 16, right: 16))
        [imageView, idLabel, nameLabel, weightLabel, heightLabel].forEach { overallStackView.addArrangedSubview($0) }
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0).isActive = true
    }
}

// MARK: - Factories
private extension PokemonViewController {
    func makeLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .white
        return label
    }
    
    func makeStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.axis = .vertical
        return stackView
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }
}
