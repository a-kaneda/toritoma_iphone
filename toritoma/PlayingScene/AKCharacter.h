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
 @file AKCharacter.h
 @brief キャラクタークラス定義
 
 当たり判定を持つオブジェクトの基本クラスを定義する。
 */

#import "AKToritoma.h"
#import "AKPlayDataInterface.h"

/// 障害物と衝突した時の動作
enum AKBlockHitAction {
    kAKBlockHitNone = 0,    ///< 無処理
    kAKBlockHitMove,        ///< 移動
    kAKBlockHitDisappear,   ///< 消滅
    kAKBlockHitPlayer,      ///< 自機
};

/// 障害物と接している面
enum AKBlockHitSide {
    kAKHitSideLeft = 1,     ///< 左側
    kAKHitSideRight = 2,    ///< 右側
    kAKHitSideTop = 4,      ///< 上側
    kAKHitSideBottom = 8    ///< 下側
};

// キャラクタークラス
@interface AKCharacter : NSObject {
    /// 画像
    CCSprite *image_;
    /// 当たり判定サイズ幅
    NSInteger width_;
    /// 当たり判定サイズ高さ
    NSInteger height_;
    /// 位置x座標
    float positionX_;
    /// 位置y座標
    float positionY_;
    /// 移動前x座標
    float prevPositionX_;
    /// 移動前y座標
    float prevPositionY_;
    /// 速度x方向
    float speedX_;
    /// 速度y方向
    float speedY_;
    /// HP
    NSInteger hitPoint_;
    /// 攻撃力
    NSInteger power_;
    /// ステージ上に存在しているかどうか
    BOOL isStaged_;
    /// アニメーションパターン数
    NSInteger animationPattern_;
    /// アニメーション間隔
    NSInteger animationInterval_;
    /// アニメーションフレーム数
    NSInteger animationFrame_;
    /// アニメーション繰り返し回数
    NSInteger animationRepeat_;
    /// アニメーション初期パターン
    NSInteger animationInitPattern_;
    /// スプライト名
    NSString *imageName_;
    /// スクロール速度の影響を受ける割合
    float scrollSpeed_;
    /// 障害物と衝突した時の動作
    enum AKBlockHitAction blockHitAction_;
    /// 障害物と接している面
    NSUInteger blockHitSide_;
    /// 画像表示のオフセット
    CGPoint offset_;
}

/// 画像
@property (nonatomic, retain)CCSprite *image;
/// 当たり判定サイズ幅
@property (nonatomic)NSInteger width;
/// 当たり判定サイズ高さ
@property (nonatomic)NSInteger height;
/// 位置x座標
@property (nonatomic)float positionX;
/// 位置y座標
@property (nonatomic)float positionY;
/// 移動前x座標
@property (nonatomic)float prevPositionX;
/// 移動前y座標
@property (nonatomic)float prevPositionY;
/// 速度x方向
@property (nonatomic)float speedX;
/// 速度y方向
@property (nonatomic)float speedY;
/// HP
@property (nonatomic)NSInteger hitPoint;
/// 攻撃力
@property (nonatomic)NSInteger power;
/// ステージ上に存在しているかどうか
@property (nonatomic)BOOL isStaged;
/// アニメーションパターン数
@property (nonatomic)NSInteger animationPattern;
/// アニメーション間隔
@property (nonatomic)NSInteger animationInterval;
/// アニメーションフレーム数
@property (nonatomic)NSInteger animationFrame;
/// アニメーション繰り返し回数
@property (nonatomic)NSInteger animationRepeat;
/// アニメーション初期パターン
@property (nonatomic)NSInteger animationInitPattern;
/// スクロール速度の影響を受ける割合
@property (nonatomic)float scrollSpeed;
/// 障害物と衝突した時の動作
@property (nonatomic)enum AKBlockHitAction blockHitAction;
/// 障害物と接している面
@property (nonatomic)NSUInteger blockHitSide;

// 画像名の取得
- (NSString *)imageName;
// 画像名の設定
- (void)setImageName:(NSString *)imageName;
// 移動処理
- (void)move:(id<AKPlayDataInterface>)data;
// キャラクター固有の動作
- (void)action:(id<AKPlayDataInterface>)data;
// 破壊処理
- (void)destroy:(id<AKPlayDataInterface>)data;
// 衝突判定(汎用)
- (BOOL)checkHit:(const NSEnumerator *)characters data:(id<AKPlayDataInterface>)data func:(SEL)func;
// キャラクター衝突判定
- (void)checkHit:(const NSEnumerator *)characters data:(id<AKPlayDataInterface>)data;
// 衝突処理
- (void)hit:(AKCharacter *)character data:(id<AKPlayDataInterface>)data;
// 障害物との衝突による移動
- (void)moveOfBlockHit:(AKCharacter *)character data:(id<AKPlayDataInterface>)data;;
// 障害物との衝突による消滅
- (void)disappearOfBlockHit:(AKCharacter *)character data:(id<AKPlayDataInterface>)data;;
// 画面外配置判定
- (BOOL)isOutOfStage:(id<AKPlayDataInterface>)data;
// 画像表示位置更新
- (void)updateImagePosition;
@end
