#!/bin/bash

# より単純なアプローチでJ-POPっぽい1分間の音楽を生成

# ベースとなるビート音を作成
sox -n -r 44100 -c 2 bass_drum.wav synth 0.1 sine 80 fade 0 0.1 0.05
sox -n -r 44100 -c 2 snare.wav synth 0.1 sine 240 fade 0 0.1 0.05
sox -n -r 44100 -c 2 hihat.wav synth 0.05 noise fade 0 0.05 0.01

# コード音を作成
sox -n -r 44100 -c 2 chord_c.wav synth 2.0 sine 261.63 fade 0 2.0 0.1 : synth 2.0 sine 329.63 fade 0 2.0 0.1 : synth 2.0 sine 392.00 fade 0 2.0 0.1
sox -n -r 44100 -c 2 chord_g.wav synth 2.0 sine 392.00 fade 0 2.0 0.1 : synth 2.0 sine 493.88 fade 0 2.0 0.1 : synth 2.0 sine 587.33 fade 0 2.0 0.1
sox -n -r 44100 -c 2 chord_am.wav synth 2.0 sine 220.00 fade 0 2.0 0.1 : synth 2.0 sine 261.63 fade 0 2.0 0.1 : synth 2.0 sine 329.63 fade 0 2.0 0.1
sox -n -r 44100 -c 2 chord_f.wav synth 2.0 sine 349.23 fade 0 2.0 0.1 : synth 2.0 sine 440.00 fade 0 2.0 0.1 : synth 2.0 sine 523.25 fade 0 2.0 0.1

# メロディ音を作成
sox -n -r 44100 -c 2 melody_c5.wav synth 0.5 sine 523.25 fade 0 0.5 0.05
sox -n -r 44100 -c 2 melody_d5.wav synth 0.5 sine 587.33 fade 0 0.5 0.05
sox -n -r 44100 -c 2 melody_e5.wav synth 0.5 sine 659.26 fade 0 0.5 0.05
sox -n -r 44100 -c 2 melody_f5.wav synth 0.5 sine 698.46 fade 0 0.5 0.05
sox -n -r 44100 -c 2 melody_g5.wav synth 0.5 sine 783.99 fade 0 0.5 0.05
sox -n -r 44100 -c 2 melody_a5.wav synth 0.5 sine 880.00 fade 0 0.5 0.05

# ドラムパターンを作成（4拍子）
sox -n -r 44100 -c 2 drum_pattern.wav trim 0.0 8.0
sox drum_pattern.wav bass_drum.wav drum_pattern_temp.wav splice 0.0 && mv drum_pattern_temp.wav drum_pattern.wav
sox drum_pattern.wav hihat.wav drum_pattern_temp.wav splice 0.5 && mv drum_pattern_temp.wav drum_pattern.wav
sox drum_pattern.wav snare.wav drum_pattern_temp.wav splice 1.0 && mv drum_pattern_temp.wav drum_pattern.wav
sox drum_pattern.wav hihat.wav drum_pattern_temp.wav splice 1.5 && mv drum_pattern_temp.wav drum_pattern.wav
sox drum_pattern.wav bass_drum.wav drum_pattern_temp.wav splice 2.0 && mv drum_pattern_temp.wav drum_pattern.wav
sox drum_pattern.wav hihat.wav drum_pattern_temp.wav splice 2.5 && mv drum_pattern_temp.wav drum_pattern.wav
sox drum_pattern.wav snare.wav drum_pattern_temp.wav splice 3.0 && mv drum_pattern_temp.wav drum_pattern.wav
sox drum_pattern.wav hihat.wav drum_pattern_temp.wav splice 3.5 && mv drum_pattern_temp.wav drum_pattern.wav
sox drum_pattern.wav bass_drum.wav drum_pattern_temp.wav splice 4.0 && mv drum_pattern_temp.wav drum_pattern.wav
sox drum_pattern.wav hihat.wav drum_pattern_temp.wav splice 4.5 && mv drum_pattern_temp.wav drum_pattern.wav
sox drum_pattern.wav snare.wav drum_pattern_temp.wav splice 5.0 && mv drum_pattern_temp.wav drum_pattern.wav
sox drum_pattern.wav hihat.wav drum_pattern_temp.wav splice 5.5 && mv drum_pattern_temp.wav drum_pattern.wav
sox drum_pattern.wav bass_drum.wav drum_pattern_temp.wav splice 6.0 && mv drum_pattern_temp.wav drum_pattern.wav
sox drum_pattern.wav hihat.wav drum_pattern_temp.wav splice 6.5 && mv drum_pattern_temp.wav drum_pattern.wav
sox drum_pattern.wav snare.wav drum_pattern_temp.wav splice 7.0 && mv drum_pattern_temp.wav drum_pattern.wav
sox drum_pattern.wav hihat.wav drum_pattern_temp.wav splice 7.5 && mv drum_pattern_temp.wav drum_pattern.wav

