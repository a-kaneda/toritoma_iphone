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
 @file AKPlayingSceneIF.m
 @brief プレイシーンインターフェースの定義
 
 プレイシーンのインターフェースクラスを定義する。
 */

#import "AKPlayingSceneIF.h"

/// プレイ中メニュー項目のタグ
const NSUInteger kAKMenuTagPlaying = 0x01;
/// ポーズ中メニュー項目のタグ
const NSUInteger kAKMenuTagPause = 0x02;
/// 終了メニュー項目のタグ
const NSUInteger kAKMenuTagQuit = 0x04;
/// ゲームオーバー時メニュー項目のタグ
const NSUInteger kAKMenuTagGameOver = 0x08;

//======================================================================
// プレイ中のメニュー項目
//======================================================================
/// シールドボタン配置位置、右からの座標
static const float kAKShieldButtonPosFromRightPoint = 50.0f;
/// シールドボタン配置位置、下からの座標
static const float kAKShieldButtonPosFromBottomPoint = 50.0f;
/// シールドボタン非選択時の画像名
static NSString *kAKShiledButtonNoSelectImage = @"ShieldButton_01.png";
/// シールドボタン選択時の画像名
static NSString *kAKShiledButtonSelectedImage = @"ShieldButton_02.png";
/// ポーズボタンの配置位置、右からの位置
static const float kAKPauseButtonPosRightPoint = 26.0f;
/// ポーズボタンの配置位置、上からの位置
static const float kAKPauseButtonPosTopPoint = 26.0f;
/// ポーズボタンの画像ファイル名
static NSString *kAKPauseButtonImage = @"PauseButton.png";

//======================================================================
// ポーズ時のメニュー項目
//======================================================================
/// 一時停止中の表示文字列
NSString *kAKPauseString = @"  PAUSE  ";
/// 一時停止解除のボタンの文字列
NSString *kAKResumeString = @"RESUME";
/// 終了ボタンの文字列
NSString *kAKQuitButtonString = @" QUIT ";
/// 一時停止メッセージの表示位置、下からの比率
const float kAKPauseMessagePosBottomRatio = 0.6f;
/// 一時停止メニュー項目の表示位置、下からの比率
const float kAKPauseMenuPosBottomRatio = 0.4f;
/// レジュームボタンの表示位置、左からの比率
const float kAKResumeButtonPosLeftRatio = 0.3f;
/// 終了ボタンの表示位置、右からの比率
const float kAKQuitButtonPosRightRatio = 0.3f;

//======================================================================
// 終了メニューのメニュー項目
//======================================================================
/// 終了確認メッセージ
static NSString *kAKQuitMessageString = @"QUIT GAME?";
/// YESボタンの文字列
static NSString *kAKQuitYesString = @" YES ";
/// NOボタンの文字列
static NSString *kAKQuitNoString = @" N O ";
/// 終了メニューキャプションの表示位置、下からの比率
static const float kAKQuitMessagePosBottomRatio = 0.6f;
/// 終了メニューボタンの表示位置、下からの比率
static const float kAKQuitButtonPosBottomRatio = 0.4f;
/// 終了メニューYESボタンの表示位置、左からの比率
static const float kAKQuitYesButtonPosLeftRatio = 0.3f;
/// 終了メニューNOボタンの表示位置、右からの比率
static const float kAKQuitNoButtonPosRightRatio = 0.3f;

//======================================================================
// ゲームオーバー時のメニュー項目
//======================================================================
/// ゲームオーバー時の表示文字列
static NSString *kAKGameOverString = @"GAME OVER";
/// タイトルへ戻るボタンのキャプション
static NSString *kAKGameOverQuitButtonCaption = @"QUIT";
/// Twitterボタンの画像ファイル名
static NSString *kAKTwitterButtonImageFile = @"TwitterButton.png";
/// ゲームオーバーキャプションの表示位置、下からの比率
static const float kAKGameOverCaptionPosBottomRatio = 0.6f;
/// タイトルへ戻るボタンの位置、下からの比率
static const float kAKGameOverQuitButtonPosBottomRatio = 0.4f;
/// Twitterボタンの配置位置、中心からの横方向の位置
static const float kAKTwitterButtonPosHorizontalCenterPoint = 120.0f;
/// Twitterボタンの配置位置、下からの位置
static const float kAKTwitterButtonPosBottomRatio = 0.6f;

/*!
 @brief プレイシーンインターフェース
 
 プレイシーンのインターフェースを管理する。
 */
