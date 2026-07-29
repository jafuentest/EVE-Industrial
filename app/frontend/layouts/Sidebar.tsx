import { Boxes, Factory, Globe, LayoutDashboard, TrendingUp } from 'lucide-react'
import type { ComponentType } from 'react'

import Brand from '@/components/Brand'
import NavItem from '@/components/NavItem'
import { useSession } from '@/contexts/AuthContext'
import type { Counters } from '@/types'

import UserDetails from './UserDetails'

import styles from './Sidebar.module.css'

interface SidebarProps {
  counters: Counters
}

type CounterKey = 'industryJobs' | 'marketOrders' | 'planetaryColonies'

const NAV_ITEMS: { path: string; label: string; icon: ComponentType; counterName?: CounterKey }[] = [
  { path: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { path: '/industry', label: 'Industry Jobs', icon: Factory, counterName: 'industryJobs' },
  { path: '/market', label: 'Market Orders', icon: TrendingUp, counterName: 'marketOrders' },
  { path: '/colonies', label: 'Planetary Colonies', icon: Globe, counterName: 'planetaryColonies' },
  { path: '/commodities', label: 'Planetary Commodities', icon: Boxes },
]

function Sidebar({ counters }: SidebarProps) {
  const session = useSession()

  return (
    <aside className={styles.sidebar}>
      <div className={styles.brandContainer}>
        <Brand />
      </div>
      <nav className={styles.nav}>
        <ul className={styles.navList}>
          {NAV_ITEMS.map(item => (
            <NavItem
              key={item.path}
              path={item.path}
              label={item.label}
              icon={item.icon}
              counter={item.counterName ? counters[item.counterName] : 0}
            />
          ))}
        </ul>
      </nav>
      {session && <UserDetails />}
    </aside>
  )
}

export default Sidebar
