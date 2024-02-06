//
//  StatisticService.swift
//  MovieQuiz
//
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    var totalCorrectAnswers: Int { get }
    var totalAmount: Int { get }
    func store(correct count: Int, total amount: Int)
    
}

final class StatisticServiceImplementation: StatisticService {
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount, totalCorrectAnswers, totalAmount
    }
    
    private let userDefaults = UserDefaults.standard
    
    var correct: Double {
        get {
            userDefaults.double(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    var total: Double {
        get {
            userDefaults.double(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    // Расчет точности исходя из истории игр
    var totalAccuracy: Double {
        get {
            totalAmount != 0 ? Double(totalCorrectAnswers) / Double(totalAmount) *  100 : 0
        }
        
    }
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
            
        }
    }
    var totalCorrectAnswers: Int {
        
        get {
            userDefaults.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        
        
        set {
            userDefaults.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
        
    }
    
    var totalAmount: Int {
        get {
            userDefaults.integer(forKey: Keys.totalAmount.rawValue)
        }
        
        
        set {
            userDefaults.set(newValue, forKey: Keys.totalAmount.rawValue)
        }
    }
    
    //Метод сохранения лучшего результата квиза и увеличение счетчиков статистики
    func store(correct count: Int, total amount: Int) {
        let currentGame: GameRecord = GameRecord(correct: count, total: amount, date: Date())
        if bestGame.isBetterThan(currentGame){
            bestGame = currentGame
        }
        gamesCount += 1
        totalCorrectAnswers += count
        totalAmount += amount
        
    }
    
}
