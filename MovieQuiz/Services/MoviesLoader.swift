//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Евгений Амплеев on 27.09.2025.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    
    // MARK: - NetworkClient
    // Создаем NetworkClient и не запускаем никаких методов (3)
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - URL
    private var mostPopularMoviesURL: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        
        print("Метод loadMovies начинает работать у которого в качестве аргумента замыкание  DispatchQueue.main.async")
        print("Вызывается метод fetch у networkClient с url, которому передается замыкание  switch result decode")
        
        networkClient.fetch(url: mostPopularMoviesURL) { result in
            
        print("Попали в замыкание на switch result")
            
            switch result {
                
            case .success(let data):
                
                print("Попали в case .success")
                print("Пробуем парсить  do { try в не созданную модель MostPopularMovies.self, но сохраняем в переменную mostPopularMovies результат в случае успеха")
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    print("Вызываем переданное замыкание уже распарсенным .success(mostPopularMovies)")
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
