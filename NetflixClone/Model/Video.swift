//
//  Video.swift
//  NetflixClone
//
//  Created by 김승희 on 8/1/24.
//

import Foundation

struct VideoResponse: Codable {
    let results: [Video]
}

struct Video: Codable {
    let key: String?
    let site: String?
    let type: String?
}
