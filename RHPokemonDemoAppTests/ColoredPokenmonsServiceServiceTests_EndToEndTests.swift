//
//  ColoredPokenmonsServiceTests_EndToEndTests.swift
//  RHPokemonDemoAppTests
//
//  Created by Chung Han Hsin on 2024/1/26.
//

import XCTest
@testable import RHPokemonDemoApp

class ColoredPokenmonsServiceTests_EndToEndTests: XCTestCase {
    func test_getAllPokemons_onSuccess() {
        let sut = PokemonsNetworkRemoteService.init()
        let exp = expectation(description: "Wait for completion...")
        sut.loadAllPokemons { result in
            switch result {
            case let .success(pokemonsDTO):
                XCTAssertEqual(pokemonsDTO.count, 1302)
                XCTAssertEqual(pokemonsDTO.results.count, 1302)
            default:
                XCTFail("Expected get pokeColorDomainModel successfully, but get failed instead!")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 30.0)
    }
    
    func test_getPokemon_onSuccess() {
        let sut = PokemonsNetworkRemoteService.init()
        let exp = expectation(description: "Wait for completion...")
        sut.loadPokemon(with: "snorlax") { result in
            switch result {
            case let .success(pokemonDTO):
                XCTAssertEqual(pokemonDTO.id, 143)
                XCTAssertEqual(pokemonDTO.name, "snorlax")
                XCTAssertEqual(pokemonDTO.weight, 4600)
                XCTAssertEqual(pokemonDTO.height, 21)
                XCTAssertEqual(pokemonDTO.sprites.other.dreamWorld.frontDefault, "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/dream-world/143.svg")
            default:
                XCTFail("Expected get pokeColorDomainModel successfully, but get failed instead!")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 30.0)
    }
}

