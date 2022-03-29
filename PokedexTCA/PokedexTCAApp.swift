import ComposableArchitecture
import SwiftUI

@main
struct PokedexTCAApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(
                    initialState: PokemonState(),
                    reducer: pokemonReducer.debug(),
                    environment: PokemonEnvironment(
                        pokeAPIClient: PokeAPIClient.live,
                        mainQueue: .main
                    )
                )
            )
        }
    }
}
