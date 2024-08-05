//
//  PosterCell.swift
//  NetflixClone
//
//  Created by 김승희 on 8/1/24.
//

import UIKit

class PosterCell: UICollectionViewCell {
    static let id = "PosterCell"
    
    let imageView : UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.clipsToBounds = true
        imageview.backgroundColor = .darkGray
        imageview.layer.cornerRadius = 10
        return imageview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.frame = contentView.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 새롭게 재활용되기 전에 어떤 로직을 수행할 것인가 - 재활용될 때 이미지뷰를 한번 비우므로 버벅임이 사라짐
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configure(with Movie: Movie) {
        guard let posterPath = Movie.posterPath else { return }
        let urlString = "https://image.tmdb.org/t/p/w500/\(posterPath).jpg"
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }
            }}
    }
}
