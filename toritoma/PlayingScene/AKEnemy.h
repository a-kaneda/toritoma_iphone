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

/// 敵種別定義
struct AKEnemyDef {
    NSInteger destroy;          ///< 破壊処理の種別
    NSInteger image;            ///< 画像ID
    NSInteger animationFrame;   ///< アニメーションフレーム数
    float animationInterval;    ///< アニメーション更新間隔
    NSInteger hitWidth;         ///< 当たり判定の幅
    NSInteger hitHeight;        ///< 当たり判定の高さ
    NSInteger hitPoint;         ///< ヒットポイント
    NSInteger score;            ///< スコア
};

// 敵クラス
@interface AKEnemy : AKCharacter {
    /// 動作開始からの経過時間(各敵種別で使用)
    ccTime time_;
    /// 動作状態(各敵種別で使用)
    NSInteger state_;
    /// 作業領域(各敵種別で使用)
    float work_;
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
- (void)actionOfDragonfly:(NSNumber *)dt data:(id<AKPlayDataInterface>)data;
// アリの動作処理
- (void)actionOfAnt:(NSNumber *)dt data:(id<AKPlayDataInterface>)data;
// チョウの動作処理
- (void)actionOfButterfly:(NSNumber *)dt data:(id<AKPlayDataInterface>)data;
// テントウムシの動作処理
- (void)actionOfLadybug:(NSNumber *)dt data:(id<AKPlayDataInterface>)data;
// ミノムシの動作処理
- (void)actionOfBagworm:(NSNumber *)dt data:(id<AKPlayDataInterface>)data;
// セミの動作処理
- (void)actionOfCicada:(NSNumber *)dt data:(id<AKPlayDataInterface>)data;
// バッタの動作処理
- (void)actionOfGrasshopper:(NSNumber *)dt data:(id<AKPlayDataInterface>)data;
// ハチの動作処理
- (void)actionOfHornet:(NSNumber *)dt data:(id<AKPlayDataInterface>)data;
// ゴキブリの動作処理
- (void)actionOfCockroach:(NSNumber *)dt data:(id<AKPlayDataInterface>)data;
// カタツムリの動作処理
- (void)actionOfSnail:(NSNumber *)dt data:(id<AKPlayDataInterface>)data;
// カブトムシの動作処理
- (void)actionOfStagBeetle:(NSNumber *)dt data:(id<AKPlayDataInterface>)data;
// 雑魚敵の破壊処理
- (void)destroyNormal:(id<AKPlayDataInterface>)data;
// 自機を狙うn-way弾発射
+ (void)fireNWayWithPosition:(CGPoint)position count:(NSInteger)count interval:(float)interval speed:(float)speed data:(id<AKPlayDataInterface>)data;
// 角度指定によるn-way弾発射
+ (void)fireNWayWithAngle:(float)angle
                     from:(CGPoint)position
                    count:(NSInteger)count
                 interval:(float)interval
                    speed:(float)speed
                     type:(NSInteger)type
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
