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
 @file AKCommon.m
 @brief 共通関数、共通定数定義
 
 アプリケーション全体で共通に使用する関数、定数の定義を行う。
 */

#import <stdio.h>
#import <math.h>
#import "AKCommon.h"

#ifdef DEBUG

/// デバッグフラグ
unsigned long debug_flg = 0;

// 共通ライブラリ用ログ区分定義
BOOL kAKLogAppBankNetworkBanner_0 = YES;
BOOL kAKLogAppBankNetworkBanner_1 = NO;
BOOL kAKLogFont_0 = YES;
BOOL kAKLogFont_1 = NO;
BOOL kAKLogInterface_0 = YES;
BOOL kAKLogInterface_1 = NO;
BOOL kAKLogLabel_0 = YES;
BOOL kAKLogLabel_1 = NO;
BOOL kAKLogMenuItem_0 = YES;
BOOL kAKLogMenuItem_1 = NO;
BOOL kAKLogNavigationController_0 = YES;
BOOL kAKLogNavigationController_1 = NO;
BOOL kAKLogScreenSize_0 = YES;
BOOL kAKLogScreenSize_1 = NO;
BOOL kAKLogTwitterHelper_0 = YES;
BOOL kAKLogTwitterHelper_1 = NO;
#endif

/// 色
const ccColor4B kAKColor[kAKColorCount] = {
    {156, 179, 137, 255},
    {110, 132, 100, 255},
    { 64,  85,  63, 255},
    { 18,  38,  26, 255}
};

/*!
 @brief 範囲チェック(実数)

 値が範囲内にあるかチェックし、範囲外にあれば範囲内の値に補正する。
 @param val 値
 @param min 最小値
 @param max 最大値
 @return 補正結果
 */
float AKRangeCheckF(float val, float min, float max)
{
    // 最小値未満
    if (val < min) {
        return min;
    }
    // 最大値超過
    else if (val > max) {
        return max;
    }
    // 範囲内
    else {
        return val;
    }
}

/*!
 @brief 範囲チェック(ループ、 実数)

 値が範囲内にあるかチェックし、範囲外にあれば反対側にループする。
 @param val 値
 @param min 最小値
 @param max 最大値
 @return 補正結果
 */
float AKRangeCheckLF(float val, float min, float max)
{
    // 最小値未満
    if (val < min) {
        return AKRangeCheckLF(val + (max - min), min, max);
    }
    // 最大値超過
    else if (val > max) {
        return AKRangeCheckLF(val - (max - min), min, max);
    }
    // 範囲内
    else {
        return val;
    }
}

/*!
 @brief rad角度からdeg角度への変換

 fadianからdegreeへ変換する。
 @param radAngle rad角度
 @return deg角度
 */
float AKCnvAngleRad2Deg(float radAngle)
{
    // radianからdegreeへ変換する
    return radAngle / (2 * M_PI) * 360;
}

/*!
 @brief rad角度からスクリーン角度への変換

 radianからdegreeへ変換し、上向きを0°とする。時計回りを正とする。
 @param radAngle rad角度
 @return スクリーン角度
 */
float AKCnvAngleRad2Scr(float radAngle)
{
    float srcAngle = 0.0f;
    
    // radianからdegreeへ変換する
    srcAngle = AKCnvAngleRad2Deg(radAngle);
    
    // 上向きを0°とするため、90°ずらす。
    srcAngle -= 90;
    
    // 時計回りを正とするため符号を反転する。
    srcAngle *= -1;
    
    return srcAngle;
}

/*!
 @brief 矩形内判定
 
 指定された座標が矩形内にあるかどうか判定する。
 @param point 座標
 @param rect 矩形
 @return 矩形内にあればYES、外側にあればNO
 */
BOOL AKIsInside(CGPoint point, CGRect rect)
{
    AKLog(NO, @"point=(%f,%f) rect=(%f,%f,%f,%f)", point.x, point.y, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    if ((point.x >= rect.origin.x && point.x <= rect.origin.x + rect.size.width) &&
        (point.y >= rect.origin.y && point.y <= rect.origin.y + rect.size.height)) {
        
        return YES;
    }
    else {
        return NO;
    }
}

/*!
 @brief 中心座標とサイズから矩形を作成する
 
 中心座標とサイズから矩形を作成する。
 @param center 中心座標
 @param size サイズ
 @return 矩形
 */
CGRect AKMakeRectFromCenter(CGPoint center, NSInteger size)
{
    return CGRectMake(center.x - size / 2, center.y - size / 2, size, size);
}

/*!
 @brief 単一色レイヤーを作成する
 
 単一色のレイヤーを作成する。
 @param colorNo 色番号
 @param rect レイヤーの矩形位置
 @return 単一色レイヤー
 */
CCLayerColor *AKCreateColorLayer(int colorNo, CGRect rect)
{
    assert(colorNo >= 0 && colorNo < kAKColorCount);
    
    // レイヤーを作成する
    CCLayerColor *layer = [CCLayerColor layerWithColor:kAKColor[colorNo]];
    
    // サイズを設定する
    layer.contentSize = rect.size;
    
    // 位置を設定する
    layer.position = rect.origin;
    
    // 作成したレイヤーを返す
    return layer;
}

/*!
 @brief 背景色レイヤーを作成する
 
 背景色で塗りつぶされ、画面サイズを埋めるサイズ・位置のレイヤーを作成する。
 @return 背景レイヤー
 */
CCLayerColor *AKCreateBackColorLayer(void)
{
    
    // サイズを画面サイズに設定する
    // Landscapeのため、幅と高さを入れ替える
    return AKCreateColorLayer(kAKColorLight,
                              CGRectMake(0.0f,
                                         0.0f,
                                         [[UIScreen mainScreen] bounds].size.height,
                                         [[UIScreen mainScreen] bounds].size.width));
}