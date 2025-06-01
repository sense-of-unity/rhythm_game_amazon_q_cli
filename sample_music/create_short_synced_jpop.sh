#!/bin/bash

# より短い同期の取れたJ-POPスタイルの音楽を生成（約1分間）

# 一時ディレクトリ作成
mkdir -p temp_short

# 基本設定
SAMPLE_RATE=44100
BEAT_LENGTH=0.5  # 1拍の長さ（秒）- BPM 120に相当

# 基本的なビートパターン（4拍子）を作成 - 正確なタイミングで
sox -n -r $SAMPLE_RATE -c 2 temp_short/kick.wav synth $BEAT_LENGTH sine 80 fade 0 $BEAT_LENGTH 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_short/snare.wav synth $BEAT_LENGTH sine 240 fade 0 $BEAT_LENGTH 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_short/hihat.wav synth 0.125 sine 880 fade 0 0.125 0.01

# 4小節（16拍）のドラムパターンを作成
sox -n -r $SAMPLE_RATE -c 2 temp_short/drum_pattern.wav trim 0.0 8.0

# キック配置（1拍目と9拍目）
sox temp_short/drum_pattern.wav temp_short/kick.wav temp_short/temp.wav pad 0.0 && mv temp_short/temp.wav temp_short/drum_pattern.wav
sox temp_short/drum_pattern.wav temp_short/kick.wav temp_short/temp.wav pad 4.0 && mv temp_short/temp.wav temp_short/drum_pattern.wav

# スネア配置（5拍目と13拍目）
sox temp_short/drum_pattern.wav temp_short/snare.wav temp_short/temp.wav pad 2.0 && mv temp_short/temp.wav temp_short/drum_pattern.wav
sox temp_short/drum_pattern.wav temp_short/snare.wav temp_short/temp.wav pad 6.0 && mv temp_short/temp.wav temp_short/drum_pattern.wav

# ハイハット配置（各拍の頭）
for i in $(seq 0 15); do
  position=$(echo "$i * 0.5" | bc -l)
  sox temp_short/drum_pattern.wav temp_short/hihat.wav temp_short/temp.wav pad $position && mv temp_short/temp.wav temp_short/drum_pattern.wav
done

# コード進行（C-G-Am-F）を作成 - 各コード4拍
sox -n -r $SAMPLE_RATE -c 2 temp_short/chord_c.wav synth 2.0 sine 261.63 fade 0 2.0 0.1 : synth 2.0 sine 329.63 fade 0 2.0 0.1 : synth 2.0 sine 392.00 fade 0 2.0 0.1
sox -n -r $SAMPLE_RATE -c 2 temp_short/chord_g.wav synth 2.0 sine 392.00 fade 0 2.0 0.1 : synth 2.0 sine 493.88 fade 0 2.0 0.1 : synth 2.0 sine 587.33 fade 0 2.0 0.1
sox -n -r $SAMPLE_RATE -c 2 temp_short/chord_am.wav synth 2.0 sine 220.00 fade 0 2.0 0.1 : synth 2.0 sine 261.63 fade 0 2.0 0.1 : synth 2.0 sine 329.63 fade 0 2.0 0.1
sox -n -r $SAMPLE_RATE -c 2 temp_short/chord_f.wav synth 2.0 sine 349.23 fade 0 2.0 0.1 : synth 2.0 sine 440.00 fade 0 2.0 0.1 : synth 2.0 sine 523.25 fade 0 2.0 0.1

# コード進行を連結
sox temp_short/chord_c.wav temp_short/chord_g.wav temp_short/chord_am.wav temp_short/chord_f.wav temp_short/chord_progression.wav

# メロディノートを作成 - 正確な長さで
sox -n -r $SAMPLE_RATE -c 2 temp_short/note_c5.wav synth 0.5 sine 523.25 fade 0 0.5 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_short/note_d5.wav synth 0.5 sine 587.33 fade 0 0.5 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_short/note_e5.wav synth 0.5 sine 659.26 fade 0 0.5 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_short/note_f5.wav synth 0.5 sine 698.46 fade 0 0.5 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_short/note_g5.wav synth 0.5 sine 783.99 fade 0 0.5 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_short/note_a5.wav synth 0.5 sine 880.00 fade 0 0.5 0.05

# 16拍のメロディパターンを作成
sox -n -r $SAMPLE_RATE -c 2 temp_short/melody_pattern.wav trim 0.0 8.0

# メロディノートを配置（正確なタイミングで）
sox temp_short/melody_pattern.wav temp_short/note_c5.wav temp_short/temp.wav pad 0.0 && mv temp_short/temp.wav temp_short/melody_pattern.wav
sox temp_short/melody_pattern.wav temp_short/note_e5.wav temp_short/temp.wav pad 1.0 && mv temp_short/temp.wav temp_short/melody_pattern.wav
sox temp_short/melody_pattern.wav temp_short/note_g5.wav temp_short/temp.wav pad 2.0 && mv temp_short/temp.wav temp_short/melody_pattern.wav
sox temp_short/melody_pattern.wav temp_short/note_e5.wav temp_short/temp.wav pad 3.0 && mv temp_short/temp.wav temp_short/melody_pattern.wav
sox temp_short/melody_pattern.wav temp_short/note_a5.wav temp_short/temp.wav pad 4.0 && mv temp_short/temp.wav temp_short/melody_pattern.wav
sox temp_short/melody_pattern.wav temp_short/note_g5.wav temp_short/temp.wav pad 5.0 && mv temp_short/temp.wav temp_short/melody_pattern.wav
sox temp_short/melody_pattern.wav temp_short/note_f5.wav temp_short/temp.wav pad 6.0 && mv temp_short/temp.wav temp_short/melody_pattern.wav
sox temp_short/melody_pattern.wav temp_short/note_d5.wav temp_short/temp.wav pad 7.0 && mv temp_short/temp.wav temp_short/melody_pattern.wav

# 各パートを繰り返して1分間の音楽を作成（8小節 × 8回 = 64小節 = 約2分）
sox temp_short/drum_pattern.wav temp_short/drum_pattern.wav temp_short/drum_pattern.wav temp_short/drum_pattern.wav temp_short/drum_pattern.wav temp_short/drum_pattern.wav temp_short/drum_pattern.wav temp_short/drum_pattern.wav temp_short/full_drums.wav
sox temp_short/chord_progression.wav temp_short/chord_progression.wav temp_short/chord_progression.wav temp_short/chord_progression.wav temp_short/full_chords.wav
sox temp_short/melody_pattern.wav temp_short/melody_pattern.wav temp_short/melody_pattern.wav temp_short/melody_pattern.wav temp_short/melody_pattern.wav temp_short/melody_pattern.wav temp_short/melody_pattern.wav temp_short/melody_pattern.wav temp_short/full_melody.wav

# すべてのトラックをミックス - 音量バランス調整
sox -m -v 0.7 temp_short/full_drums.wav -v 0.5 temp_short/full_chords.wav -v 0.8 temp_short/full_melody.wav temp_short/short_synced_jpop_raw.wav

# 音量調整とエフェクト追加
sox temp_short/short_synced_jpop_raw.wav short_synced_jpop.wav reverb 30 30 100 100 0 0

# MP3に変換
ffmpeg -i short_synced_jpop.wav -codec:a libmp3lame -qscale:a 2 short_synced_jpop.mp3

# 一時ファイルのクリーンアップ
rm -rf temp_short

echo "同期の取れたJ-POPスタイルの音楽ファイル（約1分）を作成しました: /home/sence_of_unity/rhythm_game_spec/sample_music/short_synced_jpop.mp3"
