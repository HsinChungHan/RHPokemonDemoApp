//
//  PokeCardDetailViewModel.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/4/19.
//

import Foundation

protocol PokeCardDetailViewModelDelegate: AnyObject {
    func pokeCardDetailViewModel(_ viewModel: PokeCardDetailViewModel, previousPokeCellModelsDidUpdate indexPaths: [IndexPath])
    func pokeCardDetailViewModel(_ viewModel: PokeCardDetailViewModel, followingPokeCellModelsDidUpdate indexPaths: [IndexPath])
    
    func pokeCardDetailViewModel(_ viewModel: PokeCardDetailViewModel, pokemonImageDidUpdate imageData: Data, atIndex index: Int)
    
    func pokeCardDetailViewModel(_ viewModel: PokeCardDetailViewModel, pokeDetailDidDownload poekDetail: PokemonDomainModel)
}

class PokeCardDetailViewModel: PokeCardDetailUseCaseDataSource {
    weak var delegate: PokeCardDetailViewModelDelegate?
    
    let networkService = PokemonsNetworkRemoteService()
    let codableStoreService = PokemonsCodableStoreService()
    let actorCodablePokemonStoreService = PokemonActorCodableStoreService()
    let actorCodablePokemonsStoreService = PokemonsActorCodableStoreService()
    let actorCodableImageDataStoreService = PokemonActorCodableImageStoreService()
    lazy var respository = PokemonsRepository(networkService: networkService, codableStoreService: codableStoreService, actorCodableStoreService: actorCodablePokemonStoreService, actorCodablePokemonsStoreService: actorCodablePokemonsStoreService, actorCodableImageDataStoreService: actorCodableImageDataStoreService)
    lazy var useCase = PokeCardDetailUseCase(repository: respository, dataSource: self)
    
    
    var isDownloading: Bool {
        useCase.isDownloadingImage || useCase.isDownloadingDetail
    }
    
    var pokeCellModels = [PokeCellModel]()
    var allPokemonInfos: [PokeInfo]
    var tmpPokeCellModel: PokeCellModel?
    
    var initialPokeInfo: PokeInfo
    init(allPokemonInfos: [PokeInfo], initialPokeInfo: PokeInfo) {
        self.allPokemonInfos = allPokemonInfos
        self.initialPokeInfo = initialPokeInfo
        useCase.delegate = self
        pokeCellModels.append(.init(fromPokeInfo: initialPokeInfo))
        firstLoadPokes()
    }
    
    func firstLoadPokes() {
        if isDownloading { return }
        insertNewPreviousPokes()
        insertNewFollowingPokes()
        useCase.firstLoadEssentialPokes()
    }
    
    func loadFollowingPokes() {
        if isDownloading { return }
        if !useCase.followingNewPokemonInfos.isEmpty {
            tmpPokeCellModel = pokeCellModels.last
            insertNewFollowingPokes()
        }
    }
    
    func loadPreviousPokes() {
        if isDownloading { return }
        if !useCase.previousNewPokemonInfos.isEmpty {
            tmpPokeCellModel = pokeCellModels.first
            insertNewPreviousPokes()
        }
    }
    
    func insertNewFollowingPokes() {
        guard !useCase.followingNewPokemonInfos.isEmpty else { return }
        let followingCellModels = useCase.followingNewPokemonInfos.map { PokeCellModel.init(fromPokeInfo: $0) }
        let satrtIndex = pokeCellModels.count
        pokeCellModels += followingCellModels
        let endIndex = pokeCellModels.count - 1
        let insertedIndexPaths = (satrtIndex...endIndex).map { IndexPath.init(row: $0, section: 0) }
        delegate?.pokeCardDetailViewModel(self, followingPokeCellModelsDidUpdate: insertedIndexPaths)
    }
    
    func insertNewPreviousPokes() {
        guard !useCase.previousNewPokemonInfos.isEmpty else { return }
        let previousCellModels = useCase.previousNewPokemonInfos.map { PokeCellModel.init(fromPokeInfo: $0) }
        pokeCellModels = previousCellModels + pokeCellModels
        let insertedIndexPaths = (0...previousCellModels.count - 1).map { IndexPath(row: $0, section: 0) }
        delegate?.pokeCardDetailViewModel(self, previousPokeCellModelsDidUpdate: insertedIndexPaths)
    }
    
    func getPokeInfo(with index: Int) -> PokeInfo {
        let cellModel = pokeCellModels[index]
        let uid = cellModel.uid
        return allPokemonInfos.first { $0.uid == uid }!
    }
    
    func getPokemonDomainModel(with index: Int) -> PokemonDomainModel? {
        let cellModel = pokeCellModels[index]
        let uid = cellModel.uid
        return useCase.allPokemonDetailDict[uid]
    }
}

extension PokeCardDetailViewModel: PokeCardDetailUseCaseDelegate {
    func pokeCardDetailUseCase(_ useCase: PokeCardDetailUseCase, pokeDetailDidDownload poekDetail: PokemonDomainModel) {
        delegate?.pokeCardDetailViewModel(self, pokeDetailDidDownload: poekDetail)
    }
    
    func pokeCardDetailUseCase(_ useCase: PokeCardDetailUseCase, imageDataDidDownload imageData: Data, ofPoekName name: String) {
        let targetCellIndex = pokeCellModels.firstIndex { $0.name == name }!
        pokeCellModels[targetCellIndex].imageData = imageData
        delegate?.pokeCardDetailViewModel(self, pokemonImageDidUpdate: imageData, atIndex: targetCellIndex)
    }
}
