import { useState } from "react"
import { Input } from "./Input";

export function Editor({level}: {level: {a: number, s: number, t: number}[]}) {
  const [addOpen, setAddOpen] = useState(false);
  const [selected, setSelected] = useState<number>();

  return (
    <div className="p-4 mx-4 flex flex-row w-full bg-zinc-900 h-[80vh]">
      <div className="w-[30%] bg-zinc-800">
        <div className="flex flex-row p-2 justify-between items-center">
          <span className="text-lg font-semibold">{level.length} beats</span>
          <button
            className="bg-white p-2 m-1 rounded-md text-black w-8 h-8 flex flex-row justify-center items-center"
            onClick={() => setAddOpen(true)}
          >
            +
          </button>
        </div>
        {level.map((beat, i) => (
          <div
            key={beat.t}
            className={`mx-2 hover:bg-zinc-700 p-2 rounded-md ${selected === i ? "bg-zinc-700" : ""}`}
            onClick={() => setSelected(i)}
          >
            Beat {beat.t}: speed {beat.s} | {beat.a}°
          </div>
        ))}
      </div>
      <div className="relative flex justify-center items-center w-full text-5xl">
        *
        {level.map((beat, i) => {
          if (selected !== undefined && selected !== i) return null;
          return (
            <div
              key={i}
              className="absolute w-4 h-4 bg-white rounded-full"
              style={{
                top: '50%',
                left: '50%',
                transform: `translate(-50%, -50%) rotate(${beat.a - 90}deg) translate(15rem)`,
              }}
            />
          )
        })}
      </div>
      {addOpen &&
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-zinc-900 rounded-lg shadow-xl p-6 w-full max-w-md relative">
            <button
              onClick={() => setAddOpen(false)}
              className="absolute top-4 right-4 text-gray-400 hover:text-white"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
            
            <h2 className="text-xl mb-4 text-white">Add</h2>
            <form onSubmit={(e) => {
              e.preventDefault();
              const formData = new FormData(e.currentTarget);
              const beat = formData.get('beat');
              const rotation = formData.get('rotation');

              if (!beat || !rotation) return;

              const add = {
                t: Number(beat),
                a: Number(rotation),
                s: 1000
              };
              level.push(add);
              setAddOpen(false);
            }}>
              <Input type="number" placeholder="Beat" name="beat"/>
              <Input type="number" placeholder="Rotation" name="rotation"/>
              <br/>
              <input type="submit" value="Done" className="bg-white text-black m-1 p-2 rounded-md"/>
            </form>
          </div>
        </div>
      }
    </div>
  )
}