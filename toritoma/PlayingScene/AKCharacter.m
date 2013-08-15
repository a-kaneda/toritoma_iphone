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
 @file AKCharacter.m
 @brief キャラクタークラス定義
 
 当たり判定を持つオブジェクトの基本クラスを定義する。
 */

#import "AKCharacter.h"

/// デフォルトアニメーション間隔
static const float kAKDefaultAnimationInterval = 0.2f;
/// 画像ファイル名のフォーマット
static NSString *kAKImageFileFormat = @"%@_%02d.png";
/// 画像ファイル名の最大文字数
static const NSUInteger kAKMaxImageFileName = 64;

/// アニメーションパターンに応じた画像名
static NSMutableString *imageFileName_ = nil;

/*!
 @brief キャラクタークラス
 
 当たり判定を持つオブジェクトの基本クラス。
 */
@implementation AKCharacter

@synthesize image = image_;
@synthesize width = width_;
@synthesize height = height_;
@synthesize positionX = positionX_;
@synthesize positionY = positionY_;
@synthesize prevPositionX = prevPositionX_;
@synthesize prevPositionY = prevPositionY_;
@synthesize speedX = speedX_;
@synthesize speedY = speedY_;
@synthesize hitPoint = hitPoint_;
@synthesize power = power_;
@synthesize isStaged = isStaged_;
@synthesize animationPattern = animationPattern_;
@synthesize animationInterval = animationInterval_;
@synthesize animationTime = animationTime_;
@synthesize animationRepeat = animationRepeat_;
@synthesize animationInitPattern = animationInitPattern_;
@synthesize scrollSpeed = scrollSpeed_;
@synthesize blockHitAction = blockHitAction_;
@synthesize blockHitSide = blockHitSide_;

/*!
 @brief オブジェクト生成処理

 オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 各メンバを0で初期化する
    self.image = nil;
    self.width = 0;
    self.height = 0;
    self.positionX = 0.0f;
    self.positionY = 0.0f;
    self.prevPositionX = 0.0f;
    self.prevPositionY = 0.0f;
    self.speedX = 0.0f;
    self.speedY = 0.0f;
    self.hitPoint = 0;
    self.isStaged = NO;
    self.animationTime = 0.0f;
    self.scrollSpeed = 0.0f;
    offset_ = ccp(0.0f, 0.0f);
    
    // 攻撃力の初期値は1とする
    self.power = 1;
    
    // アニメーションのデフォルトパターン数は1(アニメーションなし)とする
    self.animationPattern = 1;
    
    // アニメーションのデフォルト間隔を設定する
    self.animationInterval = kAKDefaultAnimationInterval;
    
    // アニメーション繰り返し回数は0(無限)とする
    self.animationRepeat = 0;
    
    // アニメーション初期パターンは1とする
    self.animationInitPattern = 1;
    
    // アニメーションパターンに応じた画像名を格納するためのグローバル変数を作成する。
    // 処理の都度NSStringのアロケートを行うと処理が重くなる。
    // 高速化のため、最初に1個作っておいて全キャラクターで使い回しを行う。
    if (imageFileName_ == nil) {
        imageFileName_ = [[NSMutableString alloc] initWithCapacity:kAKMaxImageFileName];
        AKLog(kAKLogCharacter_1, @"imageFileName_=%p", imageFileName_);
    }
    
    return self;
}

/*!
 @brief インスタンス解放時処理

 インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    // スプライトを解放する
    [self.image removeFromParentAndCleanup:YES];
    self.image = nil;
    
    // スーパークラスの解放処理
    [super dealloc];
}

/*!
 @brief 画像名の取得
 
 画像名を取得する。
 @return 画像名
 */
- (NSString *)imageName
{
    return imageName_;
}

/*!
 @brief 画像名の設定
 
 画像名を設定する。
 @param imageName 画像名
 */
- (void)setImageName:(NSString *)imageName
{
    // スプライト名を設定する
    if (imageName_ != imageName) {
        [imageName_ release];
        imageName_ = [imageName retain];
    }
    
    // スプライト名が設定された場合はスプライト作成を行う
    if (imageName_ != nil) {
        
        // 画像ファイル名を決定する
        NSString *imageFileName = [NSString stringWithFormat:kAKImageFileFormat, imageName_, 1];
        
        // スプライト作成前の場合はスプライトを作成する
        if (self.image == nil) {
            self.image = [CCSprite spriteWithSpriteFrameName:imageFileName];
        }
        // すでにスプライトを作成している場合は画像の切り替えを行う
        else {
            [self.image setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageFileName]];
        }
    }
}

