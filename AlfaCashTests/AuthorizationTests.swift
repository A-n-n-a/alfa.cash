//
//  AuthorizationTests.swift
//  alfa.cash
//
//  Created by Anna on 7/13/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import XCTest
@testable import alfa_cash

class AuthorizationTests: XCTestCase {

    //=================================================
    // MARK: - Setup Testing Environment
    //=================================================
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }

    //=================================================
    // MARK: - Test Cases
    //=================================================
    
    func testLongUsernameValidation() {
        
        let username = "abcdefghijklmnopqrstuvwxyz"
        let valid = username.isNameValid()
        XCTAssert(!valid, "Username's length must be between 4 to 20 symbols")
    }
    
    func testUsernameValidation() {
        
        let username = "ab_c0defg6hiJKLmnopq"
        let valid = username.isNameValid()
        XCTAssert(valid, "Username must contain a-z, A-Z, 0-9 and _")
    }
    
    func testUsernameExtraSymbolsValidation() {
        
        let username = "ab:c0defg6hiJKLmnopq"
        let valid = username.isNameValid()
        XCTAssert(!valid, "Username must contain a-z, A-Z, 0-9 and _")
    }
}

