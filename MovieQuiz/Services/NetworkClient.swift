//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Евгений Амплеев on 27.09.2025.
//

import Foundation

protocol NetworkRouting {
    func fetch(url:URL, handler: @escaping (Result<Data, Error>) -> Void)
}


// Отвечает за загрузку данных по URL
struct NetworkClient: NetworkRouting {
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void){
        print("попали в функцию fetch, которая приняла замыкание decode")
        let request = URLRequest(url:url)
        
        print("fetch создает задачу URLSession.shared.dataTask")
        print("Видимо в этот момент стартует запрос...")
        sleep(3)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            print("А вот здесь мы ответ уже получили...")
        
            // Проверяем пришла ли ошибка
            if let error = error {
                handler(.failure(error))
                return
            }
            
            print("Ошибки нет")
            
            // Проверяем, что нам пришел успешный код ответа
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            print("Корректный код ответа")
            
            guard let data = data else { return }
            
            print("Data есть")
            print("Вызываем переданное замыкание с аргументом .success(data)")
            handler(.success(data))
        }
        
        task.resume()
    }
    
}
