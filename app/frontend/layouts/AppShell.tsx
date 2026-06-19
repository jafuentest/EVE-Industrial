import styles from './AppShell.module.css'

import type { ReactNode } from 'react'
import type { Session } from '@/types'

import Sidebar from './Sidebar'
import TopBar from './TopBar'

interface AppShellProps {
  children: ReactNode
  session: Session | null
}

function AppShell({ children, session }: AppShellProps) {
  return (
    <>
      <Sidebar session={session} />
      <div className={styles.container}>
        <header>
          <TopBar session={session} />
        </header>
        <main>{children}</main>
        <footer className={styles.footer}>
          &copy; {new Date().getFullYear()} EVE Industrial
        </footer>
      </div>
    </>
  )
}

export default AppShell
