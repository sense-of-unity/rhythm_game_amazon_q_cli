#!/bin/bash

# メロディとリズムの同期を改善したJ-POPスタイルの音楽を生成

# 一時ディレクトリ作成
mkdir -p temp_sync

# 基本設定
SAMPLE_RATE=44100
BEAT_LENGTH=0.5  # 1拍の長さ（秒）- BPM 120に相当

# 基本的なビートパターン（4拍子）を作成 - 正確なタイミングで
sox -n -r $SAMPLE_RATE -c 2 temp_sync/kick.wav synth $BEAT_LENGTH sine 80 fade 0 $BEAT_LENGTH 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_sync/snare.wav synth $BEAT_LENGTH sine 240 fade 0 $BEAT_LENGTH 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_sync/hihat.wav synth $(echo "$BEAT_LENGTH / 4" | bc -l) sine 880 fade 0 $(echo "$BEAT_LENGTH / 4" | bc -l) 0.01

# 4小節（16拍）のドラムパターンを作成
sox -n -r $SAMPLE_RATE -c 2 temp_sync/drum_pattern.wav trim 0.0 $(echo "$BEAT_LENGTH * 16" | bc -l)

# キック配置（1拍目と9拍目）
sox temp_sync/drum_pattern.wav temp_sync/kick.wav temp_sync/temp.wav pad $(echo "$BEAT_LENGTH * 0" | bc -l) && mv temp_sync/temp.wav temp_sync/drum_pattern.wav
sox temp_sync/drum_pattern.wav temp_sync/kick.wav temp_sync/temp.wav pad $(echo "$BEAT_LENGTH * 8" | bc -l) && mv temp_sync/temp.wav temp_sync/drum_pattern.wav

# スネア配置（5拍目と13拍目）
sox temp_sync/drum_pattern.wav temp_sync/snare.wav temp_sync/temp.wav pad $(echo "$BEAT_LENGTH * 4" | bc -l) && mv temp_sync/temp.wav temp_sync/drum_pattern.wav
sox temp_sync/drum_pattern.wav temp_sync/snare.wav temp_sync/temp.wav pad $(echo "$BEAT_LENGTH * 12" | bc -l) && mv temp_sync/temp.wav temp_sync/drum_pattern.wav

# ハイハット配置（各拍の頭）
for i in $(seq 0 15); do
  sox temp_sync/drum_pattern.wav temp_sync/hihat.wav temp_sync/temp.wav pad $(echo "$BEAT_LENGTH * $i" | bc -l) && mv temp_sync/temp.wav temp_sync/drum_pattern.wav
done

# コード進行（C-G-Am-F）を作成 - 各コード4拍
sox -n -r $SAMPLE_RATE -c 2 temp_sync/chord_c.wav synth $(echo "$BEAT_LENGTH * 4" | bc -l) sine 261.63 fade 0 $(echo "$BEAT_LENGTH * 4" | bc -l) 0.1 : synth $(echo "$BEAT_LENGTH * 4" | bc -l) sine 329.63 fade 0 $(echo "$BEAT_LENGTH * 4" | bc -l) 0.1 : synth $(echo "$BEAT_LENGTH * 4" | bc -l) sine 392.00 fade 0 $(echo "$BEAT_LENGTH * 4" | bc -l) 0.1
sox -n -r $SAMPLE_RATE -c 2 temp_sync/chord_g.wav synth $(echo "$BEAT_LENGTH * 4" | bc -l) sine 392.00 fade 0 $(echo "$BEAT_LENGTH * 4" | bc -l) 0.1 : synth $(echo "$BEAT_LENGTH * 4" | bc -l) sine 493.88 fade 0 $(echo "$BEAT_LENGTH * 4" | bc -l) 0.1 : synth $(echo "$BEAT_LENGTH * 4" | bc -l) sine 587.33 fade 0 $(echo "$BEAT_LENGTH * 4" | bc -l) 0.1
sox -n -r $SAMPLE_RATE -c 2 temp_sync/chord_am.wav synth $(echo "$BEAT_LENGTH * 4" | bc -l) sine 220.00 fade 0 $(echo "$BEAT_LENGTH * 4" | bc -l) 0.1 : synth $(echo "$BEAT_LENGTH * 4" | bc -l) sine 261.63 fade 0 $(echo "$BEAT_LENGTH * 4" | bc -l) 0.1 : synth $(echo "$BEAT_LENGTH * 4" | bc -l) sine 329.63 fade 0 $(echo "$BEAT_LENGTH * 4" | bc -l) 0.1
sox -n -r $SAMPLE_RATE -c 2 temp_sync/chord_f.wav synth $(echo "$BEAT_LENGTH * 4" | bc -l) sine 349.23 fade 0 $(echo "$BEAT_LENGTH * 4" | bc -l) 0.1 : synth $(echo "$BEAT_LENGTH * 4" | bc -l) sine 440.00 fade 0 $(echo "$BEAT_LENGTH * 4" | bc -l) 0.1 : synth $(echo "$BEAT_LENGTH * 4" | bc -l) sine 523.25 fade 0 $(echo "$BEAT_LENGTH * 4" | bc -l) 0.1

