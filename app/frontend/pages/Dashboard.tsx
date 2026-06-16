import type { Session } from '../types'

interface DashboardProps {
  session: Session
}

function Dashboard({ session }: DashboardProps) {
  return (
    <div>EVE Industrial — logged in as {session.user.character_name}</div>
  )
}

export default Dashboard
