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

// 敵弾の種類
enum AKEnemyShotType {
    kAKEnemyShotTypeNormal = 0,     ///< 標準弾
    kAKEnemyShotTypeChangeSpeed,    ///< 速度変更弾
    kAKEnemyShotTypeDefCount        ///< 敵弾の種類の数
};

/// 画像名のフォーマット
static NSString *kAKImageNameFormat = @"EnemyShot_%02d";
/// 画像の種類の数
static const NSInteger kAKEnemyShotImageDefCount = 1;
/// 反射弾の威力
static const NSInteger kAKReflectionPower = 5;

/// 敵弾画像の定義
static const struct AKEnemyShotImageDef kAKEnemyShotImageDef[kAKEnemyShotImageDefCount] = {
    {1, 1, 0.0f}   // 標準弾
};

/// 敵弾の定義
static const struct AKEnemyShotDef kAKEnemyShotDef[kAKEnemyShotTypeDefCount] = {
    {1, 1, 6, 6, 5},    // 標準弾
    {2, 1, 6, 6, 5}     // 速度変更弾
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
- (void)action:(id<AKPlayDataInterface>)data
{
    // 動作開始からのフレーム数をカウントする
    frame_++;

    // 敵弾種別ごとの処理を実行
    [self performSelector:action_ withObject:data];
}

/*!
 @brief 通常弾生成
 
 通常弾を生成する。
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param angle 進行方向
 @param speed スピード
 @param parent 配置する親ノード
 */
- (void)createNormalShotAtX:(NSInteger)x
                          y:(NSInteger)y
                      angle:(float)angle
                      speed:(float)speed
                     parent:(CCNode *)parent
{
    // 種別に通常弾を指定して生成を行う
    [self createEnemyShotType:kAKEnemyShotTypeNormal
                            x:x
                            y:y
                        angle:angle
                        speed:speed
                       parent:parent];
}

/*!
 @brief スクロール影響弾生成
 
 スクリールスピードの影響を受ける弾を生成する。
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param angle 進行方向
 @param speed スピード
 @param parent 配置する親ノード
 */
- (void)createScrollShotAtX:(NSInteger)x
                          y:(NSInteger)y
                      angle:(float)angle
                      speed:(float)speed
                     parent:(CCNode *)parent
{
    // 種別に通常弾を指定して生成を行う
    [self createEnemyShotType:kAKEnemyShotTypeNormal
                            x:x
                            y:y
                        angle:angle
                        speed:speed
                       parent:parent];
    
    // スクロールスピードの影響を設定する
    self.scrollSpeed = 1.0f;
}

/*!
 @brief 速度変更弾生成

 途中で速度を変更する弾を生成する。
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param angle 進行方向
 @param speed スピード
 @param parent 配置する親ノード
 */
- (void)createChangeSpeedShotAtX:(NSInteger)x
                               y:(NSInteger)y
                           angle:(float)angle
                           speed:(float)speed
                  changeInterval:(NSInteger)changeInterval
                     changeAngle:(float)changeAngle
                     changeSpeed:(float)changeSpeed
                          parent:(CCNode *)parent
{
    // 種別に速度変更弾を指定して生成を行う
    [self createEnemyShotType:kAKEnemyShotTypeChangeSpeed
                            x:x
                            y:y
                        angle:angle
                        speed:speed
                       parent:parent];
    
    // 速度変更までの間隔を設定する
    changeInterval_ = changeInterval;
    
    // 変更後のスピードを設定する
    changeSpeedX_ = cosf(changeAngle) * changeSpeed;
    changeSpeedY_ = sinf(changeAngle) * changeSpeed;
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
    
    AKLog(kAKLogEnemyShot_1, @"angle=%f speed=(%f, %f)", angle * 180 / M_PI, self.speedX, self.speedY);
    
    // 配置フラグを立てる
    isStaged_ = YES;

    // 動作フレーム数をクリアする
    frame_ = 0;
    
    // 状態をクリアする
    state_ = 0;
    
    // 動作処理を設定する
    self.action = [self actionSelector:kAKEnemyShotDef[type].action];
    
    // 画像定義を取得する
    const struct AKEnemyShotImageDef *imageDef = &kAKEnemyShotImageDef[kAKEnemyShotDef[type].image - 1];
    
    // 画像名を作成する
    self.imageName = [NSString stringWithFormat:kAKImageNameFormat, imageDef->fileNo];
    
    // アニメーションフレームの個数を設定する
    self.animationPattern = imageDef->animationFrame;
    
    // アニメーションフレーム間隔を設定する
    self.animationInterval = imageDef->animationInterval;
    
    // 当たり判定のサイズを設定する
    self.width = kAKEnemyShotDef[type].hitWidth;
    self.height = kAKEnemyShotDef[type].hitHeight;
    
    // ヒットポイントを設定する
    self.hitPoint = 1;
    
    // かすりポイントを設定する
    self.grazePoint = kAKEnemyShotDef[type].grazePoint;
    
    // 障害物衝突時は消滅する
    self.blockHitAction = kAKBlockHitDisappear;
    
    // スクロールをなしにする
    self.scrollSpeed = 0.0f;

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
    
    // 動作フレーム数をクリアする
    frame_ = 0;
    
    // 状態をクリアする
    state_ = 0;
    
    // 動作処理をなしにする
    self.action = @selector(actionNone:);
    
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
            return @selector(actionNone:);
            
        case 2:
            return @selector(actionChangeSpeed:);
            
        default:
            NSAssert(NO, @"不正な種別");
            return @selector(actionNone:);
    }
}

/*!
 @brief 動作処理なし
 
 スピード一定のまま進めるため、無処理。
 @param data ゲームデータ
 */
- (void)actionNone:(id<AKPlayDataInterface>)data
{
    
}

/*!
 @brief 速度変更
 
 途中で速度を変更する。
 @param data ゲームデータ
 */
- (void)actionChangeSpeed:(id<AKPlayDataInterface>)data
{
    AKLog(kAKLogEnemyShot_2, @"frame=%d changeInterval=%d", frame_, changeInterval_);
    
    // 速度変更までの間隔が経過している場合は速度を変更する
    if (frame_ >= changeInterval_) {
        
        AKLog(kAKLogEnemyShot_1, @"speed=(%f, %f)", self.speedX, self.speedY);
        
        self.speedX = changeSpeedX_;
        self.speedY = changeSpeedY_;

        AKLog(kAKLogEnemyShot_1, @"speed=(%f, %f)", self.speedX, self.speedY);
    }
}
@end
