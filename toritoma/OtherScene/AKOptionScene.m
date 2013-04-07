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
 @file AKOptionScene.m
 @brief オプション画面シーンクラスの定義
 
 オプション画面シーンクラスを定義する。
 */

#import "AKOptionScene.h"
#import "AKTitleScene.h"
//#import "AKInAppPurchaseHelper.h"

// オプション画面シーンに配置するノードのタグ
enum {
    kAKOptionSceneBackColor = 0,    ///< 背景色のタグ
    kAKOptionSceneInterface         ///< インターフェースレイヤーのタグ
};

/// Game Cetnerのページ
static const NSInteger kAKPageGameCenter = 1;
/// Storeのページ
static const NSInteger kAKPageStore = 2;
/// 全ページに表示する項目のタグ
static const NSUInteger kAKMenuAll = 0x00;
/// Game Centerページの項目のタグ
static const NSUInteger kAKMenuGameCenter = 0x01;
/// Storeページ(共通)の項目のタグ
static const NSUInteger kAKMenuStore = 0x02;
/// Storeページ(購入前)の項目のタグ
static const NSUInteger kAKMenuStoreBeforePurchase = 0x04;
/// Storeページ(購入後)の項目のタグ
static const NSUInteger kAKMenuStoreAfterPurcase = 0x08;
/// Option画面ページ数
static const NSInteger kAKMenuPageCount = 2;

/// 前ページボタンの画像ファイル名
static NSString *kAKPrevImage = @"PrevButton.png";
/// 次ページボタンの画像ファイル名
static NSString *kAKNextImage = @"NextButton.png";
/// 戻るボタンの画像ファイル名
static NSString *kAKBackImage = @"BackButton.png";
/// 前ページボタンの位置、左からの位置
static const float kAKPrevPosLeftPoint = 40.0f;
/// 次ページボタンの位置、右からの位置
static const float kAKNextPosRightPoint = 40.0f;
/// 戻るボタンの位置、右からの位置
static const float kAKBackPosRightPoint = 26.0f;
/// 戻るボタンの位置、上からの位置
static const float kAKBackPosTopPoint = 26.0f;

/// Game Centerのキャプション
static NSString *kAKGameCenterCaption = @"GAME CENTER";
/// Leaderboardボタンのキャプション
static NSString *kAKLeaderboardCaption = @"LEADERBOARD";
/// Achievementsボタンのキャプション
static NSString *kAKAchievementsCaption = @"ACHIEVEMENTS";
/// Game Centerのキャプション位置、上からの比率
static const float kAKGameCenterCaptionPosTopRatio = 0.1f;
/// Leaderboardボタンの位置、上からの比率
static const float kAKLeaderboardPosTopRatio = 0.3f;
//: Achievementsボタンの位置、上からの比率
static const float kAKAchievemetnsPosTopRatio = 0.5f;

/// Storeのキャプション
static NSString *kAKStoreCaption = @"STORE";
/// 購入ボタンのキャプション
static NSString *kAKBuyButtonCaption = @"  BUY  ";
/// リストアボタンのキャプション
static NSString *kAKRestoreButtonCaption = @"RESTORE";
/// Storeメッセージのキー
static NSString *kAKStoreMessageKey = @"StoreMessage";
/// 購入済みのキャプションのキー
static NSString *kAKStorePurchasedKey = @"StorePurchased";
/// Storeのキャプション位置、上からの比率
static const float kAKStoreCaptionPosTopRatio = 0.1f;
/// ボタンの位置、上からの比率
static const float kAKButtonPosTopRatio = 0.3f;
/// 購入ボタンの位置、左からの比率
static const float kAKBuyButtonPosLeftRatio = 0.3f;
/// リストアボタンの位置、左からの比率
static const float kAKRestoreButtonPosLeftRatio = 0.7f;
/// メッセージボックスの1行の文字数
static const NSInteger kAKMsgLength = 20;
/// メッセージボックスの行数
static const NSInteger kAKMsgLineCount = 3;
/// メッセージボックスの位置、下からの位置
static const float kAKMsgPosBottomPoint = 120.0f;
/// 購入済みのキャプションの位置、上からの比率
static const float kAKPurchasedCaptionPosTopRatio = 0.3f;

/*!
 @brief オプション画面シーン
 
 オプション画面のシーン。
 */
@implementation AKOptionScene

@synthesize leaderboardButton = leaderboardButton_;
@synthesize achievementsButton = achievementsButton_;
@synthesize buyButton = buyButton_;
@synthesize restoreButton = restoreButton_;
@synthesize connectingView = connectingView_;

