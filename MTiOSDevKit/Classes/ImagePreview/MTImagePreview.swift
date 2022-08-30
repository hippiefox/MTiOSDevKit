//
//  MTImagePreview.swift
//  MTiOSDevKit
//
//  Created by PanGu on 2022/8/30.
//

import Foundation
import SnapKit
import Kingfisher

open class MTImagePreview: UIViewController {
    public var imgUrl: String?

    public lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = true
        return view
    }()

    public lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.delegate = self
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.maximumZoomScale = 2
        view.minimumZoomScale = 1
        return view
    }()

    public lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapImageView))
        tap.numberOfTapsRequired = 2
        return tap
    }()

    open override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
}

// MARK: - Configure UI

extension MTImagePreview {
    open func configUI() {
        view.backgroundColor = .black
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        imageView.addGestureRecognizer(tap)
        scrollView.addSubview(imageView)
        imageView.snp.remakeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(scrollView)
        }
    }

    open func loadRemoteImage() {
        guard let urlStr = imgUrl?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: urlStr) else {
            handleLoadFailed()
            return
        }

        imageView.kf.setImage(with: url, placeholder: nil, options: nil) { result in
            switch result {
            case let .success(imgResult):
                self.imageView.image = imgResult.image
            case .failure:
                self.handleLoadFailed()
            }
        }
    }

    open func handleLoadFailed() {
        navigationController?.popViewController(animated: true)
    }
}
 
extension MTImagePreview: UIScrollViewDelegate {
    @objc private func tapImageView() {
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(1, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
