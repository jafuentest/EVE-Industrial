import { useRequiredSession } from '@/contexts/AuthContext'

function Dashboard() {
  const session = useRequiredSession()

  return (
    <div>EVE Industrial — logged in as {session.user.characterName}</div>
  )
}

export default Dashboard
