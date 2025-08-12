import { useState } from 'react'
import Board from '../components/Board'

export default function Home() {
  const [matchId, setMatchId] = useState('local-1')
  return (
    <div style={{padding:20}}>
      <h1>Chess — demo</h1>
      <Board matchId={matchId} />
    </div>
  )
}
