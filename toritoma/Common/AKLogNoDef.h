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
 @file AKLogNoDef.h
 @brief ログ区分定義
 
 ログの開始、停止を管理するための定数を定義する。
 定数名はkAK<クラス名>_<区分>とする。
 区分は0:エラー処理、1:通常処理、2〜:ループ処理等頻繁に呼ばれる処理とする。
 */

#ifdef DEBUG
extern BOOL kAKLogBack_0;
extern BOOL kAKLogBack_1;
extern BOOL kAKLogBlock_0;
extern BOOL kAKLogBlock_1;
extern BOOL kAKLogCharacter_0;
extern BOOL kAKLogCharacter_1;
extern BOOL kAKLogCharacterPool_0;
extern BOOL kAKLogCharacterPool_1;
extern BOOL kAKLogChickenGauge_0;
extern BOOL kAKLogChickenGauge_1;
extern BOOL kAKLogEffect_0;
extern BOOL kAKLogEffect_1;
extern BOOL kAKLogEnemy_0;
extern BOOL kAKLogEnemy_1;
extern BOOL kAKLogEnemyShot_0;
extern BOOL kAKLogEnemyShot_1;
extern BOOL kAKLogGameCenterHelper_0;
extern BOOL kAKLogGameCenterHelper_1;
extern BOOL kAKLogHowToPlayScene_0;
extern BOOL kAKLogHowToPlayScene_1;
extern BOOL kAKLogLife_0;
extern BOOL kAKLogLife_1;
extern BOOL kAKLogOption_0;
extern BOOL kAKLogOption_1;
extern BOOL kAKLogOptionScene_0;
extern BOOL kAKLogOptionScene_1;
extern BOOL kAKLogPlayData_0;
extern BOOL kAKLogPlayData_1;
extern BOOL kAKLogPlayData_2;
extern BOOL kAKLogPlayData_3;
extern BOOL kAKLogPlayer_0;
extern BOOL kAKLogPlayer_1;
extern BOOL kAKLogPlayerShot_0;
extern BOOL kAKLogPlayerShot_1;
extern BOOL kAKLogPlayingScene_0;
extern BOOL kAKLogPlayingScene_1;
extern BOOL kAKLogPlayingScene_2;
extern BOOL kAKLogPlayingScene_3;
extern BOOL kAKLogPlayingSceneIF_0;
extern BOOL kAKLogPlayingSceneIF_1;
extern BOOL kAKLogScript_0;
extern BOOL kAKLogScript_1;
extern BOOL kAKLogScript_2;
extern BOOL kAKLogScriptData_0;
extern BOOL kAKLogScriptData_1;
extern BOOL kAKLogTitleScene_0;
extern BOOL kAKLogTitleScene_1;
#endif