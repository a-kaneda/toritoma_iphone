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
 @file AKPlayerShot.m
 @brief 自機弾クラス定義
 
 自機の発射する弾のクラスを定義する。
 */

#import "AKPlayerShot.h"

/// 自機弾のスピード
static const float kAKPlayerShotSpeed = 5.0f;
/// 自機弾の画像名
static NSString *kAKPlayerShotImage = @"PlayerShot_01";
/// 自機弾の幅
static const NSInteger kAKPlayerShotWidth = 6;
/// 自機弾の高さ
static const NSInteger kAKPlayerShotHeight = 6;

@implementation AKPlayerShot

/*!
 @brief 自機弾生成
 
 自機の弾を生成する。
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param parent 配置する親ノード
 */
- (void)createPlayerShotAtX:(NSInteger)x y:(NSInteger)y parent:(CCNode *)parent
{
    // パラメータの内容をメンバに設定する
    self.positionX = x;
    self.positionY = y;
    
    // スピードを設定する。右方向へまっすぐに進む。
    self.speedX = kAKPlayerShotSpeed;
    self.speedY = 0.0f;
    
    // 配置フラグを立てる
    isStaged_ = YES;
    
    // 画像名を設定する
    self.imageName = kAKPlayerShotImage;
    
    // アニメーションフレームの個数を設定する
    self.animationPattern = 1;
    
    // アニメーションフレーム間隔を設定する
    self.animationInterval = 0.0f;
    
    // 当たり判定のサイズを設定する
    self.width = kAKPlayerShotWidth;
    self.height = kAKPlayerShotHeight;
    
    // ヒットポイントを設定する
    self.hitPoint = 1;
    
    // 障害物衝突時は消滅する
    self.blockHitAction = kAKBlockHitDisappear;

    // レイヤーに配置する
    [parent addChild:self.image];
}

@end
