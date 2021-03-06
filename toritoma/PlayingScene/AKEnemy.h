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
 @file AKEnemy.h
 @brief 敵クラス定義
 
 敵キャラクターのクラスの定義をする。
 */

#import "AKCharacter.h"
#import "AKNWayAngle.h"

/// 作業領域の要素数
#define kAKEnemyWorkCount 5

/// 敵種別定義
struct AKEnemyDef {
    NSInteger destroy;              ///< 破壊処理の種別
    NSInteger image;                ///< 画像ID
    NSInteger animationFrame;       ///< アニメーションフレーム数
    NSInteger animationInterval;    ///< アニメーション更新間隔
    NSInteger hitWidth;             ///< 当たり判定の幅
    NSInteger hitHeight;            ///< 当たり判定の高さ
    NSInteger offsetX;              ///< 当たり判定オフセットx軸
    NSInteger offsetY;              ///< 当たり判定オフセットy軸
    NSInteger hitPoint;             ///< ヒットポイント
    NSInteger score;                ///< スコア
};

// 敵クラス
@interface AKEnemy : AKCharacter {
    /// 動作開始からの経過フレーム数(各敵種別で使用)
    NSInteger frame_;
    /// 動作状態(各敵種別で使用)
    NSInteger state_;
    /// 作業領域(各敵種別で使用)
    NSInteger work_[kAKEnemyWorkCount];
    /// 動作処理のセレクタ
    SEL action_;
    /// 破壊処理のセレクタ
    SEL destroy_;
    /// スコア
    NSInteger score_;
    /// 倒した時に進む進行度
    NSInteger progress_;
}

// 生成処理
- (void)createEnemyType:(NSInteger)type x:(NSInteger)x y:(NSInteger)y progress:(NSInteger)progress parent:(CCNode*)parent;
// 動作処理取得
- (SEL)actionSelector:(NSInteger)type;
// 破壊処理取得
- (SEL)destroySeletor:(NSInteger)type;
// トンボの動作処理
- (void)actionOfDragonfly:(id<AKPlayDataInterface>)data;
// アリの動作処理
- (void)actionOfAnt:(id<AKPlayDataInterface>)data;
// チョウの動作処理
- (void)actionOfButterfly:(id<AKPlayDataInterface>)data;
// テントウムシの動作処理
- (void)actionOfLadybug:(id<AKPlayDataInterface>)data;
// ミノムシの動作処理
- (void)actionOfBagworm:(id<AKPlayDataInterface>)data;
// セミの動作処理
- (void)actionOfCicada:(id<AKPlayDataInterface>)data;
// バッタの動作処理
- (void)actionOfGrasshopper:(id<AKPlayDataInterface>)data;
// ハチの動作処理
- (void)actionOfHornet:(id<AKPlayDataInterface>)data;
// ゴキブリの動作処理
- (void)actionOfCockroach:(id<AKPlayDataInterface>)data;
// カタツムリの動作処理
- (void)actionOfSnail:(id<AKPlayDataInterface>)data;
// クワガタの動作処理
- (void)actionOfStagBeetle:(id<AKPlayDataInterface>)data;
// カブトムシの動作処理
- (void)actionOfRhinocerosBeetle:(id<AKPlayDataInterface>)data;
// カマキリの動作処理
- (void)actionOfMantis:(id<AKPlayDataInterface>)data;
// 雑魚敵の破壊処理
- (void)destroyNormal:(id<AKPlayDataInterface>)data;
// 自機を狙うn-way弾発射
+ (void)fireNWayWithPosition:(CGPoint)position
                       count:(NSInteger)count
                    interval:(float)interval
                       speed:(float)speed
                        data:(id<AKPlayDataInterface>)data;
// 角度指定によるn-way弾発射
+ (void)fireNWayWithAngle:(float)angle
                     from:(CGPoint)position
                    count:(NSInteger)count
                 interval:(float)interval
                    speed:(float)speed
                 isScroll:(BOOL)isScroll
                     data:(id<AKPlayDataInterface>)data;
// 自機を狙うグループ弾発射
+ (void)fireGroupShotWithPosition:(CGPoint)position
                         distance:(const CGPoint *)distance
                            count:(NSInteger)count
                            speed:(float)speed
                             data:(id<AKPlayDataInterface>)data;
// 破裂弾発射
+ (void)fireBurstShotWithPosition:(CGPoint)position
                            count:(NSInteger)count
                         interval:(float)interval
                            speed:(float)speed
                    burstInterval:(float)burstInterval
                       burstSpeed:(float)burstSpeed
                             data:(id<AKPlayDataInterface>)data;
// 逆さま判定
- (void)checkReverse:(NSArray *)blocks;
// 障害物との衝突判定
+ (CGPoint)checkBlockPosition:(CGPoint)current
                         size:(CGSize)size
                    isReverse:(BOOL)isReverse
                         data:(id<AKPlayDataInterface>)data;
// 足元の障害物を取得する
+ (AKCharacter *)getBlockAtFeetAtX:(float)x
                              from:(float)top
                         isReverse:(BOOL)isReverse
                            blocks:(NSArray *)blocks;
@end