/*!
 @brief アニメーション初期パターンの設定
 
 アニメーション初期パターンを設定する。
 @param animationInitPattern アニメーション初期パターン
 */
- (void)setAnimationInitPattern:(NSInteger)animationInitPattern
{
    // メンバに設定する
    animationInitPattern_ = animationInitPattern;
    
    // すでにスプライトを作成している場合は画像の切り替えを行う
    if (self.image != nil) {
        
        // アニメーション時間を初期化する
        self.animationTime = 0.0f;
        
        // アニメーションパターンに応じて画像ファイル名を作成する
        NSRange range = {0, imageFileName_.length};
        [imageFileName_ deleteCharactersInRange:range];
        [imageFileName_ appendFormat:kAKImageFileFormat, self.imageName, animationInitPattern];
        
        // 表示スプライトを変更する
        [self.image setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageFileName_]];
    }
}

/*!
 @brief 移動処理

 速度によって位置を移動する。
 アニメーションを行う。
 @param dt フレーム更新間隔
 @param data ゲームデータ
 */
- (void)move:(ccTime)dt data:(id<AKPlayDataInterface>)data
{
    // 画面に配置されていない場合は無処理
    if (!self.isStaged) {
        return;
    }
    
    // HPが0になった場合は破壊処理を行う
    if (self.hitPoint <= 0) {
        [self destroy:data];
        return;
    }
    
    // 画面外に出た場合は削除する
    if ([self isOutOfStage:data]) {

        // ステージ配置フラグを落とす
        self.isStaged = NO;
        
        // 画面から取り除く
        [self.image removeFromParentAndCleanup:YES];
        
        return;
    }
    
    // 移動前の座標を記憶する
    self.prevPositionX = self.positionX;
    self.prevPositionY = self.positionY;
    
    AKLog(kAKLogCharacter_2, @"scroll=(%f, %f)", data.scrollSpeedX, data.scrollSpeedY);
            
    // 座標の移動
    // 画面スクロールの影響を受ける場合は画面スクロール分も移動する
    self.positionX += (self.speedX * dt) - (data.scrollSpeedX * dt * self.scrollSpeed);
    self.positionY += (self.speedY * dt) - (data.scrollSpeedY * dt * self.scrollSpeed);
        
    // 障害物との衝突判定を行う
    switch (self.blockHitAction) {
        case kAKBlockHitNone:       // 無処理
        case kAKBlockHitPlayer:     // 自機
            break;
            
        case kAKBlockHitMove:       // 移動
            [self checkHit:[data.blocks objectEnumerator]
                      data:data
                      func:@selector(moveOfBlockHit:data:)];
            break;
            
        case kAKBlockHitDisappear:  // 消滅
            [self checkHit:[data.blocks objectEnumerator]
                      data:data
                      func:@selector(disappearOfBlockHit:data:)];
            break;
            
        default:
            break;
    }
    
    AKLog(kAKLogCharacter_2, @"pos=(%.0f, %.0f) scr=(%d, %d)",
          self.positionX, self.positionY,
          [AKScreenSize xOfStage:self.positionX], [AKScreenSize yOfStage:self.positionY]);
        
    // 画像表示位置の更新を行う
    [self updateImagePosition];
    
    // アニメーション時間をカウントする
    self.animationTime += dt;
    
    // 表示するパターンを決定する
    NSInteger pattern = self.animationInitPattern;
    
    AKLog([self.imageName isEqualToString:@"Enemy_12"] && NO, @"self.animationPattern = %d", self.animationPattern);
    
    // アニメーションパターンが複数存在する場合はパターン切り替えを行う
    if (self.animationPattern >= 2) {
        
        // 経過時間からパターンを決定する
        pattern = (NSInteger)(self.animationTime / self.animationInterval) + self.animationInitPattern;
    
        // パターンがパターン数を超えた場合はアニメーション時間をリセットし、パターンを最初のものに戻す。
        if (pattern - (self.animationInitPattern - 1) > self.animationPattern) {
            self.animationTime = 0.0f;
            pattern = self.animationInitPattern;
            
            // 繰り返し回数が設定されている場合
            if (self.animationRepeat > 0) {
                
                // 繰り返し回数を減らす
                self.animationRepeat--;
                
                // 繰り返し回数が0になった場合は画面から取り除く
                if (self.animationRepeat <= 0) {
                    
                    // ステージ配置フラグを落とす
                    self.isStaged = NO;
                    
                    // 画面から取り除く
                    [self.image removeFromParentAndCleanup:YES];
                    
                    return;
                }
            }
        }
        
        AKLog([self.imageName isEqualToString:@"Enemy_12"] && NO, @"pattern=%d time=%f interval=%f", pattern, self.animationTime, self.animationInterval);
        
        // アニメーションパターンに応じて画像ファイル名を作成する
        NSRange range = {0, imageFileName_.length};
        [imageFileName_ deleteCharactersInRange:range];
        [imageFileName_ appendFormat:kAKImageFileFormat, self.imageName, pattern];
        
        // 表示スプライトを変更する
        [self.image setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageFileName_]];
    }
    
    // キャラクター固有の動作を行う
    [self action:dt data:data];
}

