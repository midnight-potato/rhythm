import json
import os
import zipfile

def export(mp3_path, metadata, level, out_path) -> tuple:
  # mp3_path is an absolute path to an mp3 music file
  # metadata is a dict with "title" "author" "designer" "bpm"
  # level is list of tuples with beat "t"/angle "a" as a percent of pi/speed "s" of entry
  if not os.path.exists(mp3_path) or not mp3_path.endswith(".mp3"):
    return (False, "MP3 does not exist at given path")
  
  with open("level.json", "w") as f:
    obj = {
      "bpm": metadata["bpm"],
      "title": metadata["title"],
      "author": metadata["author"],
      "designer": metadata["designer"],
      "notes": level,
      "music": os.path.split(mp3_path)[-1]
    }
    json.dump(obj, f)
  
  filenames = ["level.json", mp3_path]
  
  with zipfile.ZipFile(out_path, mode="w") as f:
    for filename in filenames:
      f.write(filename, os.path.split(filename)[-1])
  
  os.unlink("level.json")