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
 @file AKPlayer.m
 @brief 自機クラス定義
 
 自機を管理するクラスを定義する。
 */

#import "AKPlayer.h"
#import "AKPlayData.h"
#import "AKEnemyShot.h"

/// 自機のサイズ
static const NSInteger kAKPlayerSize = 8;
/// 自機のかすり判定サイズ
static const NSInteger kAKPlayerGrazeSize = 32;
/// 復活後の無敵状態の時間
static const float kAKInvincibleTime = 2.0f;
/// 自機の画像ファイル名
static NSString *kAKPlayerImageFile = @"Player_%02d";
/// 画像サイズ
static const float kAKPlayerImageSize = 32;
/// アニメーションフレーム数
static const NSInteger kAKPlayerAnimationCount = 2;
/// 弾発射の間隔
static const float kAKPlayerShotInterval = 0.2f;
/// 最大のオプション数
static const NSInteger kAKMaxOptionCount = 3;

/*!
 @brief 自機クラス

 自機を管理する。
 */
@implementation AKPlayer

@synthesize isInvincible = isInvincible_;
@synthesize chickenGauge = chickenGauge_;
@synthesize option = option_;

/*!
 @brief オブジェクト生成処理

 オブジェクトの生成を行う。
 @param parent 画像を配置するノード
 @param optionParent オプションの画像を配置するノード
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithParent:(CCNode *)parent optionParent:(CCNode *)optionParent;
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }

    // サイズを設定する
    self.width = kAKPlayerSize;
    self.height = kAKPlayerSize;
    
    // アニメーションフレームの個数を設定する
    self.animationPattern = kAKPlayerAnimationCount;
    
    // 状態を初期化する
    [self reset];
    
    // 画像名を設定する
    self.imageName = [NSString stringWithFormat:kAKPlayerImageFile, 1];
    
    // 弾発射までの残り時間を設定する
    shootTime_ = kAKPlayerShotInterval;
    
    // チキンゲージをリセットする
    self.chickenGauge = 0.0f;
    
    // 障害物と衝突した時の処理に自機を設定する。
    // 自機の場合は移動時は無処理(画面入力時にチェックするため)。
    // 障害物の衝突判定時は移動を行う。
    self.blockHitAction = kAKBlockHitPlayer;
    
    // 画像を親ノードに配置する
    [parent addChild:self.image];
    
    // オプションを作成する
    self.option = [[[AKOption alloc] initWithOptionCount:kAKMaxOptionCount parent:optionParent] autorelease];
                                              
    return self;
}

/*!
 @brief キャラクター固有の動作

 速度によって位置を移動する。自機の表示位置は固定とする。
 オプションの移動も行う。
 @param dt フレーム更新間隔
 */
- (void)action:(ccTime)dt
{
    // 無敵状態の時は無敵時間をカウントする
    if (isInvincible_) {
        invincivleTime_ -= dt;
        
        // 無敵時間が切れている場合は通常状態に戻す
        if (invincivleTime_ < 0.0f) {
            isInvincible_ = NO;
        }
    }
    
    // 弾発射までの時間をカウントする
    shootTime_ -= dt;
    
    // 弾発射までの残り時間が0になっている場合は弾を発射する
    if (shootTime_ < 0.0f) {
        
        // 自機弾を生成する
        [[AKPlayData sharedInstance] createPlayerShotAtX:self.positionX y:self.positionY];
        
        // 弾発射までの残り時間をリセットする
        shootTime_ = kAKPlayerShotInterval;
    }
    
    // オプションの移動を行う
    if (self.option) {
        [self.option move:dt];
    }
}

/*!
 @brief 破壊処理
 
 HPが0になったときに爆発エフェクトを生成する。
 */
- (void)destroy
{
    // [TODO]破壊時の効果音を鳴らす

    // 画面効果を生成する
    [[AKPlayData sharedInstance] createEffect:2 x:self.positionX y:self.positionY];
    
    // 配置フラグを落とす
    self.isStaged = NO;
    
    // 非表示とする
    self.image.visible = NO;
    
    // 自機破壊時の処理を行う
    [[AKPlayData sharedInstance] miss];
}

/*!
 @brief 復活
 
 破壊された自機を復活させる。
 */
- (void)rebirth
{    
    // HPの設定
    hitPoint_ = 1;
    
    // ステージ配置フラグを立てる
    isStaged_ = YES;
    
    // 表示させる
    self.image.visible = YES;
    
    // 無敵状態にする
    isInvincible_ = YES;
    invincivleTime_ = kAKInvincibleTime;
    
    // チキンゲージを初期化する
    self.chickenGauge = 0.0f;
    
    // 無敵中はブリンクする
    CCBlink *blink = [CCBlink actionWithDuration:kAKInvincibleTime blinks:kAKInvincibleTime * 8];
    [self.image runAction:blink];
}

