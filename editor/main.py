from tkinter import *
from tkinter import ttk, filedialog
from os import path
from writer import export

def select():
  file = filedialog.askopenfile(
    title="Select a music MP3",
    filetypes=(('MP3 files', '*.mp3'), ('All files', '*.*'))
  )

  if not file:
    return
  
  mp3.set(file.name)

def editor():
  pass

def out():
  dir = filedialog.askdirectory(
    title="Select a directory to output the zipfile"
  )

  if not dir:
    return
  
  out_path = path.join(dir, f"{title.get()}.zip")
  
  export(
    mp3.get(),
    {
      "title": title.get(),
      "author": author.get(),
      "designer": designer.get(),
      "bpm": bpm.get()
    },
    level,
    out_path
  )

win = Tk()

frm = ttk.Frame(win, padding=10)
frm.grid()

mp3 = StringVar(value="Select an MP3 music file")
level = []

ttk.Label(frm, text="Level Editor").grid(column=0, row=0, sticky="W")

ttk.Label(frm, textvariable=mp3).grid(row=1, column=0)
ttk.Button(frm, text="Select", command=select).grid(row=1, column=1)

ttk.Label(frm, text="BPM").grid(row=2, column=0, sticky="W")
bpm = ttk.Entry(frm)
bpm.grid(row=2, column=1, sticky="W")

ttk.Label(frm, text="Title").grid(row=3, column=0, sticky="W")
title = ttk.Entry(frm)
title.grid(row=3, column=1, sticky="W")

ttk.Label(frm, text="Author").grid(row=4, column=0, sticky="W")
author = ttk.Entry(frm)
author.grid(row=4, column=1, sticky="W")

ttk.Label(frm, text="Designer").grid(row=5, column=0, sticky="W")
designer = ttk.Entry(frm)
designer.grid(row=5, column=1, sticky="W")

ttk.Button(frm, text="Level Editor", command=editor).grid(row=6, column=0, sticky="W")

ttk.Button(frm, text="Export", command=out).grid(row=7, column=0, sticky="W")

win.mainloop()