/*
 * Copyright (c) 2013 Akihiro Kaneda.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   1.Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *   2.Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *   3.Neither the name of the Monochrome Soft nor the names of its contributors
 *     may be used to endorse or promote products derived from this software
 *     without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
/*!
 @file AKPlayingScene.h
 @brief プレイシーンの定義
 
 プレイシーンクラスを定義する。
 */

#import "AKLib.h"
#import "AKPlayingSceneIF.h"
#import "AKPlayData.h"
#import "AKChickenGauge.h"
#import "AKLife.h"
#import "AKTitleScene.h"

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
    /// スリープ後に遷移する状態
    enum AKGameState nextState_;
    /// スリープ時間
    float sleepTime_;
    /// 残機表示
    AKLife *life_;
}

/// ゲームデータ
@property (nonatomic, retain)AKPlayData *data;
/// ゲームプレイの状態
@property (nonatomic)enum AKGameState state;
/// キャラクターレイヤー
@property (nonatomic, readonly)CCLayer *characterLayer;
/// 情報レイヤー
@property (nonatomic, readonly)CCLayer *infoLayer;
/// インターフェースレイヤー
@property (nonatomic, readonly)AKPlayingSceneIF *interfaceLayer;
/// チキンゲージ
@property (nonatomic, readonly)AKChickenGauge *chickenGauge;
/// 残機表示
@property (nonatomic, readonly)AKLife *life;
/// スコア表示
@property (nonatomic, readonly)AKLabel *score;
/// ハイスコア表示
@property (nonatomic, readonly)AKLabel *hiScore;
/// ゲームオーバーかどうか
@property (nonatomic, readonly)BOOL isGameOver;

// 背景レイヤー作成
- (void)createBackGround;
// キャラクターレイヤー作成
- (void)createCharacterLayer;
// 情報レイヤー作成
- (void)createInfoLayer;
// インターフェースレイヤー作成
- (void)createInterface;
// 枠レイヤー作成
- (void)createFrame;
// 自機の移動
- (void)movePlayer:(id)object;
// シールドボタン選択処理
- (void)touchShieldButton:(id)object;
// 終了ボタン選択処理
- (void)touchQuitButton:(id)object;
// ゲーム開始時の更新処理
- (void)updateStart:(ccTime)dt;
// プレイ中の更新処理
- (void)updatePlaying:(ccTime)dt;
// スリープ処理中の更新処理
- (void)updateSleep:(ccTime)dt;
// シールドボタン表示切替
- (void)setShieldButtonSelected:(BOOL)selected;
// スコアラベル更新
- (void)setScoreLabel:(NSInteger)score;
// ハイスコアラベル更新
- (void)setHiScoreLabel:(NSInteger)hiScore;
// ゲームオーバー
- (void)gameOver;

@end
