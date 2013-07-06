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
 @file AKScript.m
 @brief スクリプト読み込みクラス
 
 ステージ構成定義のスクリプトファイルを読み込む。
 */

#import "AKScript.h"
#import "AKPlayData.h"

/// 進行待ち待機イベント初期配列数
static const NSUInteger kAKWaitEventsInitCapacity = 5;

/// タイルマップのファイル名
static NSString *kAKTileMapFileName = @"Stage_%02d.tmx";

// 障害物生成
static void createBlock(float x, float y, NSDictionary *properties, AKScript *selfptr);
// イベント実行
static void execEvent(float x, float y, NSDictionary *properties, AKScript *selfptr);

/*!
 @brief スクリプト読み込みクラス
 
 ステージ構成定義のスクリプトファイルを読み込む。
 */
@implementation AKScript

@synthesize dataList = dataList_;
@synthesize repeatList = repeatList_;
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
 @return 初期化したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithStageNo:(NSInteger)stage
{
    // スーパークラスの初期化処理を行う
    self = [super init];
    if (!self) {
        AKLog(kAKLogScript_0, @"error");
        return nil;
    }
    
    // メンバ変数を初期化する
    isPause_ = NO;
    currentLine_ = 0;
    sleepTime_ = 0.0f;
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
    
    NSAssert(self.background != nil, @"背景レイヤーの取得に失敗");
    NSAssert(self.foreground != nil, @"前景レイヤーの取得に失敗");
    NSAssert(self.block != nil, @"障害物レイヤーの取得に失敗");
    NSAssert(self.event != nil, @"イベントレイヤーの取得に失敗");
    
    // 背景・前景以外は非表示とする
    self.block.visible = NO;
    self.event.visible = NO;
    
    // シーンの背景レイヤーに配置する
    CCLayer *sceneLayer = [AKPlayData sharedInstance].scene.backgroundLayer;
    [sceneLayer addChild:self.tileMap z:1];
    
    // 左端に初期位置を移動する
    self.tileMap.position = ccp([AKScreenSize xOfStage:0], [AKScreenSize yOfStage:0]);
    
    return self;
}

/*!
 @brief コンビニエンスコンストラクタ
 
 インスタンスの生成、初期化、autoreleaseを行う。
 @param stage ステージ番号
 @return 初期化したオブジェクト。失敗時はnilを返す。
 */
+ (id)scriptWithStageNo:(NSInteger)stage
{
    return [[[AKScript alloc] initWithStageNo:stage] autorelease];
}

/*!
 @brief オブジェクト解放処理
 
 オブジェクトの解放を行う。
 */
