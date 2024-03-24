//
//  PokemonViewModel.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/26.
//

import Foundation
import SVGKit
import UIKit

protocol PokemonViewModelDelegate: AnyObject {
    func pokemonViewModel(with pokemonViewModel: PokemonViewModel, didUpdatePokemon name: String)
    func pokemonViewModel(with pokemonViewModel: PokemonViewModel, didLoad pokemon: PokemonDomainModel)
    func pokemonViewModel(with pokemonViewModel: PokemonViewModel, didLoad pokemonImage: UIImage)
    func pokemonViewModel(with pokemonViewModel: PokemonViewModel, didLoad pokemonImage: Data)
    func pokemonViewModel(with pokemonViewModel: PokemonViewModel, didLoad error: PokemonNetworkServiceError)
}

class PokemonViewModel {
    weak var delegate: PokemonViewModelDelegate?
    
    var pokemonName: String = "" {
        didSet {
            delegate?.pokemonViewModel(with: self, didUpdatePokemon: pokemonName)
        }
    }
    
    let useCase: PokemonsUseCaseProtocol
    init(useCase: PokemonsUseCaseProtocol) {
        self.useCase = useCase
    }
    
    func loadPokemon() {
        useCase.loadPokemon(with: pokemonName) {[weak self] result in
            guard let self else { return }
            switch result {
            case let .success(pokemon):
                downloadPokemonImage(with: pokemon.id, name: pokemon.name)
//                self.makeImage(with: pokemon.imgaeUrl) {
//                    self.delegate?.pokemonViewModel(with: self, didLoad: $0)
//                }
                self.delegate?.pokemonViewModel(with: self, didLoad: pokemon)
            case let .failure(error):
                self.delegate?.pokemonViewModel(with: self, didLoad: error)
            }
        }
    }
    
    func downloadPokemonImage(with id: Int, name: String) {
        useCase.downloadPokemonImage(with: "\(id)", name: name) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(data):
                self.delegate?.pokemonViewModel(with: self, didLoad: data)
            case let .failure(error):
                self.delegate?.pokemonViewModel(with: self, didLoad: error)
            }
        }
    }
}

// MARK: - Helpers
private extension PokemonViewModel {
    // SVG only
    func makeImage(with url: URL?, then action: @escaping (UIImage) -> Void) {
        let concurrentQueue = DispatchQueue(label: "com.pokemonDemoApp.concurrentQueue", attributes: .concurrent)
        concurrentQueue.async {
            if
                let imgaeUrl = url,
                let image = SVGKImage(contentsOf: imgaeUrl) {
                DispatchQueue.main.async {
                    action(image.uiImage)
                }
            }
        }
    }
}
