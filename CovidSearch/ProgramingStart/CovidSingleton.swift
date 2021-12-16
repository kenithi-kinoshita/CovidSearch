//
//  CovidSingleton.swift
//  CovidSearch
//
//  Created by 木下健一 on 2021/12/16.
//

import Foundation

class CovidSinglton {
    
    private init() {}
    static let shared = CovidSinglton ()
    var prefecture:[CovidInfo.Prefecture] = []
    
}
