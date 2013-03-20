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
 @file AKCommon.h
 @brief 共通関数、共通定数定義
 
 アプリケーション全体で共通に使用する関数、定数の定義を行う。
 */

#ifndef keigeki_common_h
#define keigeki_common_h

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "cocos2d.h"

/// 色番号
enum kAKColorNumber {
    kAKColorLight = 0,      ///< 明るい色
    kAKColorLittleLight,    ///< やや明るい色
    kAKColorLittleDark,     ///< やや暗い色
    kAKColorDark,           ///< 暗い色
    kAKColorCount           ///< 色種類数
};

// 色
const ccColor4B kAKColor[kAKColorCount];

#ifdef DEBUG

/// デバッグフラグ
extern unsigned long debug_flg;

// ライブラリ用ログ区分
extern BOOL kAKLogFont_0;
extern BOOL kAKLogFont_1;
extern BOOL kAKLogInterface_0;
extern BOOL kAKLogInterface_1;
extern BOOL kAKLogLabel_0;
extern BOOL kAKLogLabel_1;
extern BOOL kAKLogMenuItem_0;
extern BOOL kAKLogMenuItem_1;
extern BOOL kAKLogNavigationController_0;
extern BOOL kAKLogNavigationController_1;
extern BOOL kAKLogScreenSize_0;
extern BOOL kAKLogScreenSize_1;
extern BOOL kAKLogTwitterHelper_0;
extern BOOL kAKLogTwitterHelper_1;

/*!
 @brief デバッグフラグ取得

 デバッグ用のフラグを取得する。ログの出力条件に使用する。
 @return フラグ値
 */
#define AKGetDebugFlg() (debug_flg)

/*!
 @brief デバッグフラグ設定
 
 デバッグ用のフラグを設定する。ログの出力条件に使用する。
 @param flg フラグ値
 */
#define AKSetDebugFlg(flg) (debug_flg = (flg))

/*!
 @brief デバッグログ
 
 デバッグログ。出力条件の指定が可能。ログの先頭にメソッド名と行数を付加する。
 @param cond 出力条件
 @param fmt 出力フォーマット
 */
#define AKLog(cond, fmt, ...) if (cond) NSLog(@"%s(%d) " fmt, __FUNCTION__, __LINE__, ## __VA_ARGS__)

#else

/*!
 @brief デバッグフラグ取得
 
 デバッグ用のフラグを取得する。ログの出力条件に使用する。
 @return フラグ値
 */
#define AKGetDebugFlg()
/*!
 @brief デバッグフラグ設定
 
 デバッグ用のフラグを設定する。ログの出力条件に使用する。
 @param flg フラグ値
 */
#define AKSetDebugFlg(flg)

/*!
 @brief デバッグログ
 
 デバッグログ。出力条件の指定が可能。ログの先頭にメソッド名と行数を付加する。
 @param cond 出力条件
 @param fmt 出力フォーマット
 */
#define AKLog(cond, fmt, ...)

#endif

// 範囲チェック
float AKRangeCheckLF(float val, float min, float max);
float AKRangeCheckF(float val, float min, float max);

// 角度変換
float AKCnvAngleRad2Deg(float radAngle);
float AKCnvAngleRad2Scr(float radAngle);

// 2点間の角度計算
float AKCalcDestAngle(float srcx, float srcy, float dstx, float dsty);

// 回転方向の計算
int AKCalcRotDirect(float angle, float srcx, float srcy, float dstx, float dsty);

// n-way弾発射時の方向計算
NSArray* AKCalcNWayAngle(int count, float centerAngle, float space);

// 矩形内判定
BOOL AKIsInside(CGPoint point, CGRect rect);

// 中心座標とサイズから矩形を作成する
CGRect AKMakeRectFromCenter(CGPoint center, NSInteger size);

// 単一色レイヤーを作成する
CCLayerColor *AKCreateColorLayer(int colorNo, CGRect rect);

// 背景色レイヤーを作成する
CCLayerColor *AKCreateBackColorLayer(void);


#endif
