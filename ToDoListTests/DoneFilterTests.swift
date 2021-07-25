//
//  DoneFilterTests.swift
//  ToDoListTests
//
//  Created by Nikolay Kryuchkov on 25.07.2021.
//

import XCTest
@testable import ToDoList

class DoneFilterTests: XCTestCase {

    var sut: ViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = ViewController()

    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testDoneFlagFalse() throws {
        // Given
        let doneFlag = sut.doneFlag

        // When

        // Then
        XCTAssert(doneFlag == false)
    }

    func testDoneFlagTrue() throws {
        // Given
        let doneFlag: Bool

        // When
        sut.toggleDoneFlag()
        doneFlag = sut.doneFlag

        // Then
        XCTAssert(doneFlag == true)
    }

}
