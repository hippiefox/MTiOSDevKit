//
//  MTPlayerControls.swift
//  MTiOSDevKit
//
//  Created by PanGu on 2022/8/30.
//

import Foundation
import MediaPlayer
import UIKit
 

open class MTPlayerControls: UIView {
    public var optionBlock: ((PlayerOption) -> Void)?
    public var duration: TimeInterval = 0 {
        didSet {
            progressSlider.minimumValue = 0
            progressSlider.maximumValue = Float(duration)
        }
    }

    public var playTime: TimeInterval = 0 {
        didSet {
            timeLabel.text = Int(playTime).mt_2time() + "/" + Int(duration).mt_2time()
            progressSlider.value = Float(playTime)
            adjustUI()
        }
    }

    public var isPlaying: Bool = false {
        didSet {
            playButton.isSelected = !isPlaying
        }
    }

    public lazy var contentView = MTPlayerContentView()
    public lazy var gestureView = MTPlayerGestureView()
    public lazy var bottomView = MTPlayerBottomView()
    public lazy var topView = MTPlayerTopView()
    //  middle -
    public lazy var middleView = MTPlayerMiddleView()

    public lazy var tipsContainerView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()

    // - middle
    public lazy var appendixView = MTPlayerAppdendixView()

    public var appendixItems: [UIView] = []

    public lazy var backButton: MTButton = {
        let button = MTButton()
        button.iconSize = MTPlayerConfig.playControlItemSize
        button.iconNormal = MTPlayerConfig.back
        button.addTarget(self, action: #selector(tapBack), for: .touchUpInside)
        return button
    }()

    public lazy var brightnessTipsView: MTButton = {
        let button = MTButton()
        button.gap = 6
        button.position = .top
        button.iconNormal = MTPlayerConfig.brightness
        button.iconSize = MTPlayerConfig.playControlItemSize
        button.titleFont = .systemFont(ofSize: 12)
        button.titleColorNormal = .white
        button.isEnabled = false
        return button
    }()

    public lazy var volumeTipsView: MTButton = {
        let button = MTButton()
        button.iconNormal = MTPlayerConfig.volume
        button.iconSize = MTPlayerConfig.playControlItemSize
        button.position = .top
        button.titleFont = .systemFont(ofSize: 12)
        button.gap = 6
        button.titleColorNormal = .white
        button.isEnabled = false
        return button
    }()

    public lazy var volumeSlider: UISlider = {
        let volumeView = MPVolumeView(frame: .init(x: 0, y: 0, width: 200, height: 6))
        volumeView.showsVolumeSlider = false
        volumeView.showsRouteButton = false
        var volumViewSlider = UISlider()
        for subView in volumeView.subviews {
            if type(of: subView).description() == "MPVolumeSlider" {
                volumViewSlider = subView as! UISlider
                return volumViewSlider
            }
        }
        return volumViewSlider
    }()

    public lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(progressSlide), for: .valueChanged)
        slider.addTarget(self, action: #selector(endProgressSlider), for: .touchUpInside)
        slider.tintColor = MTPlayerConfig.progressColor
        slider.setThumbImage(MTPlayerConfig.slide, for: .normal)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapSlider(_:)))
        slider.addGestureRecognizer(tap)
        return slider
    }()

    public lazy var playButton: MTButton = {
        let button = MTButton()
        
        button.iconNormal = MTPlayerConfig.pause
        button.iconSelected = MTPlayerConfig.play
        button.position = .left
        button.gap = mt_baseline(8)
        button.iconSize = MTPlayerConfig.playControlItemSize
        button.addTarget(self, action: #selector(playAndPause), for: .touchUpInside)
        return button
    }()

    lazy var rotateButton: MTButton = {
        let button = MTButton()
        button.iconNormal = MTPlayerConfig.rotate
        button.position = .top
        button.iconSize = MTPlayerConfig.playControlItemSize
        button.addTarget(self, action: #selector(tapRotate), for: .touchUpInside)
        return button
    }()

    public var isLock: Bool = false
    public lazy var lockButton: MTButton = {
        let button = MTButton()
        button.iconNormal = MTPlayerConfig.unlock
        button.iconSelected = MTPlayerConfig.lock
        button.gap = 6
        button.titleFont = .systemFont(ofSize: 10)
        button.titleColorNormal = .white
        button.titleNormal = "解锁"
        button.titleSelected = "锁屏"
        button.position = .top
        button.iconSize = MTPlayerConfig.playControlItemSize
        button.addTarget(self, action: #selector(tapLock), for: .touchUpInside)
        return button
    }()

    public lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.textColor = .white
        return label
    }()

    public lazy var timeTipsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.7)
        return label
    }()

    public lazy var accelerateTipsView: MTButton = {
        let button = MTButton()
        button.iconNormal = MTPlayerConfig.accelerate
        button.titleFont = .systemFont(ofSize: 12)
        button.titleColorNormal = .white
        button.titleNormal = "3倍速播放中"
        button.iconSize = .init(width: mt_baseline(17), height: mt_baseline(17))
        button.position = .left
        button.backgroundColor = UIColor(red: 42/255.0, green: 42/255.0, blue: 42/255.0, alpha: 1)
        button.isEnabled = false
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        return button
    }()

    public lazy var rateButton: UIButton = {
        let color = UIColor.white
        let button = UIButton()
        button.addTarget(self, action: #selector(tapRate), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 8)
        button.setTitleColor(color, for: .normal)
        button.setTitle("1.0", for: .normal)
        button.layer.cornerRadius = 2
        button.layer.masksToBounds = true
        button.layer.borderColor = color.cgColor
        button.layer.borderWidth = 2
        return button
    }()

    public lazy var softHardButton: MTButton = {
        let button = MTButton()
        button.titleColorNormal = .white
        button.titleFont = .systemFont(ofSize: 10)
        button.gap = 6
        button.position = .top
        button.iconNormal = MTPlayerConfig.softHardDecode
        button.iconSize = MTPlayerConfig.playControlItemSize
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleNormal = "软硬解"
        button.addTarget(self, action: #selector(tapSoftHard), for: .touchUpInside)
        return button
    }()

    public lazy var scaleButton: MTButton = {
        let button = MTButton()
        button.titleColorNormal = .white
        button.titleFont = .systemFont(ofSize: 10)
        button.gap = 6
        button.position = .top
        button.iconNormal = MTPlayerConfig.scale
        button.iconSize = MTPlayerConfig.playControlItemSize
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleNormal = "画面"
        button.addTarget(self, action: #selector(tapScale), for: .touchUpInside)
        return button
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        addGestures()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var lastTouchTime: TimeInterval = Date().timeIntervalSince1970
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        lastTouchTime = Date().timeIntervalSince1970
        return super.hitTest(point, with: event)
    }

    open func adjustUI() {
        let now = Date().timeIntervalSince1970
        let isLongEnough = now - lastTouchTime > 3
        if isLock, isLongEnough {
            lockButton.isHidden = true
        }

        if isLock == false, isPlaying, isLongEnough {
            toggleShowLockedViews(false)
        }
    }

    // MARK: (gestures)

    public lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapSelf(_:)))
        tap.delegate = self
        return tap
    }()

    public var isAccellarate: Bool = false
    public lazy var longPress: UILongPressGestureRecognizer = {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressSelf(_:)))
        longPress.delegate = self
        return longPress
    }()

    public var panOption: PanOption = .none
    public var startPanLocation: CGPoint = .zero
    public var startPanValue: Float = 0
    public lazy var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panSelf(_:)))
        pan.delegate = self
        return pan
    }()

    open func updateSpeedButton(with speed: String) {
        rateButton.setTitle(speed, for: .normal)
    }
}

