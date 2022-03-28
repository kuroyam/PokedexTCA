import Combine
import SwiftUI

struct ContentView: View {

    init() {
        fetch()
    }

    var body: some View {
        Text("Hello, world!")
            .padding()
    }

    func fetch() {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/1") else {
            assertionFailure()
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                return
            }

            let pokemon = try! JSONDecoder().decode(Pokemon.self, from: data)
            print(pokemon)
        }
        .resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Pokemon: Codable {
    let id: Int
    let name: String
}
