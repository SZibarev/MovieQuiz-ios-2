//
//  AggregationCompositionExample.swift
//  MovieQuiz
//
//  Created by Сергей on 05.09.2025.
//

import Foundation

// Класс для получения данных
class DataFetcher {
    init() {
        // Инициализация
    }
}

// Агрегация
class ReportGeneratorWithAggregation {
    let dataFetcher: DataFetcher

    init(dataFetcher: DataFetcher) {
        self.dataFetcher = dataFetcher // Получает свой экземпляр извне
    }
}

// Композиция
class ReportGeneratorWithComposition {
    private let dataFetcher: DataFetcher

    init() {
        self.dataFetcher = DataFetcher() // Создает свой собственный экземпляр
    }
}

// Использование созданных классов

// Агрегация
let sharedFetcher = DataFetcher()
let reportAgg = ReportGeneratorWithAggregation(dataFetcher: sharedFetcher)

// Композиция
let reportComp = ReportGeneratorWithComposition()