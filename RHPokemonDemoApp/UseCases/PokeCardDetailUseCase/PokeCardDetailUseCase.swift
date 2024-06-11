//
//  PokeCardDetailUseCase.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/4/19.
//

import Foundation

protocol PokeCardDetailUseCaseDelegate: AnyObject {
    func pokeCardDetailUseCase(_ useCase: PokeCardDetailUseCase, imageDataDidDownload imageData: Data, ofPoekName name: String)
    
    func pokeCardDetailUseCase(_ useCase: PokeCardDetailUseCase, pokeDetailDidDownload poekDetail: PokemonDomainModel)
}

protocol PokeCardDetailUseCaseDataSource: AnyObject {
    var allPokemonInfos: [PokeInfo] { get set }
    var initialPokeInfo: PokeInfo { get }
}

class PokeCardDetailUseCase {
    weak var delegate: PokeCardDetailUseCaseDelegate?
    let offset = 50
    
    var downloadImagesTaskGroup = DispatchGroup()
    var downloadDetailTaskGroup = DispatchGroup()
    var isDownloadingImage = false
    var isDownloadingDetail = false
    
    var previousNewPokemonRanges: ClosedRange<Int>? {
        if currentStartIndex <= 0 {
            return nil
        }
        let startIndex = max(currentStartIndex - offset, 0)
        let endIndex = max(currentStartIndex - 1, 0)
        return startIndex...endIndex
    }
    
    var followingNewPokemonRanges: ClosedRange<Int>? {
        if currentEndIndex >= allPokemonInfos.count - 1 {
            return nil
        }
        let startIndex = min(allPokemonInfos.count - 1, currentEndIndex + 1)
        let endIndex = min(currentEndIndex + offset, allPokemonInfos.count - 1)
        return startIndex...endIndex
    }
    
    var previousNewPokemonInfos: [PokeInfo] {
        guard let previousNewPokemonRanges else {
            return []
        }
        return Array(allPokemonInfos[previousNewPokemonRanges])
    }
    
    var followingNewPokemonInfos: [PokeInfo] {
        guard let followingNewPokemonRanges else {
            return []
        }
        return Array(allPokemonInfos[followingNewPokemonRanges])
    }
    
    
    var initialPokeIndex: Int {
        allPokemonInfos.firstIndex { $0.uid == initialPokeInfo.uid } ?? 0
    }
    
    let allPokemonInfos: [PokeInfo]
    var allPokemonDetailDict = [String: PokemonDomainModel]()
    let initialPokeInfo: PokeInfo
    var currentEndIndex: Int
    var currentStartIndex: Int
    let repository: PokemonsRepositoryProtocol
    init(repository: PokemonsRepositoryProtocol, dataSource: PokeCardDetailUseCaseDataSource) {
        self.repository = repository
        allPokemonInfos = dataSource.allPokemonInfos
        initialPokeInfo = dataSource.initialPokeInfo
        
        currentEndIndex = dataSource.allPokemonInfos.firstIndex { $0.uid == dataSource.initialPokeInfo.uid } ?? 0
        currentStartIndex = currentEndIndex
    }
}

// MARK: - Internal Methods
extension PokeCardDetailUseCase {
    // 第一次要把 initial pokemon + 前後各 10 隻的 pokemon 圖片 load 完
    func firstLoadEssentialPokes() {
        if isDownloadingImage && isDownloadingDetail { return }
        loadInitialPoke()
        loadFollowingPokes()
        loadPreviousPokes()
    }
    
    func loadInitialPoke() {
        loadInitialPokeImage()
        loadInitialPokeDetail()
    }
    
    func loadFollowingPokes() {
        loadFollowingImages()
        loadFollowingPokeDetails()
    }
    
    func loadPreviousPokes() {
        loadPreviousImages()
        loadPreviousPokeDetails()
    }
}

