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
 @file AKPlayDataInterface.h
 @brief ゲームデータインターフェースプロトコル
 
 キャラクターやタイルマップのイベント処理がゲームデータにアクセスする
 インターフェースのプロトコルを定義する。
 */

#import "AKToritoma.h"

@class AKEnemyShot;

/*!
 @brief ゲームデータインターフェースプロトコル
 
 キャラクターやタイルマップのイベント処理がゲームデータにアクセスする
 インターフェースのプロトコル。
 */
@protocol AKPlayDataInterface <NSObject>

/// x軸方向のスクロールスピード
@property (nonatomic)float scrollSpeedX;
/// y軸方向のスクロールスピード
@property (nonatomic)float scrollSpeedY;
/// 障害物キャラクター
@property (nonatomic, readonly)NSArray *blocks;
/// 自機の位置情報
@property (nonatomic, readonly)CGPoint playerPosition;

/// デバイス座標からタイル座標の取得
- (CGPoint)tilePositionFromDevicePosition:(CGPoint)devicePosition;
/// 自機弾生成
- (void)createPlayerShotAtX:(NSInteger)x y:(NSInteger)y;
/// 反射弾生成
- (void)createReflectiedShot:(AKEnemyShot *)enemyShot;
/// 敵生成
- (void)createEnemy:(NSInteger)type x:(NSInteger)x y:(NSInteger)y progress:(NSInteger)progress;
/// 敵弾インスタンスの取得
- (AKEnemyShot *)getEnemyShot;
/// 敵弾配置ノードの取得
- (CCNode *)getEnemyShotParent;
/// 画面効果生成
- (void)createEffect:(NSInteger)type x:(NSInteger)x y:(NSInteger)y;
/// 障害物生成
- (void)createBlock:(NSInteger)type x:(float)x y:(float)y;
/// 失敗時処理
- (void)miss;
/// 進行度を進める
- (void)addProgress:(NSInteger)progress;
/// スコア加算
- (void)addScore:(NSInteger)score;

@end
