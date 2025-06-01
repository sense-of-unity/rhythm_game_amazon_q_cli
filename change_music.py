#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
リズムゲームの音楽ファイルを変更するスクリプト
"""

import os
import sys
import shutil
import pygame

def list_music_files():
    """sample_musicディレクトリ内の音楽ファイルを一覧表示"""
    music_dir = os.path.join(os.path.dirname(__file__), "sample_music")
    
    # sample_musicディレクトリが存在しない場合は作成
    if not os.path.exists(music_dir):
        os.makedirs(music_dir)
        print(f"sample_musicディレクトリを作成しました: {music_dir}")
        print("音楽ファイルをこのディレクトリに追加してください。")
        return []
    
    music_files = [f for f in os.listdir(music_dir) if f.endswith(('.mp3', '.ogg', '.wav'))]
    
    print("利用可能な音楽ファイル:")
    for i, file in enumerate(music_files, 1):
        print(f"{i}. {file}")
    
    return music_files

def modify_game_file(music_file):
    """ゲームファイルの音楽ファイルパスを変更"""
    game_file_path = os.path.join(os.path.dirname(__file__), "rhythm_game.py")
    
    with open(game_file_path, 'r') as file:
        content = file.read()
    
    # 音楽ファイルのパスを変更
    import re
    new_content = re.sub(
        r'music_filename = "[^"]+"',
        f'music_filename = "{music_file}"',
        content
    )
    
    with open(game_file_path, 'w') as file:
        file.write(new_content)
    
    print(f"音楽ファイルを '{music_file}' に変更しました。")

def main():
    """メイン関数"""
    print("リズムゲーム - 音楽ファイル変更ツール")
    print("=" * 40)
    
    music_files = list_music_files()
    
    if not music_files:
        print("音楽ファイルが見つかりません。")
        return
    
    try:
        choice = int(input("\n使用する音楽ファイルの番号を入力してください: "))
        if 1 <= choice <= len(music_files):
            selected_music = music_files[choice - 1]
            modify_game_file(selected_music)
            print("\nゲームを起動するには './run_game.sh' を実行してください。")
        else:
            print("無効な選択です。")
    except ValueError:
        print("数値を入力してください。")

if __name__ == "__main__":
    main()