/*!
 @brief キャラクター固有の動作

 キャラクター種別ごとの動作を行う。
 @param dt フレーム更新間隔
 @param data ゲームデータ
 */
- (void)action:(ccTime)dt data:(id<AKPlayDataInterface>)data
{
    // 派生クラスで動作を定義する
}

/*!
 @brief 破壊処理

 HPが0になったときの処理
 @param data ゲームデータ
 */
- (void)destroy:(id<AKPlayDataInterface>)data
{
    // ステージ配置フラグを落とす
    self.isStaged = NO;
    
    // 画面から取り除く
    AKLog(kAKLogCharacter_1, @"removeFromParentAndCleanup実行");
    [self.image removeFromParentAndCleanup:YES];
}

/*!
 @brief 衝突判定(汎用)
 
 衝突判定を行う。衝突時にどのような処理を行うかをパラメータで指定する。
 @param characters 判定対象のキャラクター群
 @param data ゲームデータ
 @param func 衝突時処理
 @return 衝突したかどうか
 */
- (BOOL)checkHit:(const NSEnumerator *)characters data:(id<AKPlayDataInterface>)data func:(SEL)func
{
    // 画面に配置されていない場合は処理しない
    if (!self.isStaged) {
        return NO;
    }
    
    // 自キャラの上下左右の端を計算する
    float myleft = self.positionX - self.width / 2.0f;
    float myright = self.positionX + self.width / 2.0f;
    float mytop = self.positionY + self.height / 2.0f;
    float mybottom = self.positionY - self.height / 2.0f;
    
    
    // 衝突したかどうかを記憶する
    BOOL isHit = NO;
    
    // 衝突している方向を初期化する
    self.blockHitSide = 0;
    
    // 判定対象のキャラクターごとに判定を行う
    for (AKCharacter *target in characters) {
        
        // 相手が画面に配置されていない場合は処理しない
        if (!target.isStaged) {
            continue;
        }
        
        // 相手の上下左右の端を計算する
        float targetleft = target.positionX - target.width / 2.0f;
        float targetright = target.positionX + target.width / 2.0f;
        float targettop = target.positionY + target.height / 2.0f;
        float targetbottom = target.positionY - target.height / 2.0f;
        
        // 以下のすべての条件を満たしている時、衝突していると判断する。
        //   ・相手の右端が自キャラの左端よりも右側にある
        //   ・相手の左端が自キャラの右端よりも左側にある
        //   ・相手の上端が自キャラの下端よりも上側にある
        //   ・相手の下端が自キャラの上端よりも下側にある
        if ((targetright > myleft) &&
            (targetleft < myright) &&
            (targettop > mybottom) &&
            (targetbottom < mytop)) {
            
            AKLog(kAKLogCharacter_3, @"my=(%f, %f, %f, %f)", myleft, myright, mytop, mybottom);
            AKLog(kAKLogCharacter_3, @"target=(%f, %f, %f, %f)", targetleft, targetright, targettop, targetbottom);
            
            // 衝突処理を行う
            if (func != NULL) {
                [self performSelector:func withObject:target withObject:data];
            }
            
            AKLog(kAKLogCharacter_3, @"self.hitPoint=%d, target.hitPoint=%d", self.hitPoint, target.hitPoint);
            
            // 衝突したかどうかを記憶する
            isHit = YES;
        }
    }
    
    // 衝突したかどうかを返す
    return isHit;
}

/*!
 @brief キャラクター衝突判定

 キャラクターが衝突しているか調べ、衝突しているときはHPを減らす。
 @param characters 判定対象のキャラクター群
 @param data ゲームデータ
 */
- (void)checkHit:(const NSEnumerator *)characters data:(id<AKPlayDataInterface>)data
{
    [self checkHit:characters data:data func:@selector(hit:data:)];
}

