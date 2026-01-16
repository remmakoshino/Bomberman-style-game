//
//  AudioManager.swift
//  BombermanGame
//
//  オーディオ管理システム
//

import Foundation
import AVFoundation
import SpriteKit

/// オーディオマネージャー - BGMとSEの再生管理
final class AudioManager {
    
    // MARK: - Singleton
    
    static let shared = AudioManager()
    
    // MARK: - Properties
    
    /// BGMプレイヤー
    private var bgmPlayer: AVAudioPlayer?
    
    /// SE用のオーディオノード（複数同時再生対応）
    private var soundEffects: [String: SKAction] = [:]
    
    /// BGMの音量（0.0 - 1.0）
    var bgmVolume: Float = 0.7 {
        didSet {
            bgmPlayer?.volume = bgmVolume
            saveSoundSettings()
        }
    }
    
    /// SEの音量（0.0 - 1.0）
    var sfxVolume: Float = 1.0 {
        didSet {
            saveSoundSettings()
        }
    }
    
    /// BGMがミュートかどうか
    var isBGMMuted: Bool = false {
        didSet {
            if isBGMMuted {
                bgmPlayer?.volume = 0
            } else {
                bgmPlayer?.volume = bgmVolume
            }
            saveSoundSettings()
        }
    }
    
    /// SEがミュートかどうか
    var isSFXMuted: Bool = false {
        didSet {
            saveSoundSettings()
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        setupAudioSession()
        loadSoundSettings()
        preloadSoundEffects()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - BGM
    
    /// BGMを再生
    func playBGM(_ name: String, loop: Bool = true) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("BGM file not found: \(name)")
            return
        }
        
        do {
            bgmPlayer = try AVAudioPlayer(contentsOf: url)
            bgmPlayer?.numberOfLoops = loop ? -1 : 0
            bgmPlayer?.volume = isBGMMuted ? 0 : bgmVolume
            bgmPlayer?.prepareToPlay()
            bgmPlayer?.play()
        } catch {
            print("Failed to play BGM: \(error)")
        }
    }
    
    /// BGMを停止
    func stopBGM() {
        bgmPlayer?.stop()
        bgmPlayer = nil
    }
    
    /// BGMを一時停止
    func pauseBGM() {
        bgmPlayer?.pause()
    }
    
    /// BGMを再開
    func resumeBGM() {
        bgmPlayer?.play()
    }
    
    /// BGMをフェードアウト
    func fadeOutBGM(duration: TimeInterval, completion: (() -> Void)? = nil) {
        guard let player = bgmPlayer else {
            completion?()
            return
        }
        
        let steps = 20
        let stepDuration = duration / Double(steps)
        let volumeStep = player.volume / Float(steps)
        
        var currentStep = 0
        
        Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
            currentStep += 1
            player.volume -= volumeStep
            
            if currentStep >= steps {
                timer.invalidate()
                self?.stopBGM()
                completion?()
            }
        }
    }
    
    // MARK: - Sound Effects
    
    /// SE効果音の種類
    enum SoundEffect: String {
        case explosion = "explosion"
        case placeBomb = "place_bomb"
        case itemPickup = "item_pickup"
        case playerDeath = "player_death"
        case enemyDeath = "enemy_death"
        case stageClear = "stage_clear"
        case gameOver = "game_over"
        case buttonPress = "button_press"
        case walk = "walk"
    }
    
    /// SEをプリロード
    private func preloadSoundEffects() {
        for effect in [SoundEffect.explosion, .placeBomb, .itemPickup] {
            if let _ = Bundle.main.url(forResource: effect.rawValue, withExtension: "wav") {
                soundEffects[effect.rawValue] = SKAction.playSoundFileNamed(
                    "\(effect.rawValue).wav",
                    waitForCompletion: false
                )
            }
        }
    }
    
    /// SEを再生（SKNodeを使用）
    func playSoundEffect(_ effect: SoundEffect, on node: SKNode) {
        guard !isSFXMuted else { return }
        
        if let action = soundEffects[effect.rawValue] {
            // 音量調整のためにカスタムアクションを使用
            let adjustedAction = SKAction.run {
                // SKActionでは直接音量調整できないため、
                // 実際のプロジェクトではAVAudioPlayerを使用するか
                // カスタムサウンドシステムを実装する
            }
            node.run(SKAction.sequence([adjustedAction, action]))
        }
    }
    
    /// SEを再生（AVAudioPlayer使用、複数同時再生可能）
    func playSoundEffect(_ effect: SoundEffect) {
        guard !isSFXMuted else { return }
        
        guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "wav") else {
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = self.sfxVolume
                player.prepareToPlay()
                player.play()
            } catch {
                print("Failed to play sound effect: \(error)")
            }
        }
    }
    
    // MARK: - Settings Persistence
    
    private func saveSoundSettings() {
        let defaults = UserDefaults.standard
        defaults.set(bgmVolume, forKey: "bgmVolume")
        defaults.set(sfxVolume, forKey: "sfxVolume")
        defaults.set(isBGMMuted, forKey: "isBGMMuted")
        defaults.set(isSFXMuted, forKey: "isSFXMuted")
    }
    
    private func loadSoundSettings() {
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: "bgmVolume") != nil {
            bgmVolume = defaults.float(forKey: "bgmVolume")
        }
        
        if defaults.object(forKey: "sfxVolume") != nil {
            sfxVolume = defaults.float(forKey: "sfxVolume")
        }
        
        isBGMMuted = defaults.bool(forKey: "isBGMMuted")
        isSFXMuted = defaults.bool(forKey: "isSFXMuted")
    }
}
