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
 @file AKEnemy.m
 @brief 敵クラス定義
 
 敵キャラクターのクラスの定義をする。
 */

#import "AKEnemy.h"
#import "AKPlayData.h"

/// 画像名のフォーマット
static NSString *kAKImageNameFormat = @"Enemy_%02d";
/// 画像の種類の数
static const NSInteger kAKEnemyImageDefCount = 1;
/// 敵の種類の数
static const NSInteger kAKEnemyDefCount = 2;

/// 敵画像の定義
static const struct AKEnemyImageDef kAKEnemyImageDef[kAKEnemyImageDefCount] = {
    {1, 2, 0.05f}   // トンボ
};

/// 敵の定義
static const struct AKEnemyDef kAKEnemyDef[kAKEnemyDefCount] = {
    {1, 1, 1, 32, 32, 3, 100},  // トンボ
    {2, 1, 1, 32, 32, 3, 100}   // テスト用
};

/// 標準弾の種別
static const NSInteger kAKEnemyShotTypeNormal = 1;

/*!
 @brief 敵クラス
 
 敵キャラクターのクラス。
 */
@implementation AKEnemy

/*!
 @brief キャラクター固有の動作

 生成時に指定されたセレクタを呼び出す。
 @param dt フレーム更新間隔
 */
- (void)action:(ccTime)dt
{
    NSNumber *objdt = NULL;     // フレーム更新間隔(オブジェクト版)
    
    // 動作開始からの経過時間をカウントする
    time_ += dt;
    
    // id型として渡すためにNSNumberを作成する
    objdt = [NSNumber numberWithFloat:dt];
    
    // 敵種別ごとの処理を実行
    [self performSelector:action_ withObject:objdt];
}

/*!
 @brief 破壊処理

 HPが0になったときに敵種別固有の破壊処理を呼び出す。
 */
- (void)destroy
{
    // 破壊時の効果音を鳴らす
//    [[SimpleAudioEngine sharedEngine] playEffect:kAKHitSE];
    
    // スコアを加算する
    [[AKPlayData sharedInstance] addScore:score_];
    
    // 敵種別ごとの処理を実行
    [self performSelector:destroy_];
    
    // 画像の解放
    [self.image removeFromParentAndCleanup:YES];
    self.image = nil;
    
    // スーパークラスの処理を行う
    [super destroy];
}

/*!
 @brief 生成処理

 敵キャラを生成する。
 @param type 敵キャラの種別
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param parent 敵キャラを配置する親ノード
 */
- (void)createEnemyType:(NSInteger)type x:(NSInteger)x y:(NSInteger)y parent:(CCNode*)parent;
{
    // パラメータの内容をメンバに設定する
    self.positionX = x;
    self.positionY = y;
    
    // 配置フラグを立てる
    isStaged_ = YES;
    
    // 動作時間をクリアする
    time_ = 0;
    
    // 状態をクリアする
    state_ = 0;
    
    NSAssert(type > 0 && type <= kAKEnemyDefCount, @"敵の種類の値が範囲外");
    NSAssert(kAKEnemyDef[type - 1].image <= kAKEnemyImageDefCount, @"敵の画像の種類の値が範囲外");
    
    // 動作処理を設定する
    action_ = [self actionSelector:kAKEnemyDef[type - 1].action];
    
    // 破壊処理を設定する
    destroy_ = [self destroySeletor:kAKEnemyDef[type - 1].destroy];
    
    // 画像定義を取得する
    const struct AKEnemyImageDef *imageDef = &kAKEnemyImageDef[kAKEnemyDef[type - 1].image - 1];
    
    // 画像名を作成する
    self.imageName = [NSString stringWithFormat:kAKImageNameFormat, imageDef->fileNo];
                
    // アニメーションフレームの個数を設定する
    self.animationPattern = imageDef->animationFrame;
    
    // アニメーションフレーム間隔を設定する
    self.animationInterval = imageDef->animationInterval;
    
    // 当たり判定のサイズを設定する
    self.width = kAKEnemyDef[type - 1].hitWidth;
    self.height = kAKEnemyDef[type - 1].hitHeight;
    
    // ヒットポイントを設定する
    self.hitPoint = kAKEnemyDef[type - 1].hitPoint;
    
    // スコアを設定する
    score_ = kAKEnemyDef[type - 1].score;
    
    // レイヤーに配置する
    [parent addChild:self.image];
}

