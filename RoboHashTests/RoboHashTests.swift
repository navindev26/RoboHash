//
//  RoboHashTests.swift
//  RoboHashTests
//
//  Created by Navin  Dev on 17/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import XCTest
import ReactiveSwift
@testable import RoboHash

class RoboHashTests: XCTestCase {
    override func setUp() {
        
       // let dummyRepo
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}


class TestRepository: RepositoryRepresentable {
    var database: RoboHashDataBase
    var service: RoboHashNetworkService

    init() {
        let dummyStack = try? CoreDataStack.setup(withModelName: CoreDataStack.modelName, storeName: "RoboHashTest")
        guard let database =  RoboHashDataBase(coreDataStack: dummyStack)  else {
            fatalError()
        }
        self.database = database
        self.service = RoboHashNetworkService()
    }
}

class TestDatabase: DataBase {
    var coreDataStack: CoreDataStack?
    typealias Model = SearchHistory
    func totalCount() throws -> Int {
        return 10
    }

    func fetchAll() throws -> [SearchHistory] {
        let testSearchHistory = SearchHistory(name: "Test", date: Date(), image: nil)
        return [testSearchHistory]
    }

    func save(_ object: SearchHistory) throws {
        print("SavedData")
    }
}

class TestNetWorkService: NetworkService {
    func makeRequest(_ endpoint: Endpoint) -> SignalProducer<SearchHistory, RoboHashError> {
        return SignalProducer(value: SearchHistory(name: "", date: Date(), image: nil))
    }
    typealias ResponseData = SearchHistory
}