# コード進行を作成（C-G-Am-F）
sox chord_c.wav chord_g.wav chord_am.wav chord_f.wav chord_progression.wav

# メロディパターンを作成
sox -n -r 44100 -c 2 melody_pattern.wav trim 0.0 8.0
sox melody_pattern.wav melody_c5.wav melody_pattern_temp.wav splice 0.0 && mv melody_pattern_temp.wav melody_pattern.wav
sox melody_pattern.wav melody_e5.wav melody_pattern_temp.wav splice 1.0 && mv melody_pattern_temp.wav melody_pattern.wav
sox melody_pattern.wav melody_g5.wav melody_pattern_temp.wav splice 2.0 && mv melody_pattern_temp.wav melody_pattern.wav
sox melody_pattern.wav melody_e5.wav melody_pattern_temp.wav splice 3.0 && mv melody_pattern_temp.wav melody_pattern.wav
sox melody_pattern.wav melody_a5.wav melody_pattern_temp.wav splice 4.0 && mv melody_pattern_temp.wav melody_pattern.wav
sox melody_pattern.wav melody_g5.wav melody_pattern_temp.wav splice 5.0 && mv melody_pattern_temp.wav melody_pattern.wav
sox melody_pattern.wav melody_f5.wav melody_pattern_temp.wav splice 6.0 && mv melody_pattern_temp.wav melody_pattern.wav
sox melody_pattern.wav melody_d5.wav melody_pattern_temp.wav splice 7.0 && mv melody_pattern_temp.wav melody_pattern.wav

# 全体を繰り返して1分間の音楽を作成
sox chord_progression.wav chord_progression.wav chord_progression.wav chord_progression.wav full_chords.wav
sox drum_pattern.wav drum_pattern.wav drum_pattern.wav drum_pattern.wav drum_pattern.wav drum_pattern.wav drum_pattern.wav full_drums.wav
sox melody_pattern.wav melody_pattern.wav melody_pattern.wav melody_pattern.wav melody_pattern.wav melody_pattern.wav melody_pattern.wav full_melody.wav

# すべてのトラックをミックス
sox -m full_chords.wav full_drums.wav full_melody.wav simple_jpop_raw.wav

# 音量調整とエフェクト追加
sox simple_jpop_raw.wav simple_jpop.wav reverb 50 50 100 100 0 0

# MP3に変換
ffmpeg -i simple_jpop.wav -codec:a libmp3lame -qscale:a 2 simple_jpop_rhythm_game.mp3

# 一時ファイルのクリーンアップ
rm -f bass_drum.wav snare.wav hihat.wav
rm -f chord_c.wav chord_g.wav chord_am.wav chord_f.wav chord_progression.wav
rm -f melody_c5.wav melody_d5.wav melody_e5.wav melody_f5.wav melody_g5.wav melody_a5.wav
rm -f drum_pattern.wav melody_pattern.wav
rm -f full_chords.wav full_drums.wav full_melody.wav
rm -f simple_jpop_raw.wav simple_jpop.wav

echo "シンプルなJ-POPスタイルの音楽ファイルを作成しました: /home/sence_of_unity/rhythm_game_spec/sample_music/simple_jpop_rhythm_game.mp3"
