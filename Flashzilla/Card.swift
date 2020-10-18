//
//  Card.swift
//  Flashzilla
//
//  Created by Vegesna, Vijay V EX1 on 10/11/20.
//

import Foundation

struct Card: Codable {
    let prompt: String
    let answer: String
    //var id = UUID()
    
    static var example: Card {
        Card(prompt: "What did you learnt this weekend?", answer: "watched Fight Club")
    }
}
