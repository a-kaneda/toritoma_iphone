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
 @file AKScriptData.h
 @brief スクリプト1行分のデータ
 
 スクリプト１行分の内容を管理するクラス。
 */

#import <Foundation/Foundation.h>
#import "AKLib.h"

/// パラメータの最大数
#define kAKMaxParamCount 3

/// スクリプト命令種別
enum AKScriptOpeType {
    kAKScriptOpeEnemy = 0,  ///< 敵の生成
    kAKScriptOpeBoss,       ///< ボスの生成
    kAKScriptOpeBack,       ///< 背景の生成
    kAKScriptOpeWall,       ///< 障害物の生成
    kAKScriptOpeScroll,     ///< スクロールスピード変更
    kAKScriptOpeBGM,        ///< BGM変更
    kAKScriptOpeSleep,      ///< 待機
    kAKScriptOpeRepeat      ///< 繰り返し
};

// スクリプト1行分のデータ
@interface AKScriptData : NSObject {
    /// 命令種別
    enum AKScriptOpeType type_;
    /// 命令の値
    NSInteger value_;
    /// 生成位置x座標
    NSInteger positionX_;
    /// 生成位置y座標
    NSInteger positionY_;
    /// パラメータ
    NSInteger params_[kAKMaxParamCount];
    /// 繰り返し命令
    AKScriptData *repeat_;
}

/// 命令種別
@property (nonatomic, readonly)enum AKScriptOpeType type;
/// 命令の値
@property (nonatomic, readonly)NSInteger value;
/// 種別
@property (nonatomic, readonly)NSInteger characterType;
/// 生成位置x座標
@property (nonatomic, readonly)NSInteger positionX;
/// 生成位置y座標
@property (nonatomic, readonly)NSInteger positionY;
/// スクロールスピードx座標
@property (nonatomic, readonly)NSInteger speedX;
/// スクロールスピードy座標
@property (nonatomic, readonly)NSInteger speedY;
/// 待機時間
@property (nonatomic, readonly)NSInteger sleepTime;
/// 繰り返し有効・無効
@property (nonatomic, readonly)BOOL enableRepeat;
/// 繰り返しID
@property (nonatomic, readonly)NSInteger repeatID;
/// 繰り返し間隔
@property (nonatomic, readonly)NSInteger repeatInterval;

// 初期化処理
- (id)initWithType:(NSString *)type value:(NSInteger)value x:(NSInteger)x y:(NSInteger)y;
// コンビニエンスコンストラクタ
+ (id)scriptDataWithType:(NSString *)type value:(NSInteger)value x:(NSInteger)x y:(NSInteger)y;

@end