@implementation AKPlayingSceneIF

@synthesize shieldButton = shieldButton_;
@synthesize resumeButton = resumeButton_;
@synthesize quitButton = quitButton_;
@synthesize quitNoButton = quitNoButton_;

/*!
 @brief オブジェクト初期化処理
 
 オブジェクトの初期化を行う。
 @return 初期化したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの処理を行う
    self = [super init];
    if (!self) {
        AKLog(kAKLogPlayingSceneIF_0, @"error");
        return nil;
    }
    
    // プレイ中のメニュー項目を作成する
    [self createPlayingMenu];
    
    // ポーズ時のメニュー項目を作成する
    [self createPauseMenu];
    
    // 終了メニューを作成する
    [self createQuitMenu];
    
    // ゲームオーバー時のメニュー項目を作成する
    [self createGameOverMenu];
    
    return self;
}

/*!
 @brief オブジェクト解放処理
 
 メンバの解放を行う。
 */
- (void)dealloc
{
    AKLog(kAKLogPlayingSceneIF_1, @"start");
    
    // メンバを解放する
    [self.shieldButton removeFromParentAndCleanup:YES];
    self.shieldButton = nil;
    self.resumeButton = nil;
    self.quitButton = nil;
    self.quitNoButton = nil;
    
    // スーパークラスの処理を行う
    [super dealloc];
    
    AKLog(kAKLogPlayingSceneIF_1, @"end");
}

/*!
 @brief プレイ中のメニュー項目作成
 
 プレイ中のメニュー項目を作成する。
 */
- (void)createPlayingMenu
{
    // シールドボタンを作成する
    self.shieldButton = [self addMenuWithSpriteFrame:kAKShiledButtonNoSelectImage
                                               atPos:ccp([AKScreenSize positionFromRightPoint:kAKShieldButtonPosFromRightPoint],
                                                         [AKScreenSize positionFromBottomPoint:kAKShieldButtonPosFromBottomPoint])
                                              action:@selector(touchShieldButton:)
                                                   z:0
                                                 tag:kAKMenuTagPlaying
                                                type:kAKMenuTypeMomentary];
    
    // ポーズボタンを追加する
    [self addMenuWithSpriteFrame:kAKPauseButtonImage
                           atPos:ccp([AKScreenSize positionFromRightPoint:kAKPauseButtonPosRightPoint],
                                     [AKScreenSize positionFromTopPoint:kAKPauseButtonPosTopPoint])
                          action:@selector(touchPauseButton:)
                               z:0
                             tag:kAKMenuTagPlaying
                            type:kAKMenuTypeButton];
    
    // スライド入力を画面全体に配置する
    [self addSlideMenuWithRect:CGRectMake(0.0f, 0.0f, [AKScreenSize screenSize].width, [AKScreenSize screenSize].height)
                        action:@selector(movePlayer:)
                           tag:kAKMenuTagPlaying];
}

/*!
 @brief ポーズ時のメニュー項目作成
 
 ポーズ時のメニュー項目を作成する。
 */
- (void)createPauseMenu
{
    // ゲームオーバーラベルを生成する
    AKLabel *label = [AKLabel labelWithString:kAKPauseString maxLength:kAKPauseString.length maxLine:1 frame:kAKLabelFrameMessage];
    
    // ゲームオーバーラベルの位置を設定する
    label.position = ccp([AKScreenSize center].x, [AKScreenSize positionFromBottomRatio:kAKPauseMessagePosBottomRatio]);
    
    // ゲームオーバーラベルをレイヤーに配置する
    [self addChild:label z:0 tag:kAKMenuTagPause];
    
    // ポーズ解除ボタンを作成する
    self.resumeButton = [self addMenuWithString:kAKResumeString
                                          atPos:ccp([AKScreenSize positionFromLeftRatio:kAKResumeButtonPosLeftRatio],
                                                    [AKScreenSize positionFromBottomRatio:kAKPauseMenuPosBottomRatio])
                                         action:@selector(touchResumeButton:)
                                              z:0
                                            tag:kAKMenuTagPause
                                      withFrame:YES];
    
    
    // 終了ボタンを作成する
    self.quitButton = [self addMenuWithString:kAKQuitButtonString
                                        atPos:ccp([AKScreenSize positionFromRightRatio:kAKQuitButtonPosRightRatio],
                                                  [AKScreenSize positionFromBottomRatio:kAKPauseMenuPosBottomRatio])
                                       action:@selector(touchQuitButton:)
                                            z:0
                                          tag:kAKMenuTagPause
                                    withFrame:YES];
}

