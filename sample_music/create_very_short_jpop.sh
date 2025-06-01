#!/bin/bash

# 本当に短い同期の取れたJ-POPスタイルの音楽を生成（約1分間）

# 一時ディレクトリ作成
mkdir -p temp_vshort

# 基本設定
SAMPLE_RATE=44100
BPM=120
BEAT_LENGTH=$(echo "60 / $BPM" | bc -l)  # 1拍の長さ（秒）- BPM 120に相当

# 基本的なビートパターン（4拍子）を作成 - 正確なタイミングで
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/kick.wav synth 0.1 sine 80 fade 0 0.1 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/snare.wav synth 0.1 sine 240 fade 0 0.1 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/hihat.wav synth 0.05 sine 880 fade 0 0.05 0.01

# 1小節（4拍）のドラムパターンを作成
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/drum_pattern.wav trim 0.0 2.0

# キック配置（1拍目と3拍目）
sox temp_vshort/drum_pattern.wav temp_vshort/kick.wav temp_vshort/temp.wav pad 0.0 && mv temp_vshort/temp.wav temp_vshort/drum_pattern.wav
sox temp_vshort/drum_pattern.wav temp_vshort/kick.wav temp_vshort/temp.wav pad 1.0 && mv temp_vshort/temp.wav temp_vshort/drum_pattern.wav

# スネア配置（2拍目と4拍目）
sox temp_vshort/drum_pattern.wav temp_vshort/snare.wav temp_vshort/temp.wav pad 0.5 && mv temp_vshort/temp.wav temp_vshort/drum_pattern.wav
sox temp_vshort/drum_pattern.wav temp_vshort/snare.wav temp_vshort/temp.wav pad 1.5 && mv temp_vshort/temp.wav temp_vshort/drum_pattern.wav

# ハイハット配置（各拍の頭と裏拍）
for i in 0 0.25 0.5 0.75 1.0 1.25 1.5 1.75; do
  sox temp_vshort/drum_pattern.wav temp_vshort/hihat.wav temp_vshort/temp.wav pad $i && mv temp_vshort/temp.wav temp_vshort/drum_pattern.wav
done

# コード進行（C-G-Am-F）を作成 - 各コード2拍
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/chord_c.wav synth 1.0 sine 261.63 fade 0 1.0 0.1 : synth 1.0 sine 329.63 fade 0 1.0 0.1 : synth 1.0 sine 392.00 fade 0 1.0 0.1
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/chord_g.wav synth 1.0 sine 392.00 fade 0 1.0 0.1 : synth 1.0 sine 493.88 fade 0 1.0 0.1 : synth 1.0 sine 587.33 fade 0 1.0 0.1
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/chord_am.wav synth 1.0 sine 220.00 fade 0 1.0 0.1 : synth 1.0 sine 261.63 fade 0 1.0 0.1 : synth 1.0 sine 329.63 fade 0 1.0 0.1
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/chord_f.wav synth 1.0 sine 349.23 fade 0 1.0 0.1 : synth 1.0 sine 440.00 fade 0 1.0 0.1 : synth 1.0 sine 523.25 fade 0 1.0 0.1

# コード進行を連結（2小節分）
sox temp_vshort/chord_c.wav temp_vshort/chord_g.wav temp_vshort/chord_am.wav temp_vshort/chord_f.wav temp_vshort/chord_progression.wav

# メロディノートを作成 - 正確な長さで
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/note_c5.wav synth 0.25 sine 523.25 fade 0 0.25 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/note_d5.wav synth 0.25 sine 587.33 fade 0 0.25 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/note_e5.wav synth 0.25 sine 659.26 fade 0 0.25 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/note_f5.wav synth 0.25 sine 698.46 fade 0 0.25 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/note_g5.wav synth 0.25 sine 783.99 fade 0 0.25 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/note_a5.wav synth 0.25 sine 880.00 fade 0 0.25 0.05

# 2小節のメロディパターンを作成
sox -n -r $SAMPLE_RATE -c 2 temp_vshort/melody_pattern.wav trim 0.0 4.0

