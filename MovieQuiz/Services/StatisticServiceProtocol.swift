//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Сергей on 05.09.2025.
//

import Foundation

protocol StatisticServiceProtocol {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    
    func store(correct count: Int, total amount: Int)
}
