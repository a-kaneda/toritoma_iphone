/*
 * Copyright (c) 2012-2013 Akihiro Kaneda.
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
 @file AKTitleScene.m
 @brief タイトルシーンクラスの定義
 
 タイトルシーンを管理するクラスを定義する。
 */

#import "AKTitleScene.h"
#import "AKPlayingScene.h"
#import "AKHowToPlayScene.h"
#import "AKOptionScene.h"

/// メニュー項目のタグ
enum {
    kAKTitleMenuGame = 1,   ///< ゲーム開始ボタン
    kAKTitleMenuHowTo,      ///< 遊び方ボタン
    kAKTitleMenuOption,     ///< オプションボタン
    kAKTitleMenuCredit,     ///< クレジットボタン
    kAKTitleMenuCount       ///< メニュー項目数
};

/// シーンに配置するレイヤーのタグ
enum {
    kAKTitleBackground = 0,     ///< 背景レイヤー
    kAKTitleInterface           ///< インターフェースレイヤー
};

// [TODO]タイトル画像のファイル名
//static NSString *kAKTitleImage = @"Title.png";

/// ゲーム開始メニューのキャプション
static NSString *kAKGameStartCaption  = @"GAME START ";
/// 遊び方画面メニューのキャプション
static NSString *kAKHowToPlayCaption  = @"HOW TO PLAY";
/// オプション画面メニューのキャプション
static NSString *kAKOptionCaption     = @"OPTION     ";
/// クレジット画面メニューのキャプション
static NSString *kAKCreditCaption     = @"CREDIT     ";

/// タイトルの位置、横方向の中心からの位置
static const float kAKTitlePosFromHorizontalCenterPoint = -100.0f;
/// タイトルの位置、上からの比率
static const float kAKTitlePosFromTopRatio = 0.45f;
/// メニュー項目の数
static const NSInteger kAKMenuItemCount = 3;
/// メニュー項目の位置、右からの位置
static const float kAKMenuPosRightPoint = 120.0f;
/// ゲーム開始メニューのキャプションの表示位置、上からの比率
static const float kAKGameStartMenuPosTopRatio = 0.25f;
/// 遊び方画面メニューのキャプションの表示位置、上からの比率
static const float kAKHowToPlayMenuPosTopRatio = 0.45f;
/// オプション画面メニューのキャプションの表示位置、上からの位置
static const float kAKOptionMenuPosTopRatio = 0.65f;
/// クレジット画面メニューのキャプションの表示位置、上からの比率
static const float kAKCreditMenuPosTopRatio = 0.85f;

/// 各ノードのz座標
enum {
    kAKTitleBackPosZ = 0,   ///< 背景のz座標
    kAKTitleLogoPosZ,       ///< タイトルロゴのz座標
    kAKTitleMenuPosZ        ///< メニュー項目のz座標
};

/*!
 @brief タイトルシーンクラス
 
 タイトルシーンを管理する。
 */
@implementation AKTitleScene

/*!
 @brief オブジェクト生成処理
 
 オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    AKLog(kAKLogTitleScene_1, @"start");
    
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 背景レイヤーを配置する
    [self addChild:AKCreateBackColorLayer() z:kAKTitleBackground tag:kAKTitleBackground];
    
    // インターフェースを作成する
    AKInterface *interface = [AKInterface interfaceWithCapacity:kAKMenuItemCount + 1];
    
    // インターフェースをシーンに配置する
    [self addChild:interface z:kAKTitleInterface tag:kAKTitleInterface];
        
    // [TODO]タイトル画像を読み込む
//    CCSprite *image = [CCSprite spriteWithFile:kAKTitleImage];
//    NSAssert(image != nil, @"can not open title image : %@", kAKTitleImage);
    
    // [TODO]配置位置を設定する
//    image.position = ccp([AKScreenSize positionFromHorizontalCenterPoint:kAKTitlePosFromHorizontalCenterPoint],
//                         [AKScreenSize positionFromTopRatio:kAKTitlePosFromTopRatio]);
    
    // [TODO]タイトル画像をシーンに配置する
//    [self addChild:image z:kAKTitleLogoPosZ];
    
    // ゲームスタートのメニューを作成する
    [interface addMenuWithString:kAKGameStartCaption
                           atPos:ccp([AKScreenSize positionFromRightPoint:kAKMenuPosRightPoint],
                                     [AKScreenSize positionFromTopRatio:kAKGameStartMenuPosTopRatio])
                          action:@selector(touchGameStartButton)
                               z:0
                             tag:kAKTitleMenuGame
                       withFrame:YES];
    
    // 遊び方のメニューを作成する
    [interface addMenuWithString:kAKHowToPlayCaption
                           atPos:ccp([AKScreenSize positionFromRightPoint:kAKMenuPosRightPoint],
                                     [AKScreenSize positionFromTopRatio:kAKHowToPlayMenuPosTopRatio])
                          action:@selector(touchHowToButton)
                               z:0
                             tag:kAKTitleMenuHowTo
                       withFrame:YES];
    
    // オプションのメニューを作成する
    [interface addMenuWithString:kAKOptionCaption
                           atPos:ccp([AKScreenSize positionFromRightPoint:kAKMenuPosRightPoint],
                                     [AKScreenSize positionFromTopRatio:kAKOptionMenuPosTopRatio])
                          action:@selector(touchOptionButton)
                               z:0
                             tag:kAKTitleMenuOption
                       withFrame:YES];
    
    // クレジットのメニューを作成する
    [interface addMenuWithString:kAKCreditCaption
                           atPos:ccp([AKScreenSize positionFromRightPoint:kAKMenuPosRightPoint],
                                     [AKScreenSize positionFromTopRatio:kAKCreditMenuPosTopRatio])
                          action:@selector(touchCreditButton)
                               z:0
                             tag:kAKTitleMenuCredit
                       withFrame:YES];
    
    // すべてのメニュー項目を有効とする
    interface.enableTag = 0xFFFFFFFFUL;
    
    AKLog(kAKLogTitleScene_1, @"end");
    return self;
}

/*!
 @brief インターフェースレイヤーの取得
 
 インターフェースレイヤーを取得する。
 @return インターフェースレイヤー
 */
