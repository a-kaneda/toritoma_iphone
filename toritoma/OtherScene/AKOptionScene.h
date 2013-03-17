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
 @file AKOptionScene.h
 @brief オプション画面シーンクラスの定義
 
 オプション画面シーンクラスを定義する。
 */

#import "AKToritoma.h"

// オプション画面シーン
@interface AKOptionScene : CCScene {
    /// Leaderboardボタン
    AKLabel *leaderboardButton_;
    /// Achievementsボタン
    AKLabel *achievementsButton_;
    /// 購入ボタン
    AKLabel *buyButton_;
    /// リストアボタン
    AKLabel *restoreButton_;
    /// ページ番号
    NSInteger pageNo_;
    /// 最大ページ番号
    NSInteger maxPage_;
    /// 通信中かどうか
    BOOL isConnecting_;
    /// 通信中ビュー
    UIView *connectingView_;
}

/// Leaderboardボタン
@property (nonatomic, retain)AKLabel *leaderboardButton;
/// Achievementsボタン
@property (nonatomic, retain)AKLabel *achievementsButton;
/// 購入ボタン
@property (nonatomic, retain)AKLabel *buyButton;
/// リストアボタン
@property (nonatomic, retain)AKLabel *restoreButton;
/// 通信中ビュー
@property (nonatomic, retain)UIView *connectingView;

// ページ共通の項目作成
- (void)initCommonItem:(AKInterface *)interface;
// Game Centerページの項目作成
- (void)initGameCenterPage:(AKInterface *)interface;
// Storeページの項目作成
- (void)initStorePage:(AKInterface *)interface;
// ページ番号取得
- (NSInteger)pageNo;
// ページ番号設定
- (void)setPageNo:(NSInteger)pageNo;
// Leaderboardボタン選択時の処理
- (void)selectLeaerboard;
// Achievementsボタン選択時の処理
- (void)selectAchievements;
// 前ページ表示
- (void)selectPrevPage;
// 次ページ表示
- (void)selectNextPage;
// 戻るボタン選択時の処理
- (void)selectBack;
// Leaderboard表示
- (void)showLeaderboard;
// Achievements表示
- (void)showAchievements;
// 購入ボタン選択時の処理
- (void)selectBuy;
// リストアボタン選択時の処理
- (void)selectRestore;
// 通信開始
- (void)startConnect;
// 通信終了
- (void)endConnect;
// インターフェース有効タグ取得
- (NSUInteger)interfaceTag:(NSInteger)page;

@end
