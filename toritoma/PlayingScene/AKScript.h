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
 @file AKScript.h
 @brief スクリプト読み込みクラス
 
 ステージ構成定義のスクリプトファイルを読み込む。
 */

#import <Foundation/Foundation.h>
#import "AKLib.h"
#import "AKScriptData.h"

// スクリプト読み込みクラス
@interface AKScript : NSObject {
    /// 読み込んだ内容
    NSMutableArray *dataList_;
    /// 繰り返し命令
    NSMutableArray *repeatList_;
    /// 実行した行番号
    NSInteger currentLine_;
    /// 待機時間
    float sleepTime_;
    /// 停止中かどうか
    BOOL isPause_;
}

/// 読み込んだ内容
@property (nonatomic, retain)NSMutableArray *dataList;
/// 繰り返し命令
@property (nonatomic, retain)NSMutableArray *repeatList;

// 初期化処理
- (id)initWithStageNo:(NSInteger)stage;
// コンビニエンスコンストラクタ
+ (id)scriptWithStageNo:(NSInteger)stage;
// 更新処理
- (BOOL)update:(float)dt;
// 命令実行
- (void)execScriptData:(AKScriptData *)data;
// 停止解除
- (void)resume;

@end
