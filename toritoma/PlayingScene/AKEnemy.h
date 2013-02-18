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

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKCharacter.h"

/// 敵画像定義
struct AKEnemyImageDef {
    NSInteger fileNo;           ///< ファイル名の番号
    NSInteger animationFrame;   ///< アニメーションフレーム数
    float animationInterval;    ///< アニメーション更新間隔
};

/// 敵種別定義
struct AKEnemyDef {
    NSInteger action;       ///< 動作処理の種別
    NSInteger destroy;      ///< 破壊処理の種別
    NSInteger image;        ///< 画像ID
    NSInteger hitWidth;     ///< 当たり判定の幅
    NSInteger hitHeight;    ///< 当たり判定の高さ
    NSInteger hitPoint;     ///< ヒットポイント
    NSInteger score;        ///< スコア
};

// 敵クラス
@interface AKEnemy : AKCharacter {
    /// 動作開始からの経過時間(各敵種別で使用)
    ccTime time_;
    /// 動作状態(各敵種別で使用)
    NSInteger state_;
    /// 動作処理のセレクタ
    SEL action_;
    /// 破壊処理のセレクタ
    SEL destroy_;
    /// スコア
    NSInteger score_;
}

// 生成処理
- (void)createEnemyType:(NSInteger)type x:(NSInteger)x y:(NSInteger)y parent:(CCNode*)parent;
// 動作処理取得
- (SEL)actionSelector:(NSInteger)type;
// 破壊処理取得
- (SEL)destroySeletor:(NSInteger)type;
// 動作処理1
- (void)action_01:(ccTime)dt;
// 動作処理2
- (void)action_02:(ccTime)dt;
// 破壊処理1
- (void)destroy_01;
// n-Way弾発射
- (void)fireNWay:(NSInteger)way interval:(float)interval speed:(float)speed;
@end
