//
//  MTRateAlert.swift
//  MTiOSDevKit
//
//  Created by PanGu on 2022/8/30.
//

import Foundation


public extension MTPlayerOptionAlert{
    static func showSoftHard(from controller: UIViewController,
                             defaultOpt: MTPlayerConfig.SoftHardDecode,
                             completion: @escaping (MTPlayerConfig.SoftHardDecode)->Void){
        let alert = MTPlayerOptionAlert<MTPlayerConfig.SoftHardDecode>.init(defaultOption: defaultOpt,
                                                                            options: MTPlayerConfig.SoftHardDecode.allCases,
                                                                            flipFrom: .bottom)
        alert.optBlock = completion
        controller.present(alert, animated: true)
    }
    
    static func showRate(from controller: UIViewController,
                             defaultOpt: MTPlayerConfig.Rate,
                             completion: @escaping (MTPlayerConfig.Rate)->Void){
        let alert = MTPlayerOptionAlert<MTPlayerConfig.Rate>.init(defaultOption: defaultOpt,
                                                                            options: MTPlayerConfig.Rate.allCases,
                                                                            flipFrom: .bottom)
        alert.optBlock = completion
        controller.present(alert, animated: true)
    }
    
    static func showScale(from controller: UIViewController,
                             defaultOpt: MTPlayerConfig.Scale,
                             completion: @escaping (MTPlayerConfig.Scale)->Void){
        let alert = MTPlayerOptionAlert<MTPlayerConfig.Scale>.init(defaultOption: defaultOpt,
                                                                            options: MTPlayerConfig.Scale.allCases,
                                                                            flipFrom: .bottom)
        alert.optBlock = completion
        controller.present(alert, animated: true)
    }
    
    
}



public protocol MTPlayerOptionProtocol: Equatable{
    var title: String{  get}
}

open class MTPlayerOptionAlert<Option:MTPlayerOptionProtocol>: MTBaseAlert,UITableViewDataSource, UITableViewDelegate{
    
    public init(defaultOption:Option,
                           options:[Option],
                           flipFrom: MTBaseAlert.FlipFrom,
                           tapToDismiss: Bool = true)
    {
        super.init(flipFrom: flipFrom, tapToDismiss: tapToDismiss)
        currentOption = defaultOption
        self.options = options
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var currentOption: Option!
    public var options: [Option]!
    public var optBlock: ((Option)->Void)?

    public lazy var tableView: UITableView = {
        let view = UITableView()
        view.dataSource = self
        view.delegate = self
        view.register(MTAlertCell.self, forCellReuseIdentifier: "MTAlertCell")
        view.showsVerticalScrollIndicator = false
        view.rowHeight = mt_baseline(50)
        view.separatorStyle = .none
        view.backgroundColor = .clear
        return view
    }()

    open override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let opt = options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MTAlertCell", for: indexPath) as! MTAlertCell
        cell.title = opt.title
        cell.isChoosed = currentOption == opt
        return cell
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let opt = options[indexPath.row]
        currentOption = opt
        tableView.reloadData()
        dismiss(animated: true) {
            self.optBlock?(opt)
        }
    }
}

// MARK: - config UI

extension MTPlayerOptionAlert {
    private func configureUI() {
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        contentView.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.width.height.equalTo(mt_baseline(28))
            $0.top.height.equalTo(mt_baseline(16))
            $0.right.equalTo(tableView)
        }
    }
}

