//
//  MoviesLoaderTests.swift
//  MovieQuiz
//
//  Created by Евгений Амплеев on 30.09.2025.
//

import XCTest
@testable import MovieQuiz

struct StubNetworkClient: NetworkRouting {
    
    enum testError: Error { // тестовая ошибка
        case test
    }
    
    private var expectedResponse: Data {
                """
                {
                "errorMessage" : "",
                   "items" : [
                      {
                         "crew" : "Dan Trachtenberg (dir.), Amber Midthunder, Dakota Beavers",
                         "fullTitle" : "Prey (2022)",
                         "id" : "tt11866324",
                         "imDbRating" : "7.2",
                         "imDbRatingCount" : "93332",
                         "image" : "https://m.media-amazon.com/images/M/MV5BMDBlMDYxMDktOTUxMS00MjcxLWE2YjQtNjNhMjNmN2Y3ZDA1XkEyXkFqcGdeQXVyMTM1MTE1NDMx._V1_Ratio0.6716_AL_.jpg",
                         "rank" : "1",
                         "rankUpDown" : "+23",
                         "title" : "Prey",
                         "year" : "2022"
                      },
                      {
                         "crew" : "Anthony Russo (dir.), Ryan Gosling, Chris Evans",
                         "fullTitle" : "The Gray Man (2022)",
                         "id" : "tt1649418",
                         "imDbRating" : "6.5",
                         "imDbRatingCount" : "132890",
                         "image" : "https://m.media-amazon.com/images/M/MV5BOWY4MmFiY2QtMzE1YS00NTg1LWIwOTQtYTI4ZGUzNWIxNTVmXkEyXkFqcGdeQXVyODk4OTc3MTY@._V1_Ratio0.6716_AL_.jpg",
                         "rank" : "2",
                         "rankUpDown" : "-1",
                         "title" : "The Gray Man",
                         "year" : "2022"
                      }
                    ]
                  }
                """.data(using: .utf8) ?? Data()
    }
    
    let emulateError: Bool
    
    func fetch(url:URL, handler: @escaping (Result <Data, Error>) -> Void){
        if emulateError {
            handler(.failure(testError.test))
        } else {
            handler(.success(expectedResponse))
        }
    }
}

class MoviesLoaderTests: XCTestCase {
    
    func testSuccessLoading() throws {
        
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: false)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        // т.к. функция загрузки фильмов асинхронная, нужно ожидание
        let expectation = expectation(description: "Loading expectation")
        
        
        loader.loadMovies { result in
            // Then
            switch result {
            case .success(let movies):
                // Проверяем, что пришло именно 2 фильма как в тестовых данных
                XCTAssertEqual(movies.items.count, 2)
                expectation.fulfill()
            case .failure(_):
                // мы не ожидаем ошибку; если она приходит, то это не ожидаемое поведение
                XCTFail("Unexpected failure")
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testFailureLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: true)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        // When
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies{ result in
            // Then
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            case .success(_):
                XCTFail("Unexpected success")
            }
        }
        
        waitForExpectations(timeout: 1)
    }
}