// MARK: UIGestureRecognizerDelegate

extension MTPlayerControls: UIGestureRecognizerDelegate {
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var result = true
        let loc = touch.location(in: contentView)

        let forbidArea: [UIView] = [topView, bottomView, appendixView]
        let touchForbid = forbidArea.filter { $0.frame.contains(loc) }.count > 0
        let forbidAreaShow = forbidArea.filter { $0.isHidden == false }.count > 0
        if touchForbid && forbidAreaShow {
            result = false
        }

        return result
    }
}

// MARK: - Actions

extension MTPlayerControls {
    @objc open func tapBack() {
        optionBlock?(.close)
    }

    @objc open func playAndPause(_ sender: MTButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            optionBlock?(.pause)
        } else {
            optionBlock?(.play)
        }
    }

    @objc open func tapRotate() {
        optionBlock?(.rotate)
    }

    @objc open func tapLock(_ sender: MTButton) {
        sender.isSelected = !sender.isSelected
        isLock = sender.isSelected
        toggleShowLockedViews(!isLock)
        sender.isHidden = false
        pan.isEnabled = !isLock
        longPress.isEnabled = !isLock
    }

    @objc open func tapRate() {
        optionBlock?(.rate)
    }

    @objc open func tapSoftHard() {
        optionBlock?(.softHard)
    }

    @objc open func tapScale() {
        optionBlock?(.scale)
    }

    // MARK: (progress slider)

    @objc open func progressSlide(_ sender: UISlider) {
        let second = Int(sender.value)
        showTimeTips(second)
    }

    @objc open func tapSlider(_ sender: UITapGestureRecognizer) {
        let p = sender.location(in: progressSlider)
        let targetValue = (progressSlider.maximumValue - progressSlider.minimumValue) * Float(p.x / progressSlider.bounds.width)
        progressSlider.value = targetValue
        endProgressSlider(progressSlider)
    }

    @objc open func endProgressSlider(_ sender: UISlider) {
        hideTipViews()
        let time = Int(sender.value)
        timeLabel.text = time.mt_2time() + "/" + Int(duration).mt_2time()
        optionBlock?(.slide(sender.value))
    }

    // MARK: (gesture)

    open func addGestures() {
        gestureView.addGestureRecognizer(tap)
        gestureView.addGestureRecognizer(longPress)
        gestureView.addGestureRecognizer(pan)
    }

    @objc open func tapSelf(_ gesture: UIGestureRecognizer) {
        if isLock {
            lockButton.isHidden = false
        } else {
            let isHide = lockButton.isHidden
            toggleShowLockedViews(isHide)
        }
    }

    @objc open func longPressSelf(_ sender: UIGestureRecognizer) {
        var isAcc = false
        switch sender.state {
        case .began, .changed: isAcc = true
        default: isAcc = false
        }

        if isAcc != isAccellarate {
            isAccellarate = isAcc
            optionBlock?(.longPress(isAcc))
        }

        if isAccellarate {
            showAccelerateTips()
        } else {
            hideTipViews()
        }
    }

    @objc open func panSelf(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            let loc = sender.location(in: self)
            startPanLocation = loc
            startPanValue = Float(playTime)
        case .changed:
            let loc = sender.location(in: self)
            let xPan = loc.x - startPanLocation.x
            let yPan = loc.y - startPanLocation.y

            // 首次移动，判断操作手势
            if panOption == .none {
                if xPan != 0 {
                    panOption = .progress
                } else if yPan != 0 {
                    if loc.x < frame.size.width / 2 {
                        panOption = .lightness
                    } else if loc.x > frame.size.width / 2 {
                        panOption = .volume
                    }
                }
                // 修正移动手势
                if xPan != 0 {
                    let absX = abs(xPan)
                    let absY = abs(yPan)
                    if absY / absX > 1.8 {
                        if loc.x < frame.size.width / 2 {
                            panOption = .lightness
                        } else if loc.x > frame.size.width / 2 {
                            panOption = .volume
                        }
                    }
                }
            }

            switch panOption {
            case .none: break
            case .progress:
                let slideDuration: Float = max(Float(duration / 6), 120)
                let sildeFrame = Float(gestureView.frame.width)
                startPanValue += (slideDuration * Float(xPan) / sildeFrame)
                startPanValue = max(0, startPanValue)
                startPanValue = min(Float(duration), startPanValue)
                showTimeTips(Int(startPanValue))
            case .volume:
                let slideFrame = Float(gestureView.frame.height)
                volumeSlider.value += (volumeSlider.maximumValue * Float(-yPan) / slideFrame)
                showVolumeTips("\(Int(volumeSlider.value / volumeSlider.maximumValue * 100))%")
            case .lightness:
                let slideFrame = bounds.height
                UIScreen.main.brightness += 1 * CGFloat(-yPan / slideFrame)
                showBrightnessTips("\(Int(UIScreen.main.brightness * 100))%")
            }
            startPanLocation = loc
        case .ended:
            hideTipViews()
            switch panOption {
            case .progress: optionBlock?(.slide(startPanValue))
            default: break
            }
            panOption = .none
            startPanLocation = .zero
        default:
            panOption = .none
            startPanLocation = .zero
            hideTipViews()
        }
    }
}