/*!
 @brief 衝突処理
 
 衝突した時の処理、自分と相手のHPを減らす。
 @param character 衝突した相手
 @param data ゲームデータ
 */
- (void)hit:(AKCharacter *)character data:(id<AKPlayDataInterface>)data
{
    // 自分と相手のHPを衝突した相手の攻撃力分減らす
    self.hitPoint -= character.power;
    character.hitPoint -= self.power;
}

/*!
 @brief 障害物との衝突による移動
 
 障害物との衝突時に行う移動処理。
 進行方向と反対方向へ移動して障害物の境界まで戻る。
 @param character 衝突した相手
 @param data ゲームデータ
 */
- (void)moveOfBlockHit:(AKCharacter *)character data:(id<AKPlayDataInterface>)data;
{
    AKLog(kAKLogCharacter_4, @"current:self=(%f, %f, %d, %d) target=(%f, %f, %d, %d)",
          self.positionX, self.positionY, self.width, self.height,
          character.positionX, character.positionY, character.width, character.height);
    AKLog(kAKLogCharacter_4, @"prev:self=(%f, %f, %d, %d) target=(%f, %f, %d, %d)",
          self.prevPositionX, self.prevPositionY, self.width, self.height,
          character.prevPositionX, character.prevPositionY, character.width, character.height);
    
    // 衝突による移動先の座標を現在の座標で初期化する
    CGPoint newPoint = ccp(self.positionX, self.positionY);
    
    // 判定後の接触フラグを現在の値で初期化する
    NSUInteger newHitSide = self.blockHitSide;
    
    // 障害物の横方向の端に合わせて移動した場合は
    // 縦方向の移動は不要になるため、フラグを立てて後で使用する。
    BOOL isXMoved = NO;
    
    // x方向右に進んでいる時に衝突した場合
    if (self.positionX > self.prevPositionX &&
        self.positionX > character.positionX - (self.width + character.width) / 2) {
        
        // 前回の右端が障害物の前回の左端よりも右側ならば
        // 障害物内部に入り込んでいるものとみなし、前回値に戻す
        if (self.prevPositionX > character.prevPositionX - (self.width + character.width) / 2) {

            AKLog(kAKLogCharacter_4, @"右側が障害物内部に入り込み");
            newPoint.x = self.prevPositionX;
        }
        // そうでない場合は右端を障害物の左端に合わせる
        else {
            
            AKLog(kAKLogCharacter_4, @"右側が接触");
            newPoint.x = character.positionX - (self.width + character.width) / 2;
            
            // 横方向移動のフラグを立てる
            isXMoved = YES;
        }
        
        // 右側との接触フラグを立てる
        newHitSide |= kAKHitSideRight;
    }
    // x方向左に進んでいる時に衝突した場合
    else if (self.positionX < self.prevPositionX &&
             self.positionX < character.positionX + (self.width + character.width) / 2) {
        
        // 前回の左端が障害物の前回の右端よりも左側ならば
        // 障害物内部に入り込んでいるものとみなし、前回値に戻す
        if (self.prevPositionX < character.prevPositionX + (self.width + character.width) / 2) {
            
            AKLog(kAKLogCharacter_4, @"左側が障害物内部に入り込み");
            newPoint.x = self.prevPositionX;
        }
        // そうでない場合は左端を障害物の右端に合わせる
        else {
            
            AKLog(kAKLogCharacter_4, @"左側が接触");
            newPoint.x = character.positionX + (self.width + character.width) / 2;
            
            // 横方向移動のフラグを立てる
            isXMoved = YES;
        }
        
        // 左側との接触フラグを立てる
        newHitSide |= kAKHitSideLeft;
    }
    // x方向に進んでいない、または衝突していない場合は無処理
    else {
        AKLog(kAKLogCharacter_4, @"横方向の接触なし");
        // 無処理
    }
    
    // 障害物の縦方向の端に合わせて移動した場合は
    // 横方向の移動は不要になるため、フラグを立てて後で使用する。
    BOOL isYMoved = NO;
    
    // y方向上に進んでいる時に衝突した場合
    if (self.positionY > self.prevPositionY &&
        self.positionY > character.positionY - (self.height + character.height) / 2) {
        
        // 前回の上端が障害物の前回の下端よりも上側ならば
        // 障害物内部に入り込んでいるものとみなし、前回値に戻す
        if (self.prevPositionY > character.prevPositionY - (self.height + character.height) / 2) {

            AKLog(kAKLogCharacter_4, @"上側が障害物内部に入り込み");
            newPoint.y = self.prevPositionY;
        }
        // そうでない場合は上端を障害物の下端に合わせる
        else {
            
            AKLog(kAKLogCharacter_4, @"上側が接触");
            newPoint.y = character.positionY - (self.height + character.height) / 2;
            
            // 縦方向移動のフラグを立てる
            isYMoved = YES;
        }
        
        // 上側との接触フラグを立てる
        newHitSide |= kAKHitSideTop;
    }
    // y方向下に進んでいる時に衝突した場合
    else if (self.positionY < self.prevPositionY &&
             self.positionY < character.positionY + (self.height + character.height) / 2) {
        
        // 前回の下端が障害物の前回の上端よりも下側ならば
        // 障害物内部に入り込んでいるものとみなし、前回値に戻す
        if (self.prevPositionY < character.prevPositionY + (self.height + character.height) / 2) {

            AKLog(kAKLogCharacter_4, @"下側が障害物内部に入り込み");
            newPoint.y = self.prevPositionY;
        }
        // そうでない場合は下端を障害物の上端に合わせる
        else {
            
            AKLog(kAKLogCharacter_4, @"下側が接触");
            newPoint.y = character.positionY + (self.height + character.height) / 2;
            
            // 縦方向移動のフラグを立てる
            isYMoved = YES;
        }
        
        // 下側との接触フラグを立てる
        newHitSide |= kAKHitSideBottom;
    }
    // y方向に進んでいない、または衝突していない場合は無処理
    else {
        AKLog(kAKLogCharacter_4, @"縦方向の接触なし");
        // 無処理
    }
    
    // 横方向へ移動した場合
    if (isXMoved) {
        // 横方向の座標と接触フラグを採用する
        self.positionX = newPoint.x;
        self.blockHitSide |= (newHitSide & (kAKHitSideLeft | kAKHitSideRight));
    }
    // 縦方向へ移動した場合
    else if (isYMoved) {
        // 縦方向の座標と接触フラグを採用する
        self.positionY = newPoint.y;
        self.blockHitSide |= (newHitSide & (kAKHitSideTop | kAKHitSideBottom));
    }
    // 障害物内部に入り込んでいる場合
    else {
        // 縦横両方の座標と接触フラグを採用する
        self.positionX = newPoint.x;
        self.positionY = newPoint.y;
        self.blockHitSide = newHitSide;
    }
    
    AKLog(kAKLogCharacter_4, @"newposition=(%f, %f)", self.positionX, self.positionY);
}

