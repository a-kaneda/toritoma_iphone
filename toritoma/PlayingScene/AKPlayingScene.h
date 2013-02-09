/*!
 @file AKPlayingScene.h
 @brief プレイシーンの定義
 
 プレイシーンクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKLib.h"
#import "AKPlayData.h"
#import "AKChickenGauge.h"

@class AKPlayData;

/// ゲームプレイの状態
enum AKGameState {
    kAKGameStatePreLoad = 0,    ///< ゲームシーン読み込み前
    kAKGameStateStart,          ///< ゲーム開始時
    kAKGameStatePlaying,        ///< プレイ中
    kAKGameStateStageClear,     ///< ステージクリア後
    kAKGameStateResult,         ///< リザルト画面表示中
    kAKGameStateGameOver,       ///< ゲームオーバーの表示中
    kAKGameStateGameClear,      ///< ゲームクリア時
    kAKGameStatePause,          ///< 一時停止中
    kAKGameStateQuitMenu,       ///< 終了メニュー表示中
    kAKGameStateWait,           ///< アクション終了待機中
    kAKGameStateSleep           ///< スリープ処理中
};

// プレイシーンクラス
@interface AKPlayingScene : CCScene {
    /// ゲームデータ
    AKPlayData *data_;
    /// ゲームプレイの状態
    enum AKGameState state_;
    /// チキンゲージ
    AKChickenGauge *chickenGauge_;
    /// シールドボタン
    CCSprite *shieldButton_;
}

/// ゲームデータ
@property (nonatomic, retain)AKPlayData *data;
/// ゲームプレイの状態
@property (nonatomic)enum AKGameState state;
/// チキンゲージ
@property (nonatomic, retain)AKChickenGauge *chickenGauge;
/// シールドボタン
@property (nonatomic, retain)CCSprite *shieldButton;

// キャラクターレイヤー取得
- (CCLayer *)characterLayer;
// ゲーム開始時の更新処理
- (void)updateStart:(ccTime)dt;
// プレイ中の更新処理
- (void)updatePlaying:(ccTime)dt;
// 自機の移動
- (void)movePlayer:(id)object;
// シールドボタン選択処理
- (void)touchShieldButton:(id)object;
// シールドボタン表示切替
- (void)setShieldButtonSelected:(Boolean)selected;

@end
