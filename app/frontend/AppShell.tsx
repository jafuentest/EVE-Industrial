import type { ReactNode } from 'react'
import type { Session } from './types'

interface AppShellProps {
  children: ReactNode
  session: Session | null
}

function AppShell({ children, session }: AppShellProps) {
  return (
    <div>
      <header>
        <h1>EVE Industrial</h1>
        {session && <p>Logged in as {session.user.character_name}</p>}
      </header>
      <main>{children}</main>
      <footer>
        &copy; {new Date().getFullYear()} EVE Industrial
      </footer>
    </div>
  )
}

export default AppShell