/*!
 @brief 障害物との衝突による消滅
 
 障害物との衝突時に行う消滅処理。自分のHPを0にする。
 @param character 衝突した相手
 @param data ゲームデータ
 */
- (void)disappearOfBlockHit:(AKCharacter *)character data:(id<AKPlayDataInterface>)data;
{
    self.hitPoint = 0.0;
}

/*!
 @brief 画面外配置判定
 
 キャラクターが画面範囲外に配置されているか調べる。
 座標が範囲外で、外側に向かって移動している場合は範囲外とみなす。
 範囲内に向かって移動している場合は範囲内とみなす。
 @param data ゲームデータ
 @return 範囲外に出ている場合はYES、範囲内にある場合はNO
 */
- (BOOL)isOutOfStage:(id<AKPlayDataInterface>)data
{
    // 表示範囲外でキャラクターを残す範囲
    const float kAKBorder = 50.0f;
    
    if ((self.positionX < -kAKBorder &&
         (self.speedX - data.scrollSpeedX * self.scrollSpeed) < 0.0f) ||
        (self.positionX > [AKScreenSize stageSize].width + kAKBorder &&
         (self.speedX - data.scrollSpeedX * self.scrollSpeed) > 0.0f) ||
        (self.positionY < -kAKBorder &&
         (self.speedY - data.scrollSpeedY * self.scrollSpeed) < 0.0f) ||
        (self.positionY > [AKScreenSize stageSize].height + kAKBorder &&
         (self.speedY - data.scrollSpeedY * self.scrollSpeed) > 0.0f)) {
        
        AKLog(kAKLogCharacter_1, @"画面外に出たため削除");
        
        return YES;
    }
    else {
        return NO;
    }
}

/*!
 @brief 画像表示位置更新
 
 画像の表示位置を現在のキャラクター位置とオフセットをもとに更新を行う。
 */
- (void)updateImagePosition
{
    self.image.position = ccp([AKScreenSize xOfStage:self.positionX + offset_.x],
                              [AKScreenSize yOfStage:self.positionY + offset_.y]);
}
@end