/*!
 @brief インスタンス初期化処理
 
 インスタンスの初期化を行う。
 @return 初期化したインスタンス。失敗時はnilを返す。
 */
- (id)init
{
    // メニュー項目の数
    // 共通:戻る、次ページ、前ページ
    // GameCenter:Leaderboard、Achievements
    // Store:Buy、Restore、Easy、Hard
    const NSInteger kAKMenuItemCount = 9;
    
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // テクスチャアトラスを読み込む
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kAKControlTextureAtlasDefFile textureFilename:kAKControlTextureAtlasFile];

    // 背景色レイヤーを作成する
    CCLayerColor *backColor = AKCreateBackColorLayer();
    
    // シーンへ配置する
    [self addChild:backColor z:kAKOptionSceneBackColor tag:kAKOptionSceneBackColor];
    
    // インターフェースを作成する
    AKInterface *interface = [AKInterface interfaceWithCapacity:kAKMenuItemCount];
    
    // シーンへ配置する
    [self addChild:interface z:kAKOptionSceneInterface tag:kAKOptionSceneInterface];
    
    // 通信中フラグはオフにする
    isConnecting_ = NO;
    
    // TODO:アプリ課金が有効な場合は全ページを表示できるようにする
//    if ([[AKInAppPurchaseHelper sharedHelper] canMakePayments]) {
//        maxPage_ = kAKMenuPageCount;
//    }
    // アプリ課金が禁止されている場合はページをひとつ減らす
//    else {
        maxPage_ = kAKMenuPageCount - 1;
//    }
    
    // 全ページ共通の項目を作成する
    [self initCommonItem:interface];
    
    // Game Centerページの項目を作成する
    [self initGameCenterPage:interface];
    
    // Storeページの項目を作成する
    [self initStorePage:interface];

    // 初期ページを1ページ目とする
    self.pageNo = 1;
    
    return self;
}

/*!
 @brief ページ共通の項目作成
 
 全ページ共通の項目を作成する。
 戻るボタン、次ページボタン、前ページボタンを作成する。
 @param interface インターフェースレイヤー
 */
- (void)initCommonItem:(AKInterface *)interface
{
    // 前ページボタンをインターフェースに配置する
    [interface addMenuWithSpriteFrame:kAKPrevImage
                                atPos:ccp([AKScreenSize positionFromLeftPoint:kAKPrevPosLeftPoint],
                                          [AKScreenSize center].y)
                               action:@selector(selectPrevPage)
                                    z:0
                                  tag:kAKMenuAll
                                 type:kAKMenuTypeButton];
    
    // 次ページボタンをインターフェースに配置する
    [interface addMenuWithSpriteFrame:kAKNextImage
                                atPos:ccp([AKScreenSize positionFromRightPoint:kAKNextPosRightPoint],
                                          [AKScreenSize center].y)
                               action:@selector(selectNextPage)
                                    z:0
                                  tag:kAKMenuAll
                                 type:kAKMenuTypeButton];
    
    // 戻るボタンをインターフェースに配置する
    [interface addMenuWithSpriteFrame:kAKBackImage
                                atPos:ccp([AKScreenSize positionFromRightPoint:kAKBackPosRightPoint],
                                          [AKScreenSize positionFromTopPoint:kAKBackPosTopPoint])
                               action:@selector(selectBack)
                                    z:0
                                  tag:kAKMenuAll
                                 type:kAKMenuTypeButton];
}

/*! 
 @brief Game Centerページの項目作成
 
 Game Centerページの項目を作成する。
 Game Centerのラベル、Leaderboardボタン、Achievementsボタンを作成する。
 @param interface インターフェースレイヤー
 */
- (void)initGameCenterPage:(AKInterface *)interface
{
    // Game Centerのラベルを作成する
    AKLabel *gameCenterLabel = [AKLabel labelWithString:kAKGameCenterCaption
                                              maxLength:kAKGameCenterCaption.length
                                                maxLine:1
                                                  frame:kAKLabelFrameNone];
    
    // Game Centerのラベルの位置を設定する
    gameCenterLabel.position = ccp([AKScreenSize center].x,
                                   [AKScreenSize positionFromTopRatio:kAKGameCenterCaptionPosTopRatio]);
    
    // Game Centerのラベルを配置する
    [interface addChild:gameCenterLabel z:0 tag:kAKMenuGameCenter];
    
    // Leaderboardのメニューを作成する
    self.leaderboardButton = [interface addMenuWithString:kAKLeaderboardCaption
                                                    atPos:ccp([AKScreenSize center].x,
                                                              [AKScreenSize positionFromTopRatio:kAKLeaderboardPosTopRatio])
                                                   action:@selector(selectLeaerboard)
                                                        z:0
                                                      tag:kAKMenuGameCenter
                                                withFrame:YES];
    
    // Achievementsのメニューを作成する
    self.achievementsButton = [interface addMenuWithString:kAKAchievementsCaption
                                                     atPos:ccp([AKScreenSize center].x,
                                                               [AKScreenSize positionFromTopRatio:kAKAchievemetnsPosTopRatio])
                                                    action:@selector(selectAchievements)
                                                         z:0
                                                       tag:kAKMenuGameCenter
                                                 withFrame:YES];
}

