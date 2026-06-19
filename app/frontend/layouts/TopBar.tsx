import styles from './TopBar.module.css'

import type { Session } from '../types'

interface TopBarProps {
  session: Session | null
}

function TopBar({ session }: TopBarProps) {
  return (
    <div className={styles.container}>
      {session && <p>Logged in as {session.user.character_name}</p>}
      <p className={styles.notifications}>Notifications Icon</p>
      <p className={styles.sync}>Sync ESI Button</p>
    </div>
  )
}

export default TopBar
