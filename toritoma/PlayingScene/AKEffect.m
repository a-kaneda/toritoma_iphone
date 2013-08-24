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
 @file AKEffect.m
 @brief 画面効果クラス定義
 
 爆発等の画面効果を生成するクラスを定義する。
 */

#import "AKEffect.h"

/// 画像名のフォーマット
static NSString *kAKImageNameFormat = @"Effect_%02d";
/// 画面効果の種類の数
static const NSInteger kAKEffectDefCount = 2;
/// 画面効果の定義
static const struct AKEffectDef kAKEffectDef[kAKEffectDefCount] = {
    {1, 32, 32, 0, 0, -1, 8, 6, 1},     // 爆発
    {2, 32, 32, 0, -1, 60, 1, 0, 0}     // 自機破壊
};

/*!
 @brief 画面効果クラス
 
 爆発等の画面効果を生成する。
 */
@implementation AKEffect

/*!
 @brief 画面効果開始
 
 画面効果を生成する。
 @param type 画面効果の種別
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param parent 画面効果を配置する親ノード
 */
- (void)createEffectType:(NSInteger)type x:(NSInteger)x y:(NSInteger)y parent:(CCLayer *)parent
{
    // パラメータの内容をメンバに設定する
    self.positionX = x;
    self.positionY = y;
    
    // 画面配置フラグとHPを設定する
    self.isStaged = YES;
    self.hitPoint = 1;
    
    NSAssert(type > 0 && type <= kAKEffectDefCount, @"画面効果種別が不正");
    
    // 速度を設定する
    self.speedX = kAKEffectDef[type - 1].speedX;
    self.speedY = kAKEffectDef[type - 1].speedY;
    
    // 生存フレーム数を設定する
    lifeFrame_ = kAKEffectDef[type - 1].lifeFrame;
    
    // 画像名を作成する
    self.imageName = [NSString stringWithFormat:kAKImageNameFormat, kAKEffectDef[type - 1].fileNo];
        
    // アニメーションフレームの個数を設定する
    self.animationPattern = kAKEffectDef[type - 1].animationFrame;
    
    // アニメーションフレーム間隔を設定する
    self.animationInterval = kAKEffectDef[type - 1].animationInterval;
    
    // アニメーション繰り返し回数を設定する
    self.animationRepeat = kAKEffectDef[type - 1].animationRepeat;

    // レイヤーに配置する
    [parent addChild:self.image];
}

/*!
 @brief キャラクター固有の動作
 
 生存時間が経過している場合は消去する。
 生存時間がマイナスの場合は未設定として無視する。
 @param data ゲームデータ
 */
- (void)action:(id<AKPlayDataInterface>)data
{
    // 生存フレーム数が設定されている場合は処理を行う
    if (lifeFrame_ > 0.0f) {
        
        // 生存フレーム数を減らす
        lifeFrame_--;
        
        // 生存フレーム数を経過している場合は削除する
        if (lifeFrame_ <= 0) {
            
            // ステージ配置フラグを落とす
            self.isStaged = NO;
            
            // 画面から取り除く
            [self.image removeFromParentAndCleanup:YES];
        }
    }
}
@end
