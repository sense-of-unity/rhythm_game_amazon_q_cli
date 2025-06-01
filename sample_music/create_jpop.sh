#!/bin/bash

# J-POPっぽい1分間の音楽を生成するスクリプト
# 一時ファイル用のディレクトリ
mkdir -p temp

# テンポ設定（BPM=120）
BEAT_LENGTH=0.5  # 4分音符の長さ（秒）

# コード進行（J-POPでよく使われるコード進行）
# C-G-Am-F の進行を使用
create_chord() {
  local name=$1
  local root=$2
  local third=$3
  local fifth=$4
  local length=$5
  
  sox -n -r 44100 -c 2 temp/${name}.wav synth $length sine $root fade 0 $length 0.1 : synth $length sine $third fade 0 $length 0.1 : synth $length sine $fifth fade 0 $length 0.1
}

# ドラムビートの作成
create_drum_beat() {
  local name=$1
  local length=$2
  local pattern=$3
  
  # キック（低い音）
  sox -n -r 44100 -c 2 temp/kick.wav synth 0.1 sine 80 fade 0 0.1 0.05
  
  # スネア（中音）
  sox -n -r 44100 -c 2 temp/snare.wav synth 0.1 sine 240 fade 0 0.1 0.05
  
  # ハイハット（高音）
  sox -n -r 44100 -c 2 temp/hihat.wav synth 0.05 noise fade 0 0.05 0.01
  
  # パターンに基づいてドラムを配置
  sox -n -r 44100 -c 2 temp/${name}.wav trim 0.0 $length
  
  local position=0.0
  for beat in $pattern; do
    case $beat in
      "k") sox temp/${name}.wav temp/kick.wav temp/temp_drum.wav splice $position && mv temp/temp_drum.wav temp/${name}.wav ;;
      "s") sox temp/${name}.wav temp/snare.wav temp/temp_drum.wav splice $position && mv temp/temp_drum.wav temp/${name}.wav ;;
      "h") sox temp/${name}.wav temp/hihat.wav temp/temp_drum.wav splice $position && mv temp/temp_drum.wav temp/${name}.wav ;;
    esac
    position=$(echo "$position + 0.25" | bc)
  done
}

# メロディの作成
create_melody() {
  local name=$1
  local length=$2
  local notes=$3
  
  sox -n -r 44100 -c 2 temp/${name}.wav trim 0.0 $length
  
  local position=0.0
  for note in $notes; do
    sox -n -r 44100 -c 2 temp/note_temp.wav synth 0.25 sine $note fade 0 0.25 0.05
    sox temp/${name}.wav temp/note_temp.wav temp/temp_melody.wav splice $position && mv temp/temp_melody.wav temp/${name}.wav
    position=$(echo "$position + 0.25" | bc)
  done
}

# コード進行の作成（各コード2小節 = 4拍 = 2秒）
create_chord "c_chord" 261.63 329.63 392.00 $BEAT_LENGTH
create_chord "g_chord" 392.00 493.88 587.33 $BEAT_LENGTH
create_chord "am_chord" 220.00 261.63 329.63 $BEAT_LENGTH
create_chord "f_chord" 349.23 440.00 523.25 $BEAT_LENGTH

# 4つのコードを1セットとして、それを繰り返す
sox temp/c_chord.wav temp/g_chord.wav temp/am_chord.wav temp/f_chord.wav temp/chord_progression.wav

# 8回繰り返して約30秒の伴奏を作成
sox temp/chord_progression.wav temp/chord_progression.wav temp/chord_progression.wav temp/chord_progression.wav temp/chord_progression.wav temp/chord_progression.wav temp/chord_progression.wav temp/chord_progression.wav temp/full_chords.wav

# ドラムビートの作成（4拍 = 1小節）
# k=キック、s=スネア、h=ハイハット、-=休符
create_drum_beat "basic_beat" 4.0 "k - s - k - s -"

# ドラムパターンを繰り返して30秒のドラムトラックを作成
sox temp/basic_beat.wav temp/basic_beat.wav temp/basic_beat.wav temp/basic_beat.wav temp/basic_beat.wav temp/basic_beat.wav temp/basic_beat.wav temp/basic_beat.wav temp/full_drums.wav

# シンプルなメロディの作成
# C メジャースケールの音符を使用
create_melody "melody1" 4.0 "523.25 523.25 783.99 659.26 523.25 587.33 523.25 493.88"
create_melody "melody2" 4.0 "493.88 493.88 783.99 659.26 523.25 587.33 523.25 440.00"

# メロディを繰り返して30秒のメロディトラックを作成
sox temp/melody1.wav temp/melody2.wav temp/melody1.wav temp/melody2.wav temp/melody1.wav temp/melody2.wav temp/melody1.wav temp/melody2.wav temp/full_melody.wav

# すべてのトラックをミックス
sox -m temp/full_chords.wav temp/full_drums.wav temp/full_melody.wav jpop_song_raw.wav

# 音量調整とエフェクト追加
sox jpop_song_raw.wav jpop_song.wav reverb 50 50 100 100 0 0

# MP3に変換
ffmpeg -i jpop_song.wav -codec:a libmp3lame -qscale:a 2 jpop_rhythm_game.mp3

# 一時ファイルの削除
rm -rf temp

echo "J-POPスタイルの音楽ファイルを作成しました: /home/sence_of_unity/rhythm_game_spec/sample_music/jpop_rhythm_game.mp3"
