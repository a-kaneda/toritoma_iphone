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
 @file AKLife.m
 @brief 残機表示クラス定義
 
 残機表示のクラスを定義する。
 */

#import "AKLife.h"

/// 残機マークの画像名
static NSString *kAKLifeMarkImageName = @"Life.png";
/// 残機数のラベル書式
static NSString *kAKLifeNumberFormat = @":%02d";
/// 残機数表示の最大値
static const NSInteger kAKLifeCountViewMax = 99;
/// 残機マークのサイズ
static const NSInteger kAKLifeMarkSize = 16;

/*!
 @brief 残機表示クラス
 
 残機の表示を行うクラス。
 */
@implementation AKLife

@synthesize mark = mark_;
@synthesize numberLabel = numberLabel_;
@synthesize lifeCount = lifeCount_;

/*!
 @brief オブジェクト初期化処理
 
 オブジェクトの初期化を行う。
 @return 初期化したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    AKLog(kAKLogLife_1, @"start");
    
    // スーパークラスの初期化処理を行う
    self = [super init];
    if (!self) {
        AKLog(kAKLogLife_0, @"error");
        return nil;
    }
    
    // 残機マークを読み込む
    self.mark = [CCSprite spriteWithSpriteFrameName:kAKLifeMarkImageName];
    
    // 残機数を初期化する
    self.lifeCount = 0;
    
    // 残機マークを左側に配置し、残機数ラベルを右側に配置する。
    // 残機マークの幅をW1、残機数ラベルの幅をW2とすると、全体の幅をWとすると。
    // 残機マークの移動量X1は初めに全体の左端に移動するように左にW/2移動し、
    // 残機マークの左端が全体の左端と一致するように右にW1/2移動する。
    //   X1 = -W / 2 + W1 / 2
    //      = -(W1 + W2) / 2 + W1 / 2
    //      = -W2 / 2
    // 同様に残機数ラベルの移動量X2は以下のようになる。
    //   X2 = W1 / 2
    
    // 残機マークの座標を設定する
    self.mark.position = ccp(-self.numberLabel.width / 2, 0.0f);
    
    // 残機数ラベルの座標を設定する
    self.numberLabel.position = ccp(kAKLifeMarkSize / 2, 0.0f);
    
    // 自ノードに残機マークを配置する
    [self addChild:self.mark];
    
    // 自ノードに残機数ラベルを配置する
    [self addChild:self.numberLabel];
    
    AKLog(kAKLogLife_1, @"end");
    return self;
}

/*!
 @brief オブジェクト解放処理
 
 メンバの解放を行う。
 */
- (void)dealloc
{
    AKLog(kAKLogLife_1, @"start");
    
    // メンバを解放する
    [self.mark removeFromParentAndCleanup:YES];
    self.mark = nil;
    [self.numberLabel removeFromParentAndCleanup:YES];
    self.numberLabel = nil;

    // スーパークラスの処理を行う
    [super dealloc];
    
    AKLog(kAKLogLife_1, @"end");
}

/*!
 @brief 残機数設定
 
 残機数を設定する。
 @param lifeCount 残機数
 */
- (void)setLifeCount:(NSInteger)lifeCount
{
    AKLog(kAKLogLife_1, @"start:lifeCount=%d", lifeCount);
    
    // メンバに設定する
    lifeCount_ = lifeCount;

    // 残機が範囲外の場合は補正する
    NSInteger lifeCountView;
    if (lifeCount < 0) {
        lifeCountView = 0;
    }
    else if (lifeCount > kAKLifeCountViewMax) {
        lifeCountView = kAKLifeCountViewMax;
    }
    else {
        lifeCountView = lifeCount;
    }
    
    // 残機文字列を作成する
    NSString *labelStr = [NSString stringWithFormat:kAKLifeNumberFormat, lifeCountView];
    
    // ラベルが作成されていない場合
    if (self.numberLabel == nil) {
        
        AKLog(1, @"ラベル作成:\"%@\"", labelStr);
        
        // 残機数ラベルを作成する
        self.numberLabel = [AKLabel labelWithString:labelStr
                                          maxLength:labelStr.length
                                            maxLine:1
                                              frame:kAKLabelFrameNone];
    }
    // ラベルが作成されている場合
    else {

        AKLog(1, @"ラベル変更:\"%@\"", labelStr);

        // 表示文字列を変更する
        [self.numberLabel setString:labelStr];
    }
    
    AKLog(kAKLogLife_1, @"end");
}

/*!
 @brief 幅取得
 
 ノードの幅を取得する。
 残機マークと残機数ラベルの幅の合計を返す。
 @return 幅
 */
- (NSInteger)width
{
    return (kAKLifeMarkSize + self.numberLabel.width);
}
@end
