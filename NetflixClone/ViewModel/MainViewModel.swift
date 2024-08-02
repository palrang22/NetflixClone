//
//  MainViewModel.swift
//  NetflixClone
//
//  Created by 김승희 on 8/2/24.
//

// ViewModel에는 UI로직이 아닌 비즈니스 로직 작성
// 핵심 비즈니스 로직: 서버로부터 영화 데이터를 불러오는 로직

import Foundation

class MainViewModel {
    private let apiKey = Bundle.main.infoDictionary?["MOVIE_API"] as? String
    
    init() {
        
    }
    
    /// Popular Movie 데이터를 불러옴
    /// ViewModel에서 수행해야 할 비즈니스 로직
    func fetchPopularMovie() {
        
    }
    
    func fetchTopRatedMovie() {
        
    }
    
    func fetchUpcomingMovie() {
        
    }
}
