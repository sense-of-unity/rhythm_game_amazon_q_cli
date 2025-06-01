#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
リズムゲーム - PyGame実装
仕様書: rhythm_game_specification.md に基づいて実装
"""

import os
import sys
import time
import pygame
import random
from pygame.locals import *

# 定数定義
SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
FPS = 60
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
GRAY = (100, 100, 100)
RED = (255, 0, 0)
GREEN = (0, 255, 0)
BLUE = (0, 0, 255)
YELLOW = (255, 255, 0)
CYAN = (0, 255, 255)
MAGENTA = (255, 0, 255)
ORANGE = (255, 165, 0)
PURPLE = (128, 0, 128)

# 判定ライン位置
JUDGMENT_LINE_Y = SCREEN_HEIGHT - 100

# キー設定（デフォルト）
KEY_CONFIG = {
    pygame.K_d: 0,  # Dキー: 左
    pygame.K_f: 1,  # Fキー: 中左
    pygame.K_j: 2,  # Jキー: 中右
    pygame.K_k: 3,  # Kキー: 右
}

# レーン設定
LANE_COUNT = 4
LANE_WIDTH = SCREEN_WIDTH // LANE_COUNT
LANE_COLORS = [BLUE, GREEN, YELLOW, RED]
LANE_KEYS = ['D', 'F', 'J', 'K']

# 判定設定
PERFECT_RANGE = 0.03  # ±0.03秒
GREAT_RANGE = 0.05    # ±0.05秒
GOOD_RANGE = 0.10     # ±0.10秒
BAD_RANGE = 0.15      # ±0.15秒

# 点数設定
PERFECT_SCORE = 100
GREAT_SCORE = 80
GOOD_SCORE = 50
BAD_SCORE = 20
MISS_SCORE = 0

# 判定色設定
PERFECT_COLOR = CYAN
GREAT_COLOR = GREEN
GOOD_COLOR = YELLOW
BAD_COLOR = ORANGE
MISS_COLOR = RED

# ノーツの落下速度（ピクセル/秒）
NOTE_SPEED = 400

class Note:
    """ノーツクラス"""
    def __init__(self, lane, time):
        self.lane = lane  # レーン番号（0-3）
        self.time = time  # 叩くタイミング（秒）
        self.y = 0        # 現在のY座標
        self.hit = False  # 叩かれたかどうか
        self.judgment = None  # 判定結果
        self.width = LANE_WIDTH - 20  # ノーツの幅
        self.height = 20             # ノーツの高さ

    def update(self, current_time, music_start_time):
        """ノーツの位置を更新"""
        # 音楽開始からの経過時間
        elapsed_time = current_time - music_start_time
        # 叩くタイミングまでの残り時間
        time_to_hit = self.time - elapsed_time
        # 残り時間に基づいてY座標を計算
        self.y = JUDGMENT_LINE_Y - (time_to_hit * NOTE_SPEED)

    def draw(self, screen):
        """ノーツを描画"""
        if not self.hit:
            x = self.lane * LANE_WIDTH + 10  # レーンの中央に配置
            pygame.draw.rect(screen, LANE_COLORS[self.lane],
                            (x, self.y, self.width, self.height))
            pygame.draw.rect(screen, WHITE,
                            (x, self.y, self.width, self.height), 2)

class RhythmGame:
    """リズムゲームのメインクラス"""
    def __init__(self):
        # PyGameの初期化
        pygame.init()
        pygame.mixer.init()
        pygame.display.set_caption("リズムゲーム")

        # 画面設定
        self.screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
        self.clock = pygame.time.Clock()

        # フォント設定 - 日本語対応
        try:
            # 日本語フォントを探す (Windows)
            self.font_large = pygame.font.SysFont("Yu Gothic", 60)
            self.font_medium = pygame.font.SysFont("Yu Gothic", 36)
            self.font_small = pygame.font.SysFont("Yu Gothic", 24)
        except:
            try:
                # 日本語フォントを探す (macOS)
                self.font_large = pygame.font.SysFont("Hiragino Sans", 60)
                self.font_medium = pygame.font.SysFont("Hiragino Sans", 36)
                self.font_small = pygame.font.SysFont("Hiragino Sans", 24)
            except:
                # フォールバック: デフォルトフォント
                self.font_large = pygame.font.SysFont(None, 60)
                self.font_medium = pygame.font.SysFont(None, 36)
                self.font_small = pygame.font.SysFont(None, 24)

        # 背景画像の読み込み
        self.background_path = os.path.join(os.path.dirname(__file__), "background.gif")
        self.background = None
        try:
            if os.path.exists(self.background_path):
                self.background = pygame.image.load(self.background_path).convert()
                self.background = pygame.transform.scale(self.background, (SCREEN_WIDTH, SCREEN_HEIGHT))
        except Exception as e:
            print(f"背景画像の読み込みに失敗しました: {e}")

        # ゲーム状態
        self.running = True
        self.game_state = "title"  # title, playing, result

        # 音楽ファイルのパス
        music_filename = "jpop_rhythm_game.mp3"
        self.music_path = os.path.join(os.path.dirname(__file__), "sample_music", music_filename)
        
        # 音楽ファイルが存在するか確認
        if not os.path.exists(self.music_path):
            print(f"警告: 音楽ファイル {self.music_path} が見つかりません。")
            # 代替の音楽ファイルを探す
            sample_music_dir = os.path.join(os.path.dirname(__file__), "sample_music")
            if os.path.exists(sample_music_dir):
                mp3_files = [f for f in os.listdir(sample_music_dir) if f.endswith('.mp3')]
                if mp3_files:
                    self.music_path = os.path.join(sample_music_dir, mp3_files[0])
                    print(f"代替の音楽ファイル {self.music_path} を使用します。")

        # 効果音ディレクトリの確認と作成
        sounds_dir = os.path.join(os.path.dirname(__file__), "sounds")
        os.makedirs(sounds_dir, exist_ok=True)

        # 効果音ファイルの生成（存在しない場合）
        self._generate_sound_effects(sounds_dir)

        # 効果音の読み込み
        try:
            self.sound_perfect = pygame.mixer.Sound(os.path.join(sounds_dir, "perfect.wav"))
            self.sound_great = pygame.mixer.Sound(os.path.join(sounds_dir, "great.wav"))
            self.sound_good = pygame.mixer.Sound(os.path.join(sounds_dir, "good.wav"))
            self.sound_bad = pygame.mixer.Sound(os.path.join(sounds_dir, "bad.wav"))
            self.sound_miss = pygame.mixer.Sound(os.path.join(sounds_dir, "miss.wav"))
        except pygame.error as e:
            print(f"効果音の読み込みに失敗しました: {e}")
            # ダミーの効果音オブジェクトを作成
            class DummySound:
                def play(self): pass
            self.sound_perfect = DummySound()
            self.sound_great = DummySound()
            self.sound_good = DummySound()
            self.sound_bad = DummySound()
            self.sound_miss = DummySound()

        # ゲームデータ
        self.notes = []
        self.score = 0
        self.combo = 0
        self.max_combo = 0
        self.judgments = {"PERFECT": 0, "GREAT": 0, "GOOD": 0, "BAD": 0, "MISS": 0}
        self.judgment_display = None
        self.judgment_time = 0

        # 音楽関連
        self.music_start_time = 0
        self.music_length = 0

        # ノーツ生成
        self.generate_notes()

    def _generate_sound_effects(self, sounds_dir):
        """効果音ファイルを生成する（存在しない場合）"""
        def generate_sound(filename, freq, duration):
            try:
                import math
                import numpy as np
                import wave
                import struct

                sample_rate = 44100
                t = np.linspace(0, duration, int(sample_rate * duration), False)
                wave_data = np.sin(2 * np.pi * freq * t) * 32767
                wave_data = np.int16(wave_data)

                # WAVファイルとして保存
                with wave.open(os.path.join(sounds_dir, filename), 'w') as wf:
                    wf.setnchannels(1)  # モノラル
                    wf.setsampwidth(2)  # 16ビット
                    wf.setframerate(sample_rate)
                    wf.writeframes(wave_data.tobytes())
                return True
            except Exception as e:
                print(f"効果音の生成に失敗しました: {e}")
                return False

        # 効果音が存在しない場合は生成
        if not os.path.exists(os.path.join(sounds_dir, "perfect.wav")):
            generate_sound("perfect.wav", 880, 0.1)
        if not os.path.exists(os.path.join(sounds_dir, "great.wav")):
            generate_sound("great.wav", 660, 0.1)
        if not os.path.exists(os.path.join(sounds_dir, "good.wav")):
            generate_sound("good.wav", 440, 0.1)
        if not os.path.exists(os.path.join(sounds_dir, "bad.wav")):
            generate_sound("bad.wav", 220, 0.1)
        if not os.path.exists(os.path.join(sounds_dir, "miss.wav")):
            generate_sound("miss.wav", 110, 0.1)

    def generate_notes(self):
        """ノーツを生成する"""
        # 譜面ファイルからノーツを読み込む
        beatmap_file = os.path.join(os.path.dirname(__file__), "beatmap.json")

        # 譜面ファイルが存在する場合は、そこからノーツを読み込む
        if os.path.exists(beatmap_file):
            import json
            try:
                with open(beatmap_file, 'r') as f:
                    beatmap_data = json.load(f)

                # 譜面データからノーツを生成
                self.notes = []
                for note_data in beatmap_data['notes']:
                    lane = note_data['lane']  # レーン (0-3)
                    time = note_data['time']  # 秒単位のタイミング
                    self.notes.append(Note(lane, time))

                # 音楽ファイルのパスを設定（譜面に指定があれば）
                if 'music_file' in beatmap_data:
                    music_path = os.path.join(os.path.dirname(__file__),
                                            "sample_music",
                                            beatmap_data['music_file'])
                    if os.path.exists(music_path):
                        self.music_path = music_path

                # 音楽の長さを取得
                try:
                    pygame.mixer.music.load(self.music_path)
                    temp_sound = pygame.mixer.Sound(self.music_path)
                    self.music_length = temp_sound.get_length()
                except pygame.error as e:
                    print(f"音楽ファイルの読み込みに失敗しました: {e}")
                    print("デフォルト値を使用します。")
                    self.music_length = 180.0  # デフォルト3分

                print(f"譜面ファイルから {len(self.notes)} 個のノーツを読み込みました")
                return
            except Exception as e:
                print(f"譜面ファイルの読み込みに失敗しました: {e}")

        # 音楽ファイルからビートを検出してノーツを生成
        if self.generate_notes_from_audio():
            return

        # 上記の方法が失敗した場合は、ランダム生成にフォールバック
        print("ランダムにノーツを生成します")
        self._generate_random_notes()

    def generate_notes_from_audio(self):
        """音楽ファイルを解析してビートを検出し、ノーツを生成する"""
        try:
            import librosa
            import numpy as np

            print(f"音楽ファイル {self.music_path} からビートを検出しています...")

            # 音楽ファイルを読み込む
            y, sr = librosa.load(self.music_path)

            # ビート検出
            tempo, beat_frames = librosa.beat.beat_track(y=y, sr=sr)
            beat_times = librosa.frames_to_time(beat_frames, sr=sr)

            print(f"テンポ: {tempo} BPM, {len(beat_times)} 個のビートを検出しました")

            # ノーツを生成
            self.notes = []

            # 最初の数秒は除外（イントロ部分）
            start_time = 2.0
            beat_times = [t for t in beat_times if t >= start_time]

            # 音楽の長さを取得
            try:
                temp_sound = pygame.mixer.Sound(self.music_path)
                self.music_length = temp_sound.get_length()
            except pygame.error:
                print("音楽の長さを取得できませんでした。デフォルト値を使用します。")
                self.music_length = 180.0  # デフォルト3分

            # ビートごとにノーツを生成
            for i, beat_time in enumerate(beat_times):
                if beat_time >= self.music_length - 1:
                    break

                # 4ビートごとに全レーンにノーツを配置
                if i % 16 == 0:
                    for lane in range(LANE_COUNT):
                        self.notes.append(Note(lane, beat_time))
                # 8ビートごとに対角線パターン
                elif i % 8 == 0:
                    lane = (i // 8) % LANE_COUNT
                    self.notes.append(Note(lane, beat_time))
                # 4ビートごとに交互パターン
                elif i % 4 == 0:
                    lane = (i // 4) % 2 * 2  # 0か2
                    self.notes.append(Note(lane, beat_time))
                    self.notes.append(Note(lane + 1, beat_time))
                # その他のビートはランダムに1つのレーンを選択
                else:
                    # 連続して同じレーンにならないようにする
                    if self.notes and i > 0:
                        last_lane = self.notes[-1].lane
                        available_lanes = [l for l in range(LANE_COUNT) if l != last_lane]
                        lane = random.choice(available_lanes)
                    else:
                        lane = random.randint(0, LANE_COUNT - 1)

                    # 一部のビートはスキップ（難易度調整）
                    if random.random() < 0.7:  # 70%の確率でノーツを配置
                        self.notes.append(Note(lane, beat_time))

            print(f"音楽のビートから {len(self.notes)} 個のノーツを生成しました")
            return True

        except ImportError:
            print("librosaライブラリがインストールされていません。")
            print("pip install librosa でインストールしてください。")
            return False
        except Exception as e:
            print(f"ビート検出中にエラーが発生しました: {e}")
            return False

            print(f"音楽のビートから {len(self.notes)} 個のノーツを生成しました")
            return True

        except ImportError:
            print("librosaライブラリがインストールされていません。")
            print("pip install librosa でインストールしてください。")
            return False
        except Exception as e:
            print(f"ビート検出中にエラーが発生しました: {e}")
            return False

    def _generate_random_notes(self):
        """ランダムにノーツを生成する（フォールバック用）"""
        # 音楽ファイルの長さを取得
        try:
            pygame.mixer.music.load(self.music_path)
            
            # 音楽の長さを取得する代替方法
            # 一時的に Sound オブジェクトを作成して長さを取得
            try:
                temp_sound = pygame.mixer.Sound(self.music_path)
                self.music_length = temp_sound.get_length()
            except pygame.error:
                print("音楽の長さを取得できませんでした。デフォルト値を使用します。")
                self.music_length = 180.0  # デフォルト3分
        except pygame.error:
            print("音楽ファイルの読み込みに失敗しました。デフォルト値を使用します。")
            self.music_length = 180.0  # デフォルト3分

        # BPMを120と仮定して、4分音符の間隔を計算
        bpm = 120
        beat_interval = 60 / bpm

        # 音楽の長さに応じてノーツを生成
        current_time = 2.0  # 最初のノーツは2秒後から
        while current_time < self.music_length - 1:
            # 各レーンにランダムにノーツを配置
            lane = random.randint(0, LANE_COUNT - 1)
            self.notes.append(Note(lane, current_time))

            # 次のノーツまでの間隔（1拍または半拍）
            if random.random() < 0.7:
                current_time += beat_interval
            else:
                current_time += beat_interval / 2

        print(f"ランダムに {len(self.notes)} 個のノーツを生成しました")

    def reset_game(self):
        """ゲームをリセットする"""
        self.notes = []
        self.score = 0
        self.combo = 0
        self.max_combo = 0
        self.judgments = {"PERFECT": 0, "GREAT": 0, "GOOD": 0, "BAD": 0, "MISS": 0}
        self.judgment_display = None
        self.judgment_time = 0
        self.generate_notes()

    def start_game(self):
        """ゲームを開始する"""
        self.game_state = "playing"
        try:
            print(f"音楽ファイルを読み込みます: {self.music_path}")
            print(f"音楽ファイルの存在確認: {os.path.exists(self.music_path)}")
            
            pygame.mixer.music.load(self.music_path)
            pygame.mixer.music.play()
            self.music_start_time = time.time()
            print(f"音楽の再生を開始しました。開始時間: {self.music_start_time}")
        except pygame.error as e:
            print(f"音楽の読み込みに失敗しました: {e}")
            print(f"ファイルパス: {self.music_path}")
            print("ゲームをリザルト画面に移行します")
            self.game_state = "result"

    def judge_note(self, lane, current_time):
        """ノーツの判定を行う"""
        # 音楽開始からの経過時間
        elapsed_time = current_time - self.music_start_time

        closest_note = None
        closest_time_diff = float('inf')

        # 指定されたレーンの中で最も近いノーツを探す
        for note in self.notes:
            if note.lane == lane and not note.hit:
                time_diff = abs(note.time - elapsed_time)
                if time_diff < closest_time_diff:
                    closest_note = note
                    closest_time_diff = time_diff

        # 最も近いノーツがない、または遠すぎる場合
        if closest_note is None or closest_time_diff > BAD_RANGE:
            return

        # 判定
        closest_note.hit = True
        if closest_time_diff <= PERFECT_RANGE:
            closest_note.judgment = "PERFECT"
            self.score += PERFECT_SCORE
            self.judgments["PERFECT"] += 1
            self.combo += 1
            self.sound_perfect.play()
        elif closest_time_diff <= GREAT_RANGE:
            closest_note.judgment = "GREAT"
            self.score += GREAT_SCORE
            self.judgments["GREAT"] += 1
            self.combo += 1
            self.sound_great.play()
        elif closest_time_diff <= GOOD_RANGE:
            closest_note.judgment = "GOOD"
            self.score += GOOD_SCORE
            self.judgments["GOOD"] += 1
            self.combo += 1
            self.sound_good.play()
        elif closest_time_diff <= BAD_RANGE:
            closest_note.judgment = "BAD"
            self.score += BAD_SCORE
            self.judgments["BAD"] += 1
            self.combo = 0
            self.sound_bad.play()

        # 最大コンボ更新
        if self.combo > self.max_combo:
            self.max_combo = self.combo

        # 判定表示
        self.judgment_display = closest_note.judgment
        self.judgment_time = current_time

    def check_missed_notes(self, current_time):
        """見逃したノーツをチェック"""
        elapsed_time = current_time - self.music_start_time

        for note in self.notes:
            if not note.hit and note.time < elapsed_time - BAD_RANGE:
                note.hit = True
                note.judgment = "MISS"
                self.judgments["MISS"] += 1
                self.combo = 0
                self.sound_miss.play()

    def calculate_rank(self):
        """プレイの評価ランクを計算"""
        total_notes = sum(self.judgments.values())
        if total_notes == 0:
            return "E"

        accuracy = (self.judgments["PERFECT"] * PERFECT_SCORE +
                   self.judgments["GREAT"] * GREAT_SCORE +
                   self.judgments["GOOD"] * GOOD_SCORE +
                   self.judgments["BAD"] * BAD_SCORE) / (total_notes * PERFECT_SCORE)

        if accuracy >= 0.95:
            return "S"
        elif accuracy >= 0.90:
            return "A"
        elif accuracy >= 0.80:
            return "B"
        elif accuracy >= 0.70:
            return "C"
        elif accuracy >= 0.60:
            return "D"
        else:
            return "E"

    def draw_title_screen(self):
        """タイトル画面を描画"""
        # 背景描画
        if self.background:
            self.screen.blit(self.background, (0, 0))
        else:
            self.screen.fill(BLACK)

        # タイトル
        title_text = self.font_large.render("リズムゲーム", True, WHITE)
        title_rect = title_text.get_rect(center=(SCREEN_WIDTH//2, SCREEN_HEIGHT//3))
        self.screen.blit(title_text, title_rect)

        # 操作説明
        instruction_text = self.font_medium.render("D, F, J, K キーでプレイ", True, WHITE)
        instruction_rect = instruction_text.get_rect(center=(SCREEN_WIDTH//2, SCREEN_HEIGHT//2))
        self.screen.blit(instruction_text, instruction_rect)

        # スタート案内
        start_text = self.font_medium.render("スペースキーでスタート", True, WHITE)
        start_rect = start_text.get_rect(center=(SCREEN_WIDTH//2, SCREEN_HEIGHT*2//3))
        self.screen.blit(start_text, start_rect)

    def draw_playing_screen(self, current_time):
        """プレイ画面を描画"""
        # 背景描画
        if self.background:
            self.screen.blit(self.background, (0, 0))
        else:
            self.screen.fill(BLACK)

        # レーンを描画
        for i in range(LANE_COUNT):
            x = i * LANE_WIDTH
            # レーン背景
            pygame.draw.rect(self.screen, GRAY, (x, 0, LANE_WIDTH, SCREEN_HEIGHT))
            # レーン境界線
            pygame.draw.line(self.screen, WHITE, (x, 0), (x, SCREEN_HEIGHT), 2)

            # キー表示
            key_text = self.font_medium.render(LANE_KEYS[i], True, WHITE)
            key_rect = key_text.get_rect(center=(x + LANE_WIDTH//2, SCREEN_HEIGHT - 50))
            self.screen.blit(key_text, key_rect)

        # 判定ライン
        pygame.draw.line(self.screen, WHITE, (0, JUDGMENT_LINE_Y), (SCREEN_WIDTH, JUDGMENT_LINE_Y), 4)

        # ノーツを描画
        for note in self.notes:
            if not note.hit:
                note.update(current_time, self.music_start_time)
                note.draw(self.screen)

        # スコア表示
        score_text = self.font_medium.render(f"Score: {self.score}", True, WHITE)
        self.screen.blit(score_text, (10, 10))

        # コンボ表示
        if self.combo > 0:
            combo_text = self.font_medium.render(f"Combo: {self.combo}", True, WHITE)
            combo_rect = combo_text.get_rect(center=(SCREEN_WIDTH//2, 50))
            self.screen.blit(combo_text, combo_rect)

        # 判定表示
        if self.judgment_display and current_time - self.judgment_time < 0.5:
            judgment_color = WHITE
            if self.judgment_display == "PERFECT":
                judgment_color = PERFECT_COLOR
            elif self.judgment_display == "GREAT":
                judgment_color = GREAT_COLOR
            elif self.judgment_display == "GOOD":
                judgment_color = GOOD_COLOR
            elif self.judgment_display == "BAD":
                judgment_color = BAD_COLOR
            elif self.judgment_display == "MISS":
                judgment_color = MISS_COLOR

            judgment_text = self.font_medium.render(self.judgment_display, True, judgment_color)
            judgment_rect = judgment_text.get_rect(center=(SCREEN_WIDTH//2, 100))
            self.screen.blit(judgment_text, judgment_rect)

    def draw_result_screen(self):
        """リザルト画面を描画"""
        # 背景描画
        if self.background:
            self.screen.blit(self.background, (0, 0))
        else:
            self.screen.fill(BLACK)

        # 半透明のオーバーレイを描画して背景を暗くする
        overlay = pygame.Surface((SCREEN_WIDTH, SCREEN_HEIGHT), pygame.SRCALPHA)
        overlay.fill((0, 0, 0, 180))  # 黒色の半透明オーバーレイ
        self.screen.blit(overlay, (0, 0))

        # タイトル
        title_text = self.font_large.render("リザルト", True, WHITE)
        title_rect = title_text.get_rect(center=(SCREEN_WIDTH//2, 50))
        self.screen.blit(title_text, title_rect)

        # スコア
        score_text = self.font_medium.render(f"スコア: {self.score}", True, WHITE)
        score_rect = score_text.get_rect(center=(SCREEN_WIDTH//2, 110))
        self.screen.blit(score_text, score_rect)

        # 最大コンボ
        combo_text = self.font_medium.render(f"最大コンボ: {self.max_combo}", True, WHITE)
        combo_rect = combo_text.get_rect(center=(SCREEN_WIDTH//2, 150))
        self.screen.blit(combo_text, combo_rect)

        # 判定内訳
        y_pos = 200
        judgment_colors = {
            "PERFECT": PERFECT_COLOR,
            "GREAT": GREAT_COLOR,
            "GOOD": GOOD_COLOR,
            "BAD": BAD_COLOR,
            "MISS": MISS_COLOR
        }

        for judgment, count in self.judgments.items():
            judgment_text = self.font_small.render(f"{judgment}: {count}", True, judgment_colors.get(judgment, WHITE))
            judgment_rect = judgment_text.get_rect(center=(SCREEN_WIDTH//2, y_pos))
            self.screen.blit(judgment_text, judgment_rect)
            y_pos += 30

        # 精度
        total_notes = sum(self.judgments.values())
        if total_notes > 0:
            accuracy = (self.judgments["PERFECT"] * PERFECT_SCORE +
                       self.judgments["GREAT"] * GREAT_SCORE +
                       self.judgments["GOOD"] * GOOD_SCORE +
                       self.judgments["BAD"] * BAD_SCORE) / (total_notes * PERFECT_SCORE) * 100
            accuracy_text = self.font_medium.render(f"精度: {accuracy:.2f}%", True, WHITE)
            accuracy_rect = accuracy_text.get_rect(center=(SCREEN_WIDTH//2, y_pos + 10))
            self.screen.blit(accuracy_text, accuracy_rect)
            y_pos += 50

        # ランク
        rank = self.calculate_rank()
        rank_text = self.font_large.render(f"ランク: {rank}", True, WHITE)
        rank_rect = rank_text.get_rect(center=(SCREEN_WIDTH//2, y_pos))
        self.screen.blit(rank_text, rank_rect)

        # 再プレイ案内
        replay_text = self.font_medium.render("Rキーで再プレイ", True, WHITE)
        replay_rect = replay_text.get_rect(center=(SCREEN_WIDTH//2, SCREEN_HEIGHT - 100))
        self.screen.blit(replay_text, replay_rect)

        # 終了案内
        quit_text = self.font_medium.render("Escキーで終了", True, WHITE)
        quit_rect = quit_text.get_rect(center=(SCREEN_WIDTH//2, SCREEN_HEIGHT - 50))
        self.screen.blit(quit_text, quit_rect)

    def run(self):
        """ゲームのメインループ"""
        while self.running:
            current_time = time.time()

            # イベント処理
            for event in pygame.event.get():
                if event.type == QUIT:
                    self.running = False

                elif event.type == KEYDOWN:
                    # タイトル画面
                    if self.game_state == "title":
                        if event.key == K_SPACE:
                            self.start_game()
                        elif event.key == K_ESCAPE:
                            self.running = False

                    # プレイ中
                    elif self.game_state == "playing":
                        if event.key in KEY_CONFIG:
                            lane = KEY_CONFIG[event.key]
                            self.judge_note(lane, current_time)
                        elif event.key == K_ESCAPE:
                            pygame.mixer.music.stop()
                            self.game_state = "result"

                    # リザルト画面
                    elif self.game_state == "result":
                        if event.key == K_r:
                            self.reset_game()
                            self.game_state = "title"
                        elif event.key == K_ESCAPE:
                            self.running = False

            # 画面描画
            if self.game_state == "title":
                self.draw_title_screen()

            elif self.game_state == "playing":
                # 見逃したノーツをチェック
                self.check_missed_notes(current_time)

                # 画面描画
                self.draw_playing_screen(current_time)

                # 音楽が終了したらリザルト画面へ
                if not pygame.mixer.music.get_busy():
                    self.game_state = "result"

            elif self.game_state == "result":
                self.draw_result_screen()

            pygame.display.flip()
            self.clock.tick(FPS)

        pygame.quit()
        sys.exit()

# メイン処理
if __name__ == "__main__":
    # 効果音ディレクトリの作成
    sounds_dir = os.path.join(os.path.dirname(__file__), "sounds")
    os.makedirs(sounds_dir, exist_ok=True)

    # 効果音ファイルの生成
    def generate_sound(filename, freq, duration):
        try:
            import math
            import numpy as np
            import wave
            import struct

            sample_rate = 44100
            t = np.linspace(0, duration, int(sample_rate * duration), False)
            wave_data = np.sin(2 * np.pi * freq * t) * 32767
            wave_data = np.int16(wave_data)

            # WAVファイルとして保存
            with wave.open(os.path.join(sounds_dir, filename), 'w') as wf:
                wf.setnchannels(1)  # モノラル
                wf.setsampwidth(2)  # 16ビット
                wf.setframerate(sample_rate)
                wf.writeframes(wave_data.tobytes())
            return True
        except Exception as e:
            print(f"効果音の生成に失敗しました: {e}")
            return False

    # 効果音が存在しない場合は生成
    if not os.path.exists(os.path.join(sounds_dir, "perfect.wav")):
        generate_sound("perfect.wav", 880, 0.1)
    if not os.path.exists(os.path.join(sounds_dir, "great.wav")):
        generate_sound("great.wav", 660, 0.1)
    if not os.path.exists(os.path.join(sounds_dir, "good.wav")):
        generate_sound("good.wav", 440, 0.1)
    if not os.path.exists(os.path.join(sounds_dir, "bad.wav")):
        generate_sound("bad.wav", 220, 0.1)
    if not os.path.exists(os.path.join(sounds_dir, "miss.wav")):
        generate_sound("miss.wav", 110, 0.1)

    # 背景画像のコピー
    background_src = os.path.join("images", "game_background.gif")
    background_dst = os.path.join(os.path.dirname(__file__), "background.gif")

    # Windowsの場合、背景画像をコピー
    if os.name == 'nt' and os.path.exists(background_src):
        try:
            import shutil
            shutil.copy(background_src, background_dst)
            print(f"背景画像をコピーしました: {background_src} -> {background_dst}")
        except Exception as e:
            print(f"背景画像のコピーに失敗しました: {e}")

    # sample_musicディレクトリの確認
    sample_music_dir = os.path.join(os.path.dirname(__file__), "sample_music")
    if not os.path.exists(sample_music_dir):
        os.makedirs(sample_music_dir, exist_ok=True)
        print(f"sample_musicディレクトリを作成しました: {sample_music_dir}")
    
    # 音楽ファイルの確認
    default_music_path = os.path.join(sample_music_dir, "jpop_rhythm_game.mp3")
    if not os.path.exists(default_music_path):
        print(f"デフォルトの音楽ファイルが見つかりません: {default_music_path}")
        # MP3ファイルを探す
        mp3_files = [f for f in os.listdir(sample_music_dir) if f.endswith('.mp3')] if os.path.exists(sample_music_dir) else []
        if not mp3_files:
            print("sample_musicディレクトリにMP3ファイルが見つかりません。")
            print("MP3ファイルを追加してください。")

    # ゲーム開始
    try:
        game = RhythmGame()
        game.run()
    except Exception as e:
        print(f"ゲーム実行中にエラーが発生しました: {e}")
        import traceback
        traceback.print_exc()