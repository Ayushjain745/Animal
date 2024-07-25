//
//  AnimalTests.swift
//  AnimalTests
//
//  Created by Ayush Jain on 24/07/24.
//

import XCTest
@testable import Animal

class AnimalPicturesViewModelTests: XCTestCase {
    var viewModel: AnimalPicturesViewModel!
    var mockAnimalService: MockAnimalService!
    
    override func setUp() {
        super.setUp()
        mockAnimalService = MockAnimalService()
        viewModel = AnimalPicturesViewModel(animalService: mockAnimalService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAnimalService = nil
        super.tearDown()
    }
    
    func testFetchAnimalPicturesSuccess() {
        mockAnimalService.picturesToReturn = ["https://example.com/image1.jpg", "https://example.com/image2.jpg"]
        
        let expectation = self.expectation(description: "Pictures update")
        var updateCount = 0
        viewModel.onPicturesUpdate = {
            updateCount += 1
            if updateCount == 1 {
                expectation.fulfill()
            }
        }
        
        viewModel.fetchAnimalPictures(for: "Dog")
        
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertEqual(viewModel.pictures.count, 2)
    }

    
    func testFetchAnimalPicturesFailure() {
        mockAnimalService.shouldReturnError = true
        
        let expectation = self.expectation(description: "Pictures update")
        var updateCount = 0
        viewModel.onPicturesUpdate = {
            updateCount += 1
            if updateCount == 1 {
                expectation.fulfill()
            }
        }
        
        viewModel.fetchAnimalPictures(for: "Dog")
        
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertEqual(viewModel.pictures.count, 0)
    }
}
