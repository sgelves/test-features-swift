//
//  PlacesPlacesPresenterTests.swift
//  test-features-swift
//
//  Created by Sergio on 11/06/2019.
//  Copyright © 2019 sgelves. All rights reserved.
//

import XCTest

class PlacesPresenterTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    class MockInteractor: InteractorToPresenterPlacesProtocol {

    }

    class MockRouter: PlacesRouterInput {

    }

    class MockViewController: PlacesViewInput {

        func setupInitialState() {

        }
    }
}
