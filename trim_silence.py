import argparse
import os
from typing import List

from pydub import AudioSegment

def get_input_fnames(input_dir: str) -> List[str]:
  if not os.path.isdir(input_dir):
    raise ValueError(f"Directory {input_dir} is invalid.")

  out_fnames = []
  for fname in os.listdir(input_dir):
    if not fname.endswith(".wav"):
      continue

    out_fnames.append(os.path.join(input_dir, fname))
  return out_fnames

def process_file(full_path: str,
                 out_dir: str,
                 skip_normalise: bool = False) -> None:
  if not os.path.isdir(out_dir):
    raise ValueError(f"Directory {out_dir} is invalid.")

  print(f"Reading: {full_path}")

  wav = AudioSegment.from_wav(full_path)
  wav = wav.strip_silence()

  if not skip_normalise:
    normalized = wav.normalize()

  fname = os.path.basename(full_path)
  tokens = os.path.splitext(fname)[0].split(" - ")
  artist = tokens[-1]
  title = tokens[0]

  tags = {
    "artist": artist,
    "title": title
  }

  flac_path = os.path.join(out_dir, f"{title} - {artist}.flac")
  print(f"Writing: {flac_path}")
  normalized.export(flac_path, format="flac", tags=tags)

def process(input_dir: str,
            output_dir: str,
            skip_normalise: bool = False) -> None:
  for fname in get_input_fnames(input_dir):
    process_file(fname, output_dir, skip_normalise=skip_normalise)

if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  parser.add_argument("input_dir", type=str)
  parser.add_argument("--output_dir", type=str, default=None)
  parser.add_argument("--skip_peak_normalise", action="store_true")

  args = parser.parse_args()

  input_dir = args.input_dir

  output_dir = args.output_dir
  if not output_dir:
    output_dir = input_dir
  
  skip_normalize = args.skip_peak_normalise

  process(input_dir, output_dir, skip_normalise=skip_normalize)
  