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

/// ステージ構成定義のスクリプトファイル名
static NSString *kAKScriptFileName = @"stage_%d";

/*!
 @brief スクリプト読み込みクラス
 
 ステージ構成定義のスクリプトファイルを読み込む。
 */
@implementation AKScript

@synthesize dataList = dataList_;
@synthesize repeatList = repeatList_;

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
    
    // ステージ番号からスクリプトファイル名を決定する
    NSString *file = [NSString stringWithFormat:kAKScriptFileName, stage];
    
    // ファイルパスをバンドルから取得する
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *filePath = [bundle pathForResource:file ofType:@"txt"];
    AKLog(kAKLogScript_1, @"filePath=%@", filePath);
    
    // ステージ定義ファイルを読み込む
    NSError *error = nil;
    NSString *stageScript = [NSString stringWithContentsOfFile:filePath
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
    // ファイル読み込みエラー
    if (stageScript == nil && error != nil) {
        AKLog(kAKLogScript_0, @"%@", [error localizedDescription]);
    }
    
    // スクリプトデータ保存用の配列を作成する
    self.dataList = [NSMutableArray array];
    
    // 繰り返し命令保存用の配列を作成する
    self.repeatList = [NSMutableArray array];
    
    // 前回のループで作成した命令オブジェクト
    AKScriptData *prevData = nil;
    
    // ステージ定義ファイルの範囲の間は処理を続ける
    for (NSRange lineRange = {0};
         lineRange.location < stageScript.length;
         lineRange.location = lineRange.location + lineRange.length, lineRange.length = 0) {
        
        // 1行の範囲を取得する
        lineRange = [stageScript lineRangeForRange:lineRange];
        
        // 1行の文字列を取得する
        NSString *line = [stageScript substringWithRange:lineRange];
        AKLog(kAKLogScript_2, @"%@", line);
        
        // 1文字目が"#"の場合は処理を飛ばす
        if ([[line substringToIndex:1] isEqualToString:@"#"]) {
            AKLog(kAKLogScript_0, @"コメント:%@", line);
            continue;
        }
        
        // 空行は処理を飛ばす
        if ([line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0) {
            continue;
        }
        
        // 空白区切りでトークンを分割する
        NSArray *params = [line componentsSeparatedByString:@" "];
        
        // スクリプトデータを作成する
        AKScriptData *scriptData = [AKScriptData scriptDataWithParams:params];
        
        // 前回作成したデータが繰り返し命令の場合は繰り返し命令のメンバに設定する
        if (prevData != nil && prevData.type == kAKScriptOpeRepeat) {
            
            AKLog(kAKLogScript_1, @"繰り返し命令の登録");
            
            // 繰り返し命令のあとに繰り返し命令、待機命令が出てきた場合はエラーとして無視する
            if (scriptData.type == kAKScriptOpeRepeat ||
                scriptData.type == kAKScriptOpeSleep) {
                
                AKLog(kAKLogScript_0, @"繰り返し対象の命令が不正:%d", scriptData.type);
                NSAssert(NO, @"繰り返し対象の命令が不正");
                continue;
            }
            
            // 繰り返し命令のメンバに設定する
            prevData.repeatOpe = scriptData;
        }
        // その他の場合は自分のメンバに設定する
        else {
            [self.dataList addObject:scriptData];
        }
        
        // 今回作成したデータを前回分として保存する
        prevData = scriptData;
    }
    
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
    
    // スーパークラスの処理を行う
    [super dealloc];
}

/*!
 @brief 更新処理
 
 スクリプトデータの実行を行う。
 待機命令を見つけるまで命令を実行する。
 待機命令を見つけたら指定された時間経過するまで待機する。
 @param dt フレーム更新間隔
 @return すべてのスクリプトを実行し終わったかどうか
 */
- (BOOL)update:(float)dt
{
    // 停止中の場合は処理を終了する
    if (isPause_) {
        return NO;
    }
    
    // 現在の待機時間をカウントする
    sleepTime_ += dt;
    
    // 繰り返し命令を実行する
    for (AKScriptData *data in [self.repeatList objectEnumerator]) {
        
        // 繰り返し待機時間をカウントする
        data.repeatWaitTime += dt;
        
        // 繰り返し間隔を経過している場合は命令を実行する
        // 繰り返し間隔はミリ秒で指定しているので桁合わせを行う
        if (data.repeatWaitTime > data.repeatInterval / 1000.0f) {
            
            // 繰り返し命令を実行する
            [self execScriptData:data.repeatOpe];
            
            // 繰り返し待機時間をリセットする
            data.repeatWaitTime = 0.0f;
        }
    }
    
    // 各命令を実行する
    for (; currentLine_ < self.dataList.count; currentLine_++) {
        
        // 命令を取得する
        AKScriptData *data = [self.dataList objectAtIndex:currentLine_];
        
        // 待機の場合は指定待機時間経過しているかチェックする
        if (data.type == kAKScriptOpeSleep) {
            
            AKLog(kAKLogScript_2, @"待機:%d 現在の待機時間:%f", data.sleepTime, sleepTime_);

            // 待機時間が経過していない場合は処理を終了する
            // 待機時間はミリ秒で指定しているので桁合わせを行う
            if (sleepTime_ < data.sleepTime / 1000.0f) {
                break;
            }
            // 待機時間が経過している場合は指定された時間分だけ
            // 現在の待機時間からマイナスして次の命令を実行する
            else {
                sleepTime_ -= data.sleepTime / 1000.0f;
                continue;
            }
        }
        
        // スクリプトの処理を実行する
        [self execScriptData:data];
    }
    
    // すべての行を実行した場合は終了を呼び出し元に返す
    if (currentLine_ >= self.dataList.count) {
        AKLog(kAKLogScript_1, @"すべての行を実行完了");
        return YES;
    }
    
    return NO;
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
            // 敵を生成する
            AKLog(kAKLogScript_1, @"敵の生成:%d pos=(%d, %d)", data.characterNo, data.positionX, data.positionY);
            [[AKPlayData sharedInstance] createEnemy:data.characterNo
                                                   x:data.positionX
                                                   y:data.positionY
                                              isBoss:NO];
            break;
            
        case kAKScriptOpeBoss:      // ボスの生成
            // ボスを生成する
            AKLog(kAKLogScript_1, @"ボスの生成:%d pos=(%d, %d)", data.characterNo, data.positionX, data.positionY);
            [[AKPlayData sharedInstance] createEnemy:data.characterNo
                                                   x:data.positionX
                                                   y:data.positionY
                                              isBoss:YES];
            
            // ボスが倒されるまでスクリプトの実行を停止する
            isPause_ = YES;
            
            break;
            
        case kAKScriptOpeBack:      // 背景の生成
            // 背景を生成する
            AKLog(kAKLogScript_1, @"背景の生成:%d pos=(%d, %d)", data.characterNo, data.positionX, data.positionY);
            [[AKPlayData sharedInstance] createBack:data.characterNo
                                                  x:data.positionX
                                                  y:data.positionY];
            break;
            
        case kAKScriptOpeWall:      // 障害物の生成
            // 障害物を生成する
            AKLog(kAKLogScript_1, @"障害物の生成:%d pos=(%d, %d)", data.characterNo, data.positionX, data.positionY);
            [[AKPlayData sharedInstance] createBlock:data.characterNo
                                                   x:data.positionX
                                                   y:data.positionY];
            break;
            
        case kAKScriptOpeScroll:    // スクロールスピード変更
            // スクロールスピードを変更する
            AKLog(kAKLogScript_1, @"スクロールスピード変更:(%d, %d)", data.speedX, data.speedY);
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
@end
