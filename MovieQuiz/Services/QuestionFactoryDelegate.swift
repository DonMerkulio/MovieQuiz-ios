//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Александр Меркулов on 12.07.23.
//

import Foundation


protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
