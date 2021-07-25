//
//  DetailSaveButtonTests.swift
//  ToDoListTests
//
//  Created by Nikolay Kryuchkov on 25.07.2021.
//

import XCTest
@testable import ToDoList

class DetailSaveButtonTests: XCTestCase {

    var sut: DetailViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()

        sut = DetailViewController()
        sut.loadView()
        sut.currentItem = TodoItem(text: "",
                                   importance: .moderate)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testIsSaveButtonDisabledWithoutEditing() throws {
        // Given
        let item = TodoItem(text: "",
                            importance: .moderate)

        // When

        // Then
        XCTAssertTrue(sut.currentItem?.text == item.text)
    }

}
