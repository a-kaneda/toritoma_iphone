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
 @file AKEnemyShot.m
 @brief 敵弾クラス定義
 
 敵の発射する弾のクラスを定義する。
 */

#import "AKEnemyShot.h"

/// 画像名のフォーマット
static NSString *kAKImageNameFormat = @"EnemyShot_%02d";
/// 画像の種類の数
static const NSInteger kAKEnemyShotImageDefCount = 1;
/// 敵弾の種類の数
static const NSInteger kAKEnemyShotDefCount = 1;
/// 反射弾の威力
static const NSInteger kAKReflectionPower = 5;

/// 敵画像の定義
static const struct AKEnemyShotImageDef kAKEnemyShotImageDef[kAKEnemyShotImageDefCount] = {
    {1, 1, 0.0f}   // 標準弾
};

/// 敵の定義
static const struct AKEnemyShotDef kAKEnemyShotDef[kAKEnemyShotDefCount] = {
    {1, 1, 6, 6, 5}   // 標準弾
};

@implementation AKEnemyShot

@synthesize action = action_;
@synthesize grazePoint = grazePoint_;

/*!
 @brief キャラクター固有の動作
 
 生成時に指定されたセレクタを呼び出す。
 @param dt フレーム更新間隔
 @param data ゲームデータ
 */
- (void)action:(ccTime)dt data:(id<AKPlayDataInterface>)data
{
    NSNumber *objdt = NULL;     // フレーム更新間隔(オブジェクト版)
    
    // かすりポイントを減少させる
    self.grazePoint -= dt;
    
    // 動作開始からの経過時間をカウントする
    time_ += dt;
    
    // id型として渡すためにNSNumberを作成する
    objdt = [NSNumber numberWithFloat:dt];
    
    // 敵弾種別ごとの処理を実行
    [self performSelector:action_ withObject:objdt withObject:data];
}

/*!
 @brief 敵弾生成
 
 敵の弾を生成する。
 @para, type 種別
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param angle 進行方向
 @param speed スピード
 @param parent 配置する親ノード
 */
- (void)createEnemyShotType:(NSInteger)type
                          x:(NSInteger)x
                          y:(NSInteger)y
                      angle:(float)angle
                      speed:(float)speed
                     parent:(CCNode *)parent
{
    // パラメータの内容をメンバに設定する
    self.positionX = x;
    self.positionY = y;
    
    // スピードをxとyに分割して設定する
    self.speedX = cos(angle) * speed;
    self.speedY = sin(angle) * speed;
    
    // 配置フラグを立てる
    isStaged_ = YES;

    // 動作時間をクリアする
    time_ = 0;
    
    // 状態をクリアする
    state_ = 0;
    
    // 動作処理を設定する
    self.action = [self actionSelector:kAKEnemyShotDef[type - 1].action];
    
    // 画像定義を取得する
    const struct AKEnemyShotImageDef *imageDef = &kAKEnemyShotImageDef[kAKEnemyShotDef[type - 1].image - 1];
    
    // 画像名を作成する
    self.imageName = [NSString stringWithFormat:kAKImageNameFormat, imageDef->fileNo];
    
    // アニメーションフレームの個数を設定する
    self.animationPattern = imageDef->animationFrame;
    
    // アニメーションフレーム間隔を設定する
    self.animationInterval = imageDef->animationInterval;
    
    // 当たり判定のサイズを設定する
    self.width = kAKEnemyShotDef[type - 1].hitWidth;
    self.height = kAKEnemyShotDef[type - 1].hitHeight;
    
    // ヒットポイントを設定する
    self.hitPoint = 1;
    
    // かすりポイントを設定する
    self.grazePoint = kAKEnemyShotDef[type - 1].grazePoint;
    
    // 障害物衝突時は消滅する
    self.blockHitAction = kAKBlockHitDisappear;

    // レイヤーに配置する
    [parent addChild:self.image];
}

/*!
 @brief 反射弾生成
 
 反射弾を生成する。
 元になった弾と速度を反対にし、残りのパラメータは同じものを生成する。
 @param base 反射する弾
 @param parent 配置する親ノード
 */
- (void)createReflectedShot:(AKEnemyShot *)base parent:(CCNode *)parent
{
    AKLog(kAKLogEnemyShot_1, @"反射弾生成");
    
    // 位置を設定する
    self.positionX = base.positionX;
    self.positionY = base.positionY;
    
    // スピード反転させて設定する
    self.speedX = -base.speedX;
    self.speedY = -base.speedY;
    
    // 配置フラグを立てる
    isStaged_ = YES;
    
    // 動作時間をクリアする
    time_ = 0;
    
    // 状態をクリアする
    state_ = 0;
    
    // 動作処理を設定する
    self.action = base.action;
    
    // 画像名を作成する
    self.imageName = base.imageName;
    
    // アニメーションフレームの個数を設定する
    self.animationPattern = base.animationPattern;
    
    // アニメーションフレーム間隔を設定する
    self.animationInterval = base.animationInterval;
    
    // 当たり判定のサイズを設定する
    self.width = base.width;
    self.height = base.height;
    
    // ヒットポイントを設定する
    self.hitPoint = 1;
    
    // 攻撃力は反射弾の場合は補正をかける
    self.power = kAKReflectionPower;
    
    // 障害物衝突時は消滅する
    self.blockHitAction = kAKBlockHitDisappear;
    
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
            return @selector(action_01:data:);
            
        default:
            NSAssert(NO, @"不正な種別");
            return @selector(action_01:data:);
    }
}

/*!
 @brief 動作処理1
 
 スピード一定のまま進めるため、無処理。
 @param dt フレーム更新間隔
 @param data ゲームデータ
 */
- (void)action_01:(ccTime)dt data:(id<AKPlayDataInterface>)data
{
}

@end
