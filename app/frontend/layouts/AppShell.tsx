import type { ReactNode } from 'react'

import { useSession } from '@/contexts/AuthContext'
import { useCounters } from '@/hooks/useCounters'

import Sidebar from './Sidebar'
import TopBar from './TopBar'

import styles from './AppShell.module.css'

interface AppShellProps {
  children: ReactNode
}

function AppShell({ children }: AppShellProps) {
  const session = useSession()
  const { counters, syncCounters } = useCounters(!!session)

  return (
    <>
      <Sidebar counters={counters} />
      <div className={styles.container}>
        {session && (<TopBar walletBalance={counters.walletBalance} onSyncEsi={syncCounters} />)}
        <main className={styles.main}>{children}</main>
        <footer className={styles.footer}>
          &copy; {new Date().getFullYear()} EVE Industrial
        </footer>
      </div>
    </>
  )
}

export default AppShell
