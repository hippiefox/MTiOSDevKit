//
//  MTBaseAlert.swift
//  MTiOSDevKit
//
//  Created by PanGu on 2022/8/30.
//

import Foundation
import UIKit

public extension MTBaseAlert {
    enum FlipFrom {
        case bottom
        case right
    }
}

open class MTBaseAlert: UIViewController {
    private var flipFrom: FlipFrom
    private let tapToDismiss: Bool
    public init(flipFrom: FlipFrom, tapToDismiss: Bool = true) {
        self.flipFrom = flipFrom
        self.tapToDismiss = tapToDismiss
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        transitioningDelegate = self
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    public lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()

    public lazy var closeButton: MTButton = {
        let button = MTButton()
        button.gap = 0
        button.position = .top
        button.iconSize = .init(width: 15, height: 15)
        button.iconNormal = MTPlayerConfig.close
        button.addTarget(self, action: #selector(actionCancel), for: .touchUpInside)
        return button
    }()

    open override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapSelf))
        tap.delegate = self
        tap.isEnabled = tapToDismiss
        view.addGestureRecognizer(tap)
    }

    deinit {
        mt_print(">>>>>>deinit", self.classForCoder.description())
    }
}

// MARK: - Actions

extension MTBaseAlert {
    @objc private func tapSelf(_ gesture: UIGestureRecognizer) {
        dismiss(animated: true)
    }

    @objc private func actionCancel() {
        dismiss(animated: true)
    }
}

extension MTBaseAlert: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let loc = gestureRecognizer.location(in: view)
        return !containerView.frame.contains(loc)
    }
}

// MARK: - - Configure UI

extension MTBaseAlert {
    private func configureUI() {
        containerView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        view.addSubview(containerView)
        containerView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.left.equalTo(containerView.safeAreaLayoutGuide.snp.left)
            $0.right.equalTo(containerView.safeAreaLayoutGuide.snp.right)
            $0.bottom.equalTo(containerView.safeAreaLayoutGuide.snp.bottom)
            $0.top.equalTo(containerView.safeAreaLayoutGuide.snp.top)
        }
    }
}

extension MTBaseAlert: UIViewControllerTransitioningDelegate {
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

extension MTBaseAlert: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let isPresenting = view.superview == nil
        let transitionContainerView = transitionContext.containerView

        if isPresenting {
            transitionContainerView.addSubview(view)
            flipFrom = MTPlayerConfig.allowedOrientation == .portrait ? .bottom : .right
            containerView.alpha = 0
            var duration = 0.3
            switch flipFrom {
            case .bottom:
                containerView.frame = .init(x: 0, y: 0, width: mt_baseline(375), height: mt_baseline(335) + view.safeAreaInsets.bottom)
                containerView.center.x = view.center.x
                containerView.frame.origin.y = MT_SCREEN_HEIGHT
            case .right:
                containerView.frame = .init(x: 0, y: 0, width: mt_baseline(250) + view.safeAreaInsets.right, height: mt_baseline(375))
                containerView.center.y = view.center.y
                containerView.frame.origin.x = max(MT_SCREEN_HEIGHT, MT_SCREEN_WIDTH)
                duration = 0.3
            }

            UIView.animate(withDuration: duration) {
                self.containerView.alpha = 1
                switch self.flipFrom {
                case .bottom: self.containerView.frame.origin.y = self.view.frame.size.height - self.containerView.frame.size.height
                case .right: self.containerView.frame.origin.x = self.view.frame.size.width - self.containerView.frame.size.width
                }
            } completion: { _ in
                transitionContext.completeTransition(true)
            }

        } else {
            UIView.animate(withDuration: 0.3) {
                switch self.flipFrom {
                case .bottom:
                    self.containerView.frame.origin.y = self.view.frame.size.height
                case .right:
                    self.containerView.frame.origin.x = self.view.frame.size.width
                }
                self.containerView.alpha = 0
            } completion: { _ in
                self.view.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }
}
