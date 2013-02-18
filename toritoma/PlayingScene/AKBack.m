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
 @file AKBack.m
 @brief 背景クラス
 
 背景を管理するクラスを定義する。
 */

#import "AKBack.h"

/// 画像名のフォーマット
static NSString *kAKImageNameFormat = @"Back_%02d";
/// 障害物の種類の数
static const NSInteger kAKBackDefCount = 1;

/// 障害物定義
static const struct AKBackDef kAKBackDef[kAKBackDefCount] = {
    {1, 1, 0.0f}
};

/*!
 @brief 背景クラス
 
 背景を管理する。
 */
@implementation AKBack

/*!
 @brief 背景生成処理
 
 背景を生成する。
 @param type 障害物種別
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param parent 配置する親ノード
 */
- (void)createBackType:(NSInteger)type x:(NSInteger)x y:(NSInteger)y parent:(CCNode *)parent
{
    AKLog(0, @"背景生成");
    
    // パラメータの内容をメンバに設定する
    self.positionX = x;
    self.positionY = y;
    
    // 配置フラグを立てる
    self.isStaged = YES;
    
    // ヒットポイントは1とする
    self.hitPoint = 1;
    
    NSAssert(type > 0 && type <= kAKBackDefCount, @"背景種別の値が範囲外");
    
    // 画像名を作成する
    self.imageName = [NSString stringWithFormat:kAKImageNameFormat, kAKBackDef[type - 1].image];
    
    // アニメーションフレームの個数を設定する
    self.animationPattern = kAKBackDef[type - 1].animationFrame;
    
    // アニメーションフレーム間隔を設定する
    self.animationInterval = kAKBackDef[type - 1].animationInterval;
    
    // 背景は画面スクロールの半分の速度で移動する
    self.scrollSpeed = 0.5f;
    
    // レイヤーに配置する
    [parent addChild:self.image];
}
@end