/*!
 @brief Storeページの項目作成
 
 Storeページの項目を作成する。
 Storeラベル、説明ラベル、購入ボタンを作成する。
 @param interface インターフェースレイヤー
 */
- (void)initStorePage:(AKInterface *)interface
{
    // Storeのラベルを作成する
    AKLabel *storeLabel = [AKLabel labelWithString:kAKStoreCaption
                                         maxLength:kAKStoreCaption.length
                                           maxLine:1
                                             frame:kAKLabelFrameNone];
    
    // Storeのラベルの位置を設定する
    storeLabel.position = ccp([AKScreenSize center].x,
                              [AKScreenSize positionFromTopRatio:kAKStoreCaptionPosTopRatio]);
    
    // Storeのラベルを配置する
    [interface addChild:storeLabel z:0 tag:kAKMenuStore];
    
    // 購入ボタンを作成する
    self.buyButton = [interface addMenuWithString:kAKBuyButtonCaption
                                            atPos:ccp([AKScreenSize positionFromLeftRatio:kAKBuyButtonPosLeftRatio],
                                                      [AKScreenSize positionFromTopRatio:kAKButtonPosTopRatio])
                                           action:@selector(selectBuy)
                                                z:0
                                              tag:kAKMenuStoreBeforePurchase
                                        withFrame:YES];

    // リストアボタンを作成する
    self.restoreButton = [interface addMenuWithString:kAKRestoreButtonCaption
                                                atPos:ccp([AKScreenSize positionFromLeftRatio:kAKRestoreButtonPosLeftRatio],
                                                          [AKScreenSize positionFromTopRatio:kAKButtonPosTopRatio])
                                               action:@selector(selectRestore)
                                                    z:0
                                                  tag:kAKMenuStoreBeforePurchase
                                            withFrame:YES];

    // メッセージボックスを作成する
    AKLabel *message = [AKLabel labelWithString:@"" maxLength:kAKMsgLength maxLine:kAKMsgLineCount frame:kAKLabelFrameMessage];
    
    // 配置位置を設定する
    message.position = ccp([AKScreenSize center].x,
                           [AKScreenSize positionFromBottomPoint:kAKMsgPosBottomPoint]);
    
    // 表示文字列を設定する
    message.string = NSLocalizedString(kAKStoreMessageKey, @"Storeページの説明文");
    
    // レイヤーに配置する
    [interface addChild:message z:0 tag:kAKMenuStore];
    
    // 購入済みの文字列を取得する
    NSString *purchasedMessage = NSLocalizedString(kAKStorePurchasedKey, @"購入済みのキャプション");
    
    // 購入済みのラベルを作成する
    AKLabel *purchasedLabel = [AKLabel labelWithString:purchasedMessage
                                             maxLength:purchasedMessage.length
                                               maxLine:1
                                                 frame:kAKLabelFrameNone];
    
    // 購入済みのラベルの位置を設定する
    purchasedLabel.position = ccp([AKScreenSize center].x,
                                  [AKScreenSize positionFromTopRatio:kAKPurchasedCaptionPosTopRatio]);
    
    // レイヤーに配置する
    [interface addChild:purchasedLabel z:0 tag:kAKMenuStoreAfterPurcase];
}

/*!
 @brief ページ番号取得
 
 表示中のページ番号を取得する。
 @return ページ番号
 */
- (NSInteger)pageNo
{
    return pageNo_;
}

/*!
 @brief ページ番号設定
 
 表示ページを変更する。
 範囲外の場合はページをループする。
 インターフェースの有効タグをページ番号にあわせて変更する。
 @param pageNo ページ番号
 */