# メロディノートを配置（正確なタイミングで）
sox temp_vshort/melody_pattern.wav temp_vshort/note_c5.wav temp_vshort/temp.wav pad 0.0 && mv temp_vshort/temp.wav temp_vshort/melody_pattern.wav
sox temp_vshort/melody_pattern.wav temp_vshort/note_e5.wav temp_vshort/temp.wav pad 0.5 && mv temp_vshort/temp.wav temp_vshort/melody_pattern.wav
sox temp_vshort/melody_pattern.wav temp_vshort/note_g5.wav temp_vshort/temp.wav pad 1.0 && mv temp_vshort/temp.wav temp_vshort/melody_pattern.wav
sox temp_vshort/melody_pattern.wav temp_vshort/note_e5.wav temp_vshort/temp.wav pad 1.5 && mv temp_vshort/temp.wav temp_vshort/melody_pattern.wav
sox temp_vshort/melody_pattern.wav temp_vshort/note_a5.wav temp_vshort/temp.wav pad 2.0 && mv temp_vshort/temp.wav temp_vshort/melody_pattern.wav
sox temp_vshort/melody_pattern.wav temp_vshort/note_g5.wav temp_vshort/temp.wav pad 2.5 && mv temp_vshort/temp.wav temp_vshort/melody_pattern.wav
sox temp_vshort/melody_pattern.wav temp_vshort/note_f5.wav temp_vshort/temp.wav pad 3.0 && mv temp_vshort/temp.wav temp_vshort/melody_pattern.wav
sox temp_vshort/melody_pattern.wav temp_vshort/note_d5.wav temp_vshort/temp.wav pad 3.5 && mv temp_vshort/temp.wav temp_vshort/melody_pattern.wav

# 各パートを繰り返して1分間の音楽を作成（2小節 × 15回 = 30小節 = 約1分）
sox temp_vshort/drum_pattern.wav temp_vshort/drum_pattern.wav temp_vshort/drum_pattern.wav temp_vshort/drum_pattern.wav temp_vshort/drum_pattern.wav temp_vshort/drum_pattern.wav temp_vshort/drum_pattern.wav temp_vshort/drum_pattern.wav temp_vshort/drum_pattern.wav temp_vshort/drum_pattern.wav temp_vshort/drum_pattern.wav temp_vshort/drum_pattern.wav temp_vshort/drum_pattern.wav temp_vshort/drum_pattern.wav temp_vshort/drum_pattern.wav temp_vshort/full_drums.wav
sox temp_vshort/chord_progression.wav temp_vshort/chord_progression.wav temp_vshort/chord_progression.wav temp_vshort/chord_progression.wav temp_vshort/chord_progression.wav temp_vshort/chord_progression.wav temp_vshort/chord_progression.wav temp_vshort/chord_progression.wav temp_vshort/full_chords.wav
sox temp_vshort/melody_pattern.wav temp_vshort/melody_pattern.wav temp_vshort/melody_pattern.wav temp_vshort/melody_pattern.wav temp_vshort/melody_pattern.wav temp_vshort/melody_pattern.wav temp_vshort/melody_pattern.wav temp_vshort/melody_pattern.wav temp_vshort/full_melody.wav

# すべてのトラックをミックス - 音量バランス調整
sox -m -v 0.7 temp_vshort/full_drums.wav -v 0.5 temp_vshort/full_chords.wav -v 0.8 temp_vshort/full_melody.wav temp_vshort/very_short_jpop_raw.wav

# 音量調整とエフェクト追加
sox temp_vshort/very_short_jpop_raw.wav very_short_jpop.wav reverb 30 30 100 100 0 0

# MP3に変換
ffmpeg -i very_short_jpop.wav -codec:a libmp3lame -qscale:a 2 very_short_jpop.mp3

# 一時ファイルのクリーンアップ
rm -rf temp_vshort

echo "同期の取れたJ-POPスタイルの音楽ファイル（約1分）を作成しました: /home/sence_of_unity/rhythm_game_spec/sample_music/very_short_jpop.mp3"
