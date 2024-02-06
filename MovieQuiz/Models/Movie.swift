//
//  Movie.swift
//  MovieQuiz
//
//

import Foundation

// Модель для хранения информации об актерах
struct Actor: Codable {
    
    enum CodingKeys: CodingKey {
        case id, image, name, asCharacter
    }
    
    let id: String
    let image: String
    let name: String
    let asCharacter: String
    
    init(from decoder: Decoder) throws {
        // создаём контейнер, в котором будут содержаться все поля будущей структуры; оттуда мы и достанем значения по ключам
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Инициализируем свойства структуры через контейнер
        id = try container.decode(String.self, forKey: .id)
        image = try container.decode(String.self, forKey: .image)
        name = try container.decode(String.self, forKey: .name)
        asCharacter = try container.decode(String.self, forKey: .asCharacter)
    }
}

// Модель для хранения информации о фильмах
struct Movie: Codable {
    
    // создаём кастомный enum для обработки ошибок
    enum ParseError: Error {
        case yearFailure
        case runtimeMinsFailure
    }
    
    enum CodingKeys: CodingKey {
        case id, title, year, image, releaseDate, runtimeMins, directors, actorList
    }
    
    let id: String
    let title: String
    let year: Int
    let image: String
    let releaseDate: String
    let runtimeMins: Int
    let directors: String
    let actorList: [Actor]
    
    init(from decoder: Decoder) throws {
        // создаём контейнер, в котором будут содержаться все поля будущей структуры; оттуда мы и достанем значения по ключам
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Инициализируем свойства структуры через контейнер
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        
        // Преобразование String -> Int
        let year = try container.decode(String.self, forKey: .year)
        guard let yearValue = Int(year) else {
            throw ParseError.yearFailure
        }
        self.year = yearValue
        
        image = try container.decode(String.self, forKey: .image)
        releaseDate = try container.decode(String.self, forKey: .releaseDate)
        
        // Преобразование String -> Int
        let runtimeMins = try container.decode(String.self, forKey: .runtimeMins)
        guard let mins = Int(runtimeMins) else {
            throw ParseError.runtimeMinsFailure
        }
        self.runtimeMins = mins
        
        directors = try container.decode(String.self, forKey: .directors)
        actorList = try container.decode([Actor].self, forKey: .actorList)
    }
}
