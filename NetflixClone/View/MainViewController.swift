//
//  ViewController.swift
//  NetflixClone
//
//  Created by 김승희 on 8/1/24.
//

import UIKit
import SnapKit
import RxSwift
import AVKit

class MainViewController: UIViewController {
    
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    private var popularMovies = [Movie]()
    private var topRatedMovies = [Movie]()
    private var upcomingMovies = [Movie]()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Netflix"
        label.textColor = UIColor(red: 229/255, green: 9/255, blue: 20/255, alpha: 1.0)
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(PosterCell.self, forCellWithReuseIdentifier: PosterCell.id)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.id)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .black
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configUI()
    }
    
    // 뷰모델과 뷰컨 이어주는 함수 - 데이터 바인딩
    func bind() {
        viewModel.popularMovieSubject
            .observe(on: MainScheduler.instance) // reloadData는 UI 작업이므로, 메인스레드에서 돌아가도록 처리
            .subscribe(onNext: { [weak self] movies in
                self?.popularMovies = movies
                self?.collectionView.reloadData()},
                       onError: { error in
                print("에러 발생: \(error)")
            }).disposed(by: disposeBag)
        
        viewModel.topRatedMovieSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.topRatedMovies = movies
                self?.collectionView.reloadData()},
                       onError: { error in
                print("에러 발생: \(error)")
            }).disposed(by: disposeBag)
        
        viewModel.upcomingMovieSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.upcomingMovies = movies
                self?.collectionView.reloadData()},
                       onError: { error in
                print("에러 발생: \(error)")
            }).disposed(by: disposeBag)
    }
    
    // 아이템 사이즈 지정 -> 아이템 선언, 그룹 사이즈 지정 -> 그룹 선언
    private func createLayout() -> UICollectionViewLayout {
        
        // 각 아이템이 그룹내에서 전체높이와 전체너비 차지 (1.0 = 100%)
        let itemSize = NSCollectionLayoutSize (
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // 각 그룹의 너비는 25% 차지, 높이는 40% 차지
        let groupSize = NSCollectionLayoutSize (
            widthDimension: .fractionalWidth(0.25),
            heightDimension: .fractionalHeight(0.4))
        
        // 수평적 그룹으로 구성되도록 선언 (수평 스크롤)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous // 스크롤 연속적으로 가능
        section.interGroupSpacing = 10 // 그룹 사이의 간격
        section.contentInsets = .init(top: 10, leading: 10, bottom: 20, trailing: 10) // section간의 inset
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configUI() {
        view.backgroundColor = .black
        [label, collectionView].forEach { view.addSubview($0) }
        
        label.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(10)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func playVideoUrl() {
        // 유튜브 url은 정책상 바로 재생할 수 없으므로 임의의 url 넣어 구현만
        let url = URL(string: "https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4")!
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }
}

enum Section: Int, CaseIterable {
    case PopularMovies
    case TopRatedMovies
    case UpcomingMovies
    
    var title: String {
        switch self {
        case.PopularMovies: return "이시간 핫한 영화"
        case.TopRatedMovies: return "평점이 가장 높은 영화"
        case.UpcomingMovies: return "곧 개봉되는 영화"
        }
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section) {
        case .PopularMovies:
            viewModel.fetchTrailerKey(movie: popularMovies[indexPath.row])
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] key in
                    self?.playVideoUrl()
                }, onFailure: {error in
                    print("에러 발생: \(error)")
                }).disposed(by: disposeBag)
            
        case .TopRatedMovies:
            viewModel.fetchTrailerKey(movie: topRatedMovies[indexPath.row])
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] key in
                    self?.playVideoUrl()
                }, onFailure: { error in
                    print("에러 발생: \(error)")
                }).disposed(by: disposeBag)
            
        case .UpcomingMovies:
            viewModel.fetchTrailerKey(movie: upcomingMovies[indexPath.row])
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] key in
                    self?.playVideoUrl()
                }, onFailure: { error in
                    print("에러 발생: \(error)")
                }).disposed(by: disposeBag)
            
        default:
            return
        }
    }
}

extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .PopularMovies: return popularMovies.count
        case .TopRatedMovies: return topRatedMovies.count
        case .UpcomingMovies: return upcomingMovies.count
        default:
            return 0
        }
    }
    
    // indexPath별 Cell 구현
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCell.id, for: indexPath) as? PosterCell else {
            return UICollectionViewCell()
        }
        
        switch Section(rawValue: indexPath.section) {
        case .PopularMovies:
            cell.configure(with: popularMovies[indexPath.row])
        case .TopRatedMovies:
            cell.configure(with: topRatedMovies[indexPath.row])
        case .UpcomingMovies:
            cell.configure(with: upcomingMovies[indexPath.row])
        default:
            return UICollectionViewCell()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.id, for: indexPath) as? SectionHeaderView else { return UICollectionReusableView() }
        
        // Section enum을 리스트로 순회 가능
        let sectionType = Section.allCases[indexPath.section]
        headerView.configure(with: sectionType.title)
        return headerView
    }
    
    // collection view section 몇개인지 설정
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
}
