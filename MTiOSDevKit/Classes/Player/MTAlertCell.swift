//
//  MTAlertCell.swift
//  MTiOSDevKit
//
//  Created by PanGu on 2022/8/30.
//

import Foundation
public class MTAlertCell: UITableViewCell {
    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    public var isChoosed: Bool = false {
        didSet {
            titleLabel.textColor = isChoosed ? MTPlayerConfig.progressColor : .white
            titleLabel.backgroundColor = isChoosed ? UIColor(red: 22 / 255.0, green: 22 / 255.0, blue: 22 / 255.0, alpha: 1) : .clear
        }
    }

    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        titleLabel.layer.cornerRadius = 8
        titleLabel.layer.masksToBounds = true
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(mt_baseline(25))
            $0.right.equalToSuperview().offset(mt_baseline(-25))
            $0.height.equalTo(mt_baseline(50))
            $0.centerY.equalToSuperview()
        }
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