- (void)setPageNo:(NSInteger)pageNo
{
    // 最小値未満の場合は最大ページへループする
    if (pageNo < 1) {
        pageNo_ = maxPage_;
    }
    // 最大値超過の場合は最小ページヘループする
    else if (pageNo > maxPage_) {
        pageNo_ = 1;
    }
    // 範囲内の場合はそのまま設定する
    else {
        pageNo_ = pageNo;
    }
    
    // インターフェースを取得する
    AKInterface *interface = (AKInterface *)[self getChildByTag:kAKOptionSceneInterface];
    
    // ページ番号によってインターフェースのタグを変更する
    interface.enableTag = [self interfaceTag:pageNo_];
}

/*!
 @brief インスタンス解放処理
 
 インスタンス解放時の処理を行う。
 メンバを解放する。
 */
- (void)dealloc
{
    // メンバを解放する
    self.leaderboardButton = nil;
    self.achievementsButton = nil;
    self.buyButton = nil;
    self.restoreButton = nil;
    self.connectingView = nil;
    
    // 親クラスの処理を実行する
    [super dealloc];
}

/*!
 @brief Leaderboardボタン選択時の処理
 
 Leaderboardボタン選択時の処理。
 Leaderboardを表示する。
 */
- (void)selectLeaerboard
{
    // TODO:メニュー選択時の効果音を鳴らす
//    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    // ボタンのブリンクアクションを作成する。
    // ブリンクアクション終了後にLeaderboardを表示する。
    // ブリンクアクションの途中でViewを表示させると、消えた状態でアニメーションが止まることがあるため。
    CCBlink *blink = [CCBlink actionWithDuration:0.2f blinks:2];
    CCCallFunc *callFunc = [CCCallFunc actionWithTarget:self selector:@selector(showLeaderboard)];
    CCSequence *action = [CCSequence actions:blink, callFunc, nil];
    
    // ブリンクアクションを開始する
    [self.leaderboardButton runAction:action];
}

/*!
 @brief Achievementsボタン選択時の処理

 Achievementsボタン選択時の処理
 Achievementsを表示する。
 */
- (void)selectAchievements
{
    // TODO:メニュー選択時の効果音を鳴らす
//    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    // ボタンのブリンクアクションを作成する
    // ブリンクアクション終了後にAchievementsを表示する。
    // ブリンクアクションの途中でViewを表示させると、消えた状態でアニメーションが止まることがあるため。
    CCBlink *blink = [CCBlink actionWithDuration:0.2f blinks:2];
    CCCallFunc *callFunc = [CCCallFunc actionWithTarget:self selector:@selector(showAchievements)];
    CCSequence *action = [CCSequence actions:blink, callFunc, nil];
        
    // ブリンクアクションを開始する
    [self.achievementsButton runAction:action];
}

/*!
 @brief 前ページ表示
 
 前ページを表示する。
 ページ番号をデクリメントする。
 */
- (void)selectPrevPage
{
    // 通信中の場合は処理を行わない
    if (isConnecting_) {
        return;
    }
    
    // TODO:メニュー選択時の効果音を鳴らす
//    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    self.pageNo = self.pageNo - 1;
}

/*!
 @brief 次ページ表示
 
 次ページを表示する。
 ページ番号をインクリメントする。
 */
- (void)selectNextPage
{
    // 通信中の場合は処理を行わない
    if (isConnecting_) {
        return;
    }
    
    // TODO:メニュー選択時の効果音を鳴らす
//    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    self.pageNo = self.pageNo + 1;
}

/*!
 @brief 戻るボタン選択時の処理
 
 戻るボタンを選択した時の処理を行う。
 効果音を鳴らし、タイトルシーンへと戻る。
 */
- (void)selectBack
{
    // 通信中の場合は処理を行わない
    if (isConnecting_) {
        return;
    }
    
    // TODO:メニュー選択時の効果音を鳴らす
//    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    // タイトルシーンへの遷移を作成する
    CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:0.5f scene:[AKTitleScene node]];
    
    // タイトルシーンへ遷移する
    [[CCDirector sharedDirector] replaceScene:transition];
}

/*!
 @brief Leaderboard表示
 
 Leaderboardを表示する。
 ボタンのブリンクアクション終了時に呼ばれるので、Leaderboard表示前にボタンのvisibleを表示に変更する。
 */
- (void)showLeaderboard
{
    // ブリンク終了直後はボタン非表示になっているため、表示を元に戻す
    self.leaderboardButton.visible = YES;
    
    // Achievementsを表示する
    [[AKGameCenterHelper sharedHelper] showLeaderboard];
}

/*! 
 @brief Achievements表示

 Achievementsを表示する。
 ボタンのブリンクアクション終了時に呼ばれるので、Achievements表示前にボタンのvisibleを表示に変更する。
 */
