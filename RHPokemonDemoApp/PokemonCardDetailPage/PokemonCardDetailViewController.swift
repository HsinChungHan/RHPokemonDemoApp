//
//  PokemonCardDetailViewController.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/4/19.
//

import RHUIComponent
import UIKit

class PokemonCardDetailViewController: UIViewController {
    lazy var pokeCollectionView = makeCollectionView()
    lazy var viewModel = makeViewModel()
    lazy var uidLabel = makeIDLabel()
    lazy var heightView = makePropertyView()
    lazy var weightView = makePropertyView()
    
    let bgImageView = UIImageView(image: .init(named: "background"))
    let allPokemonInfos: [PokeInfo]
    let initialPokeInfo: PokeInfo
    init(allPokemonInfos: [PokeInfo], initialPokeInfo: PokeInfo) {
        self.allPokemonInfos = allPokemonInfos
        self.initialPokeInfo = initialPokeInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = initialPokeInfo.name
        setupLayout()
        view.layoutIfNeeded()
        let scrollToIndexPath = IndexPath(row: viewModel.pokeCellModels.firstIndex { $0.uid == initialPokeInfo.uid } ?? 0, section: 0)
        pokeCollectionView.scrollToItem(at: scrollToIndexPath, at: .centeredHorizontally, animated: false)
    }
    
    func setupLayout() {
        [bgImageView, pokeCollectionView, uidLabel, heightView, weightView].forEach { view.addSubview($0) }
        bgImageView.fillSuperView()
        pokeCollectionView.constraint(top: view.safeAreaLayoutGuide.snp.top, centerX: view.snp.centerX, padding: .init(top: 32, left: 0, bottom: 0, right: 0), size: .init(width: UIScreen.main.bounds.width, height: 350))
        uidLabel.constraint(top: pokeCollectionView.snp.bottom, leading: view.snp.leading, padding: .init(top: 32, left: 16, bottom: 0, right: 0), size: .init(width: 100, height: 32))
        heightView.constraint(top: uidLabel.snp.bottom, leading: uidLabel.snp.leading, padding: .init(top: 32, left: 0, bottom: 0, right: 0), size: .init(width: 170, height: 100))
        weightView.constraint(top: uidLabel.snp.bottom, trailing: view.snp.trailing, padding: .init(top: 32, left: 0, bottom: 0, right: 16), size: .init(width: 170, height: 100))
    }
}

private extension PokemonCardDetailViewController {
    func makeCollectionView() -> UICollectionView {
        let flowLayout = AnimatedGridCardFlowLayout(itemSize: .init(width: 250, height: 350))
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.register(PokeCardDetailCell.self, forCellWithReuseIdentifier: String(describing: PokeCardDetailCell.self))
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }
    
    func makeViewModel() -> PokeCardDetailViewModel {
        let viewModel = PokeCardDetailViewModel(allPokemonInfos: allPokemonInfos, initialPokeInfo: initialPokeInfo)
        viewModel.delegate = self
        return viewModel
    }
    
    func makeIDLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .semibold)
        label.textColor = .lightGray
        return label
    }
    
    func makePropertyView() -> PropertyView {
        let view = PropertyView()
        return view
    }
}

private extension PokemonCardDetailViewController {
    var indexOfCentralCell: IndexPath? {
        let centerPoint = CGPoint(x: pokeCollectionView.bounds.midX + pokeCollectionView.contentOffset.x, y: pokeCollectionView.bounds.midY + pokeCollectionView.contentOffset.y)
            pokeCollectionView.indexPathForItem(
                at: CGPoint.init(x: 100, y: pokeCollectionView.bounds.midY + pokeCollectionView.contentOffset.y))
        return pokeCollectionView.indexPathForItem(at: centerPoint)
    }
    
    func updateCenteredCell(with indexPath: IndexPath) {
        let pokeCellModel = viewModel.pokeCellModels[indexPath.item]
        title = pokeCellModel.name
        if let pokemon = viewModel.getPokemonDomainModel(with: indexPath.item) {
            uidLabel.text = "NO.\(pokemon.id)"
            heightView.configureView(with: .init(icon: "height", title: "Height", value: "\(pokemon.meterHeight)"))
            weightView.configureView(with: .init(icon: "weight", title: "Weight", value: "\(pokemon.kgWeight)"))
        }
    }
}

extension PokemonCardDetailViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if 
            let layout = pokeCollectionView.collectionViewLayout as? AnimatedGridCardFlowLayout,
            let indexPath = layout.indexPathForCenteredVisibleCell() {
            updateCenteredCell(with: indexPath)
        }
    }
}

extension PokemonCardDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.pokeCellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PokeCardDetailCell.self), for: indexPath) as! PokeCardDetailCell
        let cellModel = viewModel.pokeCellModels[indexPath.row]
        cell.configureCell(with: cellModel)
        return cell
    }
}

extension PokemonCardDetailViewController: PokeCardDetailViewModelDelegate {
    func pokeCardDetailViewModel(_ viewModel: PokeCardDetailViewModel, pokeDetailDidDownload poekDetail: PokemonDomainModel) {
        if
            let layout = pokeCollectionView.collectionViewLayout as? AnimatedGridCardFlowLayout,
            let indexPath = layout.indexPathForCenteredVisibleCell() {
            let pokeCellModel = viewModel.pokeCellModels[indexPath.item]
            if pokeCellModel.uid == String(poekDetail.id) {
                updateCenteredCell(with: indexPath)
            }
        }
    }
    
    private var tmpPokeCellModelIndex: Int? {
        guard
            let tmpPokeCellModel = viewModel.tmpPokeCellModel,
            let scrollToIndex = viewModel.pokeCellModels.firstIndex(where: { $0.uid == tmpPokeCellModel.uid })
        else {
            return nil
        }
        return scrollToIndex
    }
    
    private func scroll(to index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        pokeCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
    
    func pokeCardDetailViewModel(_ viewModel: PokeCardDetailViewModel, previousPokeCellModelsDidUpdate pokeCellModels: [PokeCellModel]) {
        pokeCollectionView.reloadData()
        if 
            let tmpPokeCellModelIndex {
            let scrolledIndex = tmpPokeCellModelIndex + 1
            scroll(to: scrolledIndex)
        }
    }
    
    func pokeCardDetailViewModel(_ viewModel: PokeCardDetailViewModel, followingPokeCellModelsDidUpdate pokeCellModels: [PokeCellModel]) {
        pokeCollectionView.reloadData()
        if
            let tmpPokeCellModelIndex {
            scroll(to: tmpPokeCellModelIndex - 1)
            title = viewModel.pokeCellModels[tmpPokeCellModelIndex - 1].name
        }
    }
    
    
    
    func pokeCardDetailViewModel(_ viewModel: PokeCardDetailViewModel, pokemonImageDidUpdate imageData: Data, atIndex index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        pokeCollectionView.performBatchUpdates({
            pokeCollectionView.reloadItems(at: [indexPath])
        }, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastSectionIndex = collectionView.numberOfSections - 1
        let lastItemIndex = collectionView.numberOfItems(inSection: lastSectionIndex) - 1
        // 檢查當前顯示的 cell 是否為最後一個
        if indexPath.section == lastSectionIndex && indexPath.item == lastItemIndex {
            viewModel.loadFollowingPokes()
        }
        // 檢查當前顯示的 cell 是否為第一個
        if indexPath.section == 0 && indexPath.item == 0 {
            viewModel.loadPreviousPokes()
        }
    }
}


