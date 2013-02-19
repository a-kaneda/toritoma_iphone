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
 @file AKChickenGauge.m
 @brief チキンゲージクラス定義
 
 チキンゲージのクラスを定義する。
 */

#import "AKChickenGauge.h"
#import "AKLib.h"

/// 空ゲージの画像名
static NSString *kAKEmptyImageName = @"ChickenGauge_01.png";
/// 満ゲージの画像名
static NSString *kAKFullImageName = @"ChickenGauge_02.png";
/// 画像の幅
static const NSInteger kAKImageWidth = 256;
/// 画像の高さ
static const NSInteger kAKImageHeight = 16;

/*!
 @brifef チキンゲージクラス
 
 チキンゲージの表示を行うクラス。
 */
@implementation AKChickenGauge

@synthesize emptyImage = emptyImage_;
@synthesize fullImage = fullImage_;
@synthesize percent = percent_;

/*!
 @brief 初期化処理
 
 初期化処理を行う。
 @return 初期化したインスタンス
 */
- (id)init
{
    // スーパークラスの初期化処理を行う
    self = [super init];
    if (!self) {
        AKLog(kAKLogChickenGauge_0, @"error");
        return nil;
    }
    
    // 空画像を読み込む
    self.emptyImage = [CCSprite spriteWithFile:kAKEmptyImageName];
    
    // 自ノードに配置する
    [self addChild:self.emptyImage z:0];
    
    // 満画像を読み込む
    self.fullImage = [CCSprite spriteWithFile:kAKFullImageName];
    
    // 自ノードに配置する
    [self addChild:self.fullImage z:1];
    
    // ゲージがたまるのを満ゲージの幅変更によって表現する。
    // 幅が変わってもx座標を変えなくても良いように左端にアンカーを設定する。
    self.fullImage.anchorPoint = ccp(0.0f, 0.5f);
    self.fullImage.position = ccp([AKScreenSize deviceLength:-kAKImageWidth / 2.0f], 0.0f);
    
    // 比率は0で初期化する
    self.percent = 0.0f;
    
    return self;
}


/*!
 @brief インスタンス解放時処理
 
 インスタンス解放時にメンバを解放する。
 */
- (void)dealloc
{
    // 画像を解放する
    [self.emptyImage removeFromParentAndCleanup:YES];
    self.emptyImage = nil;
    [self.fullImage removeFromParentAndCleanup:YES];
    self.fullImage = nil;
    
    // テクスチャを解放する
    [[CCTextureCache sharedTextureCache] removeTextureForKey:kAKEmptyImageName];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:kAKFullImageName];
    
    // スーパークラスの解放処理
    [super dealloc];
}

/*!
 @brief ゲージの溜まっている比率設定
 
 ゲージの溜まっている比率を設定する。
 満ゲージの幅を更新する。
 @param parcent ゲージの溜まっている比率
 */
- (void)setPercent:(float)percent
{
    // メンバに設定する。
    percent_ = percent;
    
    // 満ゲージの幅を更新する
    [self.fullImage setTextureRect:[AKScreenSize deviceRectByX:0.0f
                                                             y:0.0f
                                                         width:kAKImageWidth * percent / 100.0f
                                                        height:kAKImageHeight]];
}

@end
