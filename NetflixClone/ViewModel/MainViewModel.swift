//
//  MainViewModel.swift
//  NetflixClone
//
//  Created by 김승희 on 8/2/24.
//

// ViewModel에는 UI로직이 아닌 비즈니스 로직 작성
// 핵심 비즈니스 로직: 서버로부터 영화 데이터를 불러오는 로직

import Foundation
import RxSwift

class MainViewModel {
    private let apiKey = Bundle.main.infoDictionary?["MOVIE_API"] as? String
    private let disposeBag = DisposeBag()
    
    
    /// View가 구독할 Subject
    // 외부에서 값을 받아올 수도 있고 내부에서 방출할 수도 있는 Subject
    // 중 초기값이 있는 BehaviorSubject
    let popularMovieSubject = BehaviorSubject(value: [Movie]())
    let topRatedMovieSubject = BehaviorSubject(value: [Movie]())
    let upcomingMovieSubject = BehaviorSubject(value: [Movie]())
    
    init() {
        fetchPopularMovie()
        fetchUpcomingMovie()
        fetchTopRatedMovie()
    }
    
    /// Popular Movie 데이터를 불러옴
    /// ViewModel에서 수행해야 할 비즈니스 로직
    func fetchPopularMovie() {
        guard let apiKey = apiKey, let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)") else {
            popularMovieSubject.onError(NetworkError.invalidUrl)
            return
        }
        
        // NetworkManager에서 single 타입으로 리턴한 것을 구독할 수 있음
        // 구독 시작: 값이 방출됐는데 success면 onSuccess 실행, failure면 onFailure 실행
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (movieResponse: MovieResponse) in
                self?.popularMovieSubject.onNext(movieResponse.results)
            }, onFailure: { [weak self] error in
                self?.popularMovieSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    
    func fetchTopRatedMovie() {
        guard let apiKey = apiKey, let url = URL(string: "https://api.themoviedb.org/3/movie/top_rated?api_key=\(apiKey)") else {
            topRatedMovieSubject.onError(NetworkError.invalidUrl)
            return
        }
        
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (movieResponse : MovieResponse) in
                self?.topRatedMovieSubject.onNext(movieResponse.results)},
                       onFailure: { [weak self] error in
                self?.topRatedMovieSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    
    func fetchUpcomingMovie() {
        guard let apiKey = apiKey, let url = URL(string: "https://api.themoviedb.org/3/tv/popular?api_key=\(apiKey)") else {
            upcomingMovieSubject.onError(NetworkError.invalidUrl)
            return
        }
        
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (movieResponse: MovieResponse) in
                self?.upcomingMovieSubject.onNext(movieResponse.results)},
                       onFailure: { [weak self] error in
                self?.upcomingMovieSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    
    func fetchTrailerKey(movie: Movie) -> Single<String> {
        guard let apiKey = apiKey, let movieId = movie.id else { return Single.error(NetworkError.dataFetchFail)}
        let urlString = "https://api.themoviedb.org/3/movie/\(movieId)/videos?api_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return Single.error(NetworkError.invalidUrl)
        }
        
        return NetworkManager.shared.fetch(url: url) // 여기까지만 보면 리턴타입이 Single<VideoResponse>
            // Single의 리턴타입을 변경해주고 싶을 때, flatMap을 활용해 리턴타입을 String으로 변경
            .flatMap { (VideoResponse: VideoResponse) -> Single<String> in
                if let trailer = VideoResponse.results.first(where: {$0.type == "Trailer" && $0.site == "YouTube"}) {
                    guard let key = trailer.key else { return Single.error(NetworkError.dataFetchFail) }
                    return Single.just(key) // key를 활용해 예고편 영상을 틀 수 있다
                } else {
                    return Single.error(NetworkError.dataFetchFail)
                }
            }
    }
}
