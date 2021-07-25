//
//  NetworkServiceTests.swift
//  ToDoListTests
//
//  Created by Nikolay Kryuchkov on 25.07.2021.
//

import XCTest
@testable import ToDoList

class NetworkServiceTests: XCTestCase {

    var sut: DefaultNetworkingService!
    var item: TodoItem!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = DefaultNetworkingService()
    }

    override func tearDownWithError() throws {
        sut.deleteTask(withId: item.id) { _, _, _ in
            return
        }
        sut = nil
        try super.tearDownWithError()
    }

    func testExample() throws {
        // Given
        item = TodoItem(text: "1",
                            importance: .moderate)

        let promise = expectation(description: "Status code: 200")

        // When
        sut.addTask(item) { _, response, error in
            // Then
            if let error = error {
                XCTFail("Error: \(error)")
                return
            }

            if let statusCode = response?.statusCode {
                if statusCode == 200 {
                    promise.fulfill()
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }
        wait(for: [promise], timeout: 15)
    }
    
}
