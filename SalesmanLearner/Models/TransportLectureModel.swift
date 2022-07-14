//
//  TransportLectureModel.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 07.06.2022.
//

import Foundation


struct TransportLectureModel: Encodable, Decodable {
    var id: Int
    var title: String
    var long: String
    var short: String
}
