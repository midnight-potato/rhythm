export function Input({type, placeholder, name}: {type: string, placeholder: string, name?: string}) {
  return (
    <input type={type} name={name} placeholder={placeholder} className="bg-zinc-800 p-2 m-1 rounded-md"/>
  )
}