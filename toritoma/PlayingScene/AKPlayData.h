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
 @file AKPlayData.h
 @brief ゲームデータ
 
 プレイ画面シーンのデータを管理するクラスを定義する。
 */

#import "AKToritoma.h"
#import "AKPlayingScene.h"
#import "AKPlayer.h"
#import "AKTileMap.h"
#import "AKCharacterPool.h"
#import "AKEnemyShot.h"
#import "AKPlayDataInterface.h"

@class AKPlayingScene;

// ゲームデータ
@interface AKPlayData : NSObject<AKPlayDataInterface> {
    /// シーンクラス(弱い参照)
    AKPlayingScene *scene_;
    /// ステージ番号
    NSInteger stage_;
    /// クリア後の待機フレーム数
    NSInteger clearWait_;
    /// 復活待機フレーム数
    NSInteger rebirthWait_;
    /// 残機
    NSInteger life_;
    /// スコア
    NSInteger score_;
    /// ハイスコア
    NSInteger hiScore_;
    /// スクリプト情報
    AKTileMap *tileMap_;
    /// 自機
    AKPlayer *player_;
    /// 自機弾プール
    AKCharacterPool *playerShotPool_;
    /// 反射弾プール
    AKCharacterPool *reflectedShotPool_;
    /// 敵キャラプール
    AKCharacterPool *enemyPool_;
    /// 敵弾プール
    AKCharacterPool *enemyShotPool_;
    /// 画面効果プール
    AKCharacterPool *effectPool_;
    /// 障害物プール
    AKCharacterPool *blockPool_;
    /// キャラクター配置バッチノード
    NSMutableArray *batches_;
    /// シールドモード
    BOOL shield_;
    /// x軸方向のスクロールスピード
    float scrollSpeedX_;
    /// y軸方向のスクロールスピード
    float scrollSpeedY_;
}

/// シーンクラス(弱い参照)
@property (nonatomic, readonly)AKPlayingScene *scene;
/// 残機
@property (nonatomic)NSInteger life;
/// スクリプト情報
@property (nonatomic, retain)AKTileMap *tileMap;
/// 自機
@property (nonatomic, retain)AKPlayer *player;
/// 自機弾プール
@property (nonatomic, retain)AKCharacterPool *playerShotPool;
/// 反射弾プール
@property (nonatomic, retain)AKCharacterPool *refrectedShotPool;
/// 敵キャラプール
@property (nonatomic, retain)AKCharacterPool *enemyPool;
/// 敵弾プール
@property (nonatomic, retain)AKCharacterPool *enemyShotPool;
/// 画面効果プール
@property (nonatomic, retain)AKCharacterPool *effectPool;
/// 障害物プール
@property (nonatomic, retain)AKCharacterPool *blockPool;
/// キャラクター配置バッチノード
@property (nonatomic, retain)NSMutableArray *batches;
/// シールドモード
@property (nonatomic)BOOL shield;
/// x軸方向のスクロールスピード
@property (nonatomic)float scrollSpeedX;
/// y軸方向のスクロールスピード
@property (nonatomic)float scrollSpeedY;

// オブジェクト初期化処理
- (id)initWithScene:(AKPlayingScene *)scene;
// メンバオブジェクト生成処理
- (void)createMember;
// 初期値設定処理
- (void)clearPlayData;
// スクリプト読み込み
- (void)readScript:(NSInteger)stage;
// ハイスコアファイル読込
- (void)readHiScore;
// ハイスコアファイル書込
- (void)writeHiScore;
// 状態更新
- (void)update;
// 自機の移動
- (void)movePlayerByDx:(float)dx dy:(float)dy;
// ツイートメッセージの作成
- (NSString *)makeTweet;
// ポーズ
- (void)pause;
// ゲーム再開
- (void)resume;

@end
