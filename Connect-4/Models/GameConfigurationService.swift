//
//  Copyright © MultiColourPixel 2020
//

import Foundation

protocol GameConfigurationFetching {
    func fetchConfiguration(completionHandler: @escaping (Result<GameConfiguration, ServiceError>) -> Void)
}

enum ServiceError: Error {
    case generalError
    case urlIncorrect
    case decodingError
}

final class GameConfigurationService: GameConfigurationFetching {

    private let base = "https://files.multicolourpixel.com/sample-code/connect4/"
    private let decoder = JSONDecoder()
    private let session = URLSession.shared

    func fetchConfiguration(completionHandler: @escaping (Result<GameConfiguration, ServiceError>) -> Void) {
        let configurationURL = base + "configuration.json"

        guard let remoteURL = URL(string: configurationURL) else {
            completionHandler(.failure(.urlIncorrect))
            return
        }

        session.dataTask(with: remoteURL) { [decoder] data, _, error in
            guard
                let data = data,
                error == nil else
            {
                completionHandler(.failure(.generalError))
                return
            }
            
            if let gameConfiguration = try? decoder.decode(GameConfiguration.self, from: data) {
                completionHandler(.success(gameConfiguration))
            } else {
                completionHandler(.failure(.decodingError))
            }
        }
        .resume()
    }
}