/*!
 @brief 初期化
 
 状態を初期化する。
 */
- (void)reset
{
    // 初期位置は原点
    self.image.position = ccp(0, 0);
    
    // HPの設定
    hitPoint_ = 1;
    
    // ステージ配置フラグを立てる
    isStaged_ = YES;
    
    // 表示させる
    self.image.visible = YES;
    
    // 無敵状態はOFFにする
    isInvincible_ = NO;
    invincivleTime_ = 0.0f;
    
    // アクションはすべて停止する
    [self.image stopAllActions];
}

/*!
 @brief かすり判定
 
 自機が敵弾にかすっているか判定し、かすっている場合は弾のかすりポイントを自機の方へ移す。
 @param characters 判定対象のキャラクター群
 */
- (void)graze:(const NSEnumerator *)characters
{
    // 画面に配置されていない場合は処理しない
    if (!self.isStaged) {
        return;
    }
    
    // 自キャラのかすり判定の上下左右の端を計算する
    float myleft = self.positionX - kAKPlayerGrazeSize / 2.0f;
    float myright = self.positionX + kAKPlayerGrazeSize / 2.0f;
    float mytop = self.positionY + kAKPlayerGrazeSize / 2.0f;
    float mybottom = self.positionY - kAKPlayerGrazeSize / 2.0f;
    
    // 判定対象のキャラクターごとに判定を行う
    for (AKEnemyShot *target in characters) {
        
        // 相手が画面に配置されていない場合は処理しない
        if (!target.isStaged) {
            continue;
        }
        
        // 相手の上下左右の端を計算する
        float targetleft = target.positionX - target.width / 2.0f;
        float targetright = target.positionX + target.width / 2.0f;
        float targettop = target.positionY + target.height / 2.0f;
        float targetbottom = target.positionY - target.height / 2.0f;
        
        AKLog(kAKLogPlayer_1, @"target=(%f, %f, %f, %f)", targetleft, targetright, targettop, targetbottom);
        
        // 以下のすべての条件を満たしている時、衝突していると判断する。
        //   ・相手の右端が自キャラの左端よりも右側にある
        //   ・相手の左端が自キャラの右端よりも左側にある
        //   ・相手の上端が自キャラの下端よりも上側にある
        //   ・相手の下端が自キャラの上端よりも下側にある
        if ((targetright > myleft) &&
            (targetleft < myright) &&
            (targettop > mybottom) &&
            (targetbottom < mytop)) {
            
            // 相手のかすりポイントを取得する
            if (target.grazePoint > 0.0f) {
                self.chickenGauge += target.grazePoint;
                
                // 最大で100%とする
                if (self.chickenGauge > 100.0f) {
                    self.chickenGauge = 100.0f;
                }
            }
            
            // 相手のかすりポイントをリセットする
            target.grazePoint = 0.0f;
            
            AKLog(kAKLogPlayer_1, @"chickenGauge=%f", self.chickenGauge);
        }
    }
}

/*!
 @brief 移動座標設定
 
 移動座標を設定する。オプションが付属している場合はオプションの移動も行う。
 @param x 移動先x座標
 @param y 移動先y座標
 */
- (void)setPositionX:(float)x y:(float)y
{
    // オプションに自分の移動前の座標を通知する
    if (self.option != nil && self.option.isStaged) {
        [self.option setPositionX:self.positionX y:self.positionY];
    }
    
    // 移動前の座標を記憶する
    self.prevPositionX = self.positionX;
    self.prevPositionY = self.positionY;
    
    // 移動先の座標を設定する
    self.positionX = x;
    self.positionY = y;
    
    // 障害物との衝突判定を行う
    [self checkHit:[[AKPlayData sharedInstance].blockPool.pool objectEnumerator]
              func:@selector(moveOfBlockHit:)];
}

/*!
 @brief オプション個数更新
 
 チキンゲージに応じてオプション個数を更新する。
 */
- (void)updateOptionCount
{
    // チキンゲージからオプション個数を計算する
    NSInteger count = self.chickenGauge / (100.0f / (kAKMaxOptionCount + 1));
    
    // 最大個数で制限をかける
    if (count > kAKMaxOptionCount) {
        count = kAKMaxOptionCount;
    }
    
    AKLog(kAKLogPlayer_1, @"ゲージ=%f オプション個数=%d", self.chickenGauge, count);
    
    // 自分の座標を初期座標として次のオプションを設定する
    if (self.option != nil) {
        [self.option setOptionCount:count x:self.positionX y:self.positionY];
    }
}

/*!
 @brief シールド有無設定
 
 オプションのシールド有無を設定する。
 @param shield シールド有無
 */
- (void)setShield:(BOOL)shield
{
    // オプションがある場合はオプションのシールド有無を設定する
    if (self.option != nil) {
        self.option.shield = shield;
    }
}
@end
