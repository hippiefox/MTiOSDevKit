//
//  MTPlayer.swift
//  MTiOSDevKit
//
//  Created by PanGu on 2022/8/30.
/*
    一个空壳Player
 */

import Foundation

open class MTPlayer: UIViewController {
    public var fileURL: URL!
    public var isPlayToEnd: Bool = false

    public var currentSoftHard: MTPlayerConfig.SoftHardDecode = .soft
    public var currentRate: MTPlayerConfig.Rate = .r_1_0
    public var currentScale: MTPlayerConfig.Scale = .default

    public lazy var playControl: MTPlayerControls = {
        let control = MTPlayerControls()
        control.optionBlock = { [weak self] opt in
            self?.handleBasicOption(opt)
        }
        return control
    }()

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .fullScreen
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clickPause()
        stopTimer()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        stopTimer()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    open func configureUI() {
        navigationController?.navigationBar.isHidden = true
        view.addSubview(playControl)
        playControl.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    public var timer: DispatchSourceTimer?

    /// 加载HUD
    open func showLoading() {}
    /// 隐藏HUD
    open func hideLoading() {}
    /// 旋转到竖屏
    open func rotatePortrait() {
        MTPlayerConfig.allowedOrientation = .portrait
        UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }

    open func rotateHorizontal() {
        MTPlayerConfig.allowedOrientation = .landscapeRight
        UIDevice.current.setValue(3, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }

    /// 软硬解码已经更换
    open func softHardHasChanged() {
    }

    /// 播放速度已经更换
    open func rateHasChanged() {
    }

    /// 比例已经更换
    open func scaleHasChanged() {
    }

    /// timer每个周期调用的方法
    open func timerFetch() {
    }

    /// 点击了关闭
    open func tapClose() {
        rotatePortrait()
        dismiss(animated: true) {
            self.stopTimer()
        }
    }

    /// 点击了播放
    open func clickPlay() {
    }

    /// 点击了暂停
    open func clickPause() {
    }

    /// 点击了旋转
    open func clickRotate() {
        var targetOrientation = 1
        if MTPlayerConfig.allowedOrientation == .portrait {
            targetOrientation = 3
            MTPlayerConfig.allowedOrientation = .landscapeRight
        } else {
            targetOrientation = 1
            MTPlayerConfig.allowedOrientation = .portrait
        }
        UIDevice.current.setValue(targetOrientation, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }

    /// 拉拽了时间
    open func slide(to time: Float) {
    }

    /// 长按屏幕倍速
    open func longPress(_ isAcc: Bool) {
    }

    /// 开始播放
    open func startPlay() {
        stopTimer()
        isPlayToEnd = false
        startTimer()
//        playControl.duration = player.duration
        playControl.isPlaying = true
    }

    /// 播放完成
    open func completePlay() {
        isPlayToEnd = true
        playControl.isPlaying = false
    }
}

// MARK: Timer

extension MTPlayer {
    public func startTimer() {
        stopTimer()
        let timeSource = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: DispatchQueue.global())
        timeSource.schedule(deadline: .now(), repeating: .milliseconds(1000))
        timeSource.setEventHandler {
            DispatchQueue.main.async {
                self.timerFetch()
            }
        }
        timeSource.activate()
        timer = timeSource
    }

    public func stopTimer() {
        timer?.cancel()
        timer = nil
    }
}

extension MTPlayer {
    public func handleBasicOption(_ opt: MTPlayerControls.PlayerOption) {
        switch opt {
        case .close: tapClose()
        case .play:
            clickPlay()
        case .pause:
            clickPause()
        case .rotate:
            clickRotate()
        case let .slide(time):
            slide(to: time)
        case let .longPress(isAcc):
            longPress(isAcc)
        case .softHard:
            MTPlayerOptionAlert<MTPlayerConfig.SoftHardDecode>.showSoftHard(from: self, defaultOpt: currentSoftHard) { [weak self] softHard in
                self?.currentSoftHard = softHard
                self?.softHardHasChanged()
            }
        case .rate:
            MTPlayerOptionAlert<MTPlayerConfig.Rate>.showRate(from: self, defaultOpt: currentRate) { [weak self] rate in
                self?.currentRate = rate
                self?.playControl.updateSpeedButton(with: "\(rate.rawValue)")
                self?.rateHasChanged()
            }
        case .scale:
            MTPlayerOptionAlert<MTPlayerConfig.Scale>.showScale(from: self, defaultOpt: currentScale) { [weak self] scale in
                self?.currentScale = scale
                self?.scaleHasChanged()
            }
        }
    }
}
