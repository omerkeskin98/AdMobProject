//
//  ViewController.swift
//  AdMobProject
//
//  Created by Omer Keskin on 22.07.2024.
//

import GoogleMobileAds
import UIKit
import SnapKit

class ViewController: UIViewController, GADFullScreenContentDelegate {

    var bannerView: GADBannerView!
    private var interstitial: GADInterstitialAd?
    private var rewardedAd: GADRewardedAd?
    
    private let rewardedAdButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Click for rewarded ad", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 25)
        button.backgroundColor = .blue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rewardedAdButton.addTarget(self, action: #selector(adButtonClicked), for: .touchUpInside)
         loadInterstitialAd()
         loadRewardedAd()
         setupButtonPlacement()
         setupBannerAd()
    }
    
    private func setupButtonPlacement() {
        view.addSubview(rewardedAdButton)
        rewardedAdButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.width.equalTo(300)
        }
    }
    
    private func setupBannerAd() {
        let viewWidth = view.frame.inset(by: view.safeAreaInsets).width
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        
        bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        addBannerViewToView(bannerView)
    }
    
    private func loadRewardedAd() {
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: GADRequest()) { ad, error in
            if let error = error {
                print("Rewarded ad failed to load with error: \(error.localizedDescription)")
                return
            }
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
            print("Rewarded ad loaded.")
        }
    }
    
    @objc private func showRewardedAd() {
        guard let rewardedAd = rewardedAd else {
            print("Ad wasn't ready.")
            return
        }
        
        rewardedAd.present(fromRootViewController: self) {
            let reward = rewardedAd.adReward
            print("Reward received with currency \(reward.type), amount \(reward.amount.doubleValue)")
        }
    }
    
    @objc private func adButtonClicked() {
        showRewardedAd()
    }
    
    private func loadInterstitialAd() {
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest()) { [weak self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self?.interstitial = ad
            self?.interstitial?.fullScreenContentDelegate = self
            self?.presentInterstitialAd()
        }
    }
    
    private func presentInterstitialAd() {
        guard let interstitial = interstitial else {
            print("Ad wasn't ready.")
            return
        }
        
        interstitial.present(fromRootViewController: self)
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content with error: \(error.localizedDescription)")
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
    }
    
    private func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        bannerView.layer.borderWidth = 0.5
        bannerView.layer.borderColor = UIColor.black.cgColor
        
        bannerView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.centerX.equalToSuperview()
        }
    }

}
