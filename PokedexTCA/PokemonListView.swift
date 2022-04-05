import ComposableArchitecture
import SwiftUI

struct PokeAPIListResponse: Codable, Equatable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonListContent]
}

struct PokemonListContent: Codable, Equatable, Hashable {
    let name: String
    let url: String
}

struct PokemonListState: Equatable {
    var pokemons: [PokemonListContent] = []
    var nextURL: String?
}

enum PokemonListAction: Equatable {
    case fetchNext(String?)
    case fetchResponse(Result<PokeAPIListResponse, PokeAPIClient.Failure>)
}

let pokemonListReducer = Reducer<PokemonListState, PokemonListAction, PokemonEnvironment> { state, action, environment in
    switch action {
    case .fetchNext(let url):
        struct PokemonListRequestID: Hashable {}
        return environment.pokeAPIClient
            .fetchPokemons(url)
            .receive(on: environment.mainQueue)
            .catchToEffect(PokemonListAction.fetchResponse)
            .cancellable(id: PokemonListRequestID())

    case .fetchResponse(.success(let response)):
        state.pokemons += response.results
        state.nextURL = response.next
        return .none

    case .fetchResponse(.failure(_)):
        return .none
    }
}

struct PokemonListView: View {

    let store: Store<PokemonListState, PokemonListAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            List(viewStore.state.pokemons, id: \.self) { pokemon in
                Text(pokemon.name)
            }
            .onAppear {
                viewStore.send(.fetchNext(nil))
            }
        }
    }
}

//struct PokemonListView_Previews: PreviewProvider {
//    static var previews: some View {
//        PokemonListView()
//    }
//}
