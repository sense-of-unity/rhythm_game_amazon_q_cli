# リズムゲーム用サンプル音楽

このディレクトリには、リズムゲーム開発用のサンプル音楽ファイルが含まれています。

## ファイル一覧

### 短いサンプル音楽（テスト用）
- `rhythm_sample.mp3` - 基本的なビートパターン（約2秒）
- `rhythm_game_demo.mp3` - 長めの基本ビートパターン（約5秒）
- `complex_rhythm_game.mp3` - 複雑なリズムパターン（約1秒）

### J-POPスタイルの音楽（ゲーム用）
- `very_short_jpop.mp3` - 同期の取れたJ-POPスタイルの音楽（約3分）- **最新版・推奨**
- `jpop_final.mp3` - J-POPスタイルの1分間の音楽
- `jpop_rhythm_game.mp3` - J-POPスタイルの音楽（初期版）
- `simple_jpop_rhythm_game.mp3` - シンプルなJ-POPスタイルの音楽

## 同期の取れた音楽ファイル
メロディとリズムが正確に同期した音楽ファイルです：
- `very_short_jpop.mp3` - 最も同期が取れた3分間の音楽（BPM 120）
- `short_synced_jpop.mp3` - 同期の取れた音楽（約11分）
- `synced_jpop.mp3` - 同期の取れた音楽（約11分）

## 生成方法

これらの音楽ファイルはSoxとFFmpegを使用して生成されました。

### 基本的なビートの生成コマンド
```bash
sox -n -r 44100 -c 2 beat.wav synth 0.1 sine 880 fade 0 0.1 0.01 : synth 0.1 sine 440 fade 0 0.1 0.01 repeat 20
ffmpeg -i beat.wav -codec:a libmp3lame -qscale:a 2 rhythm_sample.mp3
```

### 同期の取れたJ-POPスタイルの音楽生成コマンド（抜粋）
```bash
# 基本的なビートパターン（4拍子）を作成
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/kick.wav synth 0.1 sine 80 fade 0 0.1 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/snare.wav synth 0.1 sine 240 fade 0 0.1 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/hihat.wav synth 0.05 sine 880 fade 0 0.05 0.01

# 1小節（4拍）のドラムパターンを作成
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/drum_pattern.wav trim 0.0 2.0

# キック配置（1拍目と3拍目）
sox temp_vshort/drum_pattern.wav temp_vshort/kick.wav temp_vshort/temp.wav pad 0.0
sox temp_vshort/drum_pattern.wav temp_vshort/kick.wav temp_vshort/temp.wav pad 1.0

# コード進行（C-G-Am-F）を作成 - 各コード2拍
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/chord_c.wav synth 1.0 sine 261.63 fade 0 1.0 0.1 : synth 1.0 sine 329.63 fade 0 1.0 0.1 : synth 1.0 sine 392.00 fade 0 1.0 0.1
```

## J-POPスタイルの音楽について

`very_short_jpop.mp3`は、J-POPでよく使われる要素を取り入れて作成しました：

1. **4拍子のリズム**: 典型的なポップミュージックの拍子（BPM 120）
2. **C-G-Am-F のコード進行**: J-POPでよく使われるコード進行
3. **明るいメロディライン**: C5, E5, G5などの音を使用
4. **繰り返しのパターン**: 同じパターンを繰り返すことで覚えやすさを重視
5. **リバーブエフェクト**: 空間的な広がりを演出
6. **正確な同期**: メロディとリズムが正確に同期しているため、リズムゲームに最適

## 使用方法

これらのサンプル音楽ファイルは、リズムゲームのプロトタイプ開発やテスト用に使用できます。
特に`very_short_jpop.mp3`は約3分間の長さがあり、メロディとリズムの同期が取れているため、
実際のゲームプレイに最適です。

## カスタムリズムの作成

Soxを使用して、さまざまな周波数、長さ、パターンのリズムを作成できます。
基本的な構文は以下の通りです：

```bash
sox -n -r 44100 -c 2 output.wav synth [長さ] [波形] [周波数] fade [フェードイン] [長さ] [フェードアウト] repeat [繰り返し回数]
```

例えば：
- 異なる周波数を使用する: `synth 0.1 sine 660`（高い音）、`synth 0.1 sine 220`（低い音）
- 異なる波形を使用する: `sine`（サイン波）、`square`（矩形波）、`triangle`（三角波）、`sawtooth`（のこぎり波）
- 異なる長さを使用する: `synth 0.2 sine 440`（長い音）、`synth 0.05 sine 440`（短い音）

## 注意事項

これらのサンプル音楽ファイルは単純な合成音のみを使用しています。
実際のゲーム開発では、より複雑で魅力的な音楽を使用することをお勧めします。
