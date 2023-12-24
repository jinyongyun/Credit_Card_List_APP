//
//  CardDetailViewController.swift
//  CreditCardList
//
//  Created by jinyong yun on 12/23/23.
//

import UIKit
import Lottie

class CardDetailViewController: UIViewController {
    
    var promotionDetail: PromotionDetail?
    
    @IBOutlet weak var lottieView: LottieAnimationView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var periodLabel: UILabel!
    
    @IBOutlet weak var conditionLabel: UILabel!
    
    @IBOutlet weak var benefitConditionLabel: UILabel!
    
    @IBOutlet weak var benefitDetailLabel: UILabel!
    
    @IBOutlet weak var benefitDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let animationView = LottieAnimationView(name: "money") //보통 이런 lottie 파일은 디자이너분이 마련
        lottieView.contentMode = .scaleAspectFit
        lottieView.addSubview(animationView)
        lottieView.frame = lottieView.bounds
        animationView.loopMode = .loop
        animationView.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let detail = promotionDetail else { return }
        
        titleLabel.text = """
          \(detail.companyName)카드 쓰면
          \(detail.amount)만원 드려요
        """
        
        periodLabel.text = detail.period
        conditionLabel.text = detail.condition
        benefitConditionLabel.text = detail.benefitCondition
        benefitDetailLabel.text = detail.benefitDetail
        benefitDateLabel.text = detail.benefitDate
    }
}
