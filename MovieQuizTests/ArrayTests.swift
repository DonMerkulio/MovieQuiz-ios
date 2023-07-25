//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Александр Меркулов on 20.07.23.
//

import Foundation
import XCTest
@testable import MovieQuiz


class ArrayTests: XCTestCase {
    // тест на успешное взятие элемента по индексу
    func testGetValueInRange() throws {
        let array = [1, 1, 2, 3, 5]
        let value = array[safe: 2]
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    // тест на взятие элемента по неправильному индексу
    func testGetValueOutOfRange() throws {
        let array = [1, 1, 2, 3, 5]
        let value = array[safe: 20]
        XCTAssertNil(value)
    }
}
