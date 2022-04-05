import ComposableArchitecture
import Foundation

struct PokeAPIClient {
    var fetch: (Int) -> Effect<Pokemon, Failure>
    var fetchPokemons: (String?) -> Effect<PokeAPIListResponse, Failure>

    struct Failure: Error, Equatable {}
}

extension PokeAPIClient {
    static let live = PokeAPIClient(
        fetch: { id in
            let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)")!

            return URLSession.shared.dataTaskPublisher(for: url)
                .map { data, _ in data }
                .decode(type: Pokemon.self, decoder: JSONDecoder())
                .mapError { _ in Failure() }
                .eraseToEffect()
        },
        fetchPokemons: { urlString in
            let url = { () -> URL in
                if let urlString = urlString {
                    return URL(string: urlString)!
                } else {
                    return URL(string: "https://pokeapi.co/api/v2/pokemon")!
                }
            }

            return URLSession.shared.dataTaskPublisher(for: url())
                .map { data, _ in data }
                .decode(type: PokeAPIListResponse.self, decoder: JSONDecoder())
                .mapError { _ in Failure() }
                .eraseToEffect()
        }
    )
}
