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
        AKLog(1, @"error");
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
    AKLog(0, @"filePath=%@", filePath);
    
    // ステージ定義ファイルを読み込む
    NSError *error = nil;
    NSString *stageScript = [NSString stringWithContentsOfFile:filePath
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
    // ファイル読み込みエラー
    if (stageScript == nil && error != nil) {
        AKLog(1, @"%@", [error localizedDescription]);
    }
    
    // スクリプトデータ保存用の配列を作成する
    self.dataList = [NSMutableArray array];
    
    // 繰り返し命令保存用の配列を作成する
    self.repeatList = [NSMutableArray array];
    
    // ステージ定義ファイルの範囲の間は処理を続ける
    for (NSRange lineRange = {0};
         lineRange.location < stageScript.length;
         lineRange.location = lineRange.location + lineRange.length, lineRange.length = 0) {
        
        // 1行の範囲を取得する
        lineRange = [stageScript lineRangeForRange:lineRange];
        
        // 1行の文字列を取得する
        NSString *line = [stageScript substringWithRange:lineRange];
        AKLog(0, @"%@", line);
        
        // 1文字目が"#"の場合は処理を飛ばす
        if ([[line substringToIndex:1] isEqualToString:@"#"]) {
            AKLog(0, @"コメント:%@", line);
            continue;
        }
        
        // 空行は処理を飛ばす
        if ([line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0) {
            continue;
        }
        
        // 空白区切りでトークンを分割する
        NSArray *params = [line componentsSeparatedByString:@" "];
             
        // 1個目のパラメータは命令種別として扱う
        NSString *type = [params objectAtIndex:0];
        
        // 2個目のパラメータは命令の値として扱う
        NSInteger value = [[params objectAtIndex:1] integerValue];
        
        // 3個目のパラメータがある場合はx座標として扱う
        NSInteger x = 0;
        if (params.count >= 3) {
            x = [[params objectAtIndex:2] integerValue];
        }
        
        // 4個目のパラメータがある場合はy座標として扱う
        NSInteger y = 0;
        if (params.count >= 4) {
            y = [[params objectAtIndex:3] integerValue];
        }
        
        // スクリプトデータを作成し、配列に格納する
        [self.dataList addObject:[AKScriptData scriptDataWithType:type value:value x:x y:y]];
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
    
    // 各命令を実行する
    for (; currentLine_ < self.dataList.count; currentLine_++) {
        
        // 命令を取得する
        AKScriptData *data = [self.dataList objectAtIndex:currentLine_];
        
        // 待機の場合は指定待機時間経過しているかチェックする
        if (data.type == kAKScriptOpeSleep) {
            
            AKLog(0, @"待機:%d 現在の待機時間:%f", data.value, sleepTime_);

            // 待機時間が経過していない場合は処理を終了する
            // 待機時間はミリ秒で指定しているので桁合わせを行う
            if (sleepTime_ < data.value / 1000.0f) {
                break;
            }
            // 待機時間が経過している場合は指定された時間分だけ
            // 現在の待機時間からマイナスして次の命令を実行する
            else {
                sleepTime_ -= data.value / 1000.0f;
                continue;
            }
        }
        
        // 命令の種別に応じて処理を実行する
        switch (data.type) {
                
            case kAKScriptOpeEnemy:     // 敵の生成
                // 敵を生成する
                AKLog(1, @"敵の生成:%d pos=(%d, %d)", data.value, data.positionX, data.positionY);
                [[AKPlayData sharedInstance] createEnemy:data.value x:data.positionX y:data.positionY isBoss:NO];
                break;
                
            case kAKScriptOpeBoss:      // ボスの生成
                // ボスを生成する
                AKLog(1, @"ボスの生成:%d", data.value);
                [[AKPlayData sharedInstance] createEnemy:data.value x:data.positionX y:data.positionY isBoss:YES];
                
                // ボスが倒されるまでスクリプトの実行を停止する
                isPause_ = YES;
                
                break;
                
            case kAKScriptOpeBack:      // 背景の生成
                // 背景を生成する
                AKLog(1, @"背景の生成:%d", data.value);
                [[AKPlayData sharedInstance] createBack:data.value x:data.positionX y:data.positionY];
                break;
                
            case kAKScriptOpeWall:      // 障害物の生成
                // 障害物を生成する
                AKLog(1, @"障害物の生成:%d pos=(%d, %d)", data.value, data.positionX, data.positionY);
                [[AKPlayData sharedInstance] createBlock:data.value x:data.positionX y:data.positionY];
                break;
                
            case kAKScriptOpeScroll:    // スクロールスピード変更
                // スクロールスピードを変更する
                AKLog(1, @"スクロールスピード変更:(%d, %d)", data.positionX, data.positionY);
                [AKPlayData sharedInstance].scrollSpeedX = data.positionX;
                [AKPlayData sharedInstance].scrollSpeedY = data.positionY;
                break;
                
            case kAKScriptOpeBGM:       // BGM変更
                // BGMを変更する
                AKLog(1, @"BGM変更:%d", data.value);
                break;
                
            default:                    // その他
                // 不明な命令種別のため、エラー
                AKLog(1, @"不明な命令種別:%d", data.value);
                NSAssert(0, @"不明な命令種別");
                break;
        }
    }
    
    // すべての行を実行した場合はステージクリア処理を行う
    if (currentLine_ >= self.dataList.count) {
        AKLog(0, @"すべての行を実行完了");
        return YES;
    }
    
    return NO;
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
