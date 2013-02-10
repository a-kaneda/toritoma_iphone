//
//  AKPlayerShot.m
//  toritoma
//
//  Created by KANEDA AKIHIRO on 2013/02/03.
//  Copyright (c) 2013年 KANEDA AKIHIRO. All rights reserved.
//

#import "AKPlayerShot.h"

/// 自機弾のスピード
static const float kAKPlayerShotSpeed = 320.0f;
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
