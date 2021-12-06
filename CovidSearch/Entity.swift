//
//  Entity.swift
//  CovidSearch
//
//  Created by 木下健一 on 2021/12/06.
//

struct CovidInfo: Codable {
    
    struct Total: Codable {
        var pcr: Int
        var positive: Int
        var hospitalize: Int
        var severe: Int
        var death: Int
        var discharge: Int
    }
}
