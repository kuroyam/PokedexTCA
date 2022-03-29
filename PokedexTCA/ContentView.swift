import ComposableArchitecture
import SwiftUI

struct Pokemon: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
}

enum PokemonAction: Equatable {
    case fetch(Int)
    case fetchResponse(Result<Pokemon, PokeAPIClient.Failure>)
}

struct PokemonEnvironment {
    var pokeAPIClient: PokeAPIClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

struct PokemonState: Equatable {
    var pokemon: Pokemon?
}

let pokemonReducer = Reducer<PokemonState, PokemonAction, PokemonEnvironment> { state, action, environment in
    switch action {
    case .fetch(let id):
        return environment.pokeAPIClient
            .fetch(id)
            .receive(on: environment.mainQueue)
            .catchToEffect(PokemonAction.fetchResponse)

    case .fetchResponse(.success(let pokemon)):
        state.pokemon = pokemon
        return .none

    case .fetchResponse(.failure(_)):
        // ここでエラーハンドリング
        return .none

    }
}

struct ContentView: View {

    let store: Store<PokemonState, PokemonAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                Text("No.\(viewStore.pokemon?.id ?? 0) \(viewStore.pokemon?.name ?? "")")
                    .padding()
                Button {
                    viewStore.send(.fetch(25))
                } label: {
                    Text("無料でピカチュウをゲット")
                }
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
