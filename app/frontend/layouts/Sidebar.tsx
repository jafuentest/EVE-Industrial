import styles from './Sidebar.module.css'

import type { Session } from '../types'

import Brand from '../components/Brand'

interface SidebarProps {
  session: Session | null
}

function Sidebar({ session }: SidebarProps) {
  return (
    <aside className={styles.sidebar}>
      <Brand />
      <nav>
        <ul>
          <li>Link to Dashboard</li>
          <li>Link to Industry Jobs</li>
          <li>Link to Market Orders</li>
          <li>Link to Planetary Colonies</li>
          <li>Link to Planetary Commodities</li>
        </ul>
      </nav>
      {session && (
        <div className={styles.userInfo}>
          <p>Logged in as {session.user.character_name}</p>
          <button>Logout</button>
        </div>
      )}
    </aside>
  )
}

export default Sidebar
