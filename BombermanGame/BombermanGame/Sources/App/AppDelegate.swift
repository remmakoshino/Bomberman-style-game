//
//  AppDelegate.swift
//  BombermanGame
//
//  iOS向けボンバーマン風アクションゲーム
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // アプリケーション起動時の初期設定
        configureAppearance()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // ゲームを一時停止
        NotificationCenter.default.post(name: .gameShouldPause, object: nil)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // バックグラウンド移行時の処理
        NotificationCenter.default.post(name: .gameShouldPause, object: nil)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // フォアグラウンド復帰時の処理
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // アクティブ状態復帰時の処理
    }
    
    // MARK: - Private Methods
    
    private func configureAppearance() {
        // ステータスバーを非表示
        // ナビゲーションバーの外観設定（必要に応じて）
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let gameShouldPause = Notification.Name("gameShouldPause")
    static let gameShouldResume = Notification.Name("gameShouldResume")
    static let gameDidEnd = Notification.Name("gameDidEnd")
}
