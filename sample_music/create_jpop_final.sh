#!/bin/bash

# 最もシンプルなアプローチでJ-POPっぽい1分間の音楽を生成

# 基本的なビートパターン（4拍子）を作成
sox -n -r 44100 -c 2 beat1.wav synth 0.2 sine 80 fade 0 0.2 0.05 : synth 0.2 sine 440 fade 0 0.2 0.05
sox -n -r 44100 -c 2 beat2.wav synth 0.2 sine 240 fade 0 0.2 0.05 : synth 0.2 sine 660 fade 0 0.2 0.05
sox -n -r 44100 -c 2 beat3.wav synth 0.1 noise fade 0 0.1 0.01 : synth 0.1 sine 880 fade 0 0.1 0.01

# 4拍のパターンを作成
sox beat1.wav beat3.wav beat2.wav beat3.wav beat_pattern.wav

# コード進行（C-G-Am-F）を作成
sox -n -r 44100 -c 2 chord_c.wav synth 2.0 sine 261.63 fade 0 2.0 0.1 : synth 2.0 sine 329.63 fade 0 2.0 0.1 : synth 2.0 sine 392.00 fade 0 2.0 0.1
sox -n -r 44100 -c 2 chord_g.wav synth 2.0 sine 392.00 fade 0 2.0 0.1 : synth 2.0 sine 493.88 fade 0 2.0 0.1 : synth 2.0 sine 587.33 fade 0 2.0 0.1
sox -n -r 44100 -c 2 chord_am.wav synth 2.0 sine 220.00 fade 0 2.0 0.1 : synth 2.0 sine 261.63 fade 0 2.0 0.1 : synth 2.0 sine 329.63 fade 0 2.0 0.1
sox -n -r 44100 -c 2 chord_f.wav synth 2.0 sine 349.23 fade 0 2.0 0.1 : synth 2.0 sine 440.00 fade 0 2.0 0.1 : synth 2.0 sine 523.25 fade 0 2.0 0.1

# コード進行を連結
sox chord_c.wav chord_g.wav chord_am.wav chord_f.wav chord_progression.wav

# メロディパターンを作成
sox -n -r 44100 -c 2 melody1.wav synth 0.5 sine 523.25 fade 0 0.5 0.05
sox -n -r 44100 -c 2 melody2.wav synth 0.5 sine 659.26 fade 0 0.5 0.05
sox -n -r 44100 -c 2 melody3.wav synth 0.5 sine 783.99 fade 0 0.5 0.05
sox -n -r 44100 -c 2 melody4.wav synth 0.5 sine 698.46 fade 0 0.5 0.05

# メロディを連結
sox melody1.wav melody2.wav melody3.wav melody2.wav melody1.wav melody4.wav melody3.wav melody1.wav melody_line.wav

# 各パートを繰り返して1分間の音楽を作成
sox beat_pattern.wav beat_pattern.wav beat_pattern.wav beat_pattern.wav beat_pattern.wav beat_pattern.wav beat_pattern.wav beat_pattern.wav beat_pattern.wav beat_pattern.wav beat_pattern.wav beat_pattern.wav beat_pattern.wav beat_pattern.wav beat_pattern.wav full_beat.wav
sox chord_progression.wav chord_progression.wav chord_progression.wav chord_progression.wav full_chord.wav
sox melody_line.wav melody_line.wav melody_line.wav melody_line.wav full_melody.wav

# すべてのトラックをミックス
sox -m full_beat.wav full_chord.wav full_melody.wav jpop_final_raw.wav

# 音量調整とエフェクト追加
sox jpop_final_raw.wav jpop_final.wav reverb 50 50 100 100 0 0

# MP3に変換
ffmpeg -i jpop_final.wav -codec:a libmp3lame -qscale:a 2 jpop_final.mp3

# 一時ファイルのクリーンアップ
rm -f beat1.wav beat2.wav beat3.wav beat_pattern.wav
rm -f chord_c.wav chord_g.wav chord_am.wav chord_f.wav chord_progression.wav
rm -f melody1.wav melody2.wav melody3.wav melody4.wav melody_line.wav
rm -f full_beat.wav full_chord.wav full_melody.wav
rm -f jpop_final_raw.wav jpop_final.wav

echo "J-POPスタイルの音楽ファイルを作成しました: /home/sence_of_unity/rhythm_game_spec/sample_music/jpop_final.mp3"
