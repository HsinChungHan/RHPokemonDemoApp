//
//  AllPokemonCardsViewModel.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/4/17.
//

import Foundation

protocol AllPokemonCardsViewModelDelegate: AnyObject {
    func allPokemonCardsViewModel(_ allPokemonCardsViewModel: AllPokemonCardsViewModel, pokeCellModelsDidUpdate pokeCellModels: [PokeCellModel], rangeDidUpdate range: ClosedRange<Int>)
    
    func allPokemonCardsViewModel(_ allPokemonCardsViewModel: AllPokemonCardsViewModel, pokeCellModelsDidFilter pokeCellModels: [PokeCellModel], pokeCellModelsShouldBeRemovedAt indexPaths: [IndexPath])
    
    func allPokemonCardsViewModel(_ allPokemonCardsViewModel: AllPokemonCardsViewModel, pokeCellModelsDidFilter pokeCellModels: [PokeCellModel], pokeCellModelsShouldBeAddesAt indexPaths: [IndexPath])
    
    func allPokemonCardsViewModel(_ allPokemonCardsViewModel: AllPokemonCardsViewModel, pokemonImageDidUpdate pokeCellModel: PokeCellModel, at index: Int)
}

class AllPokemonCardsViewModel {
    weak var delegate: AllPokemonCardsViewModelDelegate?
    
    let networkService = PokemonsNetworkRemoteService()
    let codableStoreService = PokemonsCodableStoreService()
    let actorCodablePokemonStoreService = PokemonActorCodableStoreService()
    let actorCodablePokemonsStoreService = PokemonsActorCodableStoreService()
    let actorCodableImageDataStoreService = PokemonActorCodableImageStoreService()
    lazy var respository = PokemonsRepository(networkService: networkService, codableStoreService: codableStoreService, actorCodableStoreService: actorCodablePokemonStoreService, actorCodablePokemonsStoreService: actorCodablePokemonsStoreService, actorCodableImageDataStoreService: actorCodableImageDataStoreService)
    lazy var useCase = AllPokemonCardStyleUseCase(repository: respository)
    var allPokemonInfos: [PokeInfo] {
        useCase.allPokemonInfos
    }
    var pokeCellModels = [PokeCellModel]()
    var shouldRemoveCellModels = [PokeCellModel]()
    var previousSearchedText = ""
    
    var isLoadingNewPokes = false
    
    var isDownloadingImages: Bool {
        useCase.isDownloadingImage
    }
    
    init() {
        useCase.delegate = self
    }
    
    func loadAllPokemonNames() {
        useCase.loadAllPokemonNameList()
    }
    
    func loadNewPokemons() {
        isLoadingNewPokes = true
        appendNewPokemonCellModels()
        loadPokemonImage()
    }
    
    func loadSearchedPokemonInfos(with searchedText: String) {
        isLoadingNewPokes = true
        filterAndInitialNewPokemonCellModels(with: searchedText)
        loadPokemonImage()
    }
}

private extension AllPokemonCardsViewModel {
    func loadPokemonImage() {
        useCase.loadPresentingImages()
    }
    
    func appendNewPokemonCellModels() {
        guard let newPokemonRanges = useCase.newPokemonRanges else { return }
        pokeCellModels += useCase.newPokemonInfos.map { .init(name: $0.name, uid: $0.uid) }
        isLoadingNewPokes = false
        delegate?.allPokemonCardsViewModel(self, pokeCellModelsDidUpdate: pokeCellModels, rangeDidUpdate: newPokemonRanges)
    }
    
    func filterAndInitialNewPokemonCellModels(with searchedText: String) {
        if previousSearchedText == searchedText { return }
        previousSearchedText = searchedText
        useCase.filterSearchedPokemonInfos(with: searchedText)
        shouldRemoveCellModels = pokeCellModels
        
        // Remove filtered models
        var newCellModels = useCase.newPokemonInfos.map { PokeCellModel.init(name: $0.name, uid: $0.uid) }
        
        let newPokeCellModelUIDs = Set(newCellModels.map { $0.uid })
        var shouldRemoveIndices = [IndexPath]()
        for (index, shouldRemoveCellModel) in shouldRemoveCellModels.enumerated() {
            if !newPokeCellModelUIDs.contains(shouldRemoveCellModel.uid) {
                shouldRemoveIndices.append(IndexPath(row: index, section: 0))
            }
        }
        
        shouldRemoveIndices = shouldRemoveIndices.sorted(by: { $0.row > $1.row })
        for indexPath in shouldRemoveIndices {
            pokeCellModels.remove(at: indexPath.row)
        }
        delegate?.allPokemonCardsViewModel(self, pokeCellModelsDidFilter: pokeCellModels, pokeCellModelsShouldBeRemovedAt: shouldRemoveIndices)
        
        
        // Add new models
        let pokeCellModelUIDs = Set(pokeCellModels.map { $0.uid })
        var newOnlyIndexes = [IndexPath]()
        
        // 遍歷 newCellModels 並找到只在新集合中的 cellModel 的索引
        for (index, newCell) in newCellModels.enumerated() {
            if !pokeCellModelUIDs.contains(newCell.uid) {
                newOnlyIndexes.append(.init(row: index, section: 0))
            }
        }
        
        newOnlyIndexes = newOnlyIndexes.sorted(by: { $0.row > $1.row })
        for indexPath in newOnlyIndexes {
            pokeCellModels.append(newCellModels[indexPath.row])
        }
        useCase.sortAllPokemonInfos(accordingTo: pokeCellModels)
        delegate?.allPokemonCardsViewModel(self, pokeCellModelsDidFilter: pokeCellModels, pokeCellModelsShouldBeAddesAt: newOnlyIndexes)
        isLoadingNewPokes = false
    }
}

extension AllPokemonCardsViewModel: AllPokemonCardStyleUseCaseDelegate {
    func allPokemonCardStyleUseCase(_ allPokemonCardStyleUseCase: AllPokemonCardStyleUseCase, pokemonInfoListDidLoad pokemonInfos: [PokeInfo]) {
        loadNewPokemons()
    }
    
    func allPokemonCardStyleUseCase(_ allPokemonCardStyleUseCase: AllPokemonCardStyleUseCase, imageDataDidDownload imageData: Data, of name: String) {
         let targetCellIndex = pokeCellModels.firstIndex { $0.name == name }
        guard let targetCellIndex else { return }
        pokeCellModels[targetCellIndex].imageData = imageData
        delegate?.allPokemonCardsViewModel(self, pokemonImageDidUpdate: pokeCellModels[targetCellIndex], at: targetCellIndex)
    }
}
