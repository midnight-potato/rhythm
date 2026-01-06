"use client";
import { FormEvent, useState } from "react";
import JSZip from "jszip";
import { Input } from "@/components/Input";

export default function Home() {
  const [file, setFile] = useState<File|null>(null);
  
  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();

    if (!file) return;

    const formData = new FormData(e.target as HTMLFormElement);
    const metadata = {
      "title": formData.get("title"),
      "author": formData.get("author"),
      "designer": formData.get("designer"),
      "bpm": formData.get("bpm"),
    }

    const zip = new JSZip();
    zip.file(file.name, file);
    zip.file("level.json", JSON.stringify(metadata));
    
    const blob = await zip.generateAsync({ type: "blob" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    
    a.href = url;
    a.download = `${formData.get("title")}-level.zip`;
    document.body.appendChild(a);
    a.click();
    
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  }

  return (
    <div className="bg-zinc-1000">
      <h1 className="font-bold text-3xl m-4">Level Creator</h1>
      <div className="flex flex-row m-4">
        <form className="flex flex-col w-[20%]" onSubmit={handleSubmit}>
          <input
            type="file"
            accept="audio/*"
            className="bg-zinc-800 p-2 m-1 rounded-md w-min"
            onChange={(e) => {
              if (e.target.files && e.target.files[0]) {
                setFile(e.target.files[0]);
              }
            }}
          />

          <Input type="text" name="title" placeholder="Title"/>
          <Input type="text" name="author" placeholder="Author"/>
          <Input type="text" name="designer" placeholder="Designer"/>
          <Input type="number" name="bpm" placeholder="BPM"/>

          <input type="submit" value="Export" className="bg-blue-600 p-2 m-1 rounded-md w-min"/>
        </form>
        <div className="w-[80%]">
          
        </div>
      </div>
    </div>
  );
}
