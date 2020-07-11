//
//  ActivityDetailInteractorTests.swift
//  ActivityLogSampleTests
//
//  Created by Simon Kim on 7/11/20.
//  Copyright © 2020 KineMaster Crop. All rights reserved.
//

import XCTest
@testable import ActivityLogSample

class MocView: ActivityDetailView {
    func update(with model: Activity) {
        onUpdate?(model)
    }
    
    var onUpdate: ((_ model: Activity) -> Void)?
}

class ActivityDetailInteractorTests: XCTestCase {

    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadInitialData_updates_view() throws {
        let view = MocView()
        let sut = ActivityDetailInteractor(view: view)
        
        let exp = expectation(description: "update received")
        view.onUpdate = { _ in
            exp.fulfill()
        }
        
        sut.send(.loadInitialData)

        wait(for: [exp], timeout: 1)
    }

    func testChangeTile_updates_view() throws {
        let view = MocView()
        let sut = ActivityDetailInteractor(view: view)
        
        let exp = expectation(description: "update received")
        view.onUpdate = { _ in
            exp.fulfill()
        }
        
        sut.send(.changeTitle("title"))

        wait(for: [exp], timeout: 1)
    }

    func testActions_dont_update_view() throws {
        let view = MocView()
        let sut = ActivityDetailInteractor(view: view)
        
        view.onUpdate = { _ in
            XCTFail()
        }
        
        sut.send(.changeProgress(0.7))
        sut.send(.changeNote("note"))
    }

    func testPickPhoto_invokes_computeColorScheme() throws {
        let view = MocView()
        let sut = ActivityDetailInteractor(view: view)
        
        let exp = expectation(description: "update received")
        view.onUpdate = { model in
            guard let scheme = model.colorScheme,
                scheme.foreground == .red,
                scheme.background == .green else {
                    XCTFail()
                    return
            }
            exp.fulfill()
        }
        
        sut.computeAIColorSchemeFrom = { image in
            return ColorScheme(.red, .green)
        }
        sut.send(.pickPhoto)

        wait(for: [exp], timeout: 1)
    }

    func testSave_invokes_saveData() {
        let view = MocView()
        let sut = ActivityDetailInteractor(view: view)
        
        let exp = expectation(description: "update received")

        sut.saveData = { model in
            guard model.isValidForSaving else {
                XCTFail()
                return
            }
            exp.fulfill()
        }
        sut.send(.changeTitle("hello"))
        sut.send(.pickPhoto)
        sut.send(.save)

        wait(for: [exp], timeout: 1)
    }
    
    func testSaveIncompleteData_doesnot_invoke_saveData() {
        let view = MocView()
        let sut = ActivityDetailInteractor(view: view)
        
        sut.saveData = { model in
            XCTFail()
        }
        sut.send(.changeTitle("hello"))
        sut.send(.save)
    }
    
}
