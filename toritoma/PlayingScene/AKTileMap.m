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
 @file AKTileMap.m
 @brief タイルマップ管理クラス
 
 ステージ構成定義のタイルマップファイルを読み込む。
 */

#import "AKTileMap.h"

/// 進行待ち待機イベント初期配列数
static const NSUInteger kAKWaitEventsInitCapacity = 5;

/// タイルマップのファイル名
static NSString *kAKTileMapFileName = @"Stage_%02d.tmx";

/*!
 @brief タイルマップ管理クラス
 
 ステージ構成定義のタイルマップファイルを読み込む。
 */
@implementation AKTileMap

@synthesize tileMap = tileMap_;
@synthesize background = background_;
@synthesize foreground = foreground_;
@synthesize block = block_;
@synthesize event = event_;
@synthesize progress = progress_;
@synthesize waitEvents = waitEvents_;

/*!
 @brief 初期化処理
 
 初期化処理を行う。
 @param stage ステージ番号
 @param layer マップを配置するレイヤー
 @return 初期化したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithStageNo:(NSInteger)stage layer:(CCNode *)layer
{
    // スーパークラスの初期化処理を行う
    self = [super init];
    if (!self) {
        AKLog(kAKLogScript_0, @"error");
        return nil;
    }
    
    // メンバ変数を初期化する
    progress_ = 0;
    waitEvents_ = [NSMutableArray arrayWithCapacity:kAKWaitEventsInitCapacity];
    
    // ステージ番号からタイルマップのファイル名を決定する
    NSString *fileName = [NSString stringWithFormat:kAKTileMapFileName, stage];
    
    // タイルマップファイルを開く
    self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:fileName];
    
    NSAssert(self.tileMap != nil, @"タイルマップ読み込みに失敗");
    
    // 各レイヤーを取得する
    self.background = [self.tileMap layerNamed:@"Background"];
    self.foreground = [self.tileMap layerNamed:@"Foreground"];
    self.block = [self.tileMap layerNamed:@"Block"];
    self.event = [self.tileMap layerNamed:@"Event"];
    self.enemy = [self.tileMap layerNamed:@"Enemy"];
    
    NSAssert(self.background != nil, @"背景レイヤーの取得に失敗");
    NSAssert(self.foreground != nil, @"前景レイヤーの取得に失敗");
    NSAssert(self.block != nil, @"障害物レイヤーの取得に失敗");
    NSAssert(self.event != nil, @"イベントレイヤーの取得に失敗");
    
    // 背景・前景以外は非表示とする
    self.block.visible = NO;
    self.enemy.visible = NO;
    self.event.visible = NO;
    
    // レイヤーに配置する
    [layer addChild:self.tileMap z:1];
    
    // 左端に初期位置を移動する
    self.tileMap.position = ccp([AKScreenSize xOfStage:0], [AKScreenSize yOfStage:0]);
    
    return self;
}

/*!
 @brief コンビニエンスコンストラクタ
 
 インスタンスの生成、初期化、autoreleaseを行う。
 @param stage ステージ番号
 @param layer マップを配置するレイヤー
 @return 初期化したオブジェクト。失敗時はnilを返す。
 */
+ (id)scriptWithStageNo:(NSInteger)stage layer:(CCNode *)layer
{
    return [[[AKTileMap alloc] initWithStageNo:stage layer:layer] autorelease];
}

/*!
 @brief オブジェクト解放処理
 
 オブジェクトの解放を行う。
 */
- (void)dealloc
{
    // メンバを解放する
    self.background = nil;
    self.foreground = nil;
    self.block = nil;
    self.event = nil;
    self.enemy = nil;
    self.tileMap = nil;
    self.waitEvents = nil;
    
    // スーパークラスの処理を行う
    [super dealloc];
}

/*!
 @brief 更新処理
 
 マップをスクロールスピードに応じてスクロールする。
 現在のスクロール位置までイベントを実行する。
 現在処理済みの列から表示中の一番右側の列+2列分までのタイルのイベントを処理する。
 @param data ゲームデータ
 */
