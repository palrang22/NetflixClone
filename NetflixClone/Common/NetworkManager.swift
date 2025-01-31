//
//  NetworkManager.swift
//  NetflixClone
//
//  Created by 김승희 on 8/2/24.
//

import Foundation
import RxSwift

enum NetworkError: Error {
    case invalidUrl
    case dataFetchFail
    case decodingFail
}

// 싱글톤으로 NetworkManager 선언
class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    // Success, Failure 중 단 하나만 뱉는 Single T 타입을 리턴
    func fetch<T:Decodable>(url: URL) -> Single<T> {
        return Single.create { observer in
            let session = URLSession(configuration: .default)
            
            session.dataTask(with: URLRequest(url: url)) {data, response, error in
                if let error = error {
                    observer(.failure(error))
                    return
                }
                
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      (200..<300).contains(response.statusCode) else {
                    observer(.failure(NetworkError.dataFetchFail))
                    return
                }
                
                // 오류가 없다면 data를 json으로 받아올 수 있는 상황
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    // 데이터를 잘 받아왔고,
                    // 디코딩이 잘 되었다면 디코딩된 데이터는 마침내 T타입의 데이터가 되어 Single에 Success로 방출
                    observer(.success(decodedData))
                } catch {
                    observer(.failure(NetworkError.decodingFail))
                }
            }.resume()
            
            return Disposables.create()
        }
    }
}