# コード進行を連結
sox temp_sync/chord_c.wav temp_sync/chord_g.wav temp_sync/chord_am.wav temp_sync/chord_f.wav temp_sync/chord_progression.wav

# メロディノートを作成 - 正確な長さで
sox -n -r $SAMPLE_RATE -c 2 temp_sync/note_c5.wav synth $BEAT_LENGTH sine 523.25 fade 0 $BEAT_LENGTH 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_sync/note_d5.wav synth $BEAT_LENGTH sine 587.33 fade 0 $BEAT_LENGTH 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_sync/note_e5.wav synth $BEAT_LENGTH sine 659.26 fade 0 $BEAT_LENGTH 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_sync/note_f5.wav synth $BEAT_LENGTH sine 698.46 fade 0 $BEAT_LENGTH 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_sync/note_g5.wav synth $BEAT_LENGTH sine 783.99 fade 0 $BEAT_LENGTH 0.05
sox -n -r $SAMPLE_RATE -c 2 temp_sync/note_a5.wav synth $BEAT_LENGTH sine 880.00 fade 0 $BEAT_LENGTH 0.05

# 16拍のメロディパターンを作成
sox -n -r $SAMPLE_RATE -c 2 temp_sync/melody_pattern.wav trim 0.0 $(echo "$BEAT_LENGTH * 16" | bc -l)

# メロディノートを配置（正確なタイミングで）
sox temp_sync/melody_pattern.wav temp_sync/note_c5.wav temp_sync/temp.wav pad $(echo "$BEAT_LENGTH * 0" | bc -l) && mv temp_sync/temp.wav temp_sync/melody_pattern.wav
sox temp_sync/melody_pattern.wav temp_sync/note_e5.wav temp_sync/temp.wav pad $(echo "$BEAT_LENGTH * 2" | bc -l) && mv temp_sync/temp.wav temp_sync/melody_pattern.wav
sox temp_sync/melody_pattern.wav temp_sync/note_g5.wav temp_sync/temp.wav pad $(echo "$BEAT_LENGTH * 4" | bc -l) && mv temp_sync/temp.wav temp_sync/melody_pattern.wav
sox temp_sync/melody_pattern.wav temp_sync/note_e5.wav temp_sync/temp.wav pad $(echo "$BEAT_LENGTH * 6" | bc -l) && mv temp_sync/temp.wav temp_sync/melody_pattern.wav
sox temp_sync/melody_pattern.wav temp_sync/note_a5.wav temp_sync/temp.wav pad $(echo "$BEAT_LENGTH * 8" | bc -l) && mv temp_sync/temp.wav temp_sync/melody_pattern.wav
sox temp_sync/melody_pattern.wav temp_sync/note_g5.wav temp_sync/temp.wav pad $(echo "$BEAT_LENGTH * 10" | bc -l) && mv temp_sync/temp.wav temp_sync/melody_pattern.wav
sox temp_sync/melody_pattern.wav temp_sync/note_f5.wav temp_sync/temp.wav pad $(echo "$BEAT_LENGTH * 12" | bc -l) && mv temp_sync/temp.wav temp_sync/melody_pattern.wav
sox temp_sync/melody_pattern.wav temp_sync/note_d5.wav temp_sync/temp.wav pad $(echo "$BEAT_LENGTH * 14" | bc -l) && mv temp_sync/temp.wav temp_sync/melody_pattern.wav

# 各パートを繰り返して1分間の音楽を作成
sox temp_sync/drum_pattern.wav temp_sync/drum_pattern.wav temp_sync/drum_pattern.wav temp_sync/drum_pattern.wav temp_sync/drum_pattern.wav temp_sync/drum_pattern.wav temp_sync/drum_pattern.wav temp_sync/drum_pattern.wav temp_sync/full_drums.wav
sox temp_sync/chord_progression.wav temp_sync/chord_progression.wav temp_sync/chord_progression.wav temp_sync/chord_progression.wav temp_sync/full_chords.wav
sox temp_sync/melody_pattern.wav temp_sync/melody_pattern.wav temp_sync/melody_pattern.wav temp_sync/melody_pattern.wav temp_sync/melody_pattern.wav temp_sync/melody_pattern.wav temp_sync/melody_pattern.wav temp_sync/melody_pattern.wav temp_sync/full_melody.wav

# すべてのトラックをミックス - 音量バランス調整
sox -m -v 0.7 temp_sync/full_drums.wav -v 0.5 temp_sync/full_chords.wav -v 0.8 temp_sync/full_melody.wav temp_sync/synced_jpop_raw.wav

# 音量調整とエフェクト追加
sox temp_sync/synced_jpop_raw.wav synced_jpop.wav reverb 30 30 100 100 0 0

# MP3に変換
ffmpeg -i synced_jpop.wav -codec:a libmp3lame -qscale:a 2 synced_jpop.mp3

# 一時ファイルのクリーンアップ
rm -rf temp_sync

echo "メロディとリズムの同期を改善したJ-POPスタイルの音楽ファイルを作成しました: /home/sence_of_unity/rhythm_game_spec/sample_music/synced_jpop.mp3"
