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
 @file AKBlock.m
 @brief 障害物クラス
 
 障害物を管理するクラスを定義する。
 */

#import "AKBlock.h"

/// 画像名のフォーマット
static NSString *kAKImageNameFormat = @"Block_%02d";
/// 障害物の種類の数
static const NSInteger kAKBlockDefCount = 6;

/// 障害物定義
static const struct AKBlcokDef kAKBlockDef[kAKBlockDefCount] = {
    {1, 1, 0.0f, 32, 32, 0,  0},   // 地面内側
    {2, 1, 0.0f, 32, 32, 0,  0},   // 地面
    {3, 1, 0.0f, 32, 16, 0,  8},   // 地面半分
    {4, 1, 0.0f, 32, 32, 0,  0},   // 天井
    {5, 1, 0.0f, 32, 16, 0, -8},   // 天井半分
    {6, 1, 0.0f, 32, 32, 0,  0}    // ブロック
};

/*!
 @brief 障害物クラス
 
 障害物を管理する。
 */
@implementation AKBlock

/*!
 @brief 障害物生成処理
 
 障害物を生成する。
 @param type 障害物種別
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param parent 配置する親ノード
 */
- (void)createBlockType:(NSInteger)type x:(float)x y:(float)y parent:(CCNode *)parent
{
    AKLog(kAKLogBlock_1, @"障害物生成");
    
    // パラメータの内容をメンバに設定する
    self.positionX = x;
    self.positionY = y;
        
    // 配置フラグを立てる
    self.isStaged = YES;

    // ヒットポイントは1とする
    self.hitPoint = 1;
        
    NSAssert(type > 0 && type <= kAKBlockDefCount, @"障害物種別の値が範囲外");
        
    // 画像名を作成する
    self.imageName = [NSString stringWithFormat:kAKImageNameFormat, kAKBlockDef[type - 1].image];
    
    // アニメーションフレームの個数を設定する
    self.animationPattern = kAKBlockDef[type - 1].animationFrame;
    
    // アニメーションフレーム間隔を設定する
    self.animationInterval = kAKBlockDef[type - 1].animationInterval;
    
    // 当たり判定のサイズを設定する
    self.width = kAKBlockDef[type - 1].hitWidth;
    self.height = kAKBlockDef[type - 1].hitHeight;
    
    // 画像表示位置オフセットを設定する
    offset_ = ccp(kAKBlockDef[type - 1].offsetX, kAKBlockDef[type - 1].offsetY);
    
    // 画像のオフセットと逆方向にキャラクター位置を移動する
    self.positionX -= offset_.x;
    self.positionY -= offset_.y;
    
    // 障害物は基本的に画面スクロールに応じて移動する
    self.scrollSpeed = 1.0f;
        
    // レイヤーに配置する
    [parent addChild:self.image];
}

/*!
 @brief 衝突処理
 
 衝突した時の処理、
 @param character 衝突した相手
 @param data ゲームデータ
 */
- (void)hit:(AKCharacter *)character data:(id<AKPlayDataInterface>)data
{
    // 相手の障害物衝突時の処理によって処理内容を分岐する
    switch (character.blockHitAction) {
        case kAKBlockHitNone:       // 無処理
            break;
            
        case kAKBlockHitMove:       // 移動
        case kAKBlockHitPlayer:     // 自機
            [self pushCharacter:character data:data];
            break;
            
        case kAKBlockHitDisappear:  // 消滅
            [self destroyCharacter:character];
            break;
            
        default:
            break;
    }
}

/*!
 @brief ぶつかったキャラクターを押し動かす
 
 ぶつかったキャラクターを押し動かす。
 移動先の座標は以下の優先度で設定し、衝突判定で問題なかった時点で採用する。
 @param character 衝突した相手
 @param data ゲームデータ
 */