// MARK: - Helpers
private extension PokeCardDetailUseCase {
    func loadInitialPokeDetail() {
        isDownloadingDetail = true
        downloadDetailTaskGroup.enter()
        repository.loadPokemon(with: initialPokeInfo.name) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.downloadDetailTaskGroup.leave()
                switch result {
                case let .success(pokemon):
                    self.allPokemonDetailDict["\(pokemon.id)"] = pokemon
                    self.delegate?.pokeCardDetailUseCase(self, pokeDetailDidDownload: pokemon)
                case .failure:
                    return
                }
            }
        }
        
        downloadDetailTaskGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.isDownloadingDetail = false
        }
    }
    
    func loadInitialPokeImage() {
        isDownloadingImage = true
        downloadImagesTaskGroup.enter()
        repository.downloadPokemonImage(with: initialPokeInfo.uid, name: initialPokeInfo.name) {
            [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.downloadImagesTaskGroup.leave()
                switch result {
                case let .success(imageData):
                    self.delegate?.pokeCardDetailUseCase(self, imageDataDidDownload: imageData, ofPoekName: self.initialPokeInfo.name)
                case .failure:
                    return
                }
            }
        }
        downloadImagesTaskGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.isDownloadingImage = false
        }
    }
    
    func loadFollowingPokeDetails() {
        if !followingNewPokemonInfos.isEmpty {
            isDownloadingDetail = true
        }
        for pokeInfo in followingNewPokemonInfos {
            downloadDetailTaskGroup.enter()
            repository.loadPokemon(with: pokeInfo.name) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.downloadDetailTaskGroup.leave()
                    switch result {
                    case let .success(pokemon):
                        self.allPokemonDetailDict["\(pokemon.id)"] = pokemon
                        self.delegate?.pokeCardDetailUseCase(self, pokeDetailDidDownload: pokemon)
                    case .failure:
                        return
                    }
                }
            }
        }
        downloadDetailTaskGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.isDownloadingDetail = false
        }
    }
    
    func loadFollowingImages() {
        if !followingNewPokemonInfos.isEmpty {
            isDownloadingImage = true
        }
        for pokeInfo in followingNewPokemonInfos {
            downloadImagesTaskGroup.enter()
            repository.downloadPokemonImage(with: pokeInfo.uid, name: pokeInfo.name) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.downloadImagesTaskGroup.leave()
                    switch result {
                    case let .success(imageData):
                        self.delegate?.pokeCardDetailUseCase(self, imageDataDidDownload: imageData, ofPoekName: pokeInfo.name)
                    case .failure:
                        return
                    }
                }
            }
        }
        downloadImagesTaskGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.isDownloadingImage = false
            self.currentEndIndex += self.offset
        }
    }
    
    func loadPreviousPokeDetails() {
        if !previousNewPokemonInfos.isEmpty {
            isDownloadingDetail = true
        }
        for pokeInfo in previousNewPokemonInfos {
            downloadDetailTaskGroup.enter()
            repository.loadPokemon(with: pokeInfo.name) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.downloadDetailTaskGroup.leave()
                    switch result {
                    case let .success(pokemon):
                        self.allPokemonDetailDict["\(pokemon.id)"] = pokemon
                        self.delegate?.pokeCardDetailUseCase(self, pokeDetailDidDownload: pokemon)
                    case .failure:
                        return
                    }
                }
            }
        }
        downloadDetailTaskGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.isDownloadingDetail = false
        }
    }
    
    func loadPreviousImages() {
        if !previousNewPokemonInfos.isEmpty {
            isDownloadingImage = true
        }
        for pokeInfo in previousNewPokemonInfos {
            downloadImagesTaskGroup.enter()
            repository.downloadPokemonImage(with: pokeInfo.uid, name: pokeInfo.name) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.downloadImagesTaskGroup.leave()
                    switch result {
                    case let .success(imageData):
                        self.delegate?.pokeCardDetailUseCase(self, imageDataDidDownload: imageData, ofPoekName: pokeInfo.name)
                    case .failure:
                        return
                    }
                }
            }
        }
        
        downloadImagesTaskGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.isDownloadingImage = false
            self.currentStartIndex -= self.offset
        }
    }
}
