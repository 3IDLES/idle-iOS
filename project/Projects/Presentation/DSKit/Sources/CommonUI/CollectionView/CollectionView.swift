//
//  CollectionView.swift
//  DSKit
//
//  Created by choijunios on 7/30/24.
//

import UIKit
import RxSwift
import RxCocoa

/// 섹션에 대한 정보를 표시합니다.
public struct SectionData {
    
    public typealias CellSize = CGSize
    
    public let titleText: String
    public let subTitle: String?
    public let subData: [CellData]
    public let cellSize: CellSize
    
    public init(titleText: String, subTitle: String? = nil, subData: [CellData], cellSize: CellSize) {
        self.titleText = titleText
        self.subTitle = subTitle
        self.subData = subData
        self.cellSize = cellSize
    }
}

extension SectionData.CellSize {
    /// Cell의 넓이가 동적으로 지정되는 경우 사용합니다.
    public static func heightOnly(_ height: CGFloat) -> SectionData.CellSize {
        .init(width: CGFloat.infinity, height: height)
    }
}

/// 셀정보를 표시합니다.
public struct CellData {
    public let cellText: String
    
    public init(cellText: String) {
        self.cellText = cellText
    }
    
    public static let fullSizeCell = CellData(cellText: "FullSizeCell")
}

public protocol CellRepresentable: UIView {
    static func createInstance() -> Self
}

/// 특정뷰룰 Cell로 랩핑합니다.
public class CellWrapper<Cell: CellRepresentable>: UICollectionViewCell {
    
    public typealias ViewType = Cell
    
    public static var identifier: String { String(describing: Cell.self) }
    
    public let innerView = Cell.createInstance()
    
    private var disposeBag: DisposeBag? = .init()
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
            
        contentView.addSubview(innerView)
        innerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            innerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            innerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            innerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            innerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    
    public override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}

/// 텍스트를 표시할 수 있는 Cell입니다, 선택/비선택 2가지 상태가 존재합니다.
public class IdleTextItemCell: UICollectionViewCell {
    
    public static let identifier = String(describing: IdleTextItemCell.self)

    // View
    public private(set) lazy var labelButtonView: StateButtonTyp1 = {
        let btn = StateButtonTyp1(
            text: "",
            initial: .normal
        )
        btn.label.typography = .Body2
        btn.label.attrTextColor = DSKitAsset.Colors.gray500.color
        return btn
    }()
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        contentView.addSubview(labelButtonView)
        labelButtonView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelButtonView.topAnchor.constraint(equalTo: contentView.topAnchor),
            labelButtonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            labelButtonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            labelButtonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

/// 타이틀을 표기하는 라벨입니다.
public class TitleHeaderView: UICollectionReusableView {
    
    public static let identifier = String(describing: TitleHeaderView.self)
    
    public let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    public let subTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .caption)
        label.attrTextColor = DSKitAsset.Colors.gray300.color
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stack = HStack(
            [titleLabel, subTitleLabel],
            spacing: 4,
            alignment: .center
        )
        
        [
            stack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            stack.leftAnchor.constraint(equalTo: self.leftAnchor),
            stack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}

/// CollectionView의 셀들을 좌로 정렬시키는 UICollectionViewFlowLayout
public class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
    
    /// 아이템과 관련된 셀의 Attribute에 접근할 수 있다.
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let attributes = super.layoutAttributesForElements(in: rect)
        var maxY = -1.0
        var leftMargin = self.sectionInset.left
        var currentSection = -1
        attributes?.forEach { attribute in
            if attribute.indexPath.section != currentSection || attribute.frame.origin.y > maxY {
                leftMargin = self.sectionInset.left
                maxY = attribute.frame.origin.y
                currentSection = attribute.indexPath.section
            }
            attribute.frame.origin.x = leftMargin
            leftMargin += attribute.frame.width + minimumLineSpacing
        }
        return attributes
    }
}
