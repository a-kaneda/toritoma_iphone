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
 @file AKScriptData.m
 @brief スクリプト1行分のデータ
 
 スクリプト１行分の内容を管理するクラス。
 */

#import "AKScriptData.h"

/*
 * パラメータリスト
 *   敵
 *     0:生成キャラクター番号
 *     1:生成位置x座標
 *     2:生成位置y座標
 *   ボス
 *     0:生成キャラクター番号
 *     1:生成位置x座標
 *     2:生成位置y座標
 *   背景
 *     0:生成キャラクター番号
 *     1:生成位置x座標
 *     2:生成位置y座標
 *   障害物
 *     0:生成キャラクター番号
 *     1:生成位置x座標
 *     2:生成位置y座標
 *   スクロールスピード
 *     0:スクロールスピードx座標
 *     1:スクロールスピードy座標
 *   BGM変更
 *     0:曲番号
 *   待機
 *     0:待機時間
 *   繰り返し
 *     0:ON/OFF
 *     1:ID
 *     2:間隔
 */

/*!
 @brief スクリプト1行分のデータ
 
 スクリプト１行分の内容を管理するクラス。
 */
@implementation AKScriptData

@synthesize type = type_;
@synthesize repeatOpe = repeatOpe_;
@synthesize repeatWaitTime = repeatWaitTime_;

/*!
 @brief 初期化処理
 
 初期化処理を行う。
 @param params 命令のパラメータ
 @return 初期化したインスタンス
 */
- (id)initWithParams:(NSArray *)params
{
    AKLog(kAKLogScriptData_1, @"start");
    
    // スーパークラスの初期化処理を行う
    self = [super init];
    if (!self) {
        AKLog(kAKLogScriptData_0, @"error");
        return nil;
    }
    
    // 種別を判別する
    NSString *type = [params objectAtIndex:0];
    // 敵
    if ([type isEqualToString:@"enemy"]) {
        type_ = kAKScriptOpeEnemy;
    }
    // ボス
    else if ([type isEqualToString:@"boss"]) {
        type_ = kAKScriptOpeBoss;
    }
    // 背景
    else if ([type isEqualToString:@"back"]) {
        type_ = kAKScriptOpeBack;
    }
    // 障害物
    else if ([type isEqualToString:@"block"]) {
        type_ = kAKScriptOpeWall;
    }
    // スクロールスピード変更
    else if ([type isEqualToString:@"speed"]) {
        type_ = kAKScriptOpeScroll;
    }
    // BGM変更
    else if ([type isEqualToString:@"bgm"]) {
        type_ = kAKScriptOpeBGM;
    }
    // 待機
    else if ([type isEqualToString:@"sleep"]) {
        type_ = kAKScriptOpeSleep;
    }
    // 繰り返し
    else if ([type isEqualToString:@"repeat"]) {
        type_ = kAKScriptOpeRepeat;
    }
    // エラー
    else {
        AKLog(kAKLogScriptData_0, @"種別が不正:%@", type);
        NSAssert(NO, @"種別が不正");
        type_ = kAKScriptOpeSleep;
        return self;
    }
    
    AKLog(kAKLogScriptData_1, @"type=%d", self.type);
    
    // 値を設定する
    for (int i = 0; i < params.count - 1; i++) {
        
        // パラメータ数最大チェック
        if (i >= kAKMaxParamCount) {
            AKLog(kAKLogScriptData_0, @"パラメータ数が最大値を超えている:%d", i);
            NSAssert(NO, @"パラメータ数が最大値を超えている");
            break;
        }
        
        // 文字列を取得する
        NSString *param = [params objectAtIndex:i + 1];
        
        // パラメータにセットする
        params_[i] = [param integerValue];
        
        AKLog(kAKLogScriptData_1, @"params_[%d]=%d", i, params_[i]);
    }
    
    // 繰り返し待機時間を0で初期化する
    self.repeatWaitTime = 0.0f;
    
    return self;
}


/*!
 @brief オブジェクト解放処理
 
 オブジェクトの解放を行う。
 */
- (void)dealloc
{
    // メンバを解放する
    self.repeatOpe = nil;
    
    // スーパークラスの処理を行う
    [super dealloc];
}

/*!
 @brief コンビニエンスコンストラクタ
 
 インスタンスの生成、初期化、autoreleaseを行う。
 @param params 命令のパラメータ
 @return 初期化したインスタンス
 */
+ (id)scriptDataWithParams:(NSArray *)params
{
    return [[[AKScriptData alloc] initWithParams:params] autorelease];
}

/*!
 @brief 生成キャラクター番号
 
 生成キャラクター番号のパラメータリストから取得する。
 @return 生成キャラクター番号
 */
- (NSInteger)characterNo
{
    return params_[0];
}

/*!
 @brief 生成位置x座標
 
 生成位置x座標のパラメータリストから取得する。
 @return 生成位置x座標
 */
- (NSInteger)positionX
{
    return params_[1];
}

/*!
 @brief 生成位置y座標
 
 生成位置y座標のパラメータリストから取得する。
 @return 生成位置y座標
 */
- (NSInteger)positionY
{
    return params_[2];
}

/*!
 @brief スクロールスピードx座標
 
 スクロールスピードx座標のパラメータリストから取得する。
 @return スクロールスピードx座標
 */
- (NSInteger)speedX
{
    return params_[0];
}

/*!
 @brief スクロールスピードy座標
 
 スクロールスピードy座標のパラメータリストから取得する。
 @return スクロールスピードy座標
 */
- (NSInteger)speedY
{
    return params_[1];
}

/*!
 @brief BGM番号
 
 BGM番号のパラメータリストから取得する。
 @return BGM番号
 */
- (NSInteger)bgmNo
{
    return params_[0];
}

/*!
 @brief 待機時間
 
 待機時間のパラメータリストから取得する。
 @return 待機時間
 */
- (NSInteger)sleepTime
{
    return params_[0];
}

/*!
 @brief 繰り返し有効・無効
 
 繰り返し有効・無効のパラメータリストから取得する。
 @return 繰り返し有効・無効
 */
- (BOOL)enableRepeat
{
    return (params_[0] != 0);
}

/*!
 @brief 繰り返しID
 
 繰り返しIDのパラメータリストから取得する。
 @return 繰り返しID
 */
- (NSInteger)repeatID
{
    return params_[1];
}

/*!
 @brief 繰り返し間隔
 
 繰り返し間隔のパラメータリストから取得する。
 @return 繰り返し間隔
 */
- (NSInteger)repeatInterval
{
    return params_[2];
}
@end