/*!
 @brief 動作処理取得
 
 種別番号から動作処理のセレクタを取得する。
 @param type 種別番号
 @return 動作処理のセレクタ
 */
- (SEL)actionSelector:(NSInteger)type
{
    switch (type) {
        case 1:
            return @selector(action_01:);
            
        case 2:
            return @selector(action_02:);
            
        default:
            NSAssert(NO, @"不正な種別");
            return @selector(action_01:);
    }
}

/*!
 @brief 破壊処理取得
 
 種別番号から破壊処理のセレクタを取得する。
 @param type 種別番号
 @return 破壊処理のセレクタ
 */
- (SEL)destroySeletor:(NSInteger)type
{
    switch (type) {
        case 1:
            return @selector(destroy_01);
            
        default:
            NSAssert(NO, @"不正な種別");
            return @selector(destroy_01);
    }
}

/*!
 @brief 動作処理1
 
 まっすぐ進む。一定間隔で自機を狙う1-way弾発射。
 @param dt フレーム更新間隔
 */
- (void)action_01:(ccTime)dt
{
    // 弾のスピード
    const float kAKShotSpeed = 150.f;
    
    // 左へ直進する
    self.speedX = -120.0f;
    self.speedY = 0.0f;
    
    // 一定時間経過しているときは自機を狙う1-way弾を発射する
    if (time_ > 1.0f) {
        
        // 弾を発射する
        [self fireNWay:1 interval:0.0f speed:kAKShotSpeed];
        
        // 動作時間の初期化を行う
        time_ = 0.0f;
    }
    
    AKLog(kAKLogEnemy_1, @"pos=(%f, %f)", self.positionX, self.positionY);
    AKLog(kAKLogEnemy_1, @"img=(%f, %f)", self.image.position.x, self.image.position.y);
}

/*!
 @brief 動作処理2
 
 停止。一定間隔で自機を狙う1-way弾発射。
 @param dt フレーム更新間隔
 */
- (void)action_02:(ccTime)dt
{
    // 弾のスピード
    const float kAKShotSpeed = 150.f;
    
    // 動かない
    self.speedX = 0.0f;
    self.speedY = 0.0f;
    
    // 一定時間経過しているときは自機を狙う1-way弾を発射する
    if (time_ > 1.0f) {
        
        // 弾を発射する
        [self fireNWay:1 interval:0.0f speed:kAKShotSpeed];
        
        // 動作時間の初期化を行う
        time_ = 0.0f;
    }
    
    AKLog(kAKLogEnemy_1, @"pos=(%f, %f)", self.positionX, self.positionY);
    AKLog(kAKLogEnemy_1, @"img=(%f, %f)", self.image.position.x, self.image.position.y);
}

/*!
 @brief 破壊処理1
 
 破壊エフェクトを発生させる。
 */
- (void)destroy_01
{
    AKLog(kAKLogEnemy_1, @"start");
    
    // 画面効果を生成する
    [[AKPlayData sharedInstance] createEffect:1 x:self.positionX y:self.positionY];
}

/*!
 @brief n-Way弾発射
 
 n-Way弾の発射を行う。
 @param way 発射方向の数
 @param interval 弾の間隔
 @param speed 弾の速度
 */
- (void)fireNWay:(NSInteger)way interval:(float)interval speed:(float)speed
{
    // 自機インスタンスを取得する
    AKCharacter *player = [AKPlayData sharedInstance].player;
    
    // 敵と自機の位置から角度を計算する
    float baseAnble = AKCalcDestAngle(self.positionX,
                                      self.positionY,
                                      player.positionX,
                                      player.positionY);
    
    // 発射角度を計算する
    NSArray *angleArray = AKCalcNWayAngle(way, baseAnble, interval);
    
    // 各弾を発射する
    for (NSNumber *angle in angleArray) {
        // 通常弾を生成する
        [[AKPlayData sharedInstance] createEnemyShotType:kAKEnemyShotTypeNormal
                                                    x:self.positionX
                                                    y:self.positionY
                                                angle:[angle floatValue]
                                                speed:speed];
    }
}
@end
