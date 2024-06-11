//
//  AllPokemonCardsViewController.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/4/17.
//

import UIKit

protocol AllPokemonCardsViewControllerDelegate: AnyObject {
    func allPokemonCardsViewController(_ viewController: AllPokemonCardsViewController, didSelectPokeInfo pokeInfo: PokeInfo, withAllPokeInfos pokeInfos: [PokeInfo])
}

class AllPokemonCardsViewController: UIViewController {
    weak var delegae: AllPokemonCardsViewControllerDelegate?
    lazy var searchController = makeSearchBar()
    lazy var collectionView = makeCollectionView()
    let viewModel = AllPokemonCardsViewModel()
    let bgImageView = UIImageView(image: .init(named: "background"))
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "What Is Your Poke?"
        
        viewModel.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        view.addSubview(bgImageView)
        view.addSubview(collectionView)
        collectionView.constraint(top: view.safeAreaLayoutGuide.snp.top, bottom: view.snp.bottom, leading: view.snp.leading, trailing: view.snp.trailing)
        bgImageView.fillSuperView()
        viewModel.loadAllPokemonNames()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        searchController.isActive = false
        searchController.searchBar.text = viewModel.previousSearchedText
    }
}

extension AllPokemonCardsViewController {
    func makeCollectionView() -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 5 // 水平間距
        flowLayout.minimumLineSpacing = 50 // 垂直間距
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PokemonCardCell.self, forCellWithReuseIdentifier: "PokemonCardCell")
        collectionView.backgroundColor = .clear
        collectionView.contentInset = .init(top: 8, left: 8, bottom: 8, right: 8)
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }
    
    func makeSearchBar() -> UISearchController {
        let view = UISearchController(searchResultsController: nil)
        view.searchResultsUpdater = self
        view.obscuresBackgroundDuringPresentation = false
        view.searchBar.isTranslucent = false
        customizeSearchBar(view.searchBar)
        return view
    }

    func customizeSearchBar(_ searchBar: UISearchBar) {
        searchBar.isTranslucent = true
        searchBar.backgroundImage = UIImage()  // 移除边框和背景
        searchBar.backgroundColor = UIColor.clear  // 设置透明背景色
        
        // 设置圆角
        searchBar.searchTextField.backgroundColor = UIColor.darkGray // 搜索框背景色
        searchBar.searchTextField.layer.cornerRadius = 10
        searchBar.searchTextField.clipsToBounds = true
        searchBar.searchTextField.textColor = UIColor.white
        searchBar.searchTextField.attributedPlaceholder = .init(string: "Search Your Poke Here", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.lightGray
        ])
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let imageView = UIImageView(image: UIImage(named: "pokeball"))
        imageView.frame = CGRectMake(100, 50, 20, 19)
        imageView.contentMode = .scaleAspectFit
        
        searchBar.searchTextField.leftView = imageView
        searchBar.searchTextField.leftViewMode = .always
        searchBar.setPositionAdjustment(.init(horizontal: 0, vertical: 5), for: .search)
        
        
        // 自定义清除按钮
        if let clearButton = searchBar.searchTextField.value(forKey: "clearButton") as? UIButton {
            clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            clearButton.tintColor = UIColor.lightGray  // 调整清除按钮图标颜色
        }
    }
}

extension AllPokemonCardsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.pokeCellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonCardCell", for: indexPath) as! PokemonCardCell
        let cellModel = viewModel.pokeCellModels[indexPath.row]
        cell.configureCell(with: cellModel)
        cell.backgroundColor = .clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastSectionIndex = collectionView.numberOfSections - 1
        let lastItemIndex = collectionView.numberOfItems(inSection: lastSectionIndex) - 1
        // 檢查當前顯示的項目是否為最後一個
        if indexPath.section == lastSectionIndex && indexPath.item == lastItemIndex {
            // 檢查是否正在加載新的數據
            if !viewModel.isLoadingNewPokes && !viewModel.isDownloadingImages {
                viewModel.loadNewPokemons()
            }
        }
    }
}

extension AllPokemonCardsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pokeInfo = viewModel.allPokemonInfos[indexPath.row]
//        viewModel.previousSearchedText = ""
        delegae?.allPokemonCardsViewController(self, didSelectPokeInfo: pokeInfo, withAllPokeInfos: viewModel.allPokemonInfos)
    }
}

extension AllPokemonCardsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 2 - 16
        return .init(width: width, height: 250)
    }
}

extension AllPokemonCardsViewController: AllPokemonCardsViewModelDelegate {
    func allPokemonCardsViewModel(_ allPokemonCardsViewModel: AllPokemonCardsViewModel, pokeCellModelsDidFilter pokeCellModels: [PokeCellModel], pokeCellModelsShouldBeRemovedAt indexPaths: [IndexPath]) {
        collectionView.performBatchUpdates({
                collectionView.deleteItems(at: indexPaths)
            }, completion: nil)
    }
    
    func allPokemonCardsViewModel(_ allPokemonCardsViewModel: AllPokemonCardsViewModel, pokeCellModelsDidFilter pokeCellModels: [PokeCellModel], pokeCellModelsShouldBeAddesAt indexPaths: [IndexPath]) {
        collectionView.performBatchUpdates({
               collectionView.insertItems(at: indexPaths)
           }, completion: nil)
    }
    

    func allPokemonCardsViewModel(_ allPokemonCardsViewModel: AllPokemonCardsViewModel, pokeCellModelsDidUpdate pokeCellModels: [PokeCellModel], rangeDidUpdate range: ClosedRange<Int>) {
        let indexPaths = range.map { IndexPath.init(row: $0, section: 0) }
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: indexPaths)
        }, completion: nil)
    }
    
    func allPokemonCardsViewModel(_ allPokemonCardsViewModel: AllPokemonCardsViewModel, pokemonImageDidUpdate pokeCellModel: PokeCellModel, at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.performBatchUpdates({
            collectionView.reloadItems(at: [indexPath])
        }, completion: nil)
    }
}

extension AllPokemonCardsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if !searchController.isActive { return }
        guard let text = searchController.searchBar.text else { return }
        viewModel.loadSearchedPokemonInfos(with: text)
    }
}