- (void)dealloc
{
    // メンバを解放する
    self.dataList = nil;
    self.repeatList = nil;
    self.background = nil;
    self.foreground = nil;
    self.block = nil;
    self.event = nil;
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
 @param dt フレーム更新間隔
 */
- (void)update:(float)dt
{
    // 背景をスクロールする
    self.tileMap.position = ccp(self.tileMap.position.x - [AKPlayData sharedInstance].scrollSpeedX * dt,
                                self.tileMap.position.y - [AKPlayData sharedInstance].scrollSpeedY * dt);
    
    // 表示中の一番右側の列+2列目までを処理対象とする
    NSInteger maxCol = ([AKScreenSize stageSize].width - [AKScreenSize xOfDevice:self.tileMap.position.x]) / self.tileMap.tileSize.width + 2;
    
    AKLog(kAKLogScript_2, @"currentCol_=%d maxCol=%d", currentCol_, maxCol);
    
    // 現在処理済みの列から最終列まで処理する
    for (; currentCol_ <= maxCol; currentCol_++) {
        
        [self execEventByCol:currentCol_];
    }
}

/*!
 @brief 命令実行
 
 スクリプトデータの命令を実行する。
 */
- (void)execScriptData:(AKScriptData *)data
{
    // 命令の種別に応じて処理を実行する
    switch (data.type) {
            
        case kAKScriptOpeEnemy:     // 敵の生成

            AKLog(kAKLogScript_1, @"敵の生成:%d pos=(%d, %d)", data.characterNo, data.positionX, data.positionY);
            
            // 敵を生成する
            [[AKPlayData sharedInstance] createEnemy:data.characterNo
                                                   x:data.positionX
                                                   y:data.positionY
                                              isBoss:NO];
            break;
            
        case kAKScriptOpeBoss:      // ボスの生成

            AKLog(kAKLogScript_1, @"ボスの生成:%d pos=(%d, %d)", data.characterNo, data.positionX, data.positionY);
            
            // ボスを生成する
            [[AKPlayData sharedInstance] createEnemy:data.characterNo
                                                   x:data.positionX
                                                   y:data.positionY
                                              isBoss:YES];
            
            // ボスが倒されるまでスクリプトの実行を停止する
            isPause_ = YES;
            
            break;
            
        case kAKScriptOpeBack:      // 背景の生成
            
            AKLog(kAKLogScript_1, @"背景の生成:%d pos=(%d, %d) priority=%d isBase=%d",
                  data.characterNo, data.positionX, data.positionY, data.priority, data.isBase);
            
            // 背景を生成する
            [[AKPlayData sharedInstance] createBack:data.characterNo
                                                  x:data.positionX
                                                  y:data.positionY
                                           priority:data.priority
                                             isBase:data.isBase];
            break;
            
        case kAKScriptOpeWall:      // 障害物の生成
            
            AKLog(kAKLogScript_1, @"障害物の生成:%d pos=(%d, %d) isBase=%d",
                  data.characterNo, data.positionX, data.positionY, data.isBase);
            
            // 障害物を生成する
            [[AKPlayData sharedInstance] createBlock:data.characterNo
                                                   x:data.positionX
                                                   y:data.positionY
                                              isBase:data.isBase];
            break;
            
        case kAKScriptOpeScroll:    // スクロールスピード変更

            AKLog(kAKLogScript_1, @"スクロールスピード変更:(%d, %d)", data.speedX, data.speedY);
            
            // スクロールスピードを変更する
            [AKPlayData sharedInstance].scrollSpeedX = data.speedX;
            [AKPlayData sharedInstance].scrollSpeedY = data.speedY;
            break;
            
        case kAKScriptOpeBGM:       // BGM変更
            // BGMを変更する
            AKLog(kAKLogScript_1, @"BGM変更:%d", data.bgmNo);
            break;
            
        case kAKScriptOpeRepeat:    // 繰り返し命令
            // 繰り返し命令を実行する
            AKLog(kAKLogScript_1, @"");
            
            // 繰り返しの開始の場合は命令を実行後、繰り返し命令配列に登録する
            if (data.enableRepeat) {
                
                // 繰り返し命令を実行する
                [self execScriptData:data.repeatOpe];
                
                // 繰り返し命令配列に登録する
                [self.repeatList addObject:data];
                
            }
            // 繰り返しの停止の場合は繰り返し命令配列から削除する
            else {
                
                // 削除対象の命令の配列を作成する
                NSMutableArray *removeDatas = [NSMutableArray arrayWithCapacity:self.repeatList.count];
                
                // 繰り返し命令配列からIDが一致するものを削除配列に登録する
                for (AKScriptData *repeatData in [self.repeatList objectEnumerator]) {
                    
                    if (repeatData.repeatID == data.repeatID) {
                        [removeDatas addObject:repeatData];
                    }
                }
                
                // 繰り返し命令配列から削除対象の命令を削除する
                [self.repeatList removeObjectsInArray:removeDatas];
            }
            break;
            
        default:                    // その他
            // 不明な命令種別のため、エラー
            AKLog(kAKLogScript_0, @"不明な命令種別:%d", data.type);
            NSAssert(NO, @"不明な命令種別");
            break;
    }
}

/*!
 @brief 停止解除
 
 停止中フラグを落とす。
 ボスを倒した時などに呼び出す。
 */
- (void)resume
{
    isPause_ = NO;
}

/*!
 @brief 列単位のイベント実行
 
 指定した列番号のタイルのイベントを実行する。
 @param col 列番号
 */
- (void)execEventByCol:(NSInteger)col
{
    // x座標はマップの左端 + タイルサイズ * 列番号 (列番号は左から0,1,2,…)
    // タイルの真ん中を指定するために列番号には+0.5する
    float x = [AKScreenSize xOfDevice:self.tileMap.position.x] + self.tileMap.tileSize.width * (col + 0.5);
    
    AKLog(kAKLogScript_4, @"position=%f x=%f", self.tileMap.position.x, x);
    
    // イベントレイヤーの処理を行う
    [self execEventLayer:self.event col:col x:x execFunc:execEvent];
    
    // 障害物レイヤーの処理を行う
    [self execEventLayer:self.block col:col x:x execFunc:createBlock];
}

/*!
 @brief レイヤーごとのイベント実行
 
 レイヤーごとにイベントを実行する。
 指定されたレイヤーの1列分のイベントを実行する。
 @param layer レイヤー
 @param col 列番号
 @param x x座標
 @param execFunc イベント処理関数
 */
- (void)execEventLayer:(CCTMXLayer *)layer col:(NSInteger)col x:(float)x execFunc:(ExecFunc)execFunc
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
                
                // イベントを実行する
                execFunc(x, y, properties, self);
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
@end

/*!
 @brief 障害物作成
 
 障害物を作成する。
 障害物レイヤーのプロパティから以下の項目を取得し、障害物の生成を行う。
 Type:障害物の種別
 @property x 生成位置x座標
 @property y 生成位置y座標
 @property properties タイルのプロパティ
 @property selfptr 自インスタンスへのポインタ
 */
static void createBlock(float x, float y, NSDictionary *properties, AKScript *selfptr)
{
    // 種別を取得する
    NSString *typeString = [properties objectForKey:@"Type"];
    NSInteger type = [typeString integerValue];
    
    // 障害物を生成する
    [[AKPlayData sharedInstance] createBlock:type x:x y:y];
}

/*!
 @brief イベント実行
 
 イベントを実行する。
 イベントレイヤーのプロパティから以下の項目を取得し、イベントを実行する。
 Type:イベントの種類
 Value:イベント実行で使用する値
 Progress:ステージ進行状況がこの値以上のときにイベント実行する
 
 イベントの種類は以下のとおり、
 hspeed:水平方向のスクロールスピードを変更する
 clear:ステージクリアのフラグを立てる
 @property x 生成位置x座標(0以上の場合はマップからの実行、マイナスの場合は進行待ちイベントの実行)
 @property y 生成位置y座標(0以上の場合はマップからの実行、マイナスの場合は進行待ちイベントの実行)
 @property properties タイルのプロパティ
 @property selfptr 自インスタンスへのポインタ
 */
static void execEvent(float x, float y, NSDictionary *properties, AKScript *selfptr)
{
    // 実行する進行状況の値を取得する
    NSString *progressString = [properties objectForKey:@"progress"];
    NSInteger progress = [progressString integerValue];
    
    // 実行する進行状況に到達していない場合は待機イベントの配列に入れて処理を終了する
    if (progress < selfptr.progress) {
        
        // 座標が0以上の場合はマップからの呼び出しと判断する。
        // マップ読み込みからの実行時は待機イベント配列へ入れる。
        if (!(x < 0.0f && y < 0.0f)) {
            
            [selfptr.waitEvents addObject:properties];
        }
        
        return;
    }
    
    // 種別を取得する
    NSString *type = [properties objectForKey:@"Type"];
    
    // 値を取得する
    NSString *valueString = [properties objectForKey:@"Value"];
    NSInteger value = [valueString integerValue];
    
    // 水平方向のスクロールスピード変更の場合
    if ([type isEqualToString:@"hspeed"]) {
        [AKPlayData sharedInstance].scrollSpeedX = value;
    }
    // ステージクリアの場合
    else if ([type isEqualToString:@"clear"]) {
        // TODO:ステージクリアフラグを立てる
    }
    // 不明な種別の場合
    else {
        AKLog(kAKLogScript_0, @"不明な種別:%@", type);
        assert(0);
    }
}