// MARK: - - Configure UI

extension MTPlayerControls {
    open func configureUI() {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.left.equalTo(self.safeAreaLayoutGuide.snp.left)
            $0.right.equalTo(self.safeAreaLayoutGuide.snp.right)
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        contentView.addSubview(gestureView)
        gestureView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        let topH = self.safeAreaInsets.top > 0 ? mt_baseline(44) : mt_baseline(64)
        contentView.addSubview(topView)
        topView.snp.makeConstraints {
            $0.height.equalTo(topH)
            $0.left.right.top.equalToSuperview()
        }

        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(mt_baseline(64))
        }

        addSubview(middleView)
        middleView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
            $0.top.equalTo(topView.snp.bottom)
        }

        addSubview(appendixView)
        appendixView.snp.makeConstraints {
            $0.width.equalTo(44)
            $0.height.equalTo(200)
            $0.right.equalToSuperview().offset(-10)
            $0.bottom.equalTo(bottomView.snp.top).offset(-20)
        }

        // MARK: (topView)

        topView.addSubview(backButton)
        backButton.snp.remakeConstraints {
            $0.size.equalTo(CGSize(width: mt_baseline(30), height: mt_baseline(30)))
            $0.left.equalTo(mt_baseline(15))
            $0.centerY.equalToSuperview()
        }

        // MARK: (middleView)

        middleView.isUserInteractionEnabled = false
        middleView.addSubview(tipsContainerView)
        tipsContainerView.isHidden = true
        tipsContainerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalToSuperview()
        }

        timeTipsLabel.isHidden = true
        tipsContainerView.addSubview(timeTipsLabel)
        timeTipsLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(mt_baseline(50))
        }

        accelerateTipsView.isHidden = true
        tipsContainerView.addSubview(accelerateTipsView)
        accelerateTipsView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 168, height: 44))
            $0.centerX.equalToSuperview()
            $0.top.equalTo(15)
        }

        volumeTipsView.isHidden = true
        tipsContainerView.addSubview(volumeTipsView)
        volumeTipsView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(CGSize(width: mt_baseline(100), height: mt_baseline(100)))
        }

        brightnessTipsView.isHidden = true
        tipsContainerView.addSubview(brightnessTipsView)
        brightnessTipsView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(volumeTipsView)
        }

        // MARK: (bottomView)

        bottomView.addSubview(progressSlider)
        progressSlider.snp.makeConstraints {
            $0.left.equalTo(mt_baseline(20))
            $0.right.equalToSuperview().offset(mt_baseline(-20))
            $0.top.equalToSuperview()
            $0.height.equalTo(mt_baseline(22))
        }

        bottomView.addSubview(playButton)
        playButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: mt_baseline(30), height: mt_baseline(30)))
            $0.left.equalTo(progressSlider)
            $0.top.equalTo(progressSlider.snp.bottom).offset(mt_baseline(2))
        }

        bottomView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints {
            $0.centerY.equalTo(playButton)
            $0.left.equalTo(playButton.snp.right).offset(15)
        }

        bottomView.addSubview(rotateButton)
        rotateButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: mt_baseline(30), height: mt_baseline(30)))
            $0.right.equalTo(progressSlider)
            $0.centerY.equalTo(playButton)
        }

        // MARK: (Appendix)

        appendixItems = [lockButton, scaleButton, softHardButton]
        configAppendix()
    }

    open func configAppendix() {
        appendixView.subviews.forEach {
            $0.removeFromSuperview()
        }

        let itemSpace: CGFloat = 2
        var preview: UIView?
        let items = appendixItems.reversed()
        items.forEach {
            appendixView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.width.height.equalTo(44)
                make.centerX.equalToSuperview()
                if preview == nil {
                    make.bottom.equalToSuperview()
                } else {
                    make.bottom.equalTo(preview!.snp.top).offset(mt_baseline(-itemSpace))
                }
            }
            preview = $0
        }

        appendixView.snp.updateConstraints {
            $0.height.equalTo(CGFloat(items.count) * (itemSpace + 44))
        }
    }

    /// 隐藏所有提示语
    open func hideTipViews() {
        tipsContainerView.subviews.forEach {
            $0.isHidden = true
        }
        tipsContainerView.isHidden = true
    }

    open func toggleShowLockedViews(_ isShow: Bool) {
        let apViews = appendixView.subviews
        let toDoViews: [UIView] = [bottomView, topView] + apViews
        toDoViews.forEach {
            $0.isHidden = !isShow
        }
    }

    open func showTimeTips(_ toTime: Int) {
        let toTimeStr = toTime.mt_2time()
        let str = toTimeStr + " / " + Int(duration).mt_2time()
        let toTimeRange = (str as NSString).range(of: toTimeStr)
        let mAttr = NSMutableAttributedString(string: str)
        mAttr.addAttributes([.foregroundColor: UIColor.white], range: toTimeRange)
        timeTipsLabel.attributedText = mAttr
        timeTipsLabel.isHidden = false
        tipsContainerView.isHidden = false
    }

    open func showAccelerateTips() {
        tipsContainerView.isHidden = false
        accelerateTipsView.isHidden = false
    }

    open func showVolumeTips(_ text: String) {
        volumeTipsView.titleNormal = text
        volumeTipsView.isHidden = false
        tipsContainerView.isHidden = false
    }

    open func showBrightnessTips(_ text: String) {
        brightnessTipsView.titleNormal = text
        brightnessTipsView.isHidden = false
        tipsContainerView.isHidden = false
    }
}



private extension Int{
    func mt_2time()-> String{
        let second = self
        let h = second / 3600
        let m = second % 3600 / 60
        let s = second % 60
        let hStr = String(format: "%02d", h)
        let mStr = String(format: "%02d", m)
        let sStr = String(format: "%02d", s)
        if h > 0 { return "\(hStr):\(mStr):\(sStr)" }
        if m > 0 { return "\(mStr):\(sStr)" }
        return "0:\(sStr)"
    }
}
