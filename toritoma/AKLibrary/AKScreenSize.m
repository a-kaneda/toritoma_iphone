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
 @file AKScreenSize.m
 @brief 画面サイズ管理クラス
 
 画面サイズ管理クラスを定義する。
 */

#import "AKScreenSize.h"
#import "AKLogNoDef.h"

/// ゲーム画面のステージサイズ
const CGSize kAKStageSize = {384, 288};

/*!
 @brief 画面サイズ管理クラス
 
 画面サイズを管理する。
 */
@implementation AKScreenSize

/*!
 @brief 画面サイズ取得
 
 デバイスの画面サイズを取得する。
 @return 画面サイズ
 */
+ (CGSize)screenSize
{
    // Landscapeのため、画面の幅と高さを入れ替えて返す
    return CGSizeMake([[UIScreen mainScreen] bounds].size.height,
                      [[UIScreen mainScreen] bounds].size.width);
}

/*!
 @brief ステージサイズ取得
 
 ゲームステージのサイズを取得する。
 @return ステージサイズ
 */
+ (CGSize)stageSize
{
    // ステージサイズを取得する
    NSInteger width = kAKStageSize.width;
    NSInteger height = kAKStageSize.height;
    
    // iPadの場合は倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        width *= 2;
        height *= 2;
    }

    return CGSizeMake(width, height);
}

/*!
 @brief 中央座標取得
 
 画面の中央の座標を取得する。
 @return 中央座標
 */
+ (CGPoint)center
{
    return CGPointMake([AKScreenSize screenSize].width / 2,
                       [AKScreenSize screenSize].height / 2);
}

/*!
 @brief 左からの比率で座標取得
 
 左からの画面サイズの比率で距離を指定したときのデバイススクリーン座標を返す。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromLeftRatio:(float)ratio
{
    return [AKScreenSize screenSize].width * ratio;
}

/*!
 @brief 右からの比率で座標取得
 
 右からの画面サイズの比率で距離を指定したときのデバイススクリーン座標を返す。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromRightRatio:(float)ratio
{
    return [AKScreenSize screenSize].width * (1 - ratio);
}

/*!
 @brief 上からの比率で座標取得
 
 上からの画面サイズの比率で距離を指定したときのデバイススクリーン座標を返す。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromTopRatio:(float)ratio
{
    return [AKScreenSize screenSize].height * (1 - ratio);
}

/*!
 @brief 下からの比率で座標取得
 
 下からの画面サイズの比率で距離を指定したときのデバイススクリーン座標を返す。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromBottomRatio:(float)ratio
{
    return [AKScreenSize screenSize].height * ratio;
}

/*!
 @brief 左からの位置で座標取得
 
 左からの座標で距離を指定したときのデバイススクリーン座標を返す。
 iPadの場合は座標を倍にして処理する。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromLeftPoint:(float)point
{
    // iPadの場合は座標を倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        point *= 2.0f;
    }
    
    return point;
}

/*!
 @brief 右からの位置で座標取得
 
 右からの座標で距離を指定したときのデバイススクリーン座標を返す。
 iPadの場合は座標を倍にして処理する。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromRightPoint:(float)point
{
    // iPadの場合は座標を倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        point *= 2.0f;
    }
    
    return [AKScreenSize screenSize].width - point;
}

/*!
 @brief 上からの位置で座標取得
 
 上からの座標で距離を指定したときのデバイススクリーン座標を返す。
 iPadの場合は座標を倍にして処理する。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromTopPoint:(float)point
{
    // iPadの場合は座標を倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        point *= 2.0f;
    }
    
    return [AKScreenSize screenSize].height - point;
}

/*!
 @brief 下からの位置で座標取得
 
 下からの座標で距離を指定したときのデバイススクリーン座標を返す。
 iPadの場合は座標を倍にして処理する。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromBottomPoint:(float)point
{
    // iPadの場合は座標を倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        point *= 2.0f;
    }
    
    return point;
}

/*!
 @brief 中心からの横方向の位置で座標取得

 中心からの横方向の座標で距離を指定したときのデバイススクリーン座標を返す。
 iPadの場合は座標を倍にして処理する。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromHorizontalCenterPoint:(float)point
{
    // iPadの場合は座標を倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        point *= 2.0f;
    }
    
    return [AKScreenSize center].x + point;
}

/*!
 @brief 中心からの縦方向の位置で座標取得
 
 中心からの縦方向の座標で距離を指定したときのデバイススクリーン座標を返す。
 iPadの場合は座標を倍にして処理する。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromVerticalCenterPoint:(float)point
{
    // iPadの場合は座標を倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        point *= 2.0f;
    }
    
    return [AKScreenSize center].y + point;
}

/*!
 @brief ステージ座標x座標からデバイススクリーン座標の取得
 
 ステージ座標からデバイススクリーン座標へと変換する。x座標を取得する。
 @param stageX ステージ座標x座標
 @return デバイススクリーン座標
 */
