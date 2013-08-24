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
 @file AKTileMap.h
 @brief タイルマップ管理クラス
 
 ステージ構成定義のタイルマップファイルを読み込む。
 */

#import "AKToritoma.h"
#import "AKPlayDataInterface.h"
#import "AKTileMapEventParameter.h"

@class AKTileMap;

// タイルマップ管理クラス
@interface AKTileMap : NSObject {
    /// タイルマップ
    CCTMXTiledMap *tileMap_;
    /// 背景レイヤー
    CCTMXLayer *background_;
    /// 前景レイヤー
    CCTMXLayer *foreground_;
    /// 障害物レイヤー
    CCTMXLayer *block_;
    /// イベントレイヤー
    CCTMXLayer *event_;
    /// 敵レイヤー
    CCTMXLayer *enemy_;
    /// 実行した列番号
    NSInteger currentCol_;
    /// ステージ進行度
    NSInteger progress_;
    /// 進行待ちのイベント
    NSMutableArray *waitEvents_;
}

/// タイルマップ
@property (nonatomic, retain)CCTMXTiledMap *tileMap;
/// 背景レイヤー
@property (nonatomic, retain)CCTMXLayer *background;
/// 前景レイヤー
@property (nonatomic, retain)CCTMXLayer *foreground;
/// 障害物レイヤー
@property (nonatomic, retain)CCTMXLayer *block;
/// イベントレイヤー
@property (nonatomic, retain)CCTMXLayer *event;
/// 敵レイヤー
@property (nonatomic, retain)CCTMXLayer *enemy;
/// ステージ進行状況
@property (nonatomic)NSInteger progress;
/// 進行待ちのイベント
@property (nonatomic, retain)NSMutableArray *waitEvents;

// 初期化処理
- (id)initWithStageNo:(NSInteger)stage layer:(CCNode *)layer;
// コンビニエンスコンストラクタ
+ (id)scriptWithStageNo:(NSInteger)stage layer:(CCNode *)layer;
// 更新処理
- (void)update:(id<AKPlayDataInterface>)data;
// 列単位のイベント実行
- (void)execEventByCol:(NSInteger)col data:(id<AKPlayDataInterface>)data;
// レイヤーごとのイベント実行
- (void)execEventLayer:(CCTMXLayer *)layer col:(NSInteger)col x:(float)x data:(id<AKPlayDataInterface>)data execFunc:(SEL)execFunc;
// デバイス座標からマップ座標の取得
- (CGPoint)mapPositionFromDevicePosition:(CGPoint)devicePosition;
// タイルの座標取得
- (CGPoint)tilePositionFromMapPosition:(CGPoint)mapPosition;
// 障害物作成
- (void)createBlock:(AKTileMapEventParameter*)param;
// 敵作成
- (void)createEnemy:(AKTileMapEventParameter*)param;
// イベント実行
- (void)execEvent:(AKTileMapEventParameter*)param;

@end
