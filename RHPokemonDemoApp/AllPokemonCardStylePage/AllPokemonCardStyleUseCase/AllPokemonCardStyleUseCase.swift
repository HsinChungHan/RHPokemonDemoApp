//
//  AllPokemonCardStyleUseCase.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/4/17.
//

import Foundation

protocol AllPokemonCardStyleUseCaseDelegate: AnyObject {
    func allPokemonCardStyleUseCase(_ allPokemonCardStyleUseCase: AllPokemonCardStyleUseCase, pokemonInfoListDidLoad pokemonInfos: [PokeInfo])
    
    func allPokemonCardStyleUseCase(_ allPokemonCardStyleUseCase: AllPokemonCardStyleUseCase, imageDataDidDownload imageData: Data, of name: String)
}

class AllPokemonCardStyleUseCase {
    weak var delegate: AllPokemonCardStyleUseCaseDelegate?
    
    var isDownloadingImage = false
    var originalAllPokemonInfos = [PokeInfo]()
    
    var allPokemonInfos = [PokeInfo]()
    let offset = 10
    
    var dispatchGroup = DispatchGroup()
    var currentPokemonLastIndex = 0
    var endIndex: Int {
        if allPokemonInfos.isEmpty {
            return 0
        }
        return min(currentPokemonLastIndex + offset, allPokemonInfos.count - 1)
    }
    
    var newPokemonRanges: ClosedRange<Int>? {
        if allPokemonInfos.isEmpty || currentPokemonLastIndex > endIndex {
            return nil
        }
        return currentPokemonLastIndex...endIndex
    }
    
    var newPokemonInfos: [PokeInfo] {
        guard let newPokemonRanges else { return [] }
        return Array(allPokemonInfos[newPokemonRanges])
    }
    
    let repository: PokemonsRepositoryProtocol
    init(repository: PokemonsRepositoryProtocol) {
        self.repository = repository
    }
}

private extension AllPokemonCardStyleUseCase {
    func indexMap(for cellModels: [PokeCellModel]) -> [String: Int] {
       var map = [String: Int]()
       for (index, model) in cellModels.enumerated() {
           map[model.uid] = index
       }
       return map
   }
}

// MARK: - Internal Methods - API
extension AllPokemonCardStyleUseCase {
    func filterSearchedPokemonInfos(with searchedText: String) {
        allPokemonInfos = originalAllPokemonInfos.filter {  $0.name.lowercased().hasPrefix(searchedText.lowercased()) }
        currentPokemonLastIndex = 0
    }
    
    func sortAllPokemonInfos(accordingTo pokeCellModels: [PokeCellModel]) {
       let map = indexMap(for: pokeCellModels)
        allPokemonInfos = allPokemonInfos.sorted {
           guard let index1 = map[$0.uid], let index2 = map[$1.uid] else {
               return false
           }
           return index1 < index2
       }
   }
    
    func loadAllPokemonNameList() {
        repository.loadAllPokemons { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .success(pokemons):
                    self.originalAllPokemonInfos = pokemons.pokeInfos
                    self.allPokemonInfos = pokemons.pokeInfos
                    self.delegate?.allPokemonCardStyleUseCase(self, pokemonInfoListDidLoad: pokemons.pokeInfos)
                case .failure:
                    return
                }
            }
        }
    }
    
    func loadPresentingImages() {
        if isDownloadingImage {
            return
        }
        if allPokemonInfos.count - 1 >= currentPokemonLastIndex {
            isDownloadingImage = true
        } else {
            return 
        }
        for pokeInfo in newPokemonInfos {
            dispatchGroup.enter()
            repository.downloadPokemonImage(with: pokeInfo.uid, name: pokeInfo.name) { [weak self] result in
                DispatchQueue.main.async {
                    self?.dispatchGroup.leave()
                    guard let self else { return }
                    switch result {
                    case let .success(imageData):
                        self.delegate?.allPokemonCardStyleUseCase(self, imageDataDidDownload: imageData, of: pokeInfo.name)
                    case .failure:
                        self.dispatchGroup.leave()
                        return
                    }
                }
            }
        }
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.isDownloadingImage = false
            self.currentPokemonLastIndex += self.offset + 1
        }
    }
}