/*!
 @brief 終了メニュー項目作成
 
 終了メニューを作成する。
 */
- (void)createQuitMenu
{
    // 終了確認メッセージラベルを生成する
    AKLabel *label = [AKLabel labelWithString:kAKQuitMessageString maxLength:kAKQuitMessageString.length maxLine:1 frame:kAKLabelFrameMessage];
    
    // 終了確認メッセージラベルの位置を設定する
    label.position = ccp([AKScreenSize center].x, [AKScreenSize positionFromBottomRatio:kAKQuitMessagePosBottomRatio]);
    
    // 終了確認メッセージラベルをレイヤーに配置する
    [self addChild:label z:0 tag:kAKMenuTagQuit];
    
    // YESボタンを作成する
    [self addMenuWithString:kAKQuitYesString
                      atPos:ccp([AKScreenSize positionFromLeftRatio:kAKQuitYesButtonPosLeftRatio],
                                [AKScreenSize positionFromBottomRatio:kAKQuitButtonPosBottomRatio])
                     action:@selector(touchQuitYesButton:)
                          z:0
                        tag:kAKMenuTagQuit
                  withFrame:YES];
    
    
    // NOボタンを作成する
    self.quitNoButton = [self addMenuWithString:kAKQuitNoString
                                          atPos:ccp([AKScreenSize positionFromRightRatio:kAKQuitNoButtonPosRightRatio],
                                                    [AKScreenSize positionFromBottomRatio:kAKQuitButtonPosBottomRatio])
                                         action:@selector(touchQuitNoButton:)
                                              z:0
                                            tag:kAKMenuTagQuit
                                      withFrame:YES];
}

/*!
 @brief ゲームオーバー時のメニュー項目作成
 
 ゲームオーバー時のメニュー項目を作成する。
 */
- (void)createGameOverMenu
{
    // ゲームオーバーラベルを生成する
    AKLabel *label = [AKLabel labelWithString:kAKGameOverString
                                    maxLength:kAKGameOverString.length
                                      maxLine:1
                                        frame:kAKLabelFrameMessage];
    
    // ゲームオーバーラベルの位置を設定する
    label.position = ccp([AKScreenSize center].x,
                         [AKScreenSize positionFromBottomRatio:kAKGameOverCaptionPosBottomRatio]);
    
    // ゲームオーバーラベルをレイヤーに配置する
    [self addChild:label z:0 tag:kAKMenuTagGameOver];
    
    // タイトルへ戻るボタンを作成する
    [self addMenuWithString:kAKGameOverQuitButtonCaption
                                     atPos:ccp([AKScreenSize center].x,
                                               [AKScreenSize positionFromBottomRatio:kAKGameOverQuitButtonPosBottomRatio])
                                    action:@selector(touchQuitButton:)
                                         z:0
                                       tag:kAKMenuTagGameOver
                                 withFrame:YES];
    
    // Twitterボタンを作成する
    [self addMenuWithSpriteFrame:kAKTwitterButtonImageFile
                           atPos:ccp([AKScreenSize positionFromHorizontalCenterPoint:kAKTwitterButtonPosHorizontalCenterPoint],
                                     [AKScreenSize positionFromBottomRatio:kAKTwitterButtonPosBottomRatio])
                          action:@selector(touchTweetButton:)
                               z:0
                             tag:kAKMenuTagGameOver
                            type:kAKMenuTypeButton];
}

/*!
 @brief シールドボタン表示切替
 
 シールドボタンの表示を選択・非選択状態で切り替えを行う。
 @param seleted 選択状態かどうか
 */
- (void)setShieldButtonSelected:(BOOL)selected
{
    // 選択中かどうかで画像を切り替える
    if (selected) {
        [self.shieldButton setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kAKShiledButtonSelectedImage]];
    }
    else {
        [self.shieldButton setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kAKShiledButtonNoSelectImage]];
    }
}

/*!
 @brief メニュー項目個別表示設定
 
 メニュー項目の表示非表示を有効タグとは別に設定したい場合に個別に設定を行う。
 プレイ中の項目は常に表示する。
 @param item 設定するメニュー項目
 */
- (void)updateVisibleItem:(CCNode *)item
{
    // プレイ中の項目は常に表示する
    if (item.tag == kAKMenuTagPlaying) {
        item.visible = YES;
    }
}
@end
