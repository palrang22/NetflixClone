//
//  Movie.swift
//  NetflixClone
//
//  Created by 김승희 on 8/1/24.
//

import Foundation

struct MovieResponse: Codable {
    let results: [Movie]
}

struct Movie: Codable {
    // 데이터가 없을 수도 있기 때문에 옵셔널 사용
    let id: Int?
    let title: String?
    let posterPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case posterPath = "poster_path"
    }
}