- (void)pushCharacter:(AKCharacter *)character data:(id<AKPlayDataInterface>)data
{
    AKLog(kAKLogBlock_1, @"移動前=(%f, %f)", character.positionX, character.positionY);
    
    // 障害物左端への移動
    float leftX = self.positionX - (self.width + character.width) / 2;
    // 障害物右端への移動
    float rightX = self.positionX + (self.width + character.width) / 2;
    // 障害物下端への移動
    float bottomY = self.positionY - (self.height + character.height) / 2;
    // 障害物上端への移動
    float topY = self.positionY + (self.height + character.height) / 2;
    // 移動先座標配列
    float movePosX[4];
    float movePosY[4];
    
    // スクロール速度を取得する
    float scrollX = data.scrollSpeedX;
    float scrollY = data.scrollSpeedY;
    
    // 移動の優先度は
    //   1.スクロール方向
    //   2.スクロールと垂直方向の近い方
    //   3.スクロールと垂直方向の遠い方
    //   4.スクロールと反対方向
    
    // x方向への移動の場合
    if (scrollX * scrollX > scrollY * scrollY) {
        
        // 左方向への移動の場合
        if (scrollX > 0) {
            movePosX[0] = leftX;
            movePosY[0] = character.positionY;
            movePosX[3] = rightX;
            movePosY[3] = character.positionY;
        }
        // 右方向への移動の場合
        else {
            movePosX[0] = rightX;
            movePosY[0] = character.positionY;
            movePosX[3] = leftX;
            movePosY[3] = character.positionY;
        }
        
        // 相手が障害物より下にある場合
        if (self.positionY > character.positionY) {
            movePosX[1] = character.positionX;
            movePosY[1] = bottomY;
            movePosX[2] = character.positionX;
            movePosY[2] = topY;
        }
        // 相手が障害物より上にある場合
        else
        {
            movePosX[1] = character.positionX;
            movePosY[1] = topY;
            movePosX[2] = character.positionX;
            movePosY[2] = bottomY;
        }
    }
    // y方向への移動の場合
    else {
        
        // 上方向への移動の場合
        if (scrollY > 0) {
            movePosX[0] = character.positionX;
            movePosY[0] = bottomY;
            movePosX[3] = character.positionX;
            movePosY[3] = topY;
        }
        // 下方向への移動の場合
        else {
            movePosX[0] = character.positionX;
            movePosY[0] = topY;
            movePosX[3] = character.positionX;
            movePosY[3] = bottomY;
        }
        
        // 相手が障害物より左にある場合
        if (self.positionX > character.positionX) {
            movePosX[1] = leftX;
            movePosY[1] = character.positionY;
            movePosX[2] = rightX;
            movePosY[2] = character.positionY;
        }
        // 相手が障害物より上にある場合
        else
        {
            movePosX[1] = rightX;
            movePosY[1] = character.positionY;
            movePosX[2] = leftX;
            movePosY[2] = character.positionY;
        }
    }
    
    // 移動前の位置を記憶する
    character.prevPositionX = character.positionX;
    character.prevPositionY = character.positionY;
    
    // 4方向へ移動を試みる
    for (int i = 0; i < 4; i++) {
        
        // 位置を変更する
        character.positionX = movePosX[i];
        character.positionY = movePosY[i];
        
        AKLog(kAKLogBlock_1, @"[%d]=(%f, %f)", i, character.positionX, character.positionY);
        
        // 自機の場合は画面外への押し出しは禁止する
        if (character.blockHitAction == kAKBlockHitPlayer) {
            
            if (character.positionX < 0.0f ||
                character.positionX > [AKScreenSize stageSize].width ||
                character.positionY < 0.0f ||
                character.positionY > [AKScreenSize stageSize].height) {
                
                continue;
            }
        }
        
        // 衝突判定を行う
        if (![character checkHit:[data.blocks objectEnumerator] data:data func:NULL]) {
            
            // 衝突しなかった場合はこの値を採用して処理を終了する
            AKLog(kAKLogBlock_1, @"移動後=(%f, %f)", character.positionX, character.positionY);
            return;
        }
    }
    
    // どの方向にも移動できなかったときは元に戻す
    character.positionX = character.prevPositionX;
    character.positionY = character.prevPositionY;
}

/*!
 @brief ぶつかったキャラクターを消す
 
 ぶつかったキャラクターを消す。相手のHPを0にする。
 @param character 衝突した相手
 */
- (void)destroyCharacter:(AKCharacter *)character
{
    character.hitPoint = 0;
}

/*!
 @brief キャラクター固有の動作
 
 キャラクター種別ごとの動作を行う。
 実数計算誤差によるタイル間の隙間の発生を防止するため、
 タイルマップの位置を基準として画像表示位置を設定し直す。
 @param dt フレーム更新間隔
 @param data ゲームデータ
 */
- (void)action:(ccTime)dt data:(id<AKPlayDataInterface>)data
{
    // デバイススクリーン座標からマップ座標へ、マップ座標からタイルの座標へ変換する
    self.image.position = [data tilePositionFromDevicePosition:self.image.position];
}
@end