- (AKInterface *)interface
{
    return (AKInterface *)[self getChildByTag:kAKTitleInterface];
}

/*!
 @brief ゲーム開始ボタンタッチ
 
 ゲームを開始する。プレイシーンへと遷移する。
 */
- (void)touchGameStartButton
{
    AKLog(kAKLogTitleScene_1, @"start");
    
    // ボタン選択エフェクトを発生させる
    [self selectButton:kAKTitleMenuGame];
    
    // ゲームシーンへの遷移を作成する
    CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:0.5f scene:[AKPlayingScene node]];
    
    // ゲームシーンへ遷移する
    [[CCDirector sharedDirector] replaceScene:transition];
}

/*!
 @brief 遊び方ボタンタッチ
 
 遊び方画面へ遷移する。
 */
- (void)touchHowToButton
{
    AKLog(kAKLogTitleScene_1, @"start");
    
    // ボタン選択エフェクトを発生させる
    [self selectButton:kAKTitleMenuHowTo];
    
    // 遊び方シーンへの遷移を作成する
    CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:0.5f scene:[AKHowToPlayScene node]];
    
    // 遊び方シーンへ遷移する
    [[CCDirector sharedDirector] replaceScene:transition];
}

/*!
 @brief オプションボタンタッチ
 
 オプション画面へ遷移する。
 */
- (void)touchOptionButton
{
    AKLog(kAKLogTitleScene_1, @"start");

    // ボタン選択エフェクトを発生させる
    [self selectButton:kAKTitleMenuOption];
    
    // [オプションシーンへの遷移を作成する
    CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:0.5f scene:[AKOptionScene node]];
    
    // オプションシーンへ遷移する
    [[CCDirector sharedDirector] replaceScene:transition];
}

/*!
 @brief クレジット画面の開始
 
 クレジット画面を開始する。クレジットシーンへと遷移する。
 */
- (void)touchCreditButton
{
    AKLog(kAKLogTitleScene_1, @"start");

    // ボタン選択エフェクトを発生させる
    [self selectButton:kAKTitleMenuCredit];
    
    // [TODO]クレジット画面シーンへの遷移を作成する
//    CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:0.5f scene:[AKCreditScene node]];
    
    // [TODO]クレジット画面シーンへ遷移する
//    [[CCDirector sharedDirector] replaceScene:transition];
}

/*!
 @brief ボタン選択エフェクト
 
 ボタン選択時のエフェクトを表示する。
 効果音を鳴らし、ボタンをブリンクする。
 @param tag ボタンのタグ
 */
- (void)selectButton:(NSInteger)tag
{
    // [TODO]メニュー選択時の効果音を鳴らす
//    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    // ボタンのブリンクアクションを作成する
    CCBlink *action = [CCBlink actionWithDuration:0.2f blinks:2];
    
    // ボタンを取得する
    CCNode *button = [self.interface getChildByTag:tag];
    
    // ブリンクアクションを開始する
    [button runAction:action];
}

@end
