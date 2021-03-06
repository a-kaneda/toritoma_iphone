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
 @file AKPlayingSceneIF.h
 @brief プレイシーンインターフェースの定義
 
 プレイシーンのインターフェースクラスを定義する。
 */

#import "AKToritoma.h"

/// プレイ中メニュー項目のタグ
extern const NSUInteger kAKMenuTagPlaying;
/// ポーズ中メニュー項目のタグ
extern const NSUInteger kAKMenuTagPause;
/// 終了メニュー項目のタグ
extern const NSUInteger kAKMenuTagQuit;
/// ゲームオーバー時メニュー項目のタグ
extern const NSUInteger kAKMenuTagGameOver;

// プレイシーンインターフェース
@interface AKPlayingSceneIF : AKInterface {
    /// シールドボタン
    CCSprite *shieldButton_;
    /// ポーズ解除ボタン
    AKLabel *resumeButton_;
    /// 終了ボタン
    AKLabel *quitButton_;
    /// 終了メニューNoボタン
    AKLabel *quitNoButton_;
}

/// シールドボタン
@property (nonatomic, retain)CCSprite *shieldButton;
/// ポーズ解除ボタン
@property (nonatomic, retain)AKLabel *resumeButton;
/// 終了ボタン
@property (nonatomic, retain)AKLabel *quitButton;
/// 終了メニューNoボタン
@property (nonatomic, retain)AKLabel *quitNoButton;

// プレイ中のメニュー項目作成
- (void)createPlayingMenu;
// ポーズ時のメニュー項目作成
- (void)createPauseMenu;
// 終了メニュー項目作成
- (void)createQuitMenu;
// ゲームオーバー時のメニュー項目作成
- (void)createGameOverMenu;
// シールドボタン表示切替
- (void)setShieldButtonSelected:(BOOL)selected;

@end