+ (NSInteger)xOfStage:(float)stageX
{
    // iPadの場合は座標を倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        stageX *= 2;
    }
    
    return stageX + ([AKScreenSize screenSize].width - [AKScreenSize stageSize].width) / 2;
}

/*!
 @brief ステージ座標y座標からデバイススクリーン座標の取得
 
 ステージ座標からデバイススクリーン座標へと変換する。y座標を取得する。
 @param stageY ステージ座標y座標
 @return デバイススクリーン座標
 */
+ (NSInteger)yOfStage:(float)stageY
{
    // 画面上部の余白は基本的には0とする
    NSInteger topMargin = 0;

    // iPadの場合
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        // iPadの場合は画面上部に余白を設定する
        topMargin = 96;
        
        // 座標を倍にする
        stageY *= 2;
    }
    
    return stageY + ([AKScreenSize screenSize].height - [AKScreenSize stageSize].height - topMargin);
}

/*!
 @brief デバイススクリーン座標x座標からステージ座標の取得
 
 デバイススクリーン座標からステージ座標へ変換する。x座標を取得する
 @param deviceX デバイススクリーン座標x座標
 @return ステージ座標
 */
+ (float)xOfDevice:(float)deviceX
{
    // iPadの場合は座標を半分にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        deviceX /= 2;
    }
    
    return (double)deviceX - ([AKScreenSize screenSize].width - [AKScreenSize stageSize].width) / 2;
}

/*!
 @brief デバイススクリーン座標y座標からステージ座標の取得
 
 デバイススクリーン座標からステージ座標へ変換する。y座標を取得する
 @param deviceY デバイススクリーン座標x座標
 @return ステージ座標
 */
+ (float)yOfDevice:(float)deviceY
{
    // 画面上部の余白は基本的には0とする
    NSInteger topMargin = 0;
    
    // iPadの場合
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        // iPadの場合は画面上部に余白を設定する
        topMargin = 96;
        
        // 座標を半分にする
        deviceY /= 2;
    }
    
    return (double)deviceY - ([AKScreenSize screenSize].height - [AKScreenSize stageSize].height - topMargin);
}

/*! 
 @brief 矩形のデバイス補正、x座標、y座標、幅、高さ指定
 
 矩形の座標とサイズをデバイスに合わせて補正する。
 x座標、y座標、幅、高さから矩形を作成する。
 iPadの場合はサイズを倍にする。
 iPhoneの場合はそのままとする。
 @param x x座標
 @param y y座標
 @param w 幅
 @param h 高さ
 @return 補正した矩形
 */
+ (CGRect)deviceRectByX:(float)x y:(float)y width:(float)w height:(float)h
{
    CGRect rect;
    
    // 矩形を作成する
    rect = CGRectMake(x, y, w, h);
    
    // iPadの場合はサイズを倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        rect.origin.x *= 2;
        rect.origin.y *= 2;
        rect.size.width *= 2;
        rect.size.height *= 2;
    }
    
    AKLog(kAKLogScreenSize_1, @"x=%f y=%f w=%f h=%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    // 作成した矩形を返す
    return rect;
}

/*!
 @brief 矩形のデバイス補正、座標、サイズ指定
 
 矩形の座標とサイズをデバイスに合わせて補正する。
 座標、サイズから矩形を作成する。
 iPadの場合はサイズを倍にする。
 iPhoneの場合はそのままとする。
 @param point 座標
 @param size サイズ
 @return 補正した矩形
 */
+ (CGRect)deviceRectByPoint:(CGPoint)point size:(CGSize)size
{
    return [AKScreenSize deviceRectByX:point.x y:point.y width:size.width height:size.height];
}

/*!
 @brief 矩形のデバイス補正、矩形指定
 
 矩形の座標とサイズをデバイスに合わせて補正する。
 矩形から矩形を作成する。
 iPadの場合はサイズを倍にする。
 iPhoneの場合はそのままとする。
 @param rect 矩形
 @return 補正した矩形
 */
+ (CGRect)deviceRectByRect:(CGRect)rect
{
    return [AKScreenSize deviceRectByX:rect.origin.x y:rect.origin.y width:rect.size.width height:rect.size.height];
}

/*!
 @brief 中心座標とサイズから矩形を作成する
 
 中心座標とサイズから矩形を作成する。
 @param center 中心座標
 @param size サイズ
 @return 矩形
 */
+ (CGRect)makeRectFromCenter:(CGPoint)center size:(NSInteger)size
{
    return CGRectMake(center.x - size / 2, center.y - size / 2, size, size);
}

/*!
 @brief 長さのデバイス補正
 
 長さをデバイスに応じて補正する。iPadの場合は2倍にする。
 @param len プログラム上の長さ
 @return デバイスごとに対応した長さ
 */
+ (float)deviceLength:(float)len
{
    // iPadの場合は倍にして返す
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return len * 2;
    }
    // iPhone/iPod touchの場合はそのままとする
    else {
        return len;
    }
}

@end