- (void)update:(id<AKPlayDataInterface>)data
{
    // 背景をスクロールする
    self.tileMap.position = ccp(self.tileMap.position.x - data.scrollSpeedX,
                                self.tileMap.position.y - data.scrollSpeedY);
    
    // 表示中の一番右側の列+2列目までを処理対象とする
    NSInteger maxCol = ([AKScreenSize stageSize].width - [AKScreenSize xOfDevice:self.tileMap.position.x]) / self.tileMap.tileSize.width + 2;
    
    AKLog(kAKLogScript_2, @"currentCol_=%d maxCol=%d", currentCol_, maxCol);
    
    // 現在処理済みの列から最終列まで処理する
    for (; currentCol_ <= maxCol; currentCol_++) {
        
        [self execEventByCol:currentCol_ data:data];
    }
}

/*!
 @brief 列単位のイベント実行
 
 指定した列番号のタイルのイベントを実行する。
 @param col 列番号
 @param data ゲームデータ
 */
- (void)execEventByCol:(NSInteger)col data:(id<AKPlayDataInterface>)data
{
    // x座標はマップの左端 + タイルサイズ * 列番号 (列番号は左から0,1,2,…)
    // タイルの真ん中を指定するために列番号には+0.5する
    float x = [AKScreenSize xOfDevice:self.tileMap.position.x] + self.tileMap.tileSize.width * (col + 0.5);
    
    AKLog(kAKLogScript_4, @"position=%f x=%f", self.tileMap.position.x, x);
    
    // イベントレイヤーの処理を行う
    [self execEventLayer:self.event col:col x:x data:data execFunc:@selector(execEvent:)];
    
    // 障害物レイヤーの処理を行う
    [self execEventLayer:self.block col:col x:x data:data execFunc:@selector(createBlock:)];
    
    // 敵レイヤーの処理を行う
    [self execEventLayer:self.enemy col:col x:x data:data execFunc:@selector(createEnemy:)];
}

/*!
 @brief レイヤーごとのイベント実行
 
 レイヤーごとにイベントを実行する。
 指定されたレイヤーの1列分のイベントを実行する。
 @param layer レイヤー
 @param col 列番号
 @param x x座標
 @param data ゲームデータ
 @param execFunc イベント処理関数
 */
- (void)execEventLayer:(CCTMXLayer *)layer col:(NSInteger)col x:(float)x data:(id<AKPlayDataInterface>)data execFunc:(SEL)execFunc
{
    // レイヤーの一番上の行から一番下の行まで処理を行う
    for (int i = 0; i < self.tileMap.mapSize.height; i++) {
        
        // 処理対象のタイルの座標を作成する
        CGPoint tilePos = ccp(col, i);
        
        // タイルのGIDを取得する
        int tileGid = [layer tileGIDAt:tilePos];
        
        AKLog(kAKLogScript_2, @"i=%d tileGid=%d", i, tileGid);
        
        // タイルが存在する場合
        if (tileGid > 0) {
            
            // プロパティを取得する
            NSDictionary *properties = [self.tileMap propertiesForGID:tileGid];
            
            AKLog(kAKLogScript_2, @"properties=%p", properties);
            
            // プロパティが取得できた場合
            if (properties) {
                
                // y座標はマップの下端 + (マップの行数 - 行番号) * タイルサイズ (行番号は上から0,1,2…)
                // タイルの真ん中を指定するために行番号には+0.5する
                float y = [AKScreenSize yOfDevice:self.tileMap.position.y] + (self.tileMap.mapSize.height - (i + 0.5)) * self.tileMap.tileSize.height;
                
                // パラメータを作成する
                AKTileMapEventParameter *param = [[[AKTileMapEventParameter alloc] init] autorelease];
                param.x = x;
                param.y = y;
                param.properties = properties;
                param.data = data;
                
                // イベントを実行する
                [self performSelector:execFunc withObject:param];
            }
        }
    }
}

/*!
 @brief デバイス座標からマップ座標の取得
 
 デバイススクリーン座標からタイルマップ上の行列番号を取得する。
 左上を(0,0)として扱う。
 @param devicePosition デバイススクリーン座標
 @return マップ座標
 */
- (CGPoint)mapPositionFromDevicePosition:(CGPoint)devicePosition
{
    // タイルマップの左端からの距離をタイル幅で割った値を列番号とする
    NSInteger col = (devicePosition.x - self.tileMap.position.x) / self.tileMap.tileSize.width;
    
    // タイルマップの下端からの距離をタイル高さで割り、上下を反転させた値を行番号とする
    NSInteger row = self.tileMap.mapSize.height - (devicePosition.y - self.tileMap.position.y) / self.tileMap.tileSize.height;
    
    return ccp(col, row);
}