- (void)showAchievements
{
    // ブリンク終了直後はボタン非表示になっているため、表示を元に戻す
    self.achievementsButton.visible = YES;
    
    // Achievementsを表示する
    [[AKGameCenterHelper sharedHelper] showAchievements];
}

/*!
 @brief 購入ボタン選択時の処理
 
 購入ボタン選択時の処理を行う。
 ボタン選択時の効果音とエフェクトを発生させる。
 In App Purchaseの購入処理を行う。
 */
- (void)selectBuy
{
    // 通信中の場合は処理を行わない
    if (isConnecting_) {
        return;
    }
    
    // TODO:メニュー選択時の効果音を鳴らす
//    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    // ボタンのブリンクアクションを作成する
    CCBlink *action = [CCBlink actionWithDuration:0.2f blinks:2];
    
    // ブリンクアクションを開始する
    [self.buyButton runAction:action];
    
    // 通信ビューを表示する
    [self startConnect];
    
    // TODO:購入処理を行う
//    [[AKInAppPurchaseHelper sharedHelper] buy];
}

/*!
 @brief リストアボタン選択時の処理
 
 リストアボタン選択時の処理を行う。
 ボタン選択時の効果音とエフェクトを発生させる。
 In App Purchaseのリストア処理を行う。
 */
- (void)selectRestore
{
    // 通信中の場合は処理を行わない
    if (isConnecting_) {
        return;
    }
    
    // TODO:メニュー選択時の効果音を鳴らす
//    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    // ボタンのブリンクアクションを作成する
    CCBlink *action = [CCBlink actionWithDuration:0.2f blinks:2];
    
    // ブリンクアクションを開始する
    [self.restoreButton runAction:action];
    
    // 通信ビューを表示する
    [self startConnect];

    // TODO:リストア処理を行う
//    [[AKInAppPurchaseHelper sharedHelper] restore];
}

/*!
 @brief 通信開始
 
 通信開始時の処理を行う。
 通信中のビューを表示し、画面入力を無視するようにする。
 */
- (void)startConnect
{
    AKLog(kAKLogOptionScene_1, @"start");
    
    // 画面入力を無効化する
    isConnecting_ = YES;
    
    // ルートビューを取得する
    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    
    // 通信中ビューを作成する
    self.connectingView = [[[UIView alloc] initWithFrame:rootView.bounds] autorelease];
    
    // 半透明の黒色とする
    self.connectingView.backgroundColor = [UIColor blackColor];
    self.connectingView.alpha = 0.5f;
    
    // インジケータを作成する
    UIActivityIndicatorView *indicator = [[[UIActivityIndicatorView alloc] init] autorelease];
    
    // 白色の大きいアイコンを表示する
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    
    // 中心位置をルートビューと揃える
    // Landscapeのため、x座標とy座標を入れ替える
    indicator.center = ccp(rootView.center.y, rootView.center.x);
    
    // 通信中ビューにインジケータを配置する
    [self.connectingView addSubview:indicator];
    
    // ルートビューに通信中ビューを配置する
    [rootView addSubview:self.connectingView];
    
    // インジケータのアニメーションを開始する
    [indicator startAnimating];
}

/*!
 @brief 通信終了
 
 通信終了時の処理を行う。
 通信中のビューを削除し、画面入力を有効にする。
 */
- (void)endConnect
{
    AKLog(kAKLogOptionScene_1, @"start");
    
    // 通信中ビューを削除する
    [self.connectingView removeFromSuperview];
    self.connectingView = nil;

    // 画面入力を有効化する
    isConnecting_ = NO;
}

/*!
 @brief インターフェース有効タグ取得
 
 インターフェースの有効タグをページ番号から作成する。
 @param page ページ番号
 @return インターフェース有効タグ
 */
- (NSUInteger)interfaceTag:(NSInteger)page
{
    // ページによってインターフェースの有効タグを判定する
    switch (page) {
        case kAKPageGameCenter:     // Game Centerのページ
            return kAKMenuGameCenter;
            
            
        case kAKPageStore:          // Storeのページ
            
            // TODO:購入済みかどうかで有効化する項目を変える
            /*
            if ([AKInAppPurchaseHelper sharedHelper].isEnableContinue) {
                return kAKMenuStore | kAKMenuStoreAfterPurcase;
            }
            else {
                return kAKMenuStore | kAKMenuStoreBeforePurchase;
            }
             */
            return kAKMenuStore;
            
        default:                    // その他のページは存在しない
            
            AKLog(kAKLogOptionScene_0, @"不正なページ番号:%d", page);
            NSAssert(NO, @"不正なページ番号");
            return kAKMenuGameCenter;
    }
}

@end
