//
//  ColoredPokemonsViewController.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/26.
//

import RHInterface
import RHUIComponent
import UIKit

protocol PokemonsViewControllerDelegate: AnyObject {
    func coloredPokemonsViewController(_ coloredPokemonsViewController: PokemonsViewController, didSelectPokemon name: String)
}

final class PokemonsViewController: UIViewController {
    weak var delegate: PokemonsViewControllerDelegate?
    
    let networkService = PokemonsNetworkRemoteService()
    let codableStoreService = PokemonsCodableStoreService()
    let actorCodablePokemonStoreService = PokemonActorCodableStoreService()
    let actorCodablePokemonsStoreService = PokemonsActorCodableStoreService()
    let actorCodableImageDataStoreService = PokemonActorCodableImageStoreService()
    lazy var respository = PokemonsRepository(networkService: networkService, codableStoreService: codableStoreService, actorCodableStoreService: actorCodablePokemonStoreService, actorCodablePokemonsStoreService: actorCodablePokemonsStoreService, actorCodableImageDataStoreService: actorCodableImageDataStoreService)
    lazy var usecase: PokemonsUseCaseProtocol = MainQueueDispatcherDecorator(decoratee: PokemonsUseCase(repository: respository))
    lazy var viewModel = PokemonsViewModel(useCase: usecase)
    lazy var tableView = makeTableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.delegate = self
        viewModel.loadAllPokemons()
    }
}

// MARK: - Helpers
extension PokemonsViewController {
    private func setupUI() {
        navigationItem.title = "Pokemons"
        view.backgroundColor = Color.Blue.v400
        view.addSubview(tableView)
        tableView.fillSuperViewWithSafeArea()
    }
}

// MARK: - Factories
extension PokemonsViewController {
    private func makeTableView() -> UITableView {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellID")
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension PokemonsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.pokemons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = viewModel.pokemons[indexPath.row].name
        cell.textLabel?.textColor = Color.Neutral.v900
        cell.backgroundColor = Color.Neutral.v200
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pokemonName = viewModel.pokemons[indexPath.row].name
        delegate?.coloredPokemonsViewController(self, didSelectPokemon: pokemonName)
    }
    
    
}

// MARK: - ColoredPokemonsViewModelDelegate
extension PokemonsViewController: PokemonsViewModelDelegate {
    func coloredPokemonsViewModel(_ coloredPokemonsViewModel: PokemonsViewModel, didGet blackPokemons: [PokemonData]) {
        tableView.reloadData()
    }
    
    func coloredPokemonsViewModel(_ coloredPokemonsViewModel: PokemonsViewModel, didGet serviceError: PokemonNetworkServiceError) {
        
    }
}