/*!
 @brief タイルの座標取得
 
 マップの行列番号からその位置のタイルのデバイススクリーン座標を取得する。
 タイルマップのデバイススクリーン座標の端数を四捨五入した上で計算を行う。
 @param mapPosition マップ座標
 @return タイルの座標
 */
- (CGPoint)tilePositionFromMapPosition:(CGPoint)mapPosition
{
    // x座標はマップの左端 + タイルサイズ * 列番号 (列番号は左から0,1,2,…)
    // タイルの真ん中を指定するために列番号には+0.5する
    NSInteger x = round(self.tileMap.position.x) + self.tileMap.tileSize.width * (mapPosition.x + 0.5);

    // y座標はマップの下端 + (マップの行数 - 行番号) * タイルサイズ (行番号は上から0,1,2…)
    // タイルの真ん中を指定するために行番号には+0.5する
    NSInteger y = round(self.tileMap.position.y) + self.tileMap.tileSize.height * (self.tileMap.mapSize.height - (mapPosition.y + 0.5));
    
    return ccp(x, y);
}


/*!
 @brief 障害物作成
 
 障害物を作成する。
 障害物レイヤーのプロパティから以下の項目を取得し、障害物の作成を行う。
 Type:障害物の種別
 @param param イベント実行パラメータ
 */
- (void)createBlock:(AKTileMapEventParameter*)param
{
    // 種別を取得する
    NSString *typeString = [param.properties objectForKey:@"Type"];
    NSInteger type = [typeString integerValue];
    
    // 障害物を作成する
    [param.data createBlock:type x:param.x y:param.y];
}

/*!
 @brief 敵作成
 
 敵を作成する。
 障害物レイヤーのプロパティから以下の項目を取得し、敵の作成を行う。
 Type:敵の種別
 Progress:倒した時に進む進行度
 @param param イベント実行パラメータ
 */
- (void)createEnemy:(AKTileMapEventParameter*)param
{
    // 種別を取得する
    NSString *typeString = [param.properties objectForKey:@"Type"];
    NSInteger type = [typeString integerValue];
    
    // 倒した時に進む進行度を取得する
    NSString *progressString = [param.properties objectForKey:@"Progress"];
    NSInteger progress = [progressString integerValue];
    
    // 敵を作成する
    [param.data createEnemy:type x:param.x y:param.y progress:progress];
}

/*!
 @brief イベント実行
 
 イベントを実行する。
 イベントレイヤーのプロパティから以下の項目を取得し、イベントを実行する。
 Type:イベントの種類
 Value:イベント実行で使用する値
 Progress:ステージ進行度がこの値以上のときにイベント実行する
 
 イベントの種類は以下のとおり、
 bgm:BGMを変更する
 hspeed:水平方向のスクロールスピードを変更する
 clear:ステージクリアのフラグを立てる
 @param param イベント実行パラメータ
 */
- (void)execEvent:(AKTileMapEventParameter*)param
{
    // 実行する進行状況の値を取得する
    NSString *progressString = [param.properties objectForKey:@"progress"];
    NSInteger progress = [progressString integerValue];
    
    // 実行する進行度に到達していない場合は待機イベントの配列に入れて処理を終了する
    if (progress < self.progress) {
        
        // 座標が0以上の場合はマップからの呼び出しと判断する。
        // マップ読み込みからの実行時は待機イベント配列へ入れる。
        if (!(param.x < 0.0f && param.y < 0.0f)) {
            
            [self.waitEvents addObject:param.properties];
        }
        
        return;
    }
    
    // 種別を取得する
    NSString *type = [param.properties objectForKey:@"Type"];
    
    // 値を取得する
    NSString *valueString = [param.properties objectForKey:@"Value"];
    NSInteger value = [valueString integerValue];
    
    // 水平方向のスクロールスピード変更の場合
    if ([type isEqualToString:@"hspeed"]) {
        // スピードは0.1単位で指定するものとする
        param.data.scrollSpeedX = value / 10.0f;
    }
    else if ([type isEqualToString:@"bgm"]) {
        // TODO:BGM変更処理を作成する
    }
    // ステージクリアの場合
    else if ([type isEqualToString:@"clear"]) {
        // TODO:ステージクリアフラグを立てる
    }
    // 不明な種別の場合
    else {
        AKLog(kAKLogScript_0, @"不明な種別:%@", type);
        NSAssert(NO, @"不明な種別");
    }
}
@end
