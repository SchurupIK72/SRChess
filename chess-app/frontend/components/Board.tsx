import { useEffect, useState } from 'react'

export default function Board({ matchId } : { matchId: string }) {
  const [socket, setSocket] = useState<WebSocket | null>(null)
  const [state, setState] = useState<any>(null)

  useEffect(() => {
    const ws = new WebSocket(`ws://${location.hostname}:8000/match/${matchId}`)
    ws.onmessage = (e) => {
      const msg = JSON.parse(e.data)
      if (msg.type === 'update') setState(msg.state)
    }
    setSocket(ws)
    return () => ws.close()
  }, [matchId])

  function sendMove(from: string, to: string) {
    socket?.send(JSON.stringify({ type: 'move', from, to }))
  }

  return (
    <div>
      <div style={{display:'grid', gridTemplateColumns:'repeat(8,40px)'}}>
        {state?.board?.flatMap((row: any[]) => row.map((cell: string) => (
          <div key={Math.random()} style={{width:40,height:40,border:'1px solid #999',display:'flex',alignItems:'center',justifyContent:'center'}}>
            {cell === '.' ? '' : cell}
          </div>
        ))) }
      </div>
      <div style={{marginTop:10}}>
        <button onClick={() => sendMove('e2','e4')}>send e2e4</button>
      </div>
    </div>
  )
}
