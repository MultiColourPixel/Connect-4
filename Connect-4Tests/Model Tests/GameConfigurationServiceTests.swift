//
//  Copyright © MultiColourPixel 2020
//

@testable import Connect_4

import XCTest

import OHHTTPStubs
import OHHTTPStubsSwift

final class GameConfigurationServiceTests: XCTestCase {

    let service = GameConfigurationService()

    lazy var response = Data("""
        [
            {
                "id":1234567890,
                "color1":"#FF0000",
                "color2":"#0000FF",
                "name1":"Sue",
                "name2":"Henry"
            }
        ]
        """.utf8)

    func testServiceDecodesResponseCorrectly() {
        let completionExpectation = expectation(description: #function)

        stub(
            condition: isPath("/sample-code/connect4/configuration.json"),
            response: { [response] _ in
                return HTTPStubsResponse(data: response, statusCode: 200, headers: [:])
            })

        service.fetchConfiguration { result in
            completionExpectation.fulfill()

            if let configuration = try? result.get() {
                XCTAssertEqual(configuration.id, 1234567890)
            } else {
                XCTFail()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testServiceCompletionHandlerReturnsDecodingError_whenResponseIsEmpty() {
        let completionExpectation = expectation(description: #function)

        stub(
            condition: isPath("/sample-code/connect4/configuration.json"),
            response: { _ in
                return HTTPStubsResponse(data: Data(), statusCode: 200, headers: [:])
            })

        service.fetchConfiguration { result in
            completionExpectation.fulfill()

            if case let .failure(error) = result {
                XCTAssertEqual(error, .decodingError)
            } else {
                XCTFail()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testServiceCompletionHandlerReturnsGeneralError_whenResponseHasError() {
        let completionExpectation = expectation(description: #function)

        stub(
            condition: isPath("/sample-code/connect4/configuration.json"),
            response: { _ in
                return HTTPStubsResponse(error: TestError.error)
            })

        service.fetchConfiguration { result in
            completionExpectation.fulfill()

            if case let .failure(error) = result {
                XCTAssertEqual(error, .generalError)
            } else {
                XCTFail()
            }
        }

        waitForExpectations(timeout: 1)
    }
}

private extension GameConfigurationServiceTests {
    enum TestError: Error {
        case error
    }
}